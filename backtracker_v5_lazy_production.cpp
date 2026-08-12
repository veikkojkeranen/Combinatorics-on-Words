#include <algorithm>
#include <cassert>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

// -----------------------------------------------------------------------------
// AA2Fr Veikko v5 + validated lazy_full integration
//
// Modes:
//   legacy    : original v5 decision: D40 + abelian-square scan only for K>=21
//   shadow    : preserve legacy search, but compare legacy vs canonical exact vs
//               lazy exact on every D40-passing candidate; HARD FAIL on mismatch
//   canonical : D40 + exact AA2Fr canonical checker (FORBID4 + all K>=2)
//   lazy      : D40 + exact AA2Fr lazy candidate checker (FORBID4 + all K>=2)
//
// The search strategy (DFS order, 50M stall threshold, 3% truncation, progressive
// logging) is intentionally kept separate from exact AA2Fr validity semantics.
// -----------------------------------------------------------------------------

using Clock = std::chrono::steady_clock;

// --- GLOBAL SEARCH STATE (preserved from v5) ---
std::vector<std::uint64_t> validFactors;
int maxDepthReached = 0;
std::size_t localPeak = 0;

std::uint64_t stepCount = 0;
std::uint64_t lastMaxDepthStep = 0;
const std::uint64_t STALL_THRESHOLD = 50000000ULL;
int targetTruncationLength = 0;
std::vector<char> currentSearchOrder = {'a', 'b', 'c'};

// --- TELEMETRY ---
struct Telemetry {
    std::uint64_t candidateCount = 0;
    std::uint64_t dictionaryRejects = 0;
    std::uint64_t dictionaryPasses = 0;
    std::uint64_t legacyRejects = 0;
    std::uint64_t canonicalRejects = 0;
    std::uint64_t lazyRejects = 0;
    std::uint64_t acceptedBranches = 0;
    std::uint64_t parityMismatches = 0;
    std::uint64_t legacyExactMismatches = 0;
    std::uint64_t stallCount = 0;
    std::uint64_t truncationCount = 0;
    std::uint64_t pathHash = 1469598103934665603ULL;
};
Telemetry telemetry;

static inline void mixPath(std::uint64_t& h, std::size_t depth, char c, bool dictOk, bool valid) {
    // Deterministic FNV-1a-style trace hash. Same search path => same hash.
    h ^= static_cast<std::uint64_t>((depth & 0xffffULL) + 1ULL);
    h *= 1099511628211ULL;
    h ^= static_cast<std::uint64_t>(static_cast<unsigned char>(c));
    h *= 1099511628211ULL;
    h ^= static_cast<std::uint64_t>((dictOk ? 1 : 0) | (valid ? 2 : 0));
    h *= 1099511628211ULL;
}

static inline std::uint8_t symOf(char c) {
    if (c == 'a') return 0;
    if (c == 'b') return 1;
    if (c == 'c') return 2;
    throw std::runtime_error("word contains symbol outside {a,b,c}");
}

// -----------------------------------------------------------------------------
// Dictionary encoding (same base-3 convention as v5)
// -----------------------------------------------------------------------------
std::uint64_t encodeSuffix(const std::string& word) {
    if (word.size() < 40) throw std::runtime_error("encodeSuffix requires length >= 40");
    std::uint64_t encodedValue = 0;
    for (std::size_t i = word.length() - 40; i < word.length(); ++i) {
        encodedValue = encodedValue * 3ULL + static_cast<std::uint64_t>(word[i] - 'a');
    }
    return encodedValue;
}

// Prospective suffix encoder: preserves the v5 O(40) dictionary work while
// allowing lazy exact validity to be tested before a physical string push.
std::uint64_t encodeCandidateSuffix(const std::string& word, char candidate) {
    if (word.size() < 39) throw std::runtime_error("encodeCandidateSuffix requires parent length >= 39");
    std::uint64_t encodedValue = 0;
    const std::size_t start = word.size() - 39;
    for (std::size_t i = start; i < word.size(); ++i) {
        encodedValue = encodedValue * 3ULL + static_cast<std::uint64_t>(word[i] - 'a');
    }
    encodedValue = encodedValue * 3ULL + static_cast<std::uint64_t>(candidate - 'a');
    return encodedValue;
}

// -----------------------------------------------------------------------------
// Original v5 macro-filter, intentionally retained for legacy/shadow comparison.
// -----------------------------------------------------------------------------
bool hasLargeAbelianSquare(const std::string& word) {
    const int len = static_cast<int>(word.length());
    for (int blockSize = 21; blockSize <= len / 2; ++blockSize) {
        int countA = 0;
        int countB = 0;
        for (int i = 0; i < blockSize; ++i) {
            const char rightChar = word[len - 1 - i];
            if (rightChar == 'a') ++countA;
            else if (rightChar == 'b') ++countB;

            const char leftChar = word[len - 1 - blockSize - i];
            if (leftChar == 'a') --countA;
            else if (leftChar == 'b') --countB;
        }
        if (countA == 0 && countB == 0) return true;
    }
    return false;
}

// -----------------------------------------------------------------------------
// Incremental exact AA2Fr state.
// Packed prefix value: low 32 bits = count(b), high 32 bits = count(c).
// count(a) is implied by interval length. Equal packed range sums therefore mean
// equal ternary Parikh vectors for equal-length blocks.
// -----------------------------------------------------------------------------
class ExactState {
public:
    explicit ExactState(std::size_t capacity = 4096) {
        word.resize(capacity);
        pref.resize(capacity + 1);
        pref[0] = 0;
    }

    void load(const std::string& s) {
        ensure(s.size() + 256);
        n = 0;
        pref[0] = 0;
        for (char c : s) pushRaw(symOf(c));
    }

    std::size_t size() const { return n; }

    void pushRaw(std::uint8_t s) {
        ensure(n + 2);
        word[n] = s;
        const std::uint64_t inc = (s == 1) ? 1ULL : ((s == 2) ? (1ULL << 32) : 0ULL);
        pref[n + 1] = pref[n] + inc;
        ++n;
    }

    void popRaw() {
        assert(n > 0);
        --n;
    }

    // Independent-style canonical implementation: physically push candidate,
    // test FORBID4 and every suffix abelian-square half-length K>=2, then leave
    // state pushed iff accepted.
    bool tryCanonical(std::uint8_t s) {
        pushRaw(s);
        if (forbidCurrent()) {
            popRaw();
            return false;
        }
        for (std::size_t h = 2; h <= n / 2; ++h) {
            const std::size_t start = n - 2 * h;
            if (range(start, start + h) == range(start + h, n)) {
                popRaw();
                return false;
            }
        }
        return true;
    }

    // Validated lazy_full implementation: candidate-specific, exact, no all-three
    // precomputation. It evaluates the appended-symbol condition directly from the
    // parent prefix sums and physically pushes only when accepted.
    bool tryLazy(std::uint8_t s) {
        const std::uint8_t bit = static_cast<std::uint8_t>(1u << s);
        if (forbidNextMask() & bit) return false;

        const std::size_t N = n;
        const std::size_t R = N + 1;
        const std::size_t H = R / 2;
        const std::uint64_t* P = pref.data();
        const std::int64_t PN = static_cast<std::int64_t>(P[N]);
        const std::int64_t target = (s == 0) ? 0LL : ((s == 1) ? 1LL : (1LL << 32));

        for (std::size_t h = 2; h <= H; ++h) {
            const std::int64_t diff =
                2LL * static_cast<std::int64_t>(P[R - h])
                - static_cast<std::int64_t>(P[R - 2 * h])
                - PN;
            if (diff == target) return false;
        }

        pushRaw(s);
        return true;
    }

private:
    std::size_t n = 0;
    std::vector<std::uint8_t> word;
    std::vector<std::uint64_t> pref;

    void ensure(std::size_t capacity) {
        if (word.size() >= capacity) return;
        const std::size_t newCap = std::max(capacity, word.size() * 2 + 128);
        word.resize(newCap);
        pref.resize(newCap + 1);
    }

    std::uint64_t range(std::size_t l, std::size_t r) const {
        return pref[r] - pref[l];
    }

    bool forbidCurrent() const {
        if (n < 4) return false;
        const auto a = word[n - 4];
        const auto b = word[n - 3];
        const auto c = word[n - 2];
        const auto d = word[n - 1];
        return
            (a == 1 && b == 0 && c == 0 && d == 2) || // baac
            (a == 2 && b == 0 && c == 0 && d == 1) || // caab
            (a == 0 && b == 1 && c == 1 && d == 2) || // abbc
            (a == 2 && b == 1 && c == 1 && d == 0) || // cbba
            (a == 0 && b == 2 && c == 2 && d == 1) || // accb
            (a == 1 && b == 2 && c == 2 && d == 0);   // bcca
    }

    std::uint8_t forbidNextMask() const {
        if (n < 3) return 0;
        const auto a = word[n - 3];
        const auto b = word[n - 2];
        const auto c = word[n - 1];
        std::uint8_t mask = 0;
        if (a == 1 && b == 0 && c == 0) mask |= 4; // baa + c
        if (a == 2 && b == 0 && c == 0) mask |= 2; // caa + b
        if (a == 0 && b == 1 && c == 1) mask |= 4; // abb + c
        if (a == 2 && b == 1 && c == 1) mask |= 1; // cbb + a
        if (a == 0 && b == 2 && c == 2) mask |= 2; // acc + b
        if (a == 1 && b == 2 && c == 2) mask |= 1; // bcc + a
        return mask;
    }
};

enum class CheckerMode { Legacy, Shadow, Canonical, Lazy };

static CheckerMode parseCheckerMode(const std::string& s) {
    if (s == "legacy") return CheckerMode::Legacy;
    if (s == "shadow") return CheckerMode::Shadow;
    if (s == "canonical") return CheckerMode::Canonical;
    if (s == "lazy") return CheckerMode::Lazy;
    throw std::runtime_error("--checker must be legacy|shadow|canonical|lazy");
}

static const char* checkerModeName(CheckerMode m) {
    switch (m) {
        case CheckerMode::Legacy: return "legacy";
        case CheckerMode::Shadow: return "shadow";
        case CheckerMode::Canonical: return "canonical";
        case CheckerMode::Lazy: return "lazy";
    }
    return "unknown";
}

struct Config {
    std::string seedFile;
    int targetLength = 2500;
    std::string dictionaryPath = "aa2fr3LetLen40ex80ms200MextendableAllPermsMirs.txt";
    std::string outputPath;
    std::string progressiveLogPath = "progressive_log.txt";
    CheckerMode checker = CheckerMode::Shadow;
    std::uint64_t stepBudget = 0; // 0 = unlimited
    bool progressLog = true;
    bool preflightExact = true;
};
Config config;

static bool wholeWordExactAA2Fr(const std::string& s) {
    ExactState st(s.size() + 16);
    st.load("");
    for (char c : s) {
        if (!st.tryCanonical(symOf(c))) return false;
    }
    return true;
}

static std::uint64_t countMissingD40Windows(const std::string& s) {
    if (s.size() < 40) return 0;
    std::uint64_t missing = 0;
    for (std::size_t end = 40; end <= s.size(); ++end) {
        std::uint64_t h = 0;
        for (std::size_t i = end - 40; i < end; ++i) {
            h = h * 3ULL + static_cast<std::uint64_t>(s[i] - 'a');
        }
        if (!std::binary_search(validFactors.begin(), validFactors.end(), h)) ++missing;
    }
    return missing;
}

// Returns true iff candidate is accepted. If accepted, exactState is left pushed
// for canonical/lazy/shadow; legacy pushes raw state so recursion remains synced.
static bool evaluateCandidate(const std::string& currentWord, char c, ExactState& exactState) {
    ++telemetry.candidateCount;

    bool dictOk = true;
    if (currentWord.size() + 1 >= 40) {
        const std::uint64_t encoded = encodeCandidateSuffix(currentWord, c);
        dictOk = std::binary_search(validFactors.begin(), validFactors.end(), encoded);
    }
    if (!dictOk) {
        ++telemetry.dictionaryRejects;
        mixPath(telemetry.pathHash, currentWord.size(), c, false, false);
        return false;
    }
    ++telemetry.dictionaryPasses;

    const std::uint8_t s = symOf(c);

    if (config.checker == CheckerMode::Legacy) {
        // Original v5 semantics: D40 + K>=21 macro filter.
        std::string tmp = currentWord;
        tmp.push_back(c);
        const bool legacyValid = !(tmp.size() > 40 && hasLargeAbelianSquare(tmp));
        if (!legacyValid) {
            ++telemetry.legacyRejects;
            mixPath(telemetry.pathHash, currentWord.size(), c, true, false);
            return false;
        }
        exactState.pushRaw(s); // keep state synchronized, not used as authority
        ++telemetry.acceptedBranches;
        mixPath(telemetry.pathHash, currentWord.size(), c, true, true);
        return true;
    }

    if (config.checker == CheckerMode::Canonical) {
        const bool valid = exactState.tryCanonical(s);
        if (!valid) ++telemetry.canonicalRejects;
        else ++telemetry.acceptedBranches;
        mixPath(telemetry.pathHash, currentWord.size(), c, true, valid);
        return valid;
    }

    if (config.checker == CheckerMode::Lazy) {
        const bool valid = exactState.tryLazy(s);
        if (!valid) ++telemetry.lazyRejects;
        else ++telemetry.acceptedBranches;
        mixPath(telemetry.pathHash, currentWord.size(), c, true, valid);
        return valid;
    }

    // SHADOW MODE: preserve original v5 semantics as the trajectory authority,
    // but require BOTH exact implementations to agree with one another AND with
    // legacy before recursion is allowed to continue.
    std::string tmp = currentWord;
    tmp.push_back(c);
    const bool legacyValid = !(tmp.size() > 40 && hasLargeAbelianSquare(tmp));

    bool canonicalValid = exactState.tryCanonical(s);
    if (canonicalValid) exactState.popRaw();

    bool lazyValid = exactState.tryLazy(s);
    if (lazyValid) exactState.popRaw();

    if (!legacyValid) ++telemetry.legacyRejects;
    if (!canonicalValid) ++telemetry.canonicalRejects;
    if (!lazyValid) ++telemetry.lazyRejects;

    if (canonicalValid != lazyValid) {
        ++telemetry.parityMismatches;
        std::ostringstream oss;
        oss << "FATAL canonical/lazy parity mismatch at parent length " << currentWord.size()
            << " candidate=" << c << " canonical=" << canonicalValid << " lazy=" << lazyValid;
        throw std::runtime_error(oss.str());
    }

    if (legacyValid != canonicalValid) {
        ++telemetry.legacyExactMismatches;
        std::ostringstream oss;
        oss << "FATAL legacy/exact mismatch at parent length " << currentWord.size()
            << " candidate=" << c << " legacy=" << legacyValid << " exact=" << canonicalValid;
        throw std::runtime_error(oss.str());
    }

    mixPath(telemetry.pathHash, currentWord.size(), c, true, legacyValid);
    if (!legacyValid) return false;

    exactState.pushRaw(s);
    ++telemetry.acceptedBranches;
    return true;
}

// -----------------------------------------------------------------------------
// v5 recursive record search with exact-state synchronization.
// -----------------------------------------------------------------------------
bool extendWord(std::string& currentWord, ExactState& exactState, const std::string& outputFile) {
    ++stepCount;

    if (config.stepBudget > 0 && stepCount >= config.stepBudget) {
        return false;
    }

    // --- BACKTRACKING TELEMETRY ---
    if (currentWord.length() > localPeak) {
        localPeak = currentWord.length();
    } else if (localPeak >= currentWord.length() + 100) {
        std::cout << currentWord.length() << " ";
        std::cout.flush();
        localPeak = currentWord.length();
    }

    // --- TRUNCATION HANDLER ---
    if (targetTruncationLength > 0) {
        if (static_cast<int>(currentWord.length()) > targetTruncationLength) {
            return false;
        } else {
            targetTruncationLength = 0;
            ++telemetry.truncationCount;

            std::next_permutation(currentSearchOrder.begin(), currentSearchOrder.end());
            if (currentSearchOrder == std::vector<char>{'c', 'b', 'a'}) {
                currentSearchOrder = {'a', 'b', 'c'};
            }

            std::cout << "\n[RECOVERY] Truncated to " << currentWord.length()
                      << ". Changed search order to: "
                      << currentSearchOrder[0] << currentSearchOrder[1] << currentSearchOrder[2]
                      << ". Resuming search...\n";

            lastMaxDepthStep = stepCount;
        }
    }

    // --- RECORD TRACKING & PROGRESSIVE SAVE ---
    if (static_cast<int>(currentWord.length()) > maxDepthReached) {
        maxDepthReached = static_cast<int>(currentWord.length());
        lastMaxDepthStep = stepCount;
        std::cout << "\n[PROGRESS] Reached new max depth: " << maxDepthReached << " letters\n";

        if (config.progressLog) {
            std::ofstream logFile(config.progressiveLogPath, std::ios::app);
            if (logFile.is_open()) {
                logFile << "Length " << maxDepthReached << ":\n" << currentWord << "\n";
            }
        }
    }

    // --- STALL DETECTOR ---
    if (stepCount - lastMaxDepthStep > STALL_THRESHOLD) {
        targetTruncationLength = static_cast<int>(currentWord.length() * 0.97);
        ++telemetry.stallCount;
        std::cout << "\n[STALL DETECTED] at length " << currentWord.length()
                  << " after " << STALL_THRESHOLD << " steps. Truncating to "
                  << targetTruncationLength << "...\n";
        lastMaxDepthStep = stepCount;
        return false;
    }

    // --- SUCCESS ---
    if (static_cast<int>(currentWord.length()) >= config.targetLength) {
        // Independent final safety check for exact modes.
        if (config.checker != CheckerMode::Legacy && !wholeWordExactAA2Fr(currentWord)) {
            throw std::runtime_error("target word failed independent exact AA2Fr verification");
        }
        std::ofstream outFile(outputFile);
        if (outFile.is_open()) {
            outFile << currentWord << '\n';
            std::cout << "\n[SUCCESS] Record word saved to: " << outputFile << "\n";
        }
        return true;
    }

    // --- DFS using dynamic global order ---
    for (char c : currentSearchOrder) {
        if (targetTruncationLength > 0) return false;
        if (config.stepBudget > 0 && stepCount >= config.stepBudget) return false;

        const bool isValid = evaluateCandidate(currentWord, c, exactState);
        if (!isValid) continue;

        currentWord.push_back(c);
        if (extendWord(currentWord, exactState, outputFile)) {
            return true;
        }
        currentWord.pop_back();
        exactState.popRaw();
    }

    return false;
}

static void printUsage() {
    std::cout
        << "Usage:\n"
        << "  backtracker_v5_lazy_shadow.exe SEED_FILE TARGET_LENGTH [options]\n\n"
        << "Options:\n"
        << "  --checker legacy|shadow|canonical|lazy   (default: shadow)\n"
        << "  --dictionary PATH                        (default: aa2fr...txt in cwd)\n"
        << "  --step-budget N                          (default: 0 = unlimited)\n"
        << "  --no-progress-log                        disable progressive_log.txt\n"
        << "  --progress-log PATH                      set log path\n"
        << "  --output PATH                            set target output path\n"
        << "  --no-preflight-exact                     skip exact seed preflight\n";
}

int main(int argc, char* argv[]) {
    try {
        if (argc < 3) {
            printUsage();
            return 2;
        }

        config.seedFile = argv[1];
        config.targetLength = std::stoi(argv[2]);

        for (int i = 3; i < argc; ++i) {
            const std::string arg = argv[i];
            if (arg == "--checker" && i + 1 < argc) {
                config.checker = parseCheckerMode(argv[++i]);
            } else if (arg == "--dictionary" && i + 1 < argc) {
                config.dictionaryPath = argv[++i];
            } else if (arg == "--step-budget" && i + 1 < argc) {
                config.stepBudget = std::stoull(argv[++i]);
            } else if (arg == "--no-progress-log") {
                config.progressLog = false;
            } else if (arg == "--progress-log" && i + 1 < argc) {
                config.progressiveLogPath = argv[++i];
            } else if (arg == "--output" && i + 1 < argc) {
                config.outputPath = argv[++i];
            } else if (arg == "--no-preflight-exact") {
                config.preflightExact = false;
            } else {
                throw std::runtime_error("unknown/incomplete option: " + arg);
            }
        }

        if (config.outputPath.empty()) {
            config.outputPath = "record_word_" + std::to_string(config.targetLength) + ".txt";
        }

        // Load seed.
        std::ifstream seedFile(config.seedFile);
        if (!seedFile) throw std::runtime_error("could not open seed file: " + config.seedFile);
        std::string seed;
        std::getline(seedFile, seed);
        const auto last = seed.find_last_not_of(" \n\r\t");
        if (last == std::string::npos) throw std::runtime_error("seed file is empty");
        seed.erase(last + 1);
        for (char c : seed) (void)symOf(c);

        std::cout << "Loaded seed from file: " << config.seedFile << "\n";

        // Load D40 dictionary exactly once.
        validFactors.reserve(2403132);
        std::cout << "Loading dictionary...\n";
        const auto startLoad = Clock::now();
        std::ifstream file(config.dictionaryPath);
        if (!file) throw std::runtime_error("could not open dictionary: " + config.dictionaryPath);
        std::string line;
        while (std::getline(file, line)) {
            const auto p = line.find_last_not_of(" \n\r\t");
            if (p == std::string::npos) continue;
            line.erase(p + 1);
            if (line.length() != 40) continue;
            std::uint64_t encoded = 0;
            for (char c : line) encoded = encoded * 3ULL + static_cast<std::uint64_t>(symOf(c));
            validFactors.push_back(encoded);
        }
        std::sort(validFactors.begin(), validFactors.end());
        const auto endLoad = Clock::now();
        std::cout << "Dictionary loaded and sorted in "
                  << std::chrono::duration<double>(endLoad - startLoad).count() << " seconds.\n";
        std::cout << "Dictionary entries: " << validFactors.size() << "\n\n";

        if (config.preflightExact && config.checker != CheckerMode::Legacy) {
            const bool exactSeed = wholeWordExactAA2Fr(seed);
            const std::uint64_t missing = countMissingD40Windows(seed);
            std::cout << "[PREFLIGHT] seed_exact_aa2fr=" << (exactSeed ? "true" : "false")
                      << " seed_d40_missing_windows=" << missing << "\n";
            if (!exactSeed) throw std::runtime_error("seed is not exact AA2Fr");
            if (missing != 0) throw std::runtime_error("seed contains D40 windows absent from dictionary");
        }

        maxDepthReached = static_cast<int>(seed.length());
        localPeak = seed.length();
        ExactState exactState(seed.size() + 1024);
        exactState.load(seed);

        std::cout << "Starting seed length: " << seed.length() << "\n";
        std::cout << "Starting seed preview: " << seed.substr(0, std::min<std::size_t>(50, seed.length())) << "...\n";
        std::cout << "Hunting for target length: " << config.targetLength << "...\n";
        std::cout << "Checker mode: " << checkerModeName(config.checker) << "\n";
        std::cout << "Stall threshold set to " << STALL_THRESHOLD << " steps.\n";
        if (config.stepBudget) std::cout << "Bounded step budget: " << config.stepBudget << "\n";
        std::cout << '\n';

        const auto startSolve = Clock::now();
        const bool success = extendWord(seed, exactState, config.outputPath);
        const auto endSolve = Clock::now();
        const double seconds = std::chrono::duration<double>(endSolve - startSolve).count();

        if (success) {
            std::cout << "\n>>> TARGET REACHED <<<\n";
            std::cout << "Word Length: " << seed.length() << "\n";
        } else if (config.stepBudget > 0 && stepCount >= config.stepBudget) {
            std::cout << "\n[BOUNDED STOP] Step budget reached.\n";
        } else {
            std::cout << "\nNo extension found before search exhausted/stopped.\n";
        }

        std::cout << std::setprecision(17);
        std::cout << "Time Taken: " << seconds << " seconds\n";
        std::cout << "Max depth reached: " << maxDepthReached << "\n";
        std::cout << "steps=" << stepCount << " candidates=" << telemetry.candidateCount
                  << " dict_rejects=" << telemetry.dictionaryRejects
                  << " dict_passes=" << telemetry.dictionaryPasses
                  << " accepted=" << telemetry.acceptedBranches << "\n";
        std::cout << "legacy_rejects=" << telemetry.legacyRejects
                  << " canonical_rejects=" << telemetry.canonicalRejects
                  << " lazy_rejects=" << telemetry.lazyRejects << "\n";
        std::cout << "parity_mismatches=" << telemetry.parityMismatches
                  << " legacy_exact_mismatches=" << telemetry.legacyExactMismatches << "\n";
        std::cout << "stalls=" << telemetry.stallCount
                  << " truncations=" << telemetry.truncationCount
                  << " path_hash=" << telemetry.pathHash << "\n";

        std::cout << "SUMMARY_JSON {"
                  << "\"mode\":\"" << checkerModeName(config.checker) << "\"," 
                  << "\"seconds\":" << seconds << ","
                  << "\"steps\":" << stepCount << ","
                  << "\"candidates\":" << telemetry.candidateCount << ","
                  << "\"dictionary_rejects\":" << telemetry.dictionaryRejects << ","
                  << "\"dictionary_passes\":" << telemetry.dictionaryPasses << ","
                  << "\"accepted\":" << telemetry.acceptedBranches << ","
                  << "\"max_depth\":" << maxDepthReached << ","
                  << "\"parity_mismatches\":" << telemetry.parityMismatches << ","
                  << "\"legacy_exact_mismatches\":" << telemetry.legacyExactMismatches << ","
                  << "\"stalls\":" << telemetry.stallCount << ","
                  << "\"truncations\":" << telemetry.truncationCount << ","
                  << "\"path_hash\":" << telemetry.pathHash << ","
                  << "\"success\":" << (success ? "true" : "false")
                  << "}\n";

        if (telemetry.parityMismatches != 0 || telemetry.legacyExactMismatches != 0) return 5;
        return 0;
    } catch (const std::exception& e) {
        std::cerr << "FATAL: " << e.what() << "\n";
        return 1;
    }
}

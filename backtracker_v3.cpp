#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <algorithm>
#include <cstdint>
#include <chrono>

// --- GLOBAL VARIABLES ---
std::vector<uint64_t> validFactors;
int maxDepthReached = 0; 

// Stall monitoring and truncation variables
uint64_t stepCount = 0;
uint64_t lastMaxDepthStep = 0;
const uint64_t STALL_THRESHOLD = 50000000; // Trigger truncation after 50M wasted steps
int targetTruncationLength = 0;
std::vector<char> currentSearchOrder = {'a', 'b', 'c'};

// 1. Ultra-fast base-3 encoder for the 40-letter suffix
uint64_t encodeSuffix(const std::string& word) {
    uint64_t encodedValue = 0;
    for (size_t i = word.length() - 40; i < word.length(); ++i) {
        encodedValue = encodedValue * 3 + (word[i] - 'a');
    }
    return encodedValue;
}

// 2. The Optimized Two-Letter Macro-Filter
bool hasLargeAbelianSquare(const std::string& word) {
    int len = word.length();
    for (int blockSize = 21; blockSize <= len / 2; ++blockSize) {
        int countA = 0;
        int countB = 0;
        
        // Single pass: Check right block and subtract left block simultaneously
        for (int i = 0; i < blockSize; ++i) {
            char rightChar = word[len - 1 - i];
            if (rightChar == 'a') countA++;
            else if (rightChar == 'b') countB++;
            
            char leftChar = word[len - 1 - blockSize - i];
            if (leftChar == 'a') countA--;
            else if (leftChar == 'b') countB--;
        }
        
        // If counts for 'a' and 'b' cancel out, 'c' must also cancel out.
        if (countA == 0 && countB == 0) {
            return true; 
        }
    }
    return false;
}

// 3. The Core Recursive Backtracker with Stochastic Truncation
bool extendWord(std::string& currentWord, int targetLength, const std::string& outputFile) {
    stepCount++;

    // --- TRUNCATION HANDLER ---
    if (targetTruncationLength > 0) {
        if (currentWord.length() > targetTruncationLength) {
            return false; // Fast-fail to quickly unwind the stack
        } else {
            // We have reached the 3% cut. Stop unwinding and resume!
            targetTruncationLength = 0;
            
            // Rotate the search order to avoid the same trap
            std::next_permutation(currentSearchOrder.begin(), currentSearchOrder.end());
            if (currentSearchOrder == std::vector<char>{'c', 'b', 'a'}) {
                currentSearchOrder = {'a', 'b', 'c'}; // cycle back around if we hit the end
            }
            
            std::cout << "\n[RECOVERY] Truncated to " << currentWord.length() 
                      << ". Changed search order to: " 
                      << currentSearchOrder[0] << currentSearchOrder[1] << currentSearchOrder[2] 
                      << ". Resuming search...\n";
            
            lastMaxDepthStep = stepCount; // Reset the stall monitor
        }
    }

    // --- RECORD TRACKING & PROGRESSIVE SAVE ---
    if (currentWord.length() > maxDepthReached) {
        maxDepthReached = currentWord.length();
        lastMaxDepthStep = stepCount;
        std::cout << "[PROGRESS] Reached new max depth: " << maxDepthReached << " letters\n";
		
		// Append the new record to the log file immediately
        std::ofstream logFile("D:\\ExtremeMathMmaComputations\\progressive_log.txt", std::ios::app);
        if (logFile.is_open()) {
            logFile << "Length " << maxDepthReached << ":\n" << currentWord << "\n\n";
            logFile.close();
		}
    }

    // --- STALL DETECTOR ---
    if (stepCount - lastMaxDepthStep > STALL_THRESHOLD) {
        targetTruncationLength = currentWord.length() * 0.97; // Calculate the 3% cut
        std::cout << "\n[STALL DETECTED] at length " << currentWord.length() 
                  << " after " << STALL_THRESHOLD << " steps. Truncating to " 
                  << targetTruncationLength << "...\n";
        
        lastMaxDepthStep = stepCount; // Prevent immediate re-triggering
        return false; // Trigger the cascading backtrack
    }

    // SUCCESS: Target length reached!
    if (currentWord.length() >= targetLength) {
        std::ofstream outFile(outputFile);
        if (outFile.is_open()) {
            outFile << currentWord << std::endl;
            outFile.close();
            std::cout << "\n[SUCCESS] Record word saved to: " << outputFile << "\n";
        }
        return true; 
    }

    // Try adding letters using the DYNAMIC global search order
    for (char c : currentSearchOrder) {
        // If a deeper branch triggered a truncation, ignore remaining sibling branches
        if (targetTruncationLength > 0) return false; 

        currentWord.push_back(c);
        bool isValid = true;

        // LAYER 1: The Micro-Filter (Dictionary check)
        if (currentWord.length() >= 40) {
            uint64_t encodedSuffix = encodeSuffix(currentWord);
            if (!std::binary_search(validFactors.begin(), validFactors.end(), encodedSuffix)) {
                isValid = false;
            }
        }

        // LAYER 2: The Macro-Filter
        if (isValid && currentWord.length() > 40) {
            if (hasLargeAbelianSquare(currentWord)) {
                isValid = false;
            }
        }

        // Dive deeper
        if (isValid) {
            if (extendWord(currentWord, targetLength, outputFile)) {
                return true; 
            }
        }

        // Backtrack
        currentWord.pop_back();
    }

    return false; 
}

int main(int argc, char* argv[]) {
    // 1. Set your new mirrored seed as the default fallback
    std::string seed = "bbcccacbcccaaabaaacaaabbbaaacccabcbbbabb";
    int targetLength = 2000; 

    // 2. Override with command-line arguments if provided
    if (argc >= 2) {
        seed = argv[1];
    }
    if (argc >= 3) {
        targetLength = std::stoi(argv[2]);
    }
    
    // Use like this: backtracker_v3.exe [YOUR_LONG_SEED_HERE] 2500
    std::string dictionaryPath = "D:\\ExtremeMathMmaComputations\\aa2fr3LetLen40ex80ms200MextendableAllPermsMirs.txt"; 
    std::string outputPath     = "D:\\ExtremeMathMmaComputations\\record_word_" + std::to_string(targetLength) + ".txt";
        
    validFactors.reserve(2403132); 
    std::cout << "Loading dictionary..." << std::endl;
    auto startLoad = std::chrono::high_resolution_clock::now();

    std::ifstream file(dictionaryPath);
    std::string line;
    if (file.is_open()) {
        while (std::getline(file, line)) {
            line.erase(line.find_last_not_of(" \n\r\t") + 1); 
            if (line.length() == 40) {
                validFactors.push_back(encodeSuffix(line));
            }
        }
        file.close();
    } else {
        std::cerr << "Error: Could not open dictionary file!" << std::endl;
        return 1;
    }

    std::sort(validFactors.begin(), validFactors.end());
    auto endLoad = std::chrono::high_resolution_clock::now();
    std::cout << "Dictionary loaded and sorted in " 
              << std::chrono::duration<double>(endLoad - startLoad).count() << " seconds.\n\n";

    // *** THE SECOND DECLARATION BLOCK HAS BEEN REMOVED FROM HERE ***

    maxDepthReached = seed.length();
    std::cout << "Starting seed: " << seed << "\n";
    std::cout << "Hunting for target length: " << targetLength << "...\n";
    std::cout << "Stall threshold set to " << STALL_THRESHOLD << " steps.\n\n";

    auto startSolve = std::chrono::high_resolution_clock::now();
    
    if (extendWord(seed, targetLength, outputPath)) {
        auto endSolve = std::chrono::high_resolution_clock::now();
        std::cout << "\n>>> RECORD SHATTERED <<< \n";
        std::cout << "Word Length: " << seed.length() << "\n";
        std::cout << "Time Taken: " << std::chrono::duration<double>(endSolve - startSolve).count() << " seconds.\n";
    } else {
        std::cout << "\nNo valid extension found for this seed up to length " << targetLength << "." << std::endl;
        std::cout << "Max depth reached before exhausting search space: " << maxDepthReached << std::endl;
    }

    return 0;
}
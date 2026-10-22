// Sliding-block-code search.
// Position i of a 4-letter a2f word w (g85 fixed point) is mapped to a ternary
// block chosen from OPTIONS, the choice depending only on the context
// w[i-l .. i+r]. The code table is filled lazily during a depth-first search;
// a context is "owned" by the first position that assigned it, and is
// unassigned again when the search backtracks past that position.
// A complete table that survives gives a morphic ternary word (a sliding-block
// code of a morphic word is morphic).
'use strict';
const L = require('./lib');

const MOLS_R = ['a', 'b', 'c', 'aaa', 'bbb', 'ccc'];                     // aa2fr molecules
const MOLS = ['a', 'b', 'c', 'aa', 'bb', 'cc', 'aaa', 'bbb', 'ccc'];      // aa2f molecules

function search(w, { l = 1, r = 1, options = MOLS_R, restricted = true, maxNodes = 5e6, seed = 0,
                     timeMs = 60000 } = {}) {
  const N = w.length - r;
  const ch = new L.SquareChecker('abc', 2, N * 3 + 10);
  const ctx = new Array(N); const ctxId = new Map();
  for (let i = l; i < N; i++) { const c = w.slice(i - l, i + r + 1); if (!ctxId.has(c)) ctxId.set(c, ctxId.size); ctx[i] = ctxId.get(c); }
  const table = new Int32Array(ctxId.size).fill(-1);
  const owner = new Uint8Array(N), choice = new Int32Array(N).fill(-1), pushed = new Int32Array(N);
  // per-context option order (random permutation if seed != 0)
  let rnd = seed || 1; const rand = () => ((rnd = (rnd * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff);
  const order = Array.from({ length: ctxId.size }, () => {
    const o = options.map((_, j) => j); if (seed) for (let j = o.length - 1; j > 0; j--) { const k = Math.floor(rand() * (j + 1)); [o[j], o[k]] = [o[k], o[j]]; } return o; });

  const runOk = () => {
    if (!restricted) return true;
    const wd = ch.word, n = wd.length;
    if (n < 3 || wd[n - 1] === wd[n - 2]) return true;
    let j = n - 2, len = 0; while (j >= 0 && wd[j] === wd[n - 2]) { j--; len++; }
    return len !== 2 || j < 0;
  };
  const tryPush = s => { let k = 0; for (const x of s) { const p = ch.push(x); k++; if (p || !runOk()) { for (; k > 0; k--) ch.pop(); return -1; } } return k; };

  let i = l, nodes = 0, best = 0, bestPos = l, assigned = 0, maxAssigned = 0; const t0 = Date.now();
  while (i >= l && i < N && nodes < maxNodes && Date.now() - t0 < timeMs) {
    const c = ctx[i]; let ok = false;
    if (table[c] >= 0 && !owner[i]) {
      nodes++; const k = tryPush(options[table[c]]);
      if (k >= 0) { pushed[i] = k; ok = true; }
    } else {
      owner[i] = 1;
      for (let j = choice[i] + 1; j < options.length; j++) {
        nodes++; const k = tryPush(options[order[c][j]]);
        if (k >= 0) { pushed[i] = k; choice[i] = j; if (table[c] < 0) assigned++; table[c] = order[c][j]; ok = true; break; }
      }
      if (!ok) { owner[i] = 0; choice[i] = -1; if (table[c] >= 0) assigned--; table[c] = -1; }
    }
    if (ok) { i++; if (i > bestPos) { bestPos = i; best = ch.n; maxAssigned = Math.max(maxAssigned, assigned); } }
    else {
      i--; while (i >= l) { for (let k = pushed[i]; k > 0; k--) ch.pop(); if (owner[i]) break; i--; }
    }
  }
  const tableOut = {}; for (const [c, id] of ctxId) if (table[id] >= 0) tableOut[c] = options[table[id]];
  return { complete: i >= N, exhausted: i < l, bestPos, best, nodes, contexts: ctxId.size, assigned, maxAssigned,
           word: ch.word.join(''), table: tableOut, ms: Date.now() - t0 };
}
module.exports = { search, MOLS, MOLS_R };

if (require.main === module) {
  const w = L.iterate(L.g85, 'a', 3);
  const timeMs = +(process.argv[2] || 20000);
  for (const restricted of [true, false]) {
    for (const [l, r] of [[0, 0], [1, 0], [0, 1], [1, 1], [2, 0], [2, 1], [1, 2], [2, 2], [3, 2], [3, 3]]) {
      const res = search(w.slice(0, 200000), { l, r, restricted, options: restricted ? MOLS_R : MOLS, timeMs });
      console.log(`${restricted ? 'aa2fr' : 'aa2f '} window l=${l} r=${r}: contexts ${res.contexts}, reached g85 pos ${res.bestPos} (ternary len ${res.best}), ` +
        `${res.exhausted ? 'EXHAUSTED' : res.complete ? 'COMPLETE' : 'timeout'}, max contexts fixed ${res.maxAssigned}, nodes ${res.nodes}`);
    }
  }
}

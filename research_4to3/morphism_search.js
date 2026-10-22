// Letter-by-letter search for a uniform morphism phi: {a,b,c,d} -> {a,b,c}^m
// such that phi(w) is aa2f (or aa2fr) for a long prefix of the g85 fixed point w.
// The 4m unknown letters phi(x)[j] are fixed lazily during a depth-first search
// along phi(w); a letter is owned by the first output position that fixed it.
'use strict';
const L = require('./lib');

function morphismSearch(w, m, { restricted = false, timeMs = 30000, alphabet = 'abc', fixFirst = true } = {}) {
  const N = w.length * m;
  const key = i => 'abcd'.indexOf(w[(i / m) | 0]) * m + (i % m);
  const ch = new L.SquareChecker('abc', 2, N + 2);
  const table = new Int8Array(4 * m).fill(-1);
  const owner = new Uint8Array(N), choice = new Int8Array(N).fill(-1);
  const runOk = () => {
    if (!restricted) return true;
    const wd = ch.word, n = wd.length;
    if (n < 3 || wd[n - 1] === wd[n - 2]) return true;
    let j = n - 2, len = 0; while (j >= 0 && wd[j] === wd[n - 2]) { j--; len++; }
    return len !== 2 || j < 0;
  };
  let i = 0, best = 0, nodes = 0; const t0 = Date.now();
  // symmetry breaking: phi(a) starts with 'a'
  const firstChoices = fixFirst ? 1 : 3;
  while (i >= 0 && i < N && Date.now() - t0 < timeMs) {
    const k = key(i); let ok = false;
    if (table[k] >= 0 && !owner[i]) {
      nodes++; if (!ch.push(alphabet[table[k]]) && runOk()) ok = true; else ch.pop();
    } else {
      owner[i] = 1;
      const lim = i === 0 ? firstChoices : 3;
      for (let c = choice[i] + 1; c < lim; c++) {
        nodes++;
        if (!ch.push(alphabet[c]) && runOk()) { choice[i] = c; table[k] = c; ok = true; break; }
        ch.pop();
      }
      if (!ok) { owner[i] = 0; choice[i] = -1; table[k] = -1; }
    }
    if (ok) { i++; if (i > best) best = i; }
    else { i--; while (i >= 0) { ch.pop(); if (owner[i]) break; i--; } }
  }
  const phi = {}; for (let x = 0; x < 4; x++) { let s = ''; for (let j = 0; j < m; j++) s += table[x * m + j] >= 0 ? alphabet[table[x * m + j]] : '?'; phi['abcd'[x]] = s; }
  return { m, best, complete: i >= N, exhausted: i < 0, nodes, ms: Date.now() - t0, phi };
}
module.exports = { morphismSearch };

if (require.main === module) {
  const restricted = process.argv[2] === 'r';
  const timeMs = +(process.argv[3] || 20000);
  const ms = (process.argv[4] || '2,3,4,5,6,7,8,9,10,12,14,16,20,24').split(',').map(Number);
  const w = L.iterate(L.g85, 'a', 3).slice(0, 4000);
  for (const m of ms) {
    const r = morphismSearch(w, m, { restricted, timeMs });
    console.log(`${restricted ? 'aa2fr' : 'aa2f '} m=${m}: best ternary prefix ${r.best} (= ${(r.best / m).toFixed(1)} g85 letters) ` +
      `${r.exhausted ? 'EXHAUSTED' : r.complete ? 'COMPLETE' : 'timeout'} nodes ${r.nodes} phi(a..d)= ${Object.values(r.phi).join(' | ')}`);
  }
}

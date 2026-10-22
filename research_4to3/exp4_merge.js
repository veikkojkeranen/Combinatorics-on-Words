// Reverse engineering: merge the molecule letters of a known word into k classes
// and test whether the merged word is still a2f. If so, the ternary word is a
// "decorated" k-letter a2f word in the sense of the research note.
'use strict';
const fs = require('fs'); const L = require('./lib');
const n = +(process.argv[2] || 3268), K = +(process.argv[3] || 4);
const w = fs.readFileSync(`data/len${n}.txt`, 'utf8').trim().split('\n')[0];
const mol = w.match(/(a+|b+|c+)/g).map(r => r[0] + r.length);
const alph = [...new Set(mol)].sort();
const ids = mol.map(x => alph.indexOf(x));
const m = alph.length;
const results = [];
// enumerate set partitions of alph into exactly K blocks (restricted growth strings)
const rg = new Array(m).fill(0);
function rec(i, mx) {
  if (i === m) {
    if (mx + 1 !== K) return;
    const merged = ids.map(j => 'abcdefghi'[rg[j]]).join('');
    const r = L.longestFreePrefix(merged, 'abcdefghi'.slice(0, K), 1);
    results.push({ part: alph.map((x, j) => x + ':' + 'abcdefghi'[rg[j]]).join(' '), len: r.len });
    return;
  }
  for (let v = 0; v <= Math.min(mx + 1, K - 1); v++) { rg[i] = v; rec(i + 1, Math.max(mx, v)); }
}
rec(0, -1);
results.sort((a, b) => b.len - a.len);
console.log(`word ${n}: ${mol.length} molecules over ${m} letters; ${results.length} partitions into ${K} classes`);
for (const r of results.slice(0, 8)) console.log(`  a2f prefix ${r.len}/${mol.length}  ${r.part}`);

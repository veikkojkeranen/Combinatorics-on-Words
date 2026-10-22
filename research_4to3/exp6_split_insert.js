// Splitting / insertion scan.
// Partition the molecules M into k classes and assign the classes to the letters
// of a k-letter a2f word W (g85 skeleton, plus an inserted letter e when k = 5).
// Every choice of molecules inside the classes gives an a2f molecule word, so
// only real ternary abelian squares (counted with multiplicity, aligned or not)
// can fail. DFS over the in-class choices (and the e-insertions).
'use strict';
const L = require('./lib'); const { dfs } = require('./skeleton_dfs');
const restricted = process.argv[2] !== 'f';
const K = +(process.argv[3] || 4);
const timeMs = +(process.argv[4] || 1500);
const MOL = restricted ? ['a', 'b', 'c', 'aaa', 'bbb', 'ccc'] : ['a', 'b', 'c', 'aa', 'bb', 'cc', 'aaa', 'bbb', 'ccc'];
const w = L.iterate(L.g85, 'a', 3).slice(0, 6000);

function partitions(m, k) {   // restricted growth strings
  const out = [], rg = new Array(m).fill(0);
  (function rec(i, mx) {
    if (i === m) { if (mx + 1 === k) out.push(rg.slice()); return; }
    for (let v = 0; v <= Math.min(mx + 1, k - 1); v++) { rg[i] = v; rec(i + 1, Math.max(mx, v)); }
  })(0, -1);
  return out;
}
function* perms(a) { if (a.length <= 1) { yield a; return; } for (let i = 0; i < a.length; i++) for (const p of perms([...a.slice(0, i), ...a.slice(i + 1)])) yield [a[i], ...p]; }

const results = [];
for (const rg of partitions(MOL.length, K)) {
  const classes = Array.from({ length: K }, () => []); rg.forEach((c, j) => classes[c].push(MOL[j]));
  // a class whose molecules all share one base can never sit next to a class of the same base
  for (const perm of perms([...Array(K).keys()])) {
    const cls = {}; 'abcde'.slice(0, K).split('').forEach((x, j) => (cls[x] = classes[perm[j]]));
    let opts;
    if (K === 4) opts = (t, i) => cls[t[i]];
    else { // e may be inserted before any skeleton letter
      const cache = {};
      opts = (t, i) => cache[t[i]] || (cache[t[i]] = [...cls[t[i]], ...cls.e.flatMap(me => cls[t[i]].map(mx => me + mx))]);
    }
    const r = dfs(w, { wild: null, contextOptions: opts, restricted, maxNodes: 4e6 });
    results.push({ best: r.best, slot: r.bestSlot, complete: r.complete, desc: Object.entries(cls).map(([x, c]) => `${x}:{${c.join(',')}}`).join(' ') });
  }
}
results.sort((a, b) => b.best - a.best);
console.log(`${restricted ? 'aa2fr' : 'aa2f'} with ${K} skeleton letters: ${results.length} class assignments tried`);
for (const r of results.slice(0, 10)) console.log(`  ternary ${r.best}  (g85 slot ${r.slot})  ${r.desc}${r.complete ? '  COMPLETE' : ''}`);

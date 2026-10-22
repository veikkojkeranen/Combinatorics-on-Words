// Pleasants' 5-letter a2f word as skeleton; molecules {a,b,c,aaa,bbb,ccc} split
// into 5 classes; DFS over the in-class choices.
'use strict';
const L = require('./lib'); const { dfs } = require('./skeleton_dfs');
const restricted = process.argv[2] !== 'f';
const timeNodes = +(process.argv[3] || 3e6);
const MOL = restricted ? ['a', 'b', 'c', 'aaa', 'bbb', 'ccc'] : ['a', 'b', 'c', 'aa', 'bb', 'cc', 'aaa', 'bbb', 'ccc'];
const W = L.iterate(L.pleasants, 'a', 4).slice(0, 20000);
console.log('skeleton a2f check (first 3000):', L.longestFreePrefix(W.slice(0, 3000), 'abcde', 1).len);
function* perms(a) { if (a.length <= 1) { yield a; return; } for (let i = 0; i < a.length; i++) for (const p of perms([...a.slice(0, i), ...a.slice(i + 1)])) yield [a[i], ...p]; }
const parts = []; const rg = new Array(MOL.length).fill(0);
(function rec(i, mx) { if (i === MOL.length) { if (mx === 4) parts.push(rg.slice()); return; } for (let v = 0; v <= Math.min(mx + 1, 4); v++) { rg[i] = v; rec(i + 1, Math.max(mx, v)); } })(0, -1);
const res = [];
for (const p of parts) {
  const classes = Array.from({ length: 5 }, () => []); p.forEach((c, j) => classes[c].push(MOL[j]));
  for (const perm of perms([0, 1, 2, 3, 4])) {
    const cls = {}; 'abcde'.split('').forEach((x, j) => (cls[x] = classes[perm[j]]));
    const r = dfs(W, { wild: null, contextOptions: (t, i) => cls[t[i]], restricted, maxNodes: timeNodes });
    res.push({ best: r.best, slot: r.bestSlot, complete: r.complete, nodes: r.nodes, desc: Object.entries(cls).map(([x, c]) => `${x}:{${c.join(',')}}`).join(' ') });
  }
}
res.sort((a, b) => b.best - a.best);
console.log(`${restricted ? 'aa2fr' : 'aa2f'} on Pleasants skeleton: ${res.length} assignments`);
for (const r of res.slice(0, 10)) console.log(`  ternary ${r.best} (skeleton slot ${r.slot}) nodes ${r.nodes} ${r.desc}`);

// Block morphisms phi: {a,b,c,d} -> aa2fr blocks of length 40, applied to the g85
// fixed point. Lazy DFS over the 4 images (window-0 code search).
'use strict';
const fs = require('fs'); const L = require('./lib'); const { search } = require('./code_search');
const pool = +(process.argv[2] || 3000), seed = +(process.argv[3] || 7), timeMs = +(process.argv[4] || 60000);
const all = fs.readFileSync('../aa2fr3LetLen40ex80ms200MextendableAllPermsMirs.txt', 'utf8').split(/\r?\n/).filter(s => s.length === 40);
let r = seed; const rand = () => ((r = (r * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff);
const cand = []; for (let i = 0; i < pool; i++) cand.push(all[Math.floor(rand() * all.length)]);
const w = L.iterate(L.g85, 'a', 2);
for (const restricted of [true, false]) {
  const res = search(w.slice(0, 2000), { l: 0, r: 0, options: cand, restricted, timeMs, maxNodes: 1e12 });
  console.log(`${restricted ? 'aa2fr' : 'aa2f '} pool ${pool}: reached g85 pos ${res.bestPos}, ternary len ${res.best}, ${res.exhausted ? 'EXHAUSTED' : res.complete ? 'COMPLETE' : 'timeout'}, nodes ${res.nodes}`);
  console.log('  table at end:', res.table);
}

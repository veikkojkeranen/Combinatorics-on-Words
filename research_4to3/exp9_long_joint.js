// Long run of the joint search for one partition, with progress output and the
// best word saved. Usage: node exp9_long_joint.js <rg e.g. 011234> <maxNodes> <out>
'use strict';
const fs = require('fs'); const L = require('./lib');
// rg of length 6 -> aa2fr molecules, length 9 -> aa2f molecules (in the order below)
const rg = process.argv[2].split('').map(Number), K = Math.max(...rg) + 1;
const MOL = rg.length === 9 ? ['a', 'b', 'c', 'aa', 'bb', 'cc', 'aaa', 'bbb', 'ccc'] : ['a', 'b', 'c', 'aaa', 'bbb', 'ccc'];
const maxNodes = +process.argv[3], out = process.argv[4];
const KL = 'abcdefgh'.slice(0, K);
const T = new L.SquareChecker('abc', 2, 1 << 17), S = new L.SquareChecker(KL, 1, 1 << 16);
const base = MOL.map(x => x[0]), seq = [], ch = [-1];
let nodes = 0, best = 0, d = 0, t0 = Date.now(), lastReport = 0;
while (d >= 0 && nodes < maxNodes) {
  let ok = false;
  for (let c = ch[d] + 1; c < MOL.length; c++) {
    nodes++;
    if (d > 0 && base[seq[d - 1]] === base[c]) continue;
    if (S.push(KL[rg[c]])) { S.pop(); continue; }
    let k = 0, bad = false;
    for (const x of MOL[c]) { k++; if (T.push(x)) { bad = true; break; } }
    if (bad) { for (; k > 0; k--) T.pop(); S.pop(); continue; }
    ch[d] = c; seq[d] = c; ok = true; break;
  }
  if (ok) { d++; ch[d] = -1; if (T.n > best) { best = T.n; if (best - lastReport >= 100) { lastReport = best; fs.writeFileSync(out, T.word.join('') + '\n'); console.log(`best ${best} after ${nodes} nodes, ${((Date.now() - t0) / 1000).toFixed(0)} s`); } } }
  else { d--; if (d >= 0) { for (let k = MOL[seq[d]].length; k > 0; k--) T.pop(); S.pop(); } }
}
console.log(`done: best ${best}, nodes ${nodes}, exhausted ${d < 0}, ${((Date.now() - t0) / 1000).toFixed(0)} s`);

// Joint exhaustive search: molecule words over M whose ternary image is aa2f(r)
// AND whose merge under a partition of M into k classes is a2f over k letters.
// Answers: can a long aa2f(r) ternary word be a decorated (split) k-letter a2f word?
'use strict';
const L = require('./lib');
const restricted = process.argv[2] !== 'f';
const K = +(process.argv[3] || 4);
const maxNodes = +(process.argv[4] || 2e7);
const MOL = restricted ? ['a', 'b', 'c', 'aaa', 'bbb', 'ccc'] : ['a', 'b', 'c', 'aa', 'bb', 'cc', 'aaa', 'bbb', 'ccc'];
const KL = 'abcdefgh'.slice(0, K);

function partitions(m, k) {
  const out = [], rg = new Array(m).fill(0);
  (function rec(i, mx) { if (i === m) { if (mx + 1 === k) out.push(rg.slice()); return; }
    for (let v = 0; v <= Math.min(mx + 1, k - 1); v++) { rg[i] = v; rec(i + 1, Math.max(mx, v)); } })(0, -1);
  return out;
}

function joint(rg) {
  const T = new L.SquareChecker('abc', 2, 1 << 16), S = new L.SquareChecker(KL, 1, 1 << 15);
  const base = MOL.map(x => x[0]), seq = [], ch = [];
  let nodes = 0, best = 0, bestWord = '';
  // molecule 0..|MOL|-1 at each depth; first molecule fixed to index 0 or 3 class reps (symmetry not used: small)
  let d = 0; ch[0] = -1;
  while (d >= 0 && nodes < maxNodes) {
    let ok = false;
    for (let c = ch[d] + 1; c < MOL.length; c++) {
      nodes++;
      if (d > 0 && base[seq[d - 1]] === base[c]) continue;           // runs must be maximal
      if (S.push(KL[rg[c]])) { S.pop(); continue; }
      let k = 0, bad = false;
      for (const x of MOL[c]) { k++; if (T.push(x)) { bad = true; break; } }
      if (bad) { for (; k > 0; k--) T.pop(); S.pop(); continue; }
      ch[d] = c; seq[d] = c; ok = true; break;
    }
    if (ok) { d++; ch[d] = -1; if (T.n > best) { best = T.n; bestWord = T.word.join(''); } }
    else { d--; if (d >= 0) { for (let k = MOL[seq[d]].length; k > 0; k--) T.pop(); S.pop(); } }
  }
  return { best, exhausted: d < 0, nodes, bestWord };
}

const res = [];
for (const rg of partitions(MOL.length, K)) {
  const r = joint(rg);
  const classes = Array.from({ length: K }, () => []); rg.forEach((c, j) => classes[c].push(MOL[j]));
  res.push({ ...r, desc: classes.map(c => '{' + c.join(',') + '}').join(' ') });
}
res.sort((a, b) => b.best - a.best);
const allEx = res.every(r => r.exhausted);
console.log(`${restricted ? 'aa2fr' : 'aa2f'}: decorated ${K}-letter a2f words, ${res.length} partitions, all exhausted: ${allEx}`);
for (const r of res.slice(0, 6)) console.log(`  max ternary length ${r.best} ${r.exhausted ? '(exhaustive)' : '(node limit)'} nodes ${r.nodes}  classes ${r.desc}\n     ${r.bestWord}`);

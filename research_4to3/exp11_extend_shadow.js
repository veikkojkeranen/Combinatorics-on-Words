// Extend the five-letter shadow of data/joint5_011234.txt on both sides.
//   mode 'pure'     : extend the shadow as an a2f word over {a,b,c,d,e} only;
//   mode 'decorated': extend the molecule word, so that the shadow stays a2f AND
//                     the ternary word stays aa2fr (classes {a},{b,c},{aaa},{bbb},{ccc}).
// Left extension = right extension of the reversal (both properties are
// invariant under reversal). Two-sided: extend right first, then extend the
// result to the left.
// Usage: node exp11_extend_shadow.js <pure|decorated> <right> <left> <maxNodes>
'use strict';
const fs = require('fs'); const L = require('./lib');
const mode = process.argv[2] || 'pure', R = +(process.argv[3] || 1000), Lft = +(process.argv[4] || 1000);
const maxNodes = +(process.argv[5] || 5e7);

const MOL = ['a', 'b', 'c', 'aaa', 'bbb', 'ccc'], CLS = ['a', 'b', 'b', 'c', 'd', 'e'], BASE = [0, 1, 2, 0, 1, 2];
const w = fs.readFileSync('data/joint5_011234.txt', 'utf8').trim();
const mol = w.match(/(a+|b+|c+)/g).map(m => MOL.indexOf(m));
const shadowOf = ms => ms.map(i => CLS[i]).join('');
const ternOf = ms => ms.map(i => MOL[i]).join('');

// DFS extension of a molecule sequence (decorated) or a shadow word (pure) by n units.
function extend(seq, n) {
  const pure = mode === 'pure';
  const S = new L.SquareChecker('abcde', 1, seq.length + n + 5);
  const T = pure ? null : new L.SquareChecker('abc', 2, (seq.length + n) * 3 + 5);
  for (const x of seq) {
    if (S.push(pure ? x : CLS[x])) throw new Error('seed shadow not a2f');
    if (!pure) for (const ch of MOL[x]) if (T.push(ch)) throw new Error('seed not aa2f');
  }
  const opts = pure ? ['a', 'b', 'c', 'd', 'e'] : [0, 1, 2, 3, 4, 5];
  const out = seq.slice(), ch = [-1], pushed = [];
  let d = 0, nodes = 0, best = 0, bestSeq = null; const t0 = Date.now();
  while (d >= 0 && d < n && nodes < maxNodes) {
    let ok = false;
    for (let c = ch[d] + 1; c < opts.length; c++) {
      nodes++;
      const x = opts[c];
      if (!pure && BASE[out[out.length - 1]] === BASE[x]) continue;          // runs stay maximal
      if (S.push(pure ? x : CLS[x])) { S.pop(); continue; }
      let k = 0, bad = false;
      if (!pure) for (const t of MOL[x]) { k++; if (T.push(t)) { bad = true; break; } }
      if (bad) { for (; k > 0; k--) T.pop(); S.pop(); continue; }
      out.push(x); pushed[d] = k; ch[d] = c; ok = true; break;
    }
    if (ok) { d++; ch[d] = -1; if (d > best) { best = d; bestSeq = out.slice(); } }
    else { d--; if (d >= 0) { out.pop(); S.pop(); if (!pure) for (let k = pushed[d]; k > 0; k--) T.pop(); } }
  }
  return { reached: best, done: d >= n, exhausted: d < 0, nodes, ms: Date.now() - t0, seq: bestSeq || seq };
}

const seed = mode === 'pure' ? shadowOf(mol).split('') : mol;
const unit = mode === 'pure' ? 'letters' : 'molecules';
console.log(`mode ${mode}: seed has ${seed.length} ${unit}`);
const r1 = extend(seed, R);
console.log(`right: +${r1.reached} ${unit} ${r1.done ? '(target reached)' : r1.exhausted ? '(EXHAUSTED: maximal)' : '(node limit)'} nodes ${r1.nodes}, ${r1.ms} ms`);
const r2 = extend(seed.slice().reverse(), Lft);
console.log(`left : +${r2.reached} ${unit} ${r2.done ? '(target reached)' : r2.exhausted ? '(EXHAUSTED: maximal)' : '(node limit)'} nodes ${r2.nodes}, ${r2.ms} ms`);
// two-sided: right extension first, then extend it to the left
const r3 = extend(r1.seq.slice().reverse(), Lft);
const both = r3.seq.slice().reverse();
const leftAdded = r3.reached, rightAdded = r1.reached;
console.log(`two-sided: +${leftAdded} left, +${rightAdded} right ${r3.done ? '' : r3.exhausted ? '(left EXHAUSTED after right extension)' : '(node limit)'}`);

// independent verification from scratch
const sh = mode === 'pure' ? both.join('') : shadowOf(both);
const tern = mode === 'pure' ? null : ternOf(both);
const seedStr = mode === 'pure' ? seed.join('') : shadowOf(seed);
const v = {
  shadowLen: sh.length, shadowA2F: L.longestFreePrefix(sh, 'abcde', 1).len === sh.length,
  seedAt: sh.indexOf(seedStr), seedPosExpected: leftAdded,
};
if (tern) Object.assign(v, { ternaryLen: tern.length, ternaryAA2F: L.longestFreePrefix(tern, 'abc', 2).len === tern.length,
  runs13: tern.match(/(a+|b+|c+)/g).every(r => r.length === 1 || r.length === 3), seedTernaryAt: tern.indexOf(w) });
console.log('verify:', JSON.stringify(v));
fs.mkdirSync('data/extend', { recursive: true });
fs.writeFileSync(`data/extend/joint5_${mode}_two_sided.txt`, (tern ? tern + '\n' : '') + sh + '\n');

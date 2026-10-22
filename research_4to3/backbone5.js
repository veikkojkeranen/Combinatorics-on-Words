// Five-letter backbone experiment.
// Backbone letters P, Q, R, S, T are the shadow classes {a}, {b,c}, {aaa}, {bbb}, {ccc}.
// We search simultaneously for
//   * a morphism H on {P,Q,R,S,T} with H(x0) starting with x0 (fixed point H^omega(x0)), and
//   * a sliding-block rule deciding b or c at every Q,
// such that the decorated fixed point is aa2fr (and, optionally, the backbone is a2f).
// Rule types:
//   'left:l' - the choice depends on the l backbone letters to the left of the Q;
//   'slot'   - the choice depends on (parent letter, offset in its image), i.e. it is
//              stored in the morphism itself (a coding of a morphism on six letters).
// Images and rule entries are unknowns fixed lazily by a depth-first search while the
// fixed point is generated; an entry is owned by the position that fixed it.
'use strict';
const L = require('./lib');

const BB = 'PQRST';
const MOLS = ['a', null, 'aaa', 'bbb', 'ccc'];           // Q -> 'b' / 'c' by rule
const BASE = [0, -1, 0, 1, 2];

function search({ lens = [8, 8, 8, 8, 8], start = 0, rule = 'left:2', backboneA2F = true,
                  timeMs = 10000, maxMol = 100000, seed = 0 } = {}) {
  const maxLen = Math.max(...lens), offs = []; let tot = 0;
  for (let x = 0; x < 5; x++) { offs.push(tot); tot += lens[x]; }
  const img = new Int8Array(tot).fill(-1);
  const [rtype, rarg] = rule.split(':'); const l = +rarg || 0;
  const ruleSize = rtype === 'slot' ? 5 * maxLen : Math.pow(5, l);
  const rtab = new Int8Array(ruleSize).fill(-1);

  const fx = new Int8Array(maxMol), qc = new Int8Array(maxMol), par = new Int32Array(maxMol), bs = new Int32Array(maxMol + 1);
  const choice = new Int8Array(maxMol).fill(-1), ownImg = new Uint8Array(maxMol), ownRule = new Uint8Array(maxMol), pushed = new Int8Array(maxMol);
  const T = new L.SquareChecker('abc', 2, maxMol * 3 + 4), B = new L.SquareChecker(BB, 1, maxMol + 2);
  let rnd = seed || 1; const rand = () => ((rnd = (rnd * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff);
  const combos = []; for (let x = 0; x < 5; x++) for (let q = 0; q < (x === 1 ? 2 : 1); q++) combos.push([x, q]);
  if (seed) for (let j = combos.length - 1; j > 0; j--) { const k = Math.floor(rand() * (j + 1)); [combos[j], combos[k]] = [combos[k], combos[j]]; }

  const ruleKey = (i, j, k) => {
    if (rtype === 'slot') return fx[j] * maxLen + k;
    let key = 0; for (let t = i - l; t < i; t++) key = key * 5 + (t >= 0 ? fx[t] : 0); return key;
  };
  const undo = i => {
    for (let c = pushed[i]; c > 0; c--) T.pop();
    if (backboneA2F) B.pop();
    const j = par[i], slot = offs[i === 0 ? start : fx[j]] + (i - bs[j]);
    if (ownImg[i] || ownRule[i]) owners.pop();
    if (ownImg[i]) { img[slot] = -1; ownImg[i] = 0; fixedCnt--; }
    if (ownRule[i]) { rtab[ruleKey(i, j, i - bs[j])] = -1; ownRule[i] = 0; }
  };

  img[offs[start]] = start; fx[0] = start;             // H(start) begins with start: a fixed point
  let i = 0, best = 0, nodes = 0, fixedCnt = 1, beyond = 0, beyondSnap = null; const owners = []; const t0 = Date.now();
  while (i >= 0 && i < maxMol && Date.now() - t0 < timeMs) {
    let j = 0;
    if (i > 0) { j = par[i - 1]; while (bs[j] + lens[fx[j]] <= i) { bs[j + 1] = bs[j] + lens[fx[j]]; j++; } if (j >= i) break; }
    par[i] = j;
    const k = i - bs[j], slot = offs[i === 0 ? start : fx[j]] + k;
    let ok = false;
    for (let c = choice[i] + 1; c < combos.length; c++) {
      const [x, q] = combos[c];
      nodes++;
      if (img[slot] >= 0 && img[slot] !== x) continue;
      const rk = x === 1 ? ruleKey(i, j, k) : -1;
      if (x === 1 && rtab[rk] >= 0 && rtab[rk] !== q) continue;
      const base = x === 1 ? 1 + q : BASE[x];
      if (i > 0) { const pb = fx[i - 1] === 1 ? 1 + qc[i - 1] : BASE[fx[i - 1]]; if (pb === base) continue; }
      if (backboneA2F && B.push(BB[x])) { B.pop(); continue; }
      const s = x === 1 ? 'bc'[q] : MOLS[x]; let n = 0, bad = false;
      for (const ch of s) { n++; if (T.push(ch)) { bad = true; break; } }
      if (bad) { for (; n > 0; n--) T.pop(); if (backboneA2F) B.pop(); continue; }
      fx[i] = x; qc[i] = q; pushed[i] = n; choice[i] = c;
      if (img[slot] < 0) { img[slot] = x; ownImg[i] = 1; fixedCnt++; }
      if (x === 1 && rtab[rk] < 0) { rtab[rk] = q; ownRule[i] = 1; }
      if (ownImg[i] || ownRule[i]) owners.push(i);
      ok = true; break;
    }
    if (ok) {
      i++; if (T.n > best) best = T.n;
      // forced streak: positions after the last free decision follow from the fixed images and rule
      const last = owners.length ? owners[owners.length - 1] : 0;
      if (i - 1 - last > beyond) { beyond = i - 1 - last; beyondSnap = { H: imgString(), R: ruleObj(), len: T.n, molecules: i, lastDecision: last }; }
    }
    else { choice[i] = -1; i--; if (i >= 0) undo(i); }
  }
  const H = imgString(), R = ruleObj();
  function imgString() { const H = {}; for (let x = 0; x < 5; x++) { let s = ''; for (let k = 0; k < lens[x]; k++) s += img[offs[x] + k] >= 0 ? BB[img[offs[x] + k]] : '?'; H[BB[x]] = s; } return H; }
  function ruleObj() { const R = {}; for (let r = 0; r < ruleSize; r++) if (rtab[r] >= 0) {
    let key; if (rtype === 'slot') key = BB[(r / maxLen) | 0] + '@' + (r % maxLen); else { key = ''; let v = r; for (let t = 0; t < l; t++) { key = BB[v % 5] + key; v = (v / 5) | 0; } }
    R[key] = 'bc'[rtab[r]];
  } return R; }
  let backbone = ''; for (let t = 0; t < i && t < maxMol; t++) backbone += BB[fx[t]];
  return { best, beyond, beyondSnap, nodes, exhausted: i < 0, complete: i >= maxMol, H, R, word: T.word.join(''), backbone, ms: Date.now() - t0 };
}
module.exports = { search, BB };

if (require.main === module) {
  const rule = process.argv[2] || 'left:2', a2f = process.argv[3] !== 'free';
  const timeMs = +(process.argv[4] || 3000), lo = +(process.argv[5] || 3), hi = +(process.argv[6] || 12);
  const out = [];
  for (let n = lo; n <= hi; n++) for (let s = 0; s < 5; s++) {
    if (s === 1) continue;                              // Q needs a rule before it exists; start elsewhere
    out.push({ n, start: BB[s], ...search({ lens: [n, n, n, n, n], start: s, rule, backboneA2F: a2f, timeMs }) });
  }
  out.sort((a, b) => b.best - a.best);
  console.log(`backbone5 rule=${rule} backboneA2F=${a2f} uniform lengths ${lo}..${hi}`);
  for (const r of out.slice(0, 6)) console.log(`  |H|=${r.n} start ${r.start}: ternary ${r.best} ${r.exhausted ? 'EXHAUSTED' : 'timeout'}  H=${JSON.stringify(r.H)}`);
  console.log('  exhausted', out.filter(r => r.exhausted).length, 'of', out.length);
}

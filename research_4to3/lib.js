// Shared helpers for the 4-letter a2f -> 3-letter aa2f(r) experiments.
'use strict';

const G85A = 'abcacdcbcdcadcdbdabacabadbabcbdbcbacbcdcacbabdabacadcbcdcacdbcbacbcdcacdcbdcdadbdcbca';
const G98A = 'abcacdcbcdcadbdcbdbabcbdcacbabdbabcabdadcdadbdcbdbabdbcbacbcdbabdcdbdcacdbcbacbcdcacdcbdcdadbdcbca';

const sigma = s => s.replace(/[abcd]/g, x => ({ a: 'b', b: 'c', c: 'd', d: 'a' })[x]);
const sigmaInv = s => s.replace(/[abcd]/g, x => ({ a: 'd', b: 'a', c: 'b', d: 'c' })[x]);

function cyclicMorphism(imgA, inverse = false) {
  const step = inverse ? sigmaInv : sigma;
  const m = { a: imgA };
  m.b = step(m.a); m.c = step(m.b); m.d = step(m.c);
  return m;
}
const g85 = cyclicMorphism(G85A);
const g98 = cyclicMorphism(G98A, true);

function apply(m, w) { let out = []; for (const x of w) out.push(m[x]); return out.join(''); }
function iterate(m, w, n) { for (let i = 0; i < n; i++) w = apply(m, w); return w; }

// Incremental abelian-square detector over an arbitrary alphabet.
// push(x) appends a letter and returns the smallest period p >= minP of an
// abelian square that is a suffix of the new word, or 0 if there is none.
class SquareChecker {
  constructor(alphabet, minP = 2, cap = 1 << 20) {
    this.idx = {}; [...alphabet].forEach((x, i) => (this.idx[x] = i));
    this.k = alphabet.length; this.minP = minP;
    this.P = Array.from({ length: this.k }, () => new Int32Array(cap + 1));
    this.n = 0; this.word = [];
  }
  push(x) {
    const j = this.idx[x], n = this.n, P = this.P;
    for (let t = 0; t < this.k; t++) P[t][n + 1] = P[t][n] + (t === j ? 1 : 0);
    this.n = n + 1; this.word.push(x);
    return this.suffixSquare();
  }
  pop() { this.n--; this.word.pop(); }
  suffixSquare() {
    const L = this.n, P = this.P, k = this.k;
    outer: for (let p = this.minP; 2 * p <= L; p++) {
      for (let t = 0; t < k; t++) {
        const A = P[t];
        if (A[L] - A[L - p] !== A[L - p] - A[L - 2 * p]) continue outer;
      }
      return p;
    }
    return 0;
  }
}

// Longest prefix of w avoiding abelian squares of period >= minP.
function longestFreePrefix(w, alphabet = 'abc', minP = 2) {
  const c = new SquareChecker(alphabet, minP, w.length + 1);
  for (let i = 0; i < w.length; i++) { const p = c.push(w[i]); if (p) return { len: i, period: p }; }
  return { len: w.length, period: 0 };
}

// All abelian squares (start, period) with period >= minP; brute force O(n^2).
function allSquares(w, alphabet = 'abc', minP = 2, maxP = Infinity) {
  const idx = {}; [...alphabet].forEach((x, i) => (idx[x] = i));
  const k = alphabet.length, n = w.length;
  const P = Array.from({ length: k }, () => new Int32Array(n + 1));
  for (let i = 0; i < n; i++) for (let t = 0; t < k; t++) P[t][i + 1] = P[t][i] + (idx[w[i]] === t ? 1 : 0);
  const res = [];
  for (let p = minP; 2 * p <= n && p <= maxP; p++)
    for (let s = 0; s + 2 * p <= n; s++) {
      let ok = true;
      for (let t = 0; t < k && ok; t++) ok = P[t][s + p] - P[t][s] === P[t][s + 2 * p] - P[t][s + p];
      if (ok) res.push([s, p]);
    }
  return res;
}

// Run-length profile, e.g. {1: 812, 2: 40, 3: 300}.
function runProfile(w) {
  const prof = {}; let i = 0;
  while (i < w.length) { let j = i; while (j < w.length && w[j] === w[i]) j++; prof[j - i] = (prof[j - i] || 0) + 1; i = j; }
  return prof;
}

module.exports = { G85A, G98A, g85, g98, sigma, apply, iterate, SquareChecker, longestFreePrefix, allSquares, runProfile };

// Pleasants' 5-letter a2f endomorphism (1970): g(a) = bacaeacadaeadab, cyclic shift a->b->c->d->e->a.
const PLA = 'bacaeacadaeadab';
const shift5 = s => s.replace(/[a-e]/g, x => 'bcdea'['abcde'.indexOf(x)]);
const pleasants = { a: PLA }; pleasants.b = shift5(pleasants.a); pleasants.c = shift5(pleasants.b); pleasants.d = shift5(pleasants.c); pleasants.e = shift5(pleasants.d);
module.exports.pleasants = pleasants;

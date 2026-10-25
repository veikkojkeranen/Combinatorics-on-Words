// Near misses inside g85^2(a):
//   uxv : |u| = |v|, Psi(u) = Psi(v), x a single letter (an abelian square "broken" by one letter);
//   uv  : |u| = |v|, Psi(u) - Psi(v) = e_x - e_y (u and v differ by one letter).
// Lists every occurrence, longest first, and saves the record ones.
'use strict';
const fs = require('fs'); const L = require('./lib');
const w = L.iterate(L.g85, 'a', 2), n = w.length;
const P = [0, 1, 2, 3].map(() => new Int32Array(n + 1));
for (let i = 0; i < n; i++) for (let t = 0; t < 4; t++) P[t][i + 1] = P[t][i] + ('abcd'.indexOf(w[i]) === t ? 1 : 0);
const vec = (s, e) => [0, 1, 2, 3].map(t => P[t][e] - P[t][s]);
const uxv = [], uv = [];
for (let p = 1; 2 * p + 1 <= n; p++)
  for (let s = 0; s + 2 * p + 1 <= n; s++) {          // u = w[s, s+p), x = w[s+p], v = w[s+p+1, s+2p+1)
    const a = vec(s, s + p), b = vec(s + p + 1, s + 2 * p + 1);
    if (a.every((x, t) => x === b[t])) uxv.push({ s, p });
  }
for (let p = 1; 2 * p <= n; p++)
  for (let s = 0; s + 2 * p <= n; s++) {              // u = w[s, s+p), v = w[s+p, s+2p)
    const a = vec(s, s + p), b = vec(s + p, s + 2 * p);
    let l1 = 0; for (let t = 0; t < 4; t++) l1 += Math.abs(a[t] - b[t]);
    if (l1 === 2) uv.push({ s, p });
  }
uxv.sort((x, y) => y.p - x.p); uv.sort((x, y) => y.p - x.p);
console.log(`g85^2(a): length ${n}; uxv occurrences ${uxv.length}, uv occurrences ${uv.length}`);
console.log('longest uxv periods:', uxv.slice(0, 8).map(o => `${o.p}@${o.s + 1}`).join(', '));
console.log('longest uv periods :', uv.slice(0, 8).map(o => `${o.p}@${o.s + 1}`).join(', '));
module.exports = { w, uxv, uv, vec };
if (require.main === module) {
  const out = { g85sq_length: n };
  for (const o of uxv.filter(o => o.p === 771)) {
    const u = w.slice(o.s, o.s + o.p), x = w[o.s + o.p], v = w.slice(o.s + o.p + 1, o.s + 2 * o.p + 1);
    (out.uxv771 = out.uxv771 || []).push({ start1: o.s + 1, x, xPos1: o.s + o.p + 1, u, v, parikh: vec(o.s, o.s + o.p) });
  }
  for (const o of uv.filter(o => o.p === 1153)) {
    const u = w.slice(o.s, o.s + o.p), v = w.slice(o.s + o.p, o.s + 2 * o.p);
    const a = vec(o.s, o.s + o.p), b = vec(o.s + o.p, o.s + 2 * o.p);
    (out.uv1153 = out.uv1153 || []).push({ start1: o.s + 1, u, v, parikhU: a, parikhV: b,
      diff: 'abcd'.split('').map((c, t) => a[t] - b[t] ? `${c}:${a[t] - b[t] > 0 ? '+' : ''}${a[t] - b[t]}` : '').filter(Boolean).join(' ') });
  }
  fs.mkdirSync('data/nearmiss', { recursive: true });
  fs.writeFileSync('data/nearmiss/g85sq_near_misses.json', JSON.stringify(out, null, 1));
  for (const k of ['uxv771', 'uv1153']) for (const o of out[k] || [])
    console.log(k, 'start', o.start1, k === 'uxv771' ? `x='${o.x}' at ${o.xPos1}, Psi(u)=Psi(v)=${o.parikh}` : `Psi(u)=${o.parikhU} Psi(v)=${o.parikhV} diff ${o.diff}`,
      '\n  u starts', o.u.slice(0, 40), '... ends', o.u.slice(-20), '\n  v starts', o.v.slice(0, 40), '... ends', o.v.slice(-20));
}

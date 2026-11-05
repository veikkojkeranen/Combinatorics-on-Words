// Haar view: H_p(i) = Psi(w[i..i+p)) - Psi(w[i+p..i+2p)); abelian square <=> H = 0.
// Clearance profile: for each p, number of positions with ||H||_1 = 2 (one-letter near misses), and minimum.
'use strict';
const L = require('../lib');
let w = 'a'; for (let k = 0; k < 2; k++) w = [...w].map(c => L.g85[c]).join('');
function profile(w, k, P) {
  const n = w.length, idx = c => c.charCodeAt(0) - 97, pre = [new Int32Array(k)];
  for (let j = 0; j < n; j++) { const v = Int32Array.from(pre[j]); v[idx(w[j])]++; pre.push(v); }
  const out = [];
  for (let p = 1; p <= P; p++) {
    let zero = 0, two = 0, tot = 0;
    for (let i = 0; i + 2 * p <= n; i++) { let s = 0; for (let c = 0; c < k; c++) s += Math.abs(2 * pre[i + p][c] - pre[i][c] - pre[i + 2 * p][c]); tot++; if (!s) zero++; else if (s === 2) two++; }
    out.push({ p, zero, two, tot });
  }
  return out;
}
const rnd = (n, k, seed = 1) => { let s = seed, r = ''; for (let i = 0; i < n; i++) { s = (s * 1103515245 + 12345) % 2147483648; r += 'abcd'[Math.floor(s / 2147483648 * k)]; } return r; };
for (const [name, ww, k] of [['g85^2(a)', w, 4], ['random4', rnd(7225, 4), 4]]) {
  const pr = profile(ww, k, 2000);
  const z = pr.reduce((s, r) => s + r.zero, 0);
  const bands = [[1, 10], [11, 100], [101, 500], [501, 2000]].map(([a, b]) => { const sl = pr.filter(r => r.p >= a && r.p <= b); const t = sl.reduce((s, r) => s + r.tot, 0); return `p${a}-${b}: near-miss share ${(sl.reduce((s, r) => s + r.two, 0) / t * 100).toFixed(2)}%`; });
  console.log(name, 'abelian squares (p<=2000):', z, '|', bands.join('; '));
}

// Cyclic ternary morphisms h(a)=u, h(b)=s(u), h(c)=s^2(u) (s: a->b->c->a). Search u (starting with a)
// such that the fixed point h^omega(a) is aa2f on a long prefix. Also report the Eisenstein multiplier
// mu = sum over u of omega^x (the eigenvalue of the circulant Parikh matrix on the plane).
'use strict';
const s = c => 'bca'['abc'.indexOf(c)];
const H = u => ({ a: u, b: [...u].map(s).join(''), c: [...u].map(c => s(s(c))).join('') });
function aa2fUpTo(w, N) {           // true if w[0..N) has no abelian square with p >= 2
  N = Math.min(N, w.length); const pre = [[0, 0, 0]];
  for (let j = 0; j < N; j++) { const v = pre[j].slice(); v['abc'.indexOf(w[j])]++; pre.push(v);
    const n = j + 1;
    for (let p = 2; 2 * p <= n; p++) { const i = n - 2 * p, A = pre[i], B = pre[n - p], C = pre[n];
      if (2 * B[0] === A[0] + C[0] && 2 * B[1] === A[1] + C[1] && 2 * B[2] === A[2] + C[2]) return false; } }
  return true;
}
const fixed = (h, N) => { let w = 'a'; while (w.length < N) { const nw = [...w].map(c => h[c]).join(''); if (nw === w) break; w = nw; } return w.slice(0, N); };
const Lmax = +process.argv[2] || 12, found = [];
for (let L = 2; L <= Lmax; L++) {
  let cand = 0, surv = 0;
  const rec = u => {
    if (u.length === L) { cand++; const h = H(u); let ok = true;
      for (const N of [60, 400, 2500]) if (!aa2fUpTo(fixed(h, N), N)) { ok = false; break; }
      if (ok) { surv++; found.push(u); } return; }
    for (const c of 'abc') { const v = u + c; if (aa2fUpTo(v, v.length)) rec(v); }
  };
  rec('a');
  console.log(`L=${L}: aa2f candidates ${cand}, fixed point aa2f up to 2500: ${surv}`);
}
const mu = u => { let x = 0, y = 0; for (const c of u) { const k = 'abc'.indexOf(c); x += Math.cos(2 * Math.PI * k / 3); y += Math.sin(2 * Math.PI * k / 3); } return [x.toFixed(2), y.toFixed(2), Math.hypot(x, y).toFixed(3)]; };
for (const u of found.slice(0, 20)) console.log(u, 'mu =', mu(u).join(' '));

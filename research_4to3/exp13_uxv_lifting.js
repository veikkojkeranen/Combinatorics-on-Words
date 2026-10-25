// Lifting uxv near misses through g85.
// Let w' = g85(w). A uxv factor of w' that is longer than a few blocks cuts the
// block structure as
//     u = suf_alpha(g(p)) g(U) pre_beta(g(y)),   x = g(y)[beta],
//     v = g(y)[beta+1..84] g(V) pre_gamma(g(q)),
// for a factor p U y V q of w. With A the Parikh matrix of g85 (invertible),
//     Psi(u) = Psi(v)  <=>  A (Psi(V) - Psi(U)) = L,
// where L = Psi(suf_alpha g(p)) + Psi(pre_beta g(y)) - Psi(g(y)[beta+1..]) - Psi(pre_gamma g(q))
// depends only on the junction (p, y, q, alpha, beta, gamma). So every uxv of w'
// comes from a factor p U y V q of w whose imbalance delta = Psi(V) - Psi(U)
// equals A^{-1} L for some junction, i.e. from an exact uxv of w (delta = 0)
// or from a near miss of w (delta != 0, small).
'use strict';
const fs = require('fs'); const L = require('./lib');
const G = L.g85, LET = 'abcd';
const psi = s => { const v = [0, 0, 0, 0]; for (const c of s) v[LET.indexOf(c)]++; return v; };
const A = LET.split('').map(r => LET.split('').map(c => psi(G[c])[LET.indexOf(r)]));   // A[r][c] = |g(c)|_r

// exact rational inverse via fractions over BigInt-free integers (4x4 Gauss-Jordan with numbers is exact enough here; we verify)
function solve(Amat, b) {                     // returns integer x with A x = b, or null
  const n = 4, M = Amat.map((row, i) => [...row, b[i]]);
  for (let c = 0; c < n; c++) {
    let piv = c; for (let r = c; r < n; r++) if (Math.abs(M[r][c]) > Math.abs(M[piv][c])) piv = r;
    [M[c], M[piv]] = [M[piv], M[c]];
    for (let r = 0; r < n; r++) if (r !== c) { const f = M[r][c] / M[c][c]; for (let k = c; k <= n; k++) M[r][k] -= f * M[c][k]; }
  }
  const x = M.map((row, i) => row[n] / row[i]);
  const xi = x.map(Math.round);
  for (let i = 0; i < n; i++) { let s = 0; for (let j = 0; j < n; j++) s += Amat[i][j] * xi[j]; if (s !== b[i]) return null; }
  return xi;
}

// junctions for one triple (p, y, q): all (alpha, beta, gamma) with an integral delta
function junctions(p, y, q) {
  const gp = G[p], gy = G[y], gq = G[q], out = [];
  // alpha in 1..85 (u starts at offset 85-alpha of g(p)) and gamma in 0..84 make the decomposition unique
  for (let alpha = 1; alpha <= 85; alpha++) for (let beta = 0; beta <= 84; beta++) for (let gamma = 0; gamma <= 84; gamma++) {
    const diff = alpha + 2 * beta - gamma - 84;          // = 85 (|V| - |U|)
    if (diff % 85) continue;
    const m = diff / 85;
    const Lv = psi(gp.slice(85 - alpha) + gy.slice(0, beta)).map((t, i) => t - psi(gy.slice(beta + 1) + gq.slice(0, gamma))[i]);
    const delta = solve(A, Lv);
    if (delta && delta.reduce((s, t) => s + t, 0) === m) out.push({ alpha, beta, gamma, m, delta, half: alpha + beta });
  }
  return out;
}

const J = {};
for (const p of LET) for (const y of LET) for (const q of LET) J[p + y + q] = junctions(p, y, q);
module.exports = { A, J, psi, solve };

if (require.main === module) {
  console.log('Parikh matrix A (columns = Psi(g85(x))):', JSON.stringify(A));
  const key = d => d.join(',');
  let tot = 0; const deltas = new Map();
  for (const [t, js] of Object.entries(J)) { tot += js.length; for (const j of js) deltas.set(key(j.delta), (deltas.get(key(j.delta)) || 0) + 1); }
  console.log(`junction solutions over all 64 triples: ${tot}; distinct delta values: ${deltas.size}`);
  console.log('  delta (=Psi(V)-Psi(U)) : count', [...deltas].sort((a, b) => b[1] - a[1]).slice(0, 12).map(([d, c]) => `(${d}):${c}`).join('  '));
  for (const t of ['adc', 'cab']) {
    const ex = J[t].filter(j => j.delta.every(z => z === 0));
    console.log(`\ntriple (p,y,q)=(${t.split('').join(',')}): ${J[t].length} junctions, ${ex.length} with delta = 0 (exact local uxv in g85(${t[0]})g85(${t[1]})g85(${t[2]}))`);
    for (const j of ex) {
      const W = G[t[0]] + G[t[1]] + G[t[2]], s = 85 - j.alpha, xp = 85 + j.beta;
      const u = W.slice(s, xp), x = W[xp], v = W.slice(xp + 1, xp + 1 + u.length);
      console.log(`  alpha=${j.alpha} beta=${j.beta} gamma=${j.gamma}: |u|=|v|=${u.length}, x='${x}' (position ${xp + 1} of W), Psi(u)=${psi(u)} Psi(v)=${psi(v)}`);
    }
    const near = J[t].filter(j => j.delta.some(z => z)).sort((a, b) => a.delta.reduce((s, z) => s + Math.abs(z), 0) - b.delta.reduce((s, z) => s + Math.abs(z), 0));
    console.log(`  junctions with delta != 0 (need a near miss one level down): ${near.length}; e.g.`, near.slice(0, 5).map(j => `a${j.alpha}/b${j.beta}/g${j.gamma} delta=(${j.delta})`).join('; '));
  }
}

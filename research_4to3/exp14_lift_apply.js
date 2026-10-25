// Apply the lifting rule of exp13: all uxv of g85(w) with |u| >= 85, from w.
'use strict';
const fs = require('fs'); const L = require('./lib'); const { J, psi } = require('./exp13_uxv_lifting');
const LET = 'abcd';
const idx = new Map();                                   // key "pyq|m|delta" -> junctions
for (const [t, js] of Object.entries(J)) for (const j of js) {
  const k = `${t}|${j.m}|${j.delta}`; if (!idx.has(k)) idx.set(k, []); idx.get(k).push(j);
}
function lift(w) {
  const n = w.length, P = [0, 1, 2, 3].map(() => new Int32Array(n + 1));
  for (let i = 0; i < n; i++) for (let t = 0; t < 4; t++) P[t][i + 1] = P[t][i] + (LET.indexOf(w[i]) === t ? 1 : 0);
  const res = [];
  for (let c = 1; c < n - 1; c++) for (let k = 0; c - k - 1 >= 0; k++) for (const m of [-1, 0, 1]) {
    const kv = k + m; if (kv < 0 || c + kv + 1 >= n) continue;
    const delta = [0, 1, 2, 3].map(t => (P[t][c + 1 + kv] - P[t][c + 1]) - (P[t][c] - P[t][c - k]));
    const js = idx.get(`${w[c - k - 1]}${w[c]}${w[c + kv + 1]}|${m}|${delta}`); if (!js) continue;
    for (const j of js) res.push({ start: 85 * (c - k - 1) + 85 - j.alpha, half: j.alpha + 85 * k + j.beta, xAt: 85 * c + j.beta,
                                   from: { c, k, m, delta, triple: w[c - k - 1] + w[c] + w[c + kv + 1] } });
  }
  return res;
}
module.exports = { lift };

if (require.main === module) {
  // 1) validation: lift g85(a) and compare with brute force on g85^2(a)
  const w1 = L.G85A, w2 = L.iterate(L.g85, 'a', 2);
  const lifted = lift(w1).filter(r => r.half >= 85);
  const n = w2.length, P = [0, 1, 2, 3].map(() => new Int32Array(n + 1));
  for (let i = 0; i < n; i++) for (let t = 0; t < 4; t++) P[t][i + 1] = P[t][i] + (LET.indexOf(w2[i]) === t ? 1 : 0);
  const brute = [];
  for (let p = 85; 2 * p + 1 <= n; p++) for (let s = 0; s + 2 * p + 1 <= n; s++) {
    let ok = true; for (let t = 0; t < 4 && ok; t++) ok = P[t][s + p] - P[t][s] === P[t][s + 2 * p + 1] - P[t][s + p + 1];
    if (ok) brute.push(`${s}:${p}`);
  }
  const ls = new Set(lifted.map(r => `${r.start}:${r.half}`)), bs = new Set(brute);
  const missing = [...bs].filter(x => !ls.has(x)), extra = [...ls].filter(x => !bs.has(x));
  console.log(`validation on g85^2(a): brute force uxv with |u|>=85: ${bs.size}; lifted: ${ls.size}; missing ${missing.length}, extra ${extra.length}`);

  // 2) prediction for g85^3(a), lifted from g85^2(a)
  const t0 = Date.now(); const L3 = lift(w2).filter(r => r.half >= 85).sort((a, b) => b.half - a.half);
  console.log(`g85^3(a) (length ${85 ** 3}): uxv with |u|>=85 found by lifting: ${L3.length} (${Date.now() - t0} ms)`);
  const top = L3.slice(0, 12);
  for (const r of top) console.log(`  |u|=|v|=${r.half}, u starts at ${r.start + 1}, x at ${r.xAt + 1}; from level-2 factor p U y V q with triple ${r.from.triple}, |U|=${r.from.k}, m=${r.from.m}, delta=(${r.from.delta})`);
  // how many come from exact level-2 uxv (delta = 0) vs from near misses (delta != 0)
  const ex = L3.filter(r => r.from.delta.every(z => z === 0)).length;
  console.log(`  from exact uxv one level down: ${ex}; from near misses (delta != 0): ${L3.length - ex}`);
  const hist = {}; for (const r of L3) { const b = r.half >= 60000 ? '>=60000' : r.half >= 10000 ? '10000-59999' : r.half >= 1000 ? '1000-9999' : '85-999'; hist[b] = (hist[b] || 0) + 1; }
  console.log('  length histogram:', JSON.stringify(hist));
  fs.mkdirSync('data/nearmiss', { recursive: true });
  fs.writeFileSync('data/nearmiss/g85cube_uxv_lifted_top.json', JSON.stringify(L3.slice(0, 200), null, 1));
}

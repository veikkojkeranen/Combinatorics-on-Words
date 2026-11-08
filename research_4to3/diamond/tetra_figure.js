// Generates the tetrahedron figure of section 4 (parallel projection) and writes it into template.html.
// Usage: node tetra_figure.js template.html   (on a rerun it only replaces the svg; AL and BE env vars set the view)
const fs = require('fs');
const s = Math.sqrt(8) / 3, T = { A: [0, 1, 0] };
[['C', 0], ['G', 1], ['T', 2]].forEach(([x, j]) => { const t = (90 + 120 * j) * Math.PI / 180; T[x] = [s * Math.cos(t), -1 / 3, s * Math.sin(t)]; });
const add = (a, b) => a.map((x, i) => x + b[i]), sub = (a, b) => a.map((x, i) => x - b[i]), mul = (a, k) => a.map(x => x * k);
const dot = (a, b) => a.reduce((s, x, i) => s + x * b[i], 0), nrm = a => mul(a, 1 / Math.hypot(...a));
const cr = (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
const u = nrm(add(T.A, T.T)), e1 = nrm(sub(T.A, T.T)), e2 = nrm(sub(T.C, T.G));
const al = +(process.env.AL || 0), be = +(process.env.BE || 0.25);
const X = nrm(add(mul(u, Math.cos(al)), mul(e2, Math.sin(al))));
const Y0 = add(mul(e1, Math.cos(be)), mul(cr(X, e1), Math.sin(be))), Y = nrm(sub(Y0, mul(X, dot(Y0, X))));
const R = 165, ox = 300, oy = 200, Zd = cr(X, Y), depth = p => dot(p, Zd);
const P = p => [ox + R * dot(p, X), oy - R * dot(p, Y)];
const f = v => v.toFixed(1);
const O = P([0, 0, 0]), V = {}; for (const k of 'ACGT') V[k] = P(T[k]);
const MAT = P(mul(add(T.A, T.T), .5)), MCG = P(mul(add(T.C, T.G), .5)), S = P(add(T.A, T.T));
const line = (p, q, cls, extra = '') => `<line x1="${f(p[0])}" y1="${f(p[1])}" x2="${f(q[0])}" y2="${f(q[1])}" ${cls}${extra}/>`;
function arrow(p, q, col, w = 2.2) {
  const dx = q[0] - p[0], dy = q[1] - p[1], L = Math.hypot(dx, dy), ux = dx / L, uy = dy / L, hl = 11, hw = 4.5;
  const b = [q[0] - ux * hl, q[1] - uy * hl];
  return `<line x1="${f(p[0])}" y1="${f(p[1])}" x2="${f(b[0])}" y2="${f(b[1])}" stroke="${col}" stroke-width="${w}"/>` +
    `<polygon points="${f(q[0])},${f(q[1])} ${f(b[0] - uy * hw)},${f(b[1] + ux * hw)} ${f(b[0] + uy * hw)},${f(b[1] - ux * hw)}" fill="${col}"/>`;
}
const off = (p, k) => [O[0] + (p[0] - O[0]) * k, O[1] + (p[1] - O[1]) * k];
const txt = (p, t, extra = '') => `<text x="${f(p[0])}" y="${f(p[1])}"${extra}>${t}</text>`;
// the line l through M_CG and M_AT, extended
const d = [MAT[0] - MCG[0], MAT[1] - MCG[1]], l0 = [20, MCG[1] + (20 - MCG[0]) * d[1] / d[0]], l1 = [620, MCG[1] + (620 - MCG[0]) * d[1] / d[0]];
const g = [];
g.push(`<svg viewBox="0 0 640 400" role="img" aria-label="Regular tetrahedron ACGT with centre O, the unit step vectors, the midpoints of the opposite edges AT and CG, the line through them and the sum t_A + t_T">`);
g.push(line(l0, l1, 'class="tf-l"'));
// edges: AG is hidden behind CT
const cross = (p, q, r2, s2) => { const o = (a, b, c) => Math.sign((b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])); return o(p, q, r2) !== o(p, q, s2) && o(r2, s2, p) !== o(r2, s2, q); };
const hid = new Set();
for (const [e, o] of [['AT', 'CG'], ['AC', 'GT'], ['AG', 'CT']]) if (cross(V[e[0]], V[e[1]], V[o[0]], V[o[1]])) {
  const de = depth(T[e[0]]) + depth(T[e[1]]), dd = depth(T[o[0]]) + depth(T[o[1]]); hid.add(de < dd ? e : o); }
console.error('hidden', [...hid]);
for (const e of ['AC', 'AG', 'AT', 'CG', 'CT', 'GT']) g.push(line(V[e[0]], V[e[1]], 'class="tf-e"', hid.has(e) ? ' stroke-dasharray="4 4"' : ''));
// parallelogram for t_A + t_T
g.push(line(V.A, S, 'class="tf-p"'), line(V.T, S, 'class="tf-p"'));
// unit vectors
const COL = { A: 'var(--la)', C: 'var(--lb)', G: 'var(--lc)', T: 'var(--ld)' };
for (const k of 'ACGT') g.push(arrow(O, V[k], COL[k]));
g.push(arrow(O, S, 'var(--hl-edge)', 2.6));
// points
for (const p of [MAT, MCG]) g.push(`<circle cx="${f(p[0])}" cy="${f(p[1])}" r="4" class="tf-m"/>`);
g.push(`<circle cx="${f(O[0])}" cy="${f(O[1])}" r="4" class="tf-o"/>`);
// labels
g.push('<g class="tf-t">');
for (const k of 'ACGT') g.push(txt(off(V[k], 1.13), k, ' class="tf-v" text-anchor="middle" dominant-baseline="middle"'));
const lab = { A: [-30, 18], C: [-6, -12], G: [6, 26], T: [-30, -10] };
for (const k of 'ACGT') { const m = off(V[k], 0.62); g.push(txt([m[0] + lab[k][0], m[1] + lab[k][1]], `<tspan font-style="italic">t</tspan><tspan baseline-shift="sub" font-size="12">${k}</tspan>`)); }
g.push(txt([O[0] - 6, O[1] + 22], 'O', ' text-anchor="end"'));
g.push(txt([MAT[0] + 8, MAT[1] - 9], `<tspan font-style="italic">M</tspan><tspan baseline-shift="sub" font-size="12">AT</tspan>`));
g.push(txt([MCG[0] - 8, MCG[1] - 10], `<tspan font-style="italic">M</tspan><tspan baseline-shift="sub" font-size="12">CG</tspan>`, ' text-anchor="end"'));
g.push(txt([S[0] - 4, S[1] - 14], `<tspan font-style="italic">t</tspan><tspan baseline-shift="sub" font-size="12">A</tspan> + <tspan font-style="italic">t</tspan><tspan baseline-shift="sub" font-size="12">T</tspan>`, ' class="tf-s"'));
g.push(txt([S[0] - 4, S[1] + 24], 'length 2/√3', ' class="tf-s tf-small"'));
g.push(txt([l0[0] + 6, l0[1] - 10], 'ℓ', ' font-style="italic" font-size="18"'));
g.push('</g></svg>');
const svg = g.join('\n');

const f2 = process.argv[2]; let src = fs.readFileSync(f2, 'utf8');
if (src.includes('<figure class="tfig">')) {   // rerun: replace only the svg
  const a = src.indexOf('<figure class="tfig">\n') + '<figure class="tfig">\n'.length, b = src.indexOf('\n<figcaption>', a);
  src = src.slice(0, a) + svg + src.slice(b); fs.writeFileSync(f2, src); console.log('svg replaced'); process.exit(0);
}
const rep = (a, b) => { const n = src.split(a).length - 1; if (n !== 1) throw new Error('count ' + n + ' for: ' + a.slice(0, 70)); src = src.replace(a, () => b); };
const sub_ = (x, y) => `<i>${x}</i><sub>${y}</sub>`;
const tA = sub_('t', 'A'), tC = sub_('t', 'C'), tG = sub_('t', 'G'), tT = sub_('t', 'T');
rep(`<ol class="refs">`, `<h3>Why |${tA} + ${tT}| = 2/√3</h3>
<p>The four step vectors ${tA}, ${tC}, ${tG}, ${tT} (${sub_('t', 'a')}, ${sub_('t', 'b')}, ${sub_('t', 'c')}, ${sub_('t', 'd')} on this page) are <b>unit vectors</b>: each points from the centre <i>O</i> of a regular tetrahedron to one of its vertices A, C, G, T, and the tetrahedron is scaled so that this distance is 1. In the coordinates of the page, ${sub_('t', 'A')} = (0, 1, 0), and ${tC}, ${tG}, ${tT} point down to the base, each with height −1/3.</p>
<figure class="tfig">
${svg}
<figcaption>The regular tetrahedron ACGT with centre <i>O</i> and the four unit step vectors. ${tA} + ${tT} (violet) is the diagonal of the parallelogram spanned by ${tA} and ${tT}. It runs along the line ℓ through the midpoints <i>M</i><sub>AT</sub> and <i>M</i><sub>CG</sub> of the opposite edges AT and CG; the hidden edge AG is dashed. The picture is a parallel projection, so lengths and angles are not to scale.</figcaption>
</figure>
<ol class="steps">
  <li><b>Each step has length 1</b>, so ${tA}·${tA} = ${tC}·${tC} = ${tG}·${tG} = ${tT}·${tT} = 1.</li>
  <li><b>Any two different steps have dot product −1/3.</b> The four vectors add up to zero, so the square of their sum is zero:
    <p class="eq">0 = |${tA} + ${tC} + ${tG} + ${tT}|² = (sum of the four |${sub_('t', 'x')}|²) + 2 · (sum of the six products ${sub_('t', 'x')}·${sub_('t', 'y')}).</p>
    By the symmetry of the tetrahedron all six products have the same value <i>c</i>, so 0 = 4 + 12<i>c</i> and <i>c</i> = −1/3. This is the tetrahedral angle arccos(−1/3) ≈ 109.47° between any two steps. In the coordinates above, ${tA}·${tT} is simply the height of ${tT}, −1/3.</li>
  <li><b>The length of the sum:</b>
    <p class="eq">|${tA} + ${tT}|² = |${tA}|² + |${tT}|² + 2 ${tA}·${tT} = 1 + 1 − 2/3 = 4/3, so |${tA} + ${tT}| = √(4/3) = 2/√3 ≈ 1.1547.</p>
    The same holds for every pair of letters; in particular ${tC} + ${tG} = −(${tA} + ${tT}) has the same length.</li>
</ol>
<p><b>Geometric meaning.</b> The midpoint of the edge AT is <i>M</i><sub>AT</sub> = (${tA} + ${tT})/2, at distance 1/√3 from <i>O</i>, and the midpoint of the opposite edge CG is <i>M</i><sub>CG</sub> = (${tC} + ${tG})/2 = −<i>M</i><sub>AT</sub>. So ℓ passes through <i>M</i><sub>CG</sub>, <i>O</i> and <i>M</i><sub>AT</sub>, and one step along ℓ, |${tA} + ${tT}| = 2/√3, is the distance between the midpoints of the opposite edges AT and CG. For comparison, an edge has length |${tA} − ${tT}| = √(1 + 1 + 2/3) = √(8/3) ≈ 1.633, so the step along ℓ is the edge length divided by √2.</p>
<ol class="refs">`);
rep(`  .ov{ text-decoration:overline; }`, `  .ov{ text-decoration:overline; }
  .tfig{ margin:18px 0; max-width:820px; } .tfig svg{ display:block; width:100%; max-width:640px; height:auto; margin:0 auto; background:var(--fig); border:1px solid var(--rule); border-radius:6px; }
  .tfig figcaption{ font-size:15px; color:var(--ink-soft); margin-top:8px; }
  .tf-e{ stroke:var(--ink-faint); stroke-width:1.4; } .tf-l{ stroke:var(--hl-edge); stroke-width:1.2; stroke-dasharray:7 5; opacity:.8; }
  .tf-p{ stroke:var(--ink-faint); stroke-width:1; stroke-dasharray:3 3; }
  .tf-m{ fill:var(--fig); stroke:var(--hl-edge); stroke-width:2; } .tf-o{ fill:var(--ink); }
  .tf-t{ fill:var(--ink); font-family:'STIX Two Text',Georgia,serif; font-size:17px; } .tf-v{ font-weight:700; font-size:19px; }
  .tf-s{ fill:var(--hl-edge); } .tf-small{ font-size:14px; }
  ol.steps{ max-width:820px; } ol.steps li{ margin:10px 0; } .eq{ margin:6px 0 6px 1em; }`);
fs.writeFileSync(f2, src); console.log('ok');

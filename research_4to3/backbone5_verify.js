// Independent check of a backbone result: iterate H directly, decorate with the
// rule, and test the ternary word (aa2fr) and the backbone (a2f) from scratch.
'use strict';
const L = require('./lib');

function decorate(H, R, start, n, rule) {
  let w = start; while (w.length < n) { const nw = [...w].map(x => H[x]).join(''); if (nw.length <= w.length) break; w = nw; }
  w = w.slice(0, n);
  if (w.includes('?')) w = w.slice(0, w.indexOf('?'));   // stop where an image letter is still unset
  const [rtype, rarg] = rule.split(':'), l = +rarg || 0;
  // parent/offset of each position for 'slot' rules
  const out = [], par = [], off = [];
  if (rtype === 'slot') { let p = 0, o = 0; for (let i = 0; i < w.length; i++) { par.push(p); off.push(o); o++; if (o === H[w[p]].length) { p++; o = 0; } } }
  for (let i = 0; i < w.length; i++) {
    const x = w[i];
    if (x !== 'Q') { out.push({ P: 'a', R: 'aaa', S: 'bbb', T: 'ccc' }[x]); continue; }
    const key = rtype === 'slot' ? w[par[i]] + '@' + off[i] : w.slice(Math.max(0, i - l), i).padStart(l, 'P');
    if (!(key in R)) return { backbone: w.slice(0, i), ternary: out.join(''), undefinedAt: i, key };
    out.push(R[key]);
  }
  return { backbone: w, ternary: out.join('') };
}

function verify(H, R, start, n, rule) {
  const d = decorate(H, R, start, n, rule);
  const t = d.ternary, mol = t.match(/(a+|b+|c+)/g) || [];
  return {
    backboneLen: d.backbone.length, ternaryLen: t.length,
    runsOk: mol.every(r => r.length === 1 || r.length === 3),
    aa2fPrefix: L.longestFreePrefix(t, 'abc', 2).len,
    backboneA2FPrefix: L.longestFreePrefix(d.backbone, 'PQRST', 1).len,
    undefinedAt: d.undefinedAt, ternary: t, backbone: d.backbone,
  };
}
module.exports = { verify, decorate };

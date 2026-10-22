// Search for a morphism h on the molecule alphabet whose fixed point h^omega(a)
// has an aa2f(r) ternary image.
// Molecules are (base, width): base a,b,c; widths {1,3} (aa2fr) or {1,2,3} (aa2f).
// sym = 'cyclic': h commutes with tau (a->b->c->a), so only the images h(a^w) are
//                 unknown (as for g85, whose images are obtained by a cyclic shift);
// sym = 'none'  : every molecule has its own image.
// The images are filled lazily while the fixed point is generated: position i of
// the fixed point lies in the image of an earlier position, so its letter is
// either already determined or is a new unknown chosen by the depth-first search.
'use strict';
const L = require('./lib');

function search({ widths = [1, 3], lens = { 1: 6, 3: 6 }, sym = 'cyclic', timeMs = 20000, maxMol = 200000 } = {}) {
  const W = widths.length, nMol = 3 * W;
  const base = id => (id / W) | 0, type = id => id % W;
  const molStr = id => 'abc'[base(id)].repeat(widths[type(id)]);
  const tauPow = (id, k) => ((base(id) + k) % 3) * W + type(id);
  const imgLen = id => lens[widths[type(id)]];
  // slot table: one unknown per (image owner, offset)
  const owners = sym === 'cyclic' ? W : nMol, ownerOf = id => (sym === 'cyclic' ? type(id) : id);
  const offs = []; let tot = 0;
  for (let t = 0; t < owners; t++) { offs.push(tot); tot += lens[widths[sym === 'cyclic' ? t : type(t)]]; }
  const img = new Int8Array(tot).fill(-1);

  const fx = new Int32Array(maxMol), par = new Int32Array(maxMol), blockStart = new Int32Array(maxMol + 1);
  const owner = new Uint8Array(maxMol), choice = new Int8Array(maxMol).fill(-1), pushed = new Int8Array(maxMol);
  const ch = new L.SquareChecker('abc', 2, maxMol * 3 + 4);
  const tryMol = (i, id) => {
    if (i > 0 && base(fx[i - 1]) === base(id)) return false;              // runs must stay maximal
    const s = molStr(id); let c = 0;
    for (const x of s) { c++; if (ch.push(x)) { for (; c > 0; c--) ch.pop(); return false; } }
    fx[i] = id; pushed[i] = c; return true;
  };

  let i = 0, best = 0, nodes = 0; const t0 = Date.now();
  while (i >= 0 && i < maxMol && Date.now() - t0 < timeMs) {
    // parent j of position i: the block h(fx[j]) containing i (fx[j] is known since j < i)
    let j = i === 0 ? 0 : par[i - 1];
    if (i > 0) while (blockStart[j] + imgLen(fx[j]) <= i) { blockStart[j + 1] = blockStart[j] + imgLen(fx[j]); j++; }
    par[i] = j;
    if (i > 0 && j >= i) break;                                            // h(a) too short to generate
    const slot = offs[ownerOf(fx[j] === undefined || i === 0 ? 0 : fx[j])] + (i - blockStart[j]);
    const frame = sym === 'cyclic' && i > 0 ? base(fx[j]) : 0;             // image letters stored in the a-frame
    let ok = false;
    if (img[slot] >= 0 && !owner[i]) { nodes++; ok = tryMol(i, tauPow(img[slot], frame)); }
    else {
      owner[i] = 1;
      for (let c = choice[i] + 1; c < nMol; c++) {
        nodes++;
        if (i === 0 && c !== 0) break;                                     // h(a) starts with a
        if (tryMol(i, tauPow(c, frame))) { choice[i] = c; img[slot] = c; ok = true; break; }
      }
      if (!ok) { owner[i] = 0; choice[i] = -1; img[slot] = -1; }
    }
    if (ok) { i++; if (ch.n > best) best = ch.n; }
    else { i--; while (i >= 0) { for (let c = pushed[i]; c > 0; c--) ch.pop(); if (owner[i]) break; i--; } }
  }
  const imgs = {};
  for (let t = 0; t < owners; t++) {
    const name = sym === 'cyclic' ? 'a'.repeat(widths[t]) : molStr(t);
    const n = lens[widths[sym === 'cyclic' ? t : type(t)]], s = [];
    for (let k = 0; k < n; k++) s.push(img[offs[t] + k] >= 0 ? molStr(img[offs[t] + k]) : '?');
    imgs[name] = s.join('.');
  }
  return { best, nodes, exhausted: i < 0, complete: i >= maxMol, imgs, word: ch.word.join(''), ms: Date.now() - t0 };
}
module.exports = { search };

if (require.main === module) {
  const restricted = process.argv[2] !== 'f';
  const sym = process.argv[3] || 'cyclic';
  const timeMs = +(process.argv[4] || 3000), lo = +(process.argv[5] || 2), hi = +(process.argv[6] || 10);
  const widths = restricted ? [1, 3] : [1, 2, 3];
  const rows = [];
  if (restricted) for (let p = Math.max(2, lo); p <= hi; p++) for (let q = lo; q <= hi; q++) rows.push({ 1: p, 3: q });
  else for (let p = Math.max(2, lo); p <= hi; p++) for (let q = lo; q <= hi; q++) for (let r = lo; r <= hi; r++) rows.push({ 1: p, 2: q, 3: r });
  const out = [];
  for (const lens of rows) out.push({ lens, ...search({ widths, lens, sym, timeMs }) });
  out.sort((a, b) => b.best - a.best);
  console.log(`${restricted ? 'aa2fr' : 'aa2f'} molecule morphisms, symmetry ${sym}, image lengths ${lo}..${hi}`);
  for (const r of out.slice(0, 8)) console.log(`  lens ${JSON.stringify(r.lens)}: best ternary ${r.best} ${r.exhausted ? 'EXHAUSTED' : 'timeout'} ${JSON.stringify(r.imgs)}`);
  console.log('  exhausted:', out.filter(r => r.exhausted).length, 'of', out.length);
}

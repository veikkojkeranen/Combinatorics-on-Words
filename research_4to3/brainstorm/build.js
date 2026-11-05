// Builds "Waves, wavelets and shadows - brainstorming methods for avoiding abelian repetitions.html"
// from template.html by inlining the ternary word aa2fr3268 and the morphism g98, and its companion
// "Haar scalograms of g85 and g98 at full resolution.html" from fullscale_template.html.
'use strict';
const fs = require('fs'), path = require('path');
const first = n => fs.readFileSync(path.join(__dirname, '..', 'data', `len${n}.txt`), 'utf8').trim().split(/\r?\n/)[0];
const g98 = JSON.stringify(require('../lib').g98);
const pages = [
  ['template.html', 'Waves, wavelets and shadows - brainstorming methods for avoiding abelian repetitions.html'],
  ['fullscale_template.html', 'Haar scalograms of g85 and g98 at full resolution.html'],
];
for (const [src, dst] of pages) {
  const out = path.join(__dirname, '..', '..', dst);
  const html = fs.readFileSync(path.join(__dirname, src), 'utf8').replace('__AA2FR3268__', () => first(3268)).replace('__G98__', () => g98);
  fs.writeFileSync(out, html);
  console.log('wrote', out, html.length, 'bytes');
}

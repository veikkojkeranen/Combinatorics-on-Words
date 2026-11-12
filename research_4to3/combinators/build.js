// Builds "Words as combinators - reading g85 and aa2f words as nested functions.html"
// in the repository root from template.html, inlining g85 from ../lib.js and the
// first 3268-letter aa2f word of ../data/len3268.txt.
'use strict';
const fs = require('fs'), path = require('path');
const { g85 } = require('../lib');
const aa2f = fs.readFileSync(path.join(__dirname, '..', 'data', 'len3268.txt'), 'utf8').split(/\r?\n/)[0].trim();
if (!/^[abc]{3268}$/.test(aa2f)) throw new Error('unexpected aa2f word');
const out = path.join(__dirname, '..', '..', 'Words as combinators - reading g85 and aa2f words as nested functions.html');
const html = fs.readFileSync(path.join(__dirname, 'template.html'), 'utf8')
  .replace('__G85__', () => JSON.stringify(g85)).replace('__AA2F__', () => aa2f);
fs.writeFileSync(out, html);
console.log('wrote', out, html.length, 'bytes');

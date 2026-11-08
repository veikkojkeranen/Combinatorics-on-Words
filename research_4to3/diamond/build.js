// Builds "Diamond walks of g85, g98 and g109.html" in the repository root
// from template.html, inlining the morphisms g85 and g98 from ../lib.js.
'use strict';
const fs = require('fs'), path = require('path');
const { g85, g98 } = require('../lib');
const out = path.join(__dirname, '..', '..', 'Diamond walks of g85, g98 and g109.html');
const html = fs.readFileSync(path.join(__dirname, 'template.html'), 'utf8')
  .replace('__G85__', () => JSON.stringify(g85)).replace('__G98__', () => JSON.stringify(g98));
fs.writeFileSync(out, html);
console.log('wrote', out, html.length, 'bytes');

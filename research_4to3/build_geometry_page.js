// Builds "Bending the string - a plane geometry for a2f and aa2f words.html" from
// geometry_page_template.html by inlining the two record ternary words.
'use strict';
const fs = require('fs');
const first = n => fs.readFileSync(`data/len${n}.txt`, 'utf8').trim().split(/\r?\n/)[0];
const html = fs.readFileSync('geometry_page_template.html', 'utf8')
  .replace('__AA2FR3268__', first(3268))
  .replace('__AA2F25379__', first(25379));
const out = '../Bending the string - a plane geometry for a2f and aa2f words.html';
fs.writeFileSync(out, html);
console.log('wrote', out, html.length, 'bytes');

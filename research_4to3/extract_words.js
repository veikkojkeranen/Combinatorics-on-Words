// Pull the long ternary words out of aa2f15796_aa2f25379_aa2fr1928+More.html.
'use strict';
const fs = require('fs');
const s = fs.readFileSync('../aa2f15796_aa2f25379_aa2fr1928+More.html', 'utf8').replace(/<[^>]+>/g, ' ');
const words = s.match(/[abc]{1000,}/g);
const byLen = {};
for (const w of words) (byLen[w.length] = byLen[w.length] || []).push(w);
fs.mkdirSync('data', { recursive: true });
for (const [n, ws] of Object.entries(byLen)) { fs.writeFileSync(`data/len${n}.txt`, ws.join('\n') + '\n'); console.log(n, ws.length); }

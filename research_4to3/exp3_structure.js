// Structure of the known words: verification, run profile, molecule (symbol) view.
'use strict';
const fs = require('fs'); const L = require('./lib');
const read = n => fs.readFileSync(`data/len${n}.txt`, 'utf8').trim().split('\n')[0];
// molecule word: a run x^k -> symbol x+k
const molecules = w => w.match(/(a+|b+|c+)/g).map(r => r[0] + r.length);
for (const n of [3268, 25379]) {
  const w = read(n);
  const t0 = Date.now(); const r = L.longestFreePrefix(w, 'abc', 2);
  console.log(`len ${n}: aa2f verified=${r.len === n} (${Date.now() - t0} ms) runs`, L.runProfile(w));
  const m = molecules(w); const freq = {}; m.forEach(x => (freq[x] = (freq[x] || 0) + 1));
  console.log('  molecule frequencies', freq, 'letter counts', [...'abc'].map(x => w.split(x).length - 1));
  // is the molecule word itself a2f over its own alphabet?
  const alph = Object.keys(freq).sort(); const code = {}; alph.forEach((x, i) => (code[x] = String.fromCharCode(65 + i)));
  const mw = m.map(x => code[x]).join('');
  const rr = L.longestFreePrefix(mw, alph.map(x => code[x]).join(''), 1);
  console.log(`  molecule word length ${mw.length}, a2f over ${alph.length} molecule letters: ${rr.len === mw.length} (prefix ${rr.len})`);
  console.log('  first 40 molecules:', m.slice(0, 40).join(' '));
}

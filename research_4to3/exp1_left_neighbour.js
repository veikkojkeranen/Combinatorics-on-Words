// Experiment 1: the "geometric approach" map  d -> left neighbour,
// applied to g85^n(a). How long is the aa2f prefix of the real ternary word w'?
'use strict';
const L = require('./lib');
const w = L.iterate(L.g85, 'a', 3);
console.log('g85^3(a) a2f prefix over abcd (expect full for short prefix):', L.longestFreePrefix(w.slice(0, 20000), 'abcd', 1));
for (const del of 'abcd') {
  let out = [];
  for (let i = 0; i < w.length && out.length < 60000; i++) out.push(w[i] === del ? out[out.length - 1] : w[i]);
  const s = out.join('').replace(new RegExp('^' + del + '+'), '');
  const map = {}; const rest = 'abcd'.replace(del, ''); [...rest].forEach((x, i) => (map[x] = 'abc'[i]));
  const t = s.replace(/./g, x => map[x]);
  const r = L.longestFreePrefix(t, 'abc', 2);
  console.log(`delete ${del} -> left neighbour: aa2f prefix length ${r.len}, first square period ${r.period}, runs`, L.runProfile(t.slice(0, r.len)));
}

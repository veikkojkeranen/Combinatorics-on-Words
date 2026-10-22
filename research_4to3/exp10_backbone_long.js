// Longer backbone runs: one image length, several random option orders.
// Usage: node exp10_backbone_long.js <rule> <a2f|free> <n> <seeds> <timeMs>
'use strict';
const { search, BB } = require('./backbone5'); const { verify } = require('./backbone5_verify');
const [rule, mode, n, seeds, timeMs] = [process.argv[2], process.argv[3], +process.argv[4], +process.argv[5], +process.argv[6]];
let top = null;
for (let seed = 0; seed < seeds; seed++) for (const start of [0, 2, 3, 4]) {
  const r = search({ lens: [n, n, n, n, n], start, rule, backboneA2F: mode === 'a2f', timeMs, seed, maxMol: 60000 });
  if (!top || r.beyond > top.beyond || (r.beyond === top.beyond && r.best > top.best)) top = { ...r, seed, start: BB[start] };
  console.log(`n=${n} seed=${seed} start=${BB[start]}: best ternary ${r.best}, longest forced streak ${r.beyond} molecules ${r.exhausted ? 'EXHAUSTED' : ''}`);
}
console.log('TOP', JSON.stringify({ n, rule, mode, best: top.best, beyond: top.beyond, seed: top.seed, start: top.start, snap: top.beyondSnap }));

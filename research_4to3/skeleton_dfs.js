// Skeleton-guided depth-first search.
// A 4-letter a2f word w (e.g. a prefix of the g85 fixed point) is used as a
// template: the letters a, b, c are kept, and every "wild" letter (d) is
// replaced by one of a set of short ternary words (possibly empty). We search
// for a choice per wild position such that the resulting ternary word is aa2f
// (or aa2fr: no maximal runs of length exactly 2).
'use strict';
const L = require('./lib');

function dfs(template, opts) {
  const { wild = 'd', options = ['', 'a', 'b', 'c'], restricted = false, maxNodes = 2e7,
          contextOptions = null, verbose = false } = opts;
  const ch = new L.SquareChecker('abc', 2, template.length * 3 + 10);
  const choice = new Int32Array(template.length).fill(-1);
  const pushed = new Int32Array(template.length);   // letters pushed for slot i
  let i = 0, nodes = 0, best = 0, bestWord = '', bestSlot = 0;

  // aa2fr: a run of length exactly 2 is forbidden once it is closed; runs of 4 are
  // already abelian squares of period 2.
  const runOk = () => {
    if (!restricted) return true;
    const w = ch.word, n = w.length;
    if (n < 3) return true;
    // the run that ended at n-2 is closed by w[n-1] != w[n-2]
    if (w[n - 1] === w[n - 2]) return true;
    let j = n - 2, len = 0; while (j >= 0 && w[j] === w[n - 2]) { j--; len++; }
    return len !== 2 || j < 0;   // allow a 2-run at the very start
  };
  const tryPush = s => {
    let k = 0;
    for (const x of s) { ch.word.length; const p = ch.push(x); k++; if (p || !runOk()) { for (; k > 0; k--) ch.pop(); return -1; } }
    return k;
  };
  const optionsAt = i => {
    if (contextOptions && (wild === null || template[i] === wild)) return contextOptions(template, i);
    return template[i] !== wild ? [template[i]] : options;
  };

  while (i >= 0 && i < template.length && nodes < maxNodes) {
    const opt = optionsAt(i);
    let c = choice[i] + 1, ok = false;
    for (; c < opt.length; c++) {
      nodes++;
      const k = tryPush(opt[c]);
      if (k >= 0) { pushed[i] = k; choice[i] = c; ok = true; break; }
    }
    if (ok) {
      i++;
      if (ch.n > best) { best = ch.n; bestSlot = i; if (verbose) process.stdout.write(`\r best ${best} at slot ${i}, nodes ${nodes}   `); }
    } else {
      choice[i] = -1; i--;
      if (i >= 0) for (let k = pushed[i]; k > 0; k--) ch.pop();
    }
  }
  bestWord = ''; // reconstruct is costly; return current word when finished
  return { complete: i >= template.length, word: ch.word.join(''), best, bestSlot, nodes,
           choices: Array.from(choice) };
}
module.exports = { dfs };

if (require.main === module) {
  const n = +(process.argv[2] || 2000);
  const w = L.iterate(L.g85, 'a', 3).slice(0, n);
  for (const [name, o] of [
    ['aa2f, d -> {e,a,b,c}', { options: ['', 'a', 'b', 'c'] }],
    ['aa2f, d -> {a,b,c}', { options: ['a', 'b', 'c'] }],
    ['aa2f, d -> {e,a,b,c,aa,bb,cc}', { options: ['', 'a', 'b', 'c', 'aa', 'bb', 'cc'] }],
    ['aa2fr, d -> {e,a,b,c,aa,bb,cc}', { options: ['', 'a', 'b', 'c', 'aa', 'bb', 'cc'], restricted: true }],
  ]) {
    const t0 = Date.now();
    const r = dfs(w, { ...o, maxNodes: 5e6 });
    console.log(`${name}: complete=${r.complete} best ternary length ${r.best} (template slot ${r.bestSlot}/${w.length}), nodes ${r.nodes}, ${Date.now() - t0} ms`);
  }
}

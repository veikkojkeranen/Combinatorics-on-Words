// Counting: ternary aa2f words (abelian squares only of period 1) and 4-letter a2f words, by length.
'use strict';
function count(k, minP, N) {
  const cnt = new Array(N + 1).fill(0), w = new Int8Array(N), pre = Array.from({ length: N + 1 }, () => new Int32Array(k));
  function ok(n) {               // word w[0..n) : does a new suffix abelian square with p >= minP appear?
    for (let p = minP; 2 * p <= n; p++) {
      const i = n - 2 * p; let eq = true;
      for (let c = 0; c < k && eq; c++) if (2 * pre[n - p][c] !== pre[i][c] + pre[n][c]) eq = false;
      if (eq) return false;
    }
    return true;
  }
  function rec(n) {
    cnt[n]++; if (n === N) return;
    for (let c = 0; c < k; c++) {
      if (n === 0 && c > 0) break;                    // fix first letter a (counts / k)
      w[n] = c; pre[n + 1].set(pre[n]); pre[n + 1][c]++;
      if (ok(n + 1)) rec(n + 1);
    }
  }
  rec(0); return cnt;
}
const t = Date.now();
const c3 = count(3, 2, +process.argv[2] || 40);
console.log('ternary aa2f (first letter a):', c3.slice(1).join(' '));
const r = []; for (let n = 10; n < c3.length; n += 5) r.push(`${n}:${(c3[n] / c3[n - 5]) ** (1 / 5)}`.slice(0, 10));
console.log('growth per letter:', r.join('  '), (Date.now() - t) + 'ms');

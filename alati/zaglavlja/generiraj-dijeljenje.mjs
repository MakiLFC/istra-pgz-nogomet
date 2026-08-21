// Slika za dijeljenje na društvenim mrežama (public/slike/dijeljenje.png).
//
// Koristi ISTI predložak kao zaglavlja liga (zaglavlje.html), samo u
// omjeru 1200x630, koji traže Facebook i ostali. Zato se ne crta zasebno:
// kad se promijeni krajolik ili paleta u zaglavlje.html, promijeni se i
// ova slika.
//
// POKRETANJE (u ovoj mapi):
//   python3 -m http.server 8098
//   node generiraj-dijeljenje.mjs
// Zatim sažmi izlaz i prebaci ga u public/slike/dijeljenje.png.

import { chromium } from 'playwright';
import { mkdirSync } from 'node:fs';

const slika = {
  dat: 'dijeljenje',
  rimski: '',
  sunceU: 0.490,
  oznaka: 'Niže nogometne lige · Istra i Primorsko-goranska županija',
  naslov: 'Lokal-<i>Arena</i>',
  podnaslov: 'Rezultati, zapisnici, tablice i strijelci',
};

// Omjer 1200x630 je viši od zaglavlja, pa naslov ide niže, slog je krupniji,
// a more počinje dublje. Vrijednosti su iste one kojima je napravljena
// dosadašnja slika, promijenjen je samo tekst nadnaslova.
const css = {
  '--w': '1200px', '--h': '630px',
  '--tx': '90px', '--ty': '216px',
  '--fs-naslov': '72px', '--fs-oznaka': '13px', '--fs-pod': '17px',
  '--more-y': '452px', '--odraz-y': '470px',
};

mkdirSync('izlaz', { recursive: true });
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const p = await b.newPage({ viewport: { width: 1200, height: 630 }, deviceScaleFactor: 1 });
await p.goto('http://127.0.0.1:8098/zaglavlje.html?v=' + Date.now());
await p.evaluate(v => {
  for (const [k, x] of Object.entries(v)) document.documentElement.style.setProperty(k, x);
}, css);
await p.evaluate(() => document.fonts.ready);
await p.evaluate(k => window.slozi(k), { ...slika, visina: 630, sirina: 1200 });
await p.waitForTimeout(250);
await p.locator('.z').screenshot({ path: 'izlaz/dijeljenje.png' });
await b.close();
console.log('napravljeno: izlaz/dijeljenje.png');

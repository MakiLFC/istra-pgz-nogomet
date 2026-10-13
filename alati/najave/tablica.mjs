// Slika ljestvice lige (1200x800) za članke. Vidi PROCITAJ.md.
//   python3 -m http.server 8099   (u mapi "alati", kao i za najave)
//   node tablica.mjs 1-znl-pgz-kolo-6
//
// Podaci su u tablice.json: brojke onakve kakve su na Semaforu (službena
// tablica, s kaznenim bodovima), a forma izračunata iz rezultata, isto
// kao na stranici (lib/tablica.ts).
import { chromium } from 'playwright';
import { readFileSync, mkdirSync } from 'node:fs';

const { tablice } = JSON.parse(readFileSync(new URL('./tablice.json', import.meta.url), 'utf8'));
const samo = process.argv[2];

mkdirSync('izlaz', { recursive: true });
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const p = await b.newPage({ viewport: { width: 1200, height: 800 }, deviceScaleFactor: 1 });
await p.goto('http://127.0.0.1:8099/najave/tablica.html?v=' + Date.now());
await p.evaluate(() => document.fonts.ready);

for (const t of tablice) {
  if (samo && t.dat !== samo) continue;
  await p.evaluate(tt => window.slozi(tt), t);
  await p.evaluate(() => document.fonts.ready);
  await p.waitForTimeout(150);
  await p.locator('.z').screenshot({ path: `izlaz/${t.ime}.png` });
  console.log('napravljeno:', `${t.ime}.png`);
}
await b.close();

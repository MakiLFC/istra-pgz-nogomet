// Naslovne slike za članke o transferima. Vidi PROCITAJ.md.
//   python3 -m http.server 8099   (u mapi "alati", ne u ovoj)
//   node generiraj.mjs
//
// Poslužitelj se diže u mapi "alati" zato što predložak koristi fontove
// iz alati/najave/fonts, pa se ne kopiraju po drugi put.
import { chromium } from 'playwright';
import { readFileSync, mkdirSync } from 'node:fs';

const { slike } = JSON.parse(readFileSync(new URL('./slike.json', import.meta.url), 'utf8'));

mkdirSync(new URL('./izlaz/', import.meta.url), { recursive: true });
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const p = await b.newPage({ viewport: { width: 1200, height: 630 }, deviceScaleFactor: 1 });
await p.goto('http://127.0.0.1:8099/transferi/transferi.html?v=' + Date.now());
await p.evaluate(() => document.fonts.ready);

for (const s of slike) {
  await p.evaluate(ss => window.slozi(ss), s);
  await p.waitForTimeout(180);
  await p.locator('.z').screenshot({ path: new URL(`./izlaz/${s.dat}.png`, import.meta.url).pathname });
  console.log('napravljeno:', `${s.dat}.png`);
}
await b.close();

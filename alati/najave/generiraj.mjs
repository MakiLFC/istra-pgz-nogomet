// Slike zaglavlja za najave kola. Vidi PROCITAJ.md.
//   python3 -m http.server 8099   (u mapi "alati", ne u ovoj)
//   node generiraj.mjs
//
// Poslužitelj se diže jedan katalog više, u "alati", da isti prozor
// posluži i alat za transfere, koji odande uzima ove fontove.
import { chromium } from 'playwright';
import { readFileSync, mkdirSync } from 'node:fs';

const { kola } = JSON.parse(readFileSync(new URL('./kola.json', import.meta.url), 'utf8'));
const { klubovi } = JSON.parse(readFileSync(new URL('./klubovi.json', import.meta.url), 'utf8'));
// Pravi grbovi (Andrejeva odluka 28.09.2026.), ako su skinuti.
let popisGrbova = {};
try {
  popisGrbova = JSON.parse(readFileSync(new URL('./grbovi/popis.json', import.meta.url), 'utf8')).klubovi;
} catch { /* grbovi jos nisu skinuti */ }
// Kolo bez polja "stil" crta se kao 'ploca'. 'redovi' je jedan par po
// retku, sa satnicom uz svaki par. 'horizont' je druga, atmosferska
// varijanta; ostaje u predlosku ako zatreba.
// Samo jedno kolo: node generiraj.mjs 3-nl-zapad-kolo-6
const samo = process.argv[2];

mkdirSync('izlaz', { recursive: true });
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const p = await b.newPage({ viewport: { width: 1200, height: 630 }, deviceScaleFactor: 1 });
await p.goto('http://127.0.0.1:8099/najave/najava.html?v=' + Date.now());
await p.evaluate(() => document.fonts.ready);

for (const k of kola) {
  if (samo && k.dat !== samo) continue;
  for (const stil of [k.stil || 'ploca']) {
    // Pregled kola ima svoje ime datoteke ("ime"), inace je najava-stil-dat.
    const ime = k.ime || `najava-${stil}-${k.dat}`;
    await p.evaluate(kk => window.slozi(kk), { ...k, stil, klubovi, popisGrbova });
    await p.waitForFunction(() => [...document.images].every(i => i.complete));
    await p.waitForTimeout(180);
    await p.locator('.z').screenshot({ path: `izlaz/${ime}.png` });
    console.log('napravljeno:', `${ime}.png`);
  }
}
await b.close();

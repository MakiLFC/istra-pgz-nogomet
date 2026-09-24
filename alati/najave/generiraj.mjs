// Slike zaglavlja za najave kola. Vidi PROCITAJ.md.
//   python3 -m http.server 8099   (u mapi "alati", ne u ovoj)
//   node generiraj.mjs
//
// Poslužitelj se diže jedan katalog više, u "alati", da isti prozor
// posluži i alat za transfere, koji odande uzima ove fontove.
import { chromium } from 'playwright';
import { readFileSync, mkdirSync } from 'node:fs';

const { kola } = JSON.parse(readFileSync(new URL('./kola.json', import.meta.url), 'utf8'));
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
    await p.evaluate(kk => window.slozi(kk), { ...k, stil });
    await p.waitForTimeout(180);
    await p.locator('.z').screenshot({ path: `izlaz/najava-${stil}-${k.dat}.png` });
    console.log('napravljeno:', `najava-${stil}-${k.dat}.png`);
  }
}
await b.close();

// Slike zaglavlja za najave kola. Vidi PROCITAJ.md.
//   python3 -m http.server 8099   (u ovoj mapi)
//   node generiraj.mjs
import { chromium } from 'playwright';
import { readFileSync, mkdirSync } from 'node:fs';

const { kola } = JSON.parse(readFileSync(new URL('./kola.json', import.meta.url), 'utf8'));
// 'horizont' je druga, atmosferska varijanta; ostaje u predlosku ako zatreba.
const stilovi = ['ploca'];

mkdirSync('izlaz', { recursive: true });
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const p = await b.newPage({ viewport: { width: 1200, height: 630 }, deviceScaleFactor: 1 });
await p.goto('http://127.0.0.1:8099/najava.html?v=' + Date.now());
await p.evaluate(() => document.fonts.ready);

for (const k of kola) {
  for (const stil of stilovi) {
    await p.evaluate(kk => window.slozi(kk), { ...k, stil });
    await p.waitForTimeout(180);
    await p.locator('.z').screenshot({ path: `izlaz/najava-${stil}-${k.dat}.png` });
    console.log('napravljeno:', `najava-${stil}-${k.dat}.png`);
  }
}
await b.close();

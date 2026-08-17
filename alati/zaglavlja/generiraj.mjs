import { chromium } from 'playwright';
const set = [
  { dat:'3-nl-zapad', rimski:'III', sunceU:0.440, oznaka:'Treći rang · sezona 2026/27', naslov:'3. NL <i>Zapad</i>', podnaslov:'Rezultati, zapisnici, tablice i strijelci' },
  { dat:'4-nl-ns-rijeka', rimski:'IV', sunceU:0.518, oznaka:'Četvrti rang · sezona 2026/27', naslov:'4. NL <i>NS Rijeka</i>', podnaslov:'Rezultati, zapisnici, tablice i strijelci' },
  { dat:'1-znl-pgz', rimski:'V', sunceU:0.604, oznaka:'Peti rang · PGŽ', naslov:'1. ŽNL <i>PGŽ</i>', podnaslov:'Rezultati, zapisnici, tablice i strijelci' },
  { dat:'2-znl-pgz', rimski:'VI', sunceU:0.652, oznaka:'Šesti rang · PGŽ', naslov:'2. ŽNL <i>PGŽ</i>', podnaslov:'Rezultati, zapisnici, tablice i strijelci' },
  { dat:'novosti', rimski:'', sunceU:0.696, oznaka:'Uredništvo · Lokal-Arena', naslov:'Novosti', podnaslov:'Transferi, najave, osvrti i derbi kola' },
];
const formati = {
  '': { w:1200, h:336, visina:336, korak:1, css:{} },
  '-mob': { w:640, h:400, visina:400, korak:0.62, css:{
    '--w':'640px','--h':'400px','--tx':'44px','--ty':'62px','--fs-naslov':'46px',
    '--fs-oznaka':'11px','--fs-pod':'13px','--fs-rimski':'188px','--rim-y':'96px',
    '--more-y':'286px','--odraz-y':'300px' } },
};
const b = await chromium.launch({ executablePath:'/opt/pw-browsers/chromium' });
for (const [sufiks, f] of Object.entries(formati)) {
  for (const skala of [1,2]) {
    const p = await b.newPage({ viewport:{width:f.w,height:f.h}, deviceScaleFactor:skala });
    await p.goto('http://127.0.0.1:8098/zaglavlje.html?v=' + Date.now());
    await p.evaluate(css => { for (const [k,v] of Object.entries(css)) document.documentElement.style.setProperty(k,v); }, f.css);
    await p.evaluate(()=>document.fonts.ready);
    for (const k of set) {
      await p.evaluate(kk => window.slozi(kk), { ...k, visina: f.visina, sirina: f.w });
      await p.waitForTimeout(200);
      await p.locator('.z').screenshot({ path:`zaglavlja/${k.dat}${sufiks}${skala===2?'@2x':''}.png` });
    }
    await p.close();
  }
}
await b.close(); console.log('gotovo');

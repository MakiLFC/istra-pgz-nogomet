-- =====================================================================
-- ČLANAK: PREGLED UTAKMICA ODIGRANIH 29.9.2026.
-- Ližnjan - Klana 1:0, Vinodol - Banjole 2:2, Rab - Krk 1:3 (kup).
-- =====================================================================
-- KAKO SE KORISTI: dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   KORAK 2 (objava) je zakomentiran na dnu.
--   Upis se smije ponoviti: prepisu se samo naslov, sazetak, tekst i slika.
--
-- BEZ LIGE, NAMJERNO
--   Stupac natjecanje je NULL, po Andrejevoj uputi: clanak ide samo u
--   novosti i na naslovnicu, ne pod jednu ligu, jer obuhvaca tri
--   natjecanja. Isto je napravljen i clanak o 1/16 finala kupa.
--
-- ODAKLE STO
--   Ližnjan - Klana i Vinodol - Banjole: zapisnici sa Semafora, posao
--   "Ispis kola" 29.09.2026. u 19:13. Poredak iz sluzbenih tablica u
--   istom ispisu.
--   Rab - Krk: slika ekrana sa Semafora koju je Andrej poslao 29.09. (kup
--   nije u scraperu). Rezultat 1:3 slijedi iz strijelaca; stranica je
--   uz utakmicu jos pokazivala "- : -" i "ZAKAZANO".
--   Begonja i Jelic po dva gola na Minti: zapisnik Kraljevica - Krk 4:5.
--
-- SLIKA
--   public/slike/najave/pregled-utakmica-29-09-2026.png, slozena
--   predloskom alati/najave (unos "utakmice-29-09-2026" u kola.json), s
--   nazivom natjecanja uz svaki par.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, slika_url, slika_opis, objavljen, objavljeno_u)
values (
  'pregled-utakmica-29-09-2026',
  'PREGLED UTAKMICA ODIGRANIH 29.9.2026.',
  'Ližnjan je svladao Klanu i popeo se na drugo mjesto 4. NL NS Rijeka, Vinodol i Banjole podijelili su bodove u 3. NL Zapad, a Krk je preokretom na Rabu prošao u osminu finala kupa.',
'U utorak 29. rujna odigrane su tri utakmice iz tri natjecanja: zadnje utakmice 4. kola 4. NL NS Rijeka i 6. kola 3. NL Zapad te posljednji susret 1/16 finala Hrvatskog nogometnog kupa.

Ližnjan - Klana 1:0 (4. NL NS Rijeka). Na Šaraji je, pred 80 gledatelja, jedini gol zabio kapetan Ližnjana Dino Balde u 80. minuti. Ližnjan je treću pobjedu u četiri utakmice iskoristio za skok na drugo mjesto. Ima devet bodova, jednako kao Borac (Bakar), koji je odigrao utakmicu manje, a ispred njega je po gol razlici. Vodeći Cres ima dvanaest bodova. Klana je ostala na tri boda i na desetom mjestu.

Vinodol - Banjole 2:2 (3. NL Zapad). Na Bahalinu, pred 70 gledatelja, sva četiri gola zabila su dvojica igrača, po jedan sa svake strane. Badara Seck doveo je Vinodol u vodstvo u 15. minuti, Ivan Giljanović izjednačio je u 56., Seck je tri minute kasnije ponovno doveo domaćine u vodstvo, a Giljanović je u 76. minuti postavio konačnih 2:2. Sudac je podijelio osam žutih kartona, po četiri svakoj momčadi. Seck sada ima četiri pogotka u sezoni, a Giljanović tri. Banjole su sa šest bodova jedanaeste, uz utakmicu manje, a Vinodol je s pet bodova četrnaesti.

Rab - Krk 1:3 (Hrvatski nogometni kup, 1/16 finala). Posljednju utakmicu 1/16 finala na Blatu je pratilo 200 gledatelja. Rab iz 1. ŽNL PGŽ poveo je u 16. minuti golom Marina Macolića, ali je Krk iz 3. NL Zapad preokrenuo. Jakov Delibegović izjednačio je u 44. minuti, Roko Begonja je u 49. doveo Krk u vodstvo, a Marko Jelić u 90. postavio konačnih 1:3. Krk je tako prošao u osminu finala. Begonja i Jelić zabili su po dva gola i tri dana ranije, u pobjedi Krka 5:4 na Minti.',
  null,
  '/slike/najave/pregled-utakmica-29-09-2026.png',
  'Rezultati utakmica odigranih 29. rujna 2026.: Ližnjan - Klana 1:0, Vinodol - Banjole 2:2, Rab - Krk 1:3',
  false,
  now()
)
on conflict (slug) do update
  set naslov     = excluded.naslov,
      sazetak    = excluded.sazetak,
      tekst      = excluded.tekst,
      slika_url  = excluded.slika_url,
      slika_opis = excluded.slika_opis;


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-utakmica-29-09-2026'
-- returning slug, naslov, objavljen;


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, slika_url, objavljen, left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-utakmica-29-09-2026';

-- =====================================================================
-- ČLANAK: PREGLED 4. KOLA 2. ŽNL PGŽ 2026/27
-- Odigrano 27.09.2026., sve tri utakmice u 16 sati.
-- =====================================================================
-- KAKO SE KORISTI: dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   KORAK 2 (objava) je zakomentiran na dnu.
--   Upis se smije ponoviti: prepisu se samo naslov, sazetak i tekst.
--
-- ODAKLE STO
--   Rezultati, strijelci s minutama, kartoni i gledatelji iz zapisnika
--   sa Semafora, posao "Ispis kola" 27.09.2026. u 18:35 po nasem.
--   Ljestvica je sluzbena, iz istog ispisa. Ljestvica prije kola i
--   ucinak u gostima iz najave 4. kola (Goranka u gostima jedan bod iz
--   dvije utakmice, Zeljeznicar jedan bod, Polet kod kuce bez pobjede).
--   Nitko od nas nije bio ni na jednoj utakmici, pa u tekstu nema opisa
--   igre, samo ono sto stoji u zapisniku.
--
-- PROVJERENO PRIJE PISANJA
--   Zbroj strijelaca po stranama slaze se s rezultatom na sve tri
--   utakmice, uz autogol Dina Knausa (klasa own_goal u zapisniku).
--   Pomaci: prije kola Gomirje 9, Mrkopalj 6, Goranka 4, Polet 3,
--   Zeljeznicar 1, Snjeznik 0; poslije Gomirje 12, Goranka 7, Mrkopalj 6,
--   Zeljeznicar 4, Polet 3, Snjeznik 0.
--
-- NE ISPISUJE SE
--   Kod Tihomira Cindrica (Goranka, 16.) i vratara Snjeznika (76.)
--   zapisnik ima dogadjaj koji scraper nije prepoznao. Nije gol (zbroj
--   se slaze) i nije poznato sto je, pa se ne spominje.
--   Zuti kartoni se ne navode po imenima: prag za ZNL nije potvrdjen.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'pregled-4-kola-2-znl-pgz-2627',
  'GOMIRJE DOBILO DERBI VRHA I IMA PET BODOVA PREDNOSTI',
  'Gomirje je s dva gola Đorđa Mrvoša svladalo Mrkopalj i ostalo jedino bez izgubljenog boda. Goranka je preokretom u Skradu došla na drugo mjesto, a Željezničar je Snježniku zabio sedam golova za prvu pobjedu u sezoni.',
'Četvrto kolo 2. ŽNL PGŽ odigrano je u nedjelju 27. rujna i donijelo je 15 pogodaka u tri utakmice, pet po susretu. Domaćini su slavili dvaput, gosti jednom, a remija nije bilo.

Gomirje - Mrkopalj 2:1. U susretu dviju jedinih momčadi bez izgubljenog boda slavilo je Gomirje, a oba gola zabio je Đorđe Mrvoš. Prvi je pao u 44. minuti, a drugi u 61. Kapetan Mrkoplja Šimun Starčević smanjio je u 68., ali gosti su od 75. minute igrali s igračem manje, nakon crvenog kartona Luke Mršića. Gomirje ima četiri pobjede iz četiri utakmice, a Mrkopalj je upisao prvi poraz u sezoni.

Polet (Sk) - Goranka 1:4. Polet je u Skradskoj Dragi poveo već u 12. minuti golom Davida Ožbolta, ali je Goranka u drugom poluvremenu preokrenula. Emanuel Liker izjednačio je u 60. minuti, Goranka je u 67. povela autogolom Dina Knausa, a Dražen Renka u 82. i Matija Delač u 85. minuti postavili su konačnih 1:4. Goranka je tako upisala prvu pobjedu u gostima ove sezone, a Polet kod kuće još čeka prvu. Utakmicu je pratilo 30 gledatelja, a sudac je podijelio osam žutih kartona.

Željezničar (M) - Snježnik 7:0. Na Kraj Dobre u Moravicama Željezničar je do prve pobjede u sezoni došao najuvjerljivijim rezultatom kola. Armin Palić otvorio je već u 5. minuti, Darin Goršić povisio u 30., a Dalibor Krebelj zabio je u 32. i 44. minuti za 4:0 na poluvremenu. U nastavku su pogodili Luka Kujavec u 51., Palić drugi put u 52. i Goran Milanović u 65. minuti. Snježnik je drugi put ove sezone primio sedam golova, a u tri utakmice primio ih je dvadeset.

STRIJELCI

Šime Božić iz Goranke ovaj put nije zabio, ali s pet pogodaka i dalje vodi. Slijedi Antonio Fenov iz Gomirja s četiri, a po tri imaju Aleksandar Ilić i Antonio Krištof iz Mrkoplja, David Ožbolt iz Poleta i Dalibor Krebelj iz Željezničara.

LJESTVICA

Gomirje vodi s dvanaest bodova, pet ispred Goranke, koja se pobjedom u Skradu popela na drugo mjesto. Mrkopalj je pao na treće sa šest bodova, ali ima utakmicu manje. Željezničar je sa četiri boda preskočio Polet, a Snježnik je i dalje bez boda. Goranka i Gomirje imaju istu gol razliku, plus devet.

Mrkopalj i Snježnik i dalje imaju utakmicu manje, jer je njihov susret iz 1. kola odgođen.

ZA SLJEDEĆE KOLO

Peto kolo propušta Luka Mršić (Mrkopalj) zbog crvenog kartona.',
  '2. ŽNL PGŽ',
  false,
  now()
)
on conflict (slug) do update
  set naslov  = excluded.naslov,
      sazetak = excluded.sazetak,
      tekst   = excluded.tekst;


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-4-kola-2-znl-pgz-2627'
-- returning slug, naslov, objavljen;


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-4-kola-2-znl-pgz-2627';

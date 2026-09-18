-- =====================================================================
-- ČLANAK: NAJAVA 3. KOLA 2. ŽNL PGŽ 2026/27
-- Igra se u subotu 19. i nedjelju 20.09.2026.
-- =====================================================================
-- KAKO SE KORISTI: dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   KORAK 2 (objava) je zakomentiran na dnu.
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- SLUG MORA POCETI S "najava-"
--   Traka "Ovaj vikend" na naslovnici po tome prepoznaje najavu tog kola.
--
-- ODAKLE STO
--   Termini, ljestvica, forma i medjusobni ogledi iz prosle sezone
--   dolaze iz public.najava_kola('2026/27','2. ŽNL PGŽ',3), a strijelci,
--   minute i iskljucenja iz
--   public.pregled_kola('2026/27','2. ŽNL PGŽ',2).
--   Nista nije dopisano izvan toga.
--
-- UTAKMICA MANJE
--   Snjeznik - Mrkopalj iz 1. kola jos nije odigran i u bazi nema novi
--   termin, pa oba kluba imaju utakmicu manje. U tekstu to stoji kod
--   ljestvice, da brojke ne zavaraju.
--
-- LJESTVICA
--   sluzbena_tablica_odstupa je false, dakle nema kaznenih bodova i
--   izracunata tablica poklapa se sa sluzbenom.
--
-- KAZNE
--   Zeljeznicar je protiv Gomirja ostao bez dvojice: Dorian Majstorovic
--   (37.) i Zoran Mamula (55.), oba crvena kartona. Polje "na_pragu" je
--   prazno.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-3-kola-2-znl-pgz-2627',
  'GORANKA I ŠIME BOŽIĆ GOSTUJU POD ČELIMBAŠOM',
  'Drugi i treći na ljestvici sastaju se u Mrkoplju, a Goranka dolazi s igračem koji je u prošlom kolu sam zabio četiri gola. Vodeće Gomirje gostuje u Gerovu.',
'Treće kolo 2. ŽNL PGŽ počinje u subotu 19. rujna u 16:30, kada Mrkopalj dočekuje Goranku Pod Čelimbašom. U nedjelju 20. rujna, također u 16:30, na rasporedu su Željezničar (M) - Polet (Sk) u Moravicama i Snježnik - Gomirje u Gerovu.

Mrkopalj - Goranka. Susret kola. Goranka je druga s četiri boda i najboljom gol razlikom u ligi, plus sedam, a takvu je razliku stekla u jednoj utakmici: 7:0 protiv Snježnika, u kojoj je Šime Božić zabio četiri gola i preuzeo vrh liste strijelaca. Zabijali su još Tihomir Cindrić, Mateo Gorupić i Davor Baroš. Mrkopalj je treći, s pobjedom 3:1 u Skradu, gdje je Antonio Krištof zabio dva gola u razmaku od pet minuta. Prošle sezone ova su se dva kluba sastala tri puta i Mrkopalj u tim susretima nije zabio nijedan gol: Goranka je slavila 5:0 i 2:0, a u Mrkoplju je bilo 0:0.

Snježnik - Gomirje. Gomirje je jedino s dvije pobjede i vodi na ljestvici. Protiv Željezničara je poveo već nakon četiri minute, golovima Antonija Fenova i Ivana Petrovića, a konačnih 3:1 postavio je Milan Lončar. Snježnik je bez bodova i s gol razlikom minus sedam, iz jedine odigrane utakmice. Prošle je sezone, međutim, Gomirje u Gerovu izgubilo 3:1, pa domaćin ima na što podsjetiti.

Željezničar (M) - Polet (Sk). Željezničar u Moravicama igra s dvojicom manje nego što je planirao: Dorian Majstorović i Zoran Mamula isključeni su protiv Gomirja, u 37. i 55. minuti, i obojica propuštaju ovo kolo. Polet je jedini uz Snježnik bez bodova, nakon poraza od Gomirja i Mrkoplja. Prošle sezone njihovi su ogledi bili tijesni: dva remija, 0:0 i 2:2, te pobjeda Poleta 2:0 u Moravicama.

LJESTVICA

Vodi Gomirje sa šest bodova, ispred Goranke s četiri i Mrkoplja s tri. Željezničar ima bod, a Polet i Snježnik su bez njih. Treba imati na umu da Mrkopalj i Snježnik imaju utakmicu manje, jer njihov susret iz prvog kola još nije odigran. Cijela ljestvica i strijelci su na stranici 2. ŽNL PGŽ.

KAZNE

Treće kolo zbog crvenih kartona propuštaju Dorian Majstorović i Zoran Mamula, obojica iz Željezničara. Na pragu žutih nema nikoga.',
  '2. ŽNL PGŽ',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-3-kola-2-znl-pgz-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-3-kola-2-znl-pgz-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-3-kola-2-znl-pgz-2627';

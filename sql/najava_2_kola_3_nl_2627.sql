-- =====================================================================
-- NAJAVA 2. KOLA, 3. NL ZAPAD, SEZONA 2026/27
-- =====================================================================
-- RADNA VERZIJA. Tekst je kostur, dopuni ga i tek onda pokreni.
--
-- KAKO SE KORISTI:
--   1. Popuni ono što je u uglatim zagradama i prepravi što želiš.
--   2. Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   3. Clanak se upisuje s objavljen = false, dakle NIJE vidljiv.
--      Objavljuje se naredbom iz odjeljka OBJAVA na dnu.
--
--   Pokrece se SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- ŠTO JOŠ TREBA:
--   a) Andrejeve bilješke o klubovima, na mjestima [DOPUNI]
--   b) naslovna slika: ploča za 2. kolo (alat alati/najave)
--   c) oznake derbija, dolje u odjeljku DERBIJI
--
-- Termini i stadioni su upisani iz baze 31.08.2026.: petak 04.09. samo
-- Lokomotiva - Crikvenica, ostalih sedam u subotu 05.09., sve u 17:30.
--
-- PODACI IZ 1. KOLA, provjereni (koriste se u tekstu):
--   Rovinj 1:0 Vinodol            Pazinka-Pazin 0:2 Pomorac
--   Jadran-Poreč 1:3 Nehaj        Naprijed (H) 0:2 Kraljevica
--   OŠK Omišalj 5:0 Rudar (L)     Halubjan 2:2 Banjole
--   Buje 0:2 Lokomotiva (R)       Crikvenica 2:2 Krk
--   Suspendirani za 2. kolo: Damjan Mendrila (Crikvenica),
--   Dorijan Jurešić (Krk).
-- =====================================================================


-- ---------------------------------------------------------------------
-- PODACI ZA TEKST: termini i stadioni 2. kola
-- ---------------------------------------------------------------------
select kolo, datum, vrijeme, domacin, gost, stadion
from public.utakmice
where sezona = '2026/27' and natjecanje = '3. NL Zapad' and kolo = 2
order by datum, vrijeme;


-- ---------------------------------------------------------------------
-- UPIS ČLANKA
-- ---------------------------------------------------------------------
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-2-kola-3-nl-zapad-2627',
  'NAJAVA 2. KOLA: 3. NL ZAPAD',
  'Kolo je razvučeno na petak i subotu, a nose ga dva derbija: Lokomotiva dočekuje Crikvenicu na Kantridi, Pomorac Jadran-Poreč u Kostreni.',
'Drugo kolo 3. NL Zapad razvučeno je na dva dana. U petak 4. rujna igra se jedna utakmica, a preostalih sedam u subotu 5. rujna, sve u 17:30.

Iz prvog kola ostalo je šest pobjeda i dva remija, uz 24 postignuta pogotka. Gosti su bili uspješniji od domaćina, s četiri pobjede na strani.

Lokomotiva (R) - Crikvenica (Stadion Kantrida, Rijeka). Petak, 17:30. Kolo otvara jedan od dva derbija ovog kola. Lokomotiva je u Bujama slavila 0:2 golovima Ivora Weitzera i Matea Monjca. Crikvenica je s Krkom remizirala 2:2, i to igrajući od 34. minute s igračem manje, a u ovo kolo ulazi bez isključenog Damjana Mendrile. Uz tri kaznena boda s početka sezone, i s tim osvojenim bodom je i dalje u minusu. S te utakmice stiže i osvrt na Lokal-Areni. [DOPUNI]

Pomorac - Jadran-Poreč (Žuknica, Kostrena). Drugi derbi kola. Pomorac je u Pazinu dobio 0:2, Jadran-Poreč je kod kuće izgubio 1:3 od Nehaja. [DOPUNI]

Kraljevica - OŠK Omišalj (Milan Ružić Minta, Kraljevica). Susret jedinih dviju momčadi koje su prvo kolo prošle s pobjedom i bez primljenog gola. Kraljevica je slavila 0:2 u Hreljinu, Omišalj je Rudar svladao 5:0, što je bila najuvjerljivija pobjeda kola. [DOPUNI]

Rovinj - Pazinka-Pazin (Valbruna umjetna trava, Rovinj). Novak u ligi dočekuje prošlogodišnjeg prvaka. Rovinj je prvi nastup u trećem rangu dobio 1:0 protiv Vinodola, a Pazinka je sezonu otvorila domaćim porazom. [DOPUNI]

Nehaj - Naprijed (H) (Nehaj, Senj). Nehaj je u Poreču slavio 1:3, Naprijed je kod kuće izgubio od Kraljevice. [DOPUNI]

Vinodol - Krk (Bahalin, Novi Vinodolski). Vinodol je u Rovinju izgubio 1:0. Krk je u Crikvenici s dva gola u sudačkoj nadoknadi spasio bod, ali u ovo kolo ulazi bez Dorijana Jurešića, isključenog u 75. minuti. [DOPUNI]

Rudar (L) - Halubjan (Gradski stadion Labin, Labin). Rudar je u Omišlju primio pet golova, a Halubjan je kod kuće ispustio dvostruko vodstvo Banjola i uzeo bod pogotkom u 87. minuti. [DOPUNI]

Banjole - Buje (Prematinka, Banjole). Banjole su u Viškovu dvaput vodile i osvojile bod, a oba gola dao je Ahmed Durmo, jedan od dvojice vodećih strijelaca lige. Buje su kod kuće izgubile 0:2. [DOPUNI]',
  '3. NL Zapad',
  false,
  '2026-09-03T10:00:00+02:00'
);


-- ---------------------------------------------------------------------
-- PROVJERA
-- ---------------------------------------------------------------------
select slug, naslov, natjecanje, objavljen, objavljeno_u
from public.clanci
where slug = 'najava-2-kola-3-nl-zapad-2627';


-- =====================================================================
-- DERBIJI (dva u ovom kolu)
-- =====================================================================
-- Prvo se gasi prošlokolski derbi te lige, pa se označavaju nova dva.
-- Naslovnica od sada prikazuje sve označene derbije lige, ne samo prvi.
--
-- update public.utakmice set derbi = false
-- where derbi = true and natjecanje = '3. NL Zapad' and sezona = '2026/27';
--
-- update public.utakmice set derbi = true
-- where natjecanje = '3. NL Zapad' and sezona = '2026/27' and kolo = 2
--   and domacin = 'NK Lokomotiva (R)' and gost = 'NK Crikvenica';
--
-- update public.utakmice set derbi = true
-- where natjecanje = '3. NL Zapad' and sezona = '2026/27' and kolo = 2
--   and domacin = 'NK Pomorac' and gost = 'NK Jadran-Poreč';
--
-- Svaka od dvije zadnje naredbe mora javiti "1 row".


-- =====================================================================
-- SLIKA (kad ploča za 2. kolo bude napravljena)
-- =====================================================================
-- update public.clanci
--    set slika_url  = '/slike/najave/najava-ploca-3-nl-zapad-kolo-2.png',
--        slika_opis = 'Ploča s parovima drugog kola 3. NL Zapad'
--  where slug = 'najava-2-kola-3-nl-zapad-2627';


-- =====================================================================
-- OBJAVA
-- =====================================================================
-- Cim se ovo pokrene, na traci "Ovaj vikend" pojavi se i gumb Najava,
-- jer on prati kolo iz sluga.
--
-- update public.clanci set objavljen = true
-- where slug = 'najava-2-kola-3-nl-zapad-2627';
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-2-kola-3-nl-zapad-2627';
-- =====================================================================

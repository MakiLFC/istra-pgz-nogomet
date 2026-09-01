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
--   a) termini i stadioni, upitom iz odjeljka PODACI ZA TEKST dolje;
--      jedna je utakmica prebačena na petak, pa se datumi ne prepisuju
--      napamet
--   b) koja je utakmica derbi kola (oznaka se stavlja zasebno, kroz
--      derbi_tjedni_predlozak.sql)
--   c) Andrejeve bilješke o klubovima
--   d) naslovna slika: ploča za 2. kolo još nije napravljena, radi se
--      alatom alati/najave (dopuni kola.json i pokreni generiraj.mjs)
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
  '[SAŽETAK, jedna do dvije rečenice. Prijedlog: Kraljevica i Omišalj,
jedine dvije momčadi s maksimalnim učinkom, sastaju se već u drugom kolu.]',
'Drugo kolo 3. NL Zapad igra se [DATUM I TERMINI, iz upita gore].

[UVOD: što je ostalo iz prvog kola. Prijedlog: šest pobjeda i dva
remija, četiri gostujuće pobjede, 24 pogotka.]

Kraljevica - OŠK Omišalj [(STADION)]. Susret jedinih dviju momčadi koje
su prvo kolo otvorile pobjedom i bez primljenog gola. Kraljevica je
slavila 0:2 u Hreljinu, Omišalj je Rudar svladao 5:0, što je bila i
najuvjerljivija pobjeda kola. [DOPUNI]

Rovinj - Pazinka-Pazin [(STADION)]. Novak u ligi dočekuje prošlogodišnjeg
prvaka. Rovinj je prvi nastup u trećem rangu dobio 1:0, a Pazinka je
sezonu otvorila domaćim porazom od Pomorca. [DOPUNI]

Nehaj - Naprijed (H) [(STADION)]. Nehaj je u Poreču slavio 1:3, Naprijed
je kod kuće izgubio od Kraljevice. [DOPUNI]

Pomorac - Jadran-Poreč [(STADION)]. Pomorac je u Pazinu dobio 0:2,
Jadran-Poreč je kod kuće izgubio 1:3. [DOPUNI]

Lokomotiva (R) - Crikvenica [(STADION)]. Lokomotiva je u Bujama slavila
0:2. Crikvenica je s Krkom remizirala 2:2, i to igrajući od 34. minute s
igračem manje, a u drugo kolo ulazi bez isključenog Damjana Mendrile.
Uz tri kaznena boda s početka sezone, i s osvojenim bodom je i dalje u
minusu. [DOPUNI]

Vinodol - Krk [(STADION)]. Vinodol je u Rovinju izgubio 1:0. Krk je u
Crikvenici s dva gola u sudačkoj nadoknadi spasio bod, ali u ovo kolo
ulazi bez Dorijana Jurešića, isključenog u 75. minuti. [DOPUNI]

Rudar (L) - Halubjan [(STADION)]. Rudar je u Omišlju primio pet golova,
Halubjan je kod kuće ispustio dvostruko vodstvo Banjola i uzeo bod
pogotkom u 87. minuti. [DOPUNI]

Banjole - Buje [(STADION)]. Banjole su u Viškovu dvaput vodile i
osvojile bod, a oba gola dao je Ahmed Durmo, jedan od dvojice vodećih
strijelaca lige. Buje su kod kuće izgubile 0:2. [DOPUNI]',
  '3. NL Zapad',
  false,
  '[DATUM OBJAVE, npr. 2026-09-03T10:00:00+02:00]'
);


-- ---------------------------------------------------------------------
-- PROVJERA
-- ---------------------------------------------------------------------
select slug, naslov, natjecanje, objavljen, objavljeno_u
from public.clanci
where slug = 'najava-2-kola-3-nl-zapad-2627';


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

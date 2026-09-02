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
-- STANJE: tekst je Andrejev, dovršen 31.08.2026. Naslovna ploča je
-- napravljena i stoji u repozitoriju, upisuje se odmah s člankom.
-- Ostaje samo označiti dva derbija, odjeljak DERBIJI dolje.
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
  (slug, naslov, sazetak, tekst, natjecanje, slika_url, slika_opis,
   objavljen, objavljeno_u)
values (
  'najava-2-kola-3-nl-zapad-2627',
  'NAJAVA 2. KOLA: 3. NL ZAPAD',
  'Kraljevica i OŠK Omišalj u borbi za održavanje stopostotnog učinka, a kolo počinje već u petak i nastavlja se u subotu. Očekuju nas dvije potencijalno najzanimljivije utakmice kola u kojima NK Lokomotiva dočekuje Crikvenicu na Kantridi, a Pomorac Jadran-Poreč u Kostreni.',
'Drugo kolo 3. NL Zapad razvučeno je na dva dana. U petak, 4. rujna, igra se jedna utakmica, a preostalih sedam u subotu 5. rujna, sve u 17:30 sati.

U prvom kolu gosti su bili uspješniji od domaćina, s ujedno čak četiri pobjede na strani pa ostaje za vidjeti hoće li se taj trend nastaviti i u ovome kolu.

Lokomotiva (R) - Crikvenica (Stadion Kantrida, Rijeka). Petak, 17:30. Kolo otvara jedna od dvije utakmice označene na našoj stranici kao derbi ovoga kola. Lokomotiva je prethodno u Bujama slavila 0:2 golovima Ivora Weitzera i Matea Monjca. Crikvenica je u infarktnoj završnici s Krkom remizirala 2:2 iako je dvije minute prije kraja vodila s dva razlike, i to igrajući od 34. minute s igračem manje, pa u ovo kolo ulazi bez isključenog Damjana Mendrile. Uz tri kaznena boda s početka sezone, i s tim osvojenim bodom je i dalje u minusu. S te utakmice stiže i osvrt na Lokal-Areni.

Pomorac - Jadran-Poreč (Žuknica, Kostrena). Drugi derbi kola. Pomorac je u Pazinu pobijedio uvjerljivo sa 0:2, dok je Jadran-Poreč pomalo iznenađujuće kod kuće izgubio 1:3 od Nehaja. Za iskupljenje ih čeka težak ispit na Žuknici.

Kraljevica - OŠK Omišalj (Milan Ružić Minta, Kraljevica). Susret jedinih dviju momčadi koje su prvo kolo prošle s pobjedom i bez primljenog gola. Kraljevica je slavila 0:2 u Hreljinu, Omišalj je Rudar svladao 5:0, što je bila najuvjerljivija pobjeda kola dok je Kraljevica na Hreljinu ostavila Naprijed praktički bez prave šanse.

Rovinj - Pazinka-Pazin (Valbruna umjetna trava, Rovinj). Novak u ligi u istarskom obračunu dočekuje prošlogodišnjeg prvaka. Rovinj je prvi nastup u trećem rangu dobio 1:0 protiv Vinodola i time dokazao da neće biti prolaznik u ovoj ligi, a Pazinka je sezonu otvorila senzacionalnim domaćim porazom.

Nehaj - Naprijed (H) (Nehaj, Senj). Nehaj nakon uvjerljive pobjede u Poreču gdje je slavio sa 1:3 samouvjereno dočekuje Naprijed koji je prethodno kod kuće pokazao bezidejnu igru protiv Kraljevice.

Vinodol - Krk (Bahalin, Novi Vinodolski). Vinodol je u 1. kolu u Rovinju izgubio 1:0 i domaći teren je prava prilika za prve bodove ove sezone. Krk je u Crikvenici s dva gola u sudačkoj nadoknadi na nevjerojatan način spasio bod te će ovu utakmicu htjeti odigrati s manje stresa, no u ovo kolo ulazi bez suspendiranog Dorijana Jurešića.

Rudar (L) - Halubjan (Gradski stadion Labin, Labin). "Kovari" su u Omišlju primili čak pet golova te im pozitivan rezultat u ovoj utakmici praktički postaje nužan za moral ekipe, dok im u goste stiže Halubjan koji je kod kuće protiv Banjola spasio bod pogotkom u 87. minuti. Valja napomenuti kako Halubjan u utakmicu ulazi pojačan novim igračem, dobro poznatom imenu s ovih prostora, Mihovilom Jeronimom Klapanom.

Banjole - Buje (Prematinka, Banjole). Banjole su u Viškovu dvaput vodile i osvojile bod, a oba gola dao je Ahmed Durmo, jedan od trenutno dvojice vodećih strijelaca lige. Buje su kod kuće izgubile 0:2 i sada će se pokušati iskupiti za taj poraz na prvom ovosezonskom gostovanju, ali i dalje na istarskom tlu.',
  '3. NL Zapad',
  '/slike/najave/najava-ploca-3-nl-zapad-kolo-2.png',
  'Ploča s parovima drugog kola 3. NL Zapad',
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
-- where derbi = true and natjecanje = '3. NL Zapad' and sezona = '2026/27'
-- returning kolo, domacin, gost;
--
-- update public.utakmice set derbi = true
-- where natjecanje = '3. NL Zapad' and sezona = '2026/27' and kolo = 2
--   and domacin = 'NK Lokomotiva (R)' and gost = 'NK Crikvenica'
-- returning kolo, domacin, gost;
--
-- update public.utakmice set derbi = true
-- where natjecanje = '3. NL Zapad' and sezona = '2026/27' and kolo = 2
--   and domacin = 'NK Pomorac' and gost = 'NK Jadran-Poreč'
-- returning kolo, domacin, gost;
--
-- Zbog "returning" svaka naredba ispiše utakmicu koju je dirnula.
-- Prazan ispis znači da nije pogodila nijednu.


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

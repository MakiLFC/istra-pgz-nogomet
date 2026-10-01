-- =====================================================================
-- ČLANAK: NAJAVA 7. KOLA 3. NL ZAPAD 2026/27
-- Igra se u subotu 03.10.2026., svih osam utakmica u 15:00.
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
--   Raspored, satnica i stadioni 7. kola, svi rezultati sezone, ljestvica
--   i strijelci: posao "Ispis kola" 01.10.2026. (3. NL, 7. kolo), uz novi
--   sazeti popis svih utakmica sezone na kraju ispisa.
--   Ucinak kod kuce i u gostima izracunat je iz tih rezultata.
--   Iskljucenja i igraci na tri zuta: pregled 6. kola
--   (sql/pregled_6_kola_3_nl_2627.sql), objavljen.
--   Krk u kupu na Rabu: clanak o utakmicama 29.09.2026.
--   Treneri (Kastrati u Jadranu, Cop u Vinodolu, Deranja u Naprijedu):
--   Andrejevi podaci iz najava 5. i 6. kola.
--
-- ZUTI KARTONI
--   Prag u 3. NL Zapad je cetiri zuta (Andrej, 24.09.2026.). Tin Jurica
--   je cetvrti dobio u 6. kolu i pauzira.
--
-- LJESTVICA
--   Crikvenica ima tri kaznena boda, pa se navodi vrh i uputa na sluzbenu
--   ljestvicu.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-7-kola-3-nl-zapad-2627',
  'NAJAVA 7. KOLA: LOKOMOTIVA S PET POBJEDA IZ PET UTAKMICA DOČEKUJE KRALJEVICU, POMORAC I PAZINKA DVA BODA IZA',
  'Vodeća Lokomotiva na Kantridi dočekuje Kraljevicu, koja je izgubila dvaput zaredom. Pomorac gostuje u Crikvenici, koja tri utakmice nije primila gol, a Pazinka na Brnasima traži petu pobjedu zaredom.',
'Sedmo kolo 3. NL Zapad igra se u subotu 3. listopada, a svih osam utakmica počinje u 15 sati. Lokomotiva je jedina momčad koja još nije izgubila bod i vodi s dva boda prednosti ispred Pomorca i Pazinke, uz utakmicu manje.

Lokomotiva (R) - Kraljevica. Prvi protiv petog na Kantridi. Ako Lokomotiva pobijedi, zadržat će najmanje dva boda prednosti, kako god igrali Pomorac i Pazinka. Ako izgubi, a oni pobijede, prestići će je. Iz pet utakmica ima pet pobjeda i gol razliku 18:2. Kod kuće je ove sezone igrala samo jednom, protiv Crikvenice 4:0, a u gostima je dobila sve četiri utakmice. Karlo Josipović sa šest pogodaka dijeli vrh liste strijelaca. Kraljevica traži izlaz iz niza od dva poraza, u Crikvenici i kod kuće protiv Krka. Porazom bi zaostatak za vodećim narastao na osam bodova. U gostima je ove sezone bila uspješnija nego kod kuće: dvije pobjede i jedan poraz, uz gol razliku 4:2. Na Kantridi ostaje bez Lovre Šuprahe, isključenog protiv Krka nakon drugog žutog kartona. Filip Znamenaček najveći je adut Kraljevice u ovome susretu: protiv Krka je zabio hat-trick i ima pet pogodaka.

Crikvenica - Pomorac. Pomorac ima trinaest bodova, jednako kao Pazinka, i ispred nje je po gol razlici. Ako Lokomotiva izgubi, pobjedom u Crikvenici prestići će je. U gostima je ove sezone savršen: tri pobjede, deset danih golova i nijedan primljeni. Prošle subote, protiv Buja, prvi put ove sezone nije zabio. Zahuktala Crikvenica dočekuje Pomorac s tri prvenstvene pobjede zaredom, sve tri bez primljenog gola, pa se sastaju momčad koja u gostima nije primila gol i momčad koja ga nije primila u posljednje tri utakmice. Crikvenica je osma sa sedam bodova; bez tri kaznena boda imala bi deset. Kod kuće ima pobjedu, remi i poraz. Jakob Šprem-Veljavečki sa šest i Marino Matković s pet pogodaka predvode Pomorčeve strijelce, a Crikveničin Ivan Lukarić jedan je žuti karton od kazne.

Halubjan - Pazinka-Pazin. Pazinka je bez poraza u pet utakmica, a posljednje četiri je dobila. Peta pobjeda zaredom držala bi je u dodiru s Lokomotivom. U gostima je dobila obje utakmice, u Rovinju 1:0 i na Hreljinu 2:1. Halubjan na Brnasima ove sezone nije pobijedio: remi s Banjolama i porazi od Kraljevice i Pomorca, uz gol razliku 3:7. Obje prvenstvene pobjede, u Senju i Rovinju, upisao je u gostima. Deseti je sa sedam bodova. Gabriel Buršić iz Pazinke jedan je žuti karton od kazne.

Krk - Nehaj. Krk je četvrti s jedanaest bodova i pobjedom bi stigao na četrnaest. Dolazi nakon dvije prvenstvene pobjede zaredom i prolaska u osminu finala kupa, izborenog u utorak na Rabu. Kod kuće ima pobjedu i poraz, 4:1 protiv Rudara i 1:3 protiv Lokomotive. Bez Tina Jurice je, nositelja igre u veznom redu, koji pauzira zbog četvrtog žutog kartona, a Lovre Travica je jedan karton od kazne. Nehaj je izgubio četiri utakmice zaredom, nakon dvije pobjede na početku sezone, i dvanaesti je sa šest bodova. Jedinu pobjedu u gostima upisao je u prvom kolu u Poreču, 3:1. Lucijan Tomac s četiri pogotka mu je najbolji strijelac.

OŠK Omišalj - Jadran-Poreč. Omišalj je na Pušći ove sezone stopostotan: tri pobjede i gol razlika 11:3. Svih devet bodova osvojio je kod kuće, jer je sve tri utakmice u gostima izgubio. Šesti je, a David Rožajac ima pet pogodaka. Jadran je deveti sa sedam bodova i u posljednje tri utakmice nije ni pobijedio ni zabio gol: 0:3 u Pazinu, 0:1 protiv Vinodola i 0:0 protiv Naprijeda. Ovo mu je druga utakmica pod vodstvom Elvisa Kastratija, koji nema lagan zadatak. U gostima ima pobjedu protiv Pomorca 3:2 i poraz u Pazinu 0:3. Ilija Batrićević ima tri pogotka, a Vedran Radman jedan je žuti karton od kazne.

Buje - Rovinj. Rovinj je posljednji s tri boda i izgubio je pet utakmica zaredom. Jedinu pobjedu upisao je u prvom kolu, 1:0 protiv Vinodola. U gostima je izgubio obje utakmice, u Poreču 2:3 i u Omišlju 2:4. Pobjedom bi se maknuo s dna, ako Naprijed ne pobijedi Vinodol. Buje su bez poraza u tri utakmice i sedme su s osam bodova, ali na Gradskom stadionu ove sezone imaju jednu pobjedu i dva poraza. Damir Bartulović ima tri pogotka, a Rovinjev Matej Vladišković jedan je žuti karton od kazne.

Banjole - Rudar (L). Izravan dvoboj klubova sa po šest bodova. Banjole su jedanaeste uz utakmicu manje i bez poraza su u tri utakmice, ali kod kuće ove sezone još nisu pobijedile: remi s Krkom i poraz od Buja. U gostima nisu izgubile nijednom, a u posljednjem kolu izborile su bod na teškom gostovanju u Novom Vinodolskom. Ahmed Durmo ima pet pogodaka, a Ivan Giljanović, koji je u utorak dvaput zabio Vinodolu, tri. Filip Rosić jedan je žuti karton od kazne. Rudar je trinaesti i izgubio je tri utakmice zaredom, uz jedanaest primljenih golova. U gostima ima pobjedu u Bujama 2:1 i poraze u Omišlju 0:5 i na Krku 1:4.

Naprijed (H) - Vinodol. Dvoboj fenjeraša: Vinodol je četrnaesti s pet bodova, Naprijed petnaesti s četiri. Pobjeda bi Naprijedu donijela sedam bodova i skok iznad Vinodola. Na Hreljinu ove sezone nije osvojio bod: tri poraza, uz gol razliku 1:9. Sva četiri boda donijela su mu gostovanja, pobjeda u Rovinju i remi u Poreču. Na klupi je Darko Deranja, a Robert Jandrek s tri pogotka najbolji je strijelac. Karlo Radošević jedan je žuti karton od kazne. Vinodol pod vodstvom Marka Čopa nije izgubio: pobjeda u Poreču, remi s Banjolama i pobjeda nad Kraljevicom u kupu. U gostima ima pobjedu, remi i poraz, uz gol razliku 3:3. Badara Seck ima četiri pogotka.

LJESTVICA

Lokomotiva vodi s petnaest bodova, uz utakmicu manje, jer joj je susret s Banjolama odgođen za 5. prosinca. Pomorac i Pazinka imaju po trinaest bodova, Krk jedanaest, a Kraljevica deset. Službena ljestvica je na stranici lige, jer uključuje i kaznene bodove Crikvenice.

KAZNE

Sedmo kolo propuštaju Lovro Šupraha (Kraljevica), isključen nakon drugog žutog kartona, i Tin Jurica (Krk), zbog četvrtog žutog kartona. Na tri žuta kartona, dakle jedan od kazne, su Filip Rosić (Banjole), Ivan Lukarić (Crikvenica), Vedran Radman (Jadran-Poreč), Lovre Travica (Krk), Karlo Radošević (Naprijed), Gabriel Buršić (Pazinka-Pazin) i Matej Vladišković (Rovinj).',
  '3. NL Zapad',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-7-kola-3-nl-zapad-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-7-kola-3-nl-zapad-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-7-kola-3-nl-zapad-2627';

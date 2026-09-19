-- =====================================================================
-- ČLANAK: PREGLED 5. KOLA 3. NL ZAPAD 2026/27
-- Odigrano 19.09.2026.
-- =====================================================================
-- KAKO SE KORISTI: pokreni po redu dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   Zatim ide KORAK 2 (objava).
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- ODAKLE STO
--   Rezultati, strijelci s minutama, kartoni, gledatelji i stadioni
--   dolaze iz zapisnika sa Semafora, procitanih poslom "Ispis kola"
--   (Actions, 19.09.2026. u 19:18 po nasem). Isti su zapisnici istog
--   navecer usli i u bazu, punim prolazom scrapera.
--   Ljestvica i pomaci su izracunati iz rezultata svih pet kola, uz
--   kaznene bodove Crikvenice. Zasto ne sa Semafora, vidi nize.
--   Nijedna recenica nije dopisana izvan toga: nema opisa tijeka igre,
--   ocjena ni izjava, jer taj podatak u bazi ne postoji.
--
-- PROVJERENO PRIJE PISANJA
--   Zbroj strijelaca po stranama slaze se s rezultatom na svih sedam
--   utakmica. Krk - Rudar 4:1 se slaze tek s autogolom: Krk ima tri
--   strijelca, a cetvrti pogodak je autogol Antonija Nacinovica iz 16.
--   minute, koji je scraper sam prepoznao po klasi own_goal.
--   Izracunata ljestvica nakon 4. kola daje Lokomotiva 12, Kraljevica
--   10, Pomorac 9, tocno kako je stajalo u najavi 5. kola. To je
--   provjera da racun nije promasen.
--
-- PAZI: SLUZBENA LJESTVICA JE BILA NA POLA POSLA
--   U trenutku scrapea (19:10 do 19:18 po nasem, dakle odmah nakon
--   zadnjeg zvizduka) HNS je u ljestvicu upisao 5. kolo za sedam
--   klubova, a za sedam jos nije. Provjereno klub po klub: redci
--   Pomorca, Pazinke, Krka, Rudara, Halubjana i Naprijeda ukljucuju
--   ovo kolo, a redci Kraljevice, Nehaja, Omislja, Jadrana, Buja,
--   Rovinja, Crikvenice i Vinodola pokazuju stanje nakon 4. kola.
--   Lokomotiva i Banjole ovo kolo nisu ni igrali.
--   To je ista bolest opisana u CLAUDE.md pod "HNS ne osvjezi sve
--   dijelove stranice odjednom", samo ovaj put na ljestvici, a ne na
--   rang-listama. Tablica se scrapa i ne racuna, pa je takva usla i u
--   bazu i takva je sada na stranici lige.
--   LIJEK JE POZNAT I BESPLATAN: jos jedno pokretanje scrapera. Pokreni
--   "Scraper HNS Semafor" prije objave ovog clanka, pa provjeri da na
--   stranici lige svih cetrnaest klubova koji su igrali ima 5 odigranih
--   utakmica. Dok to nije tako, recenica "Sluzbena ljestvica je na
--   stranici lige" upucuje na polovicnu tablicu.
--   Brojke u tekstu su tocne bez obzira na to, jer su racunate iz
--   rezultata, a ne prepisane s ljestvice.
--
-- KAZNE
--   Tri iskljucenja: Gabriel Bursic (Pazinka) i Andro Depeder
--   (Kraljevica) nakon drugog zutog kartona, Petar Vidovic
--   (Crikvenica) nakon crvenog.
--   Zuti kartoni se navode kao brojka, bez rijeci o tome sto slijedi.
--   Prag od cetiri zuta jos nije potvrdjen u propozicijama, pa se o
--   posljedicama ne pise (isto pravilo kao u najavi 5. kola).
--
-- ODGODJENA UTAKMICA
--   Lokomotiva (R) - Banjole igra se 05.12.2026. u 13:00, pa je u ovom
--   kolu odigrano sedam utakmica.
--
-- BEZ FOTOGRAFIJE
--   Clanak nema sliku, pa se na kartici prikazuje zaglavlje 3. NL
--   Zapad, a pri dijeljenju zajednicka slika Lokal-Arene.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'pregled-5-kola-3-nl-zapad-2627',
  'POMORAC STIGAO LOKOMOTIVU, KRALJEVICA IZGUBILA PRVI PUT',
  'Kolo bez ijednog remija. Pomorac je slavio u Brnasima i izjednačio se s Lokomotivom na vrhu, Crikvenica je s igračem više svladala Kraljevicu, a Vinodol je u Poreču došao do prve pobjede u sezoni.',
'Peto kolo 3. NL Zapad odigrano je u subotu 19. rujna i prošlo je bez ijednog remija. Od sedam utakmica četiri su pripale domaćinima, a tri gostima. Palo je 22 pogotka, više od tri po utakmici, a trojica igrača završila su susret prije kraja. Utakmica Lokomotiva (R) - Banjole premještena je za 5. prosinca, pa su te dvije momčadi ovo kolo odmarale.

Crikvenica - Kraljevica 1:0. Najvažnija utakmica kola odigrana je na Gradskom stadionu u Crikvenici, pred 70 gledatelja. Gosti su od 61. minute ostali s igračem manje, jer je Andro Depeder dobio drugi žuti karton, a jedanaest minuta kasnije Luka Mikulica zabio je jedini pogodak. Kraljevica je tako upisala prvi poraz sezone i propustila priliku da se popne na vrh. U sudačkoj nadoknadi crveni karton vidio je i domaći Petar Vidović. Crikvenici je to druga pobjeda zaredom.

Halubjan - Pomorac 0:3. U Brnasima je bilo 200 gledatelja, najviše u kolu. Marino Matković zabio je u 41. i 61. minuti, a Ian Benčić u 71. Pomorcu je to treća pobjeda zaredom i njome je stigao Lokomotivu na vrhu ljestvice.

OŠK Omišalj - Rovinj 4:2. Najviše golova vidjelo se na Pušći. David Rožajac doveo je domaće u vodstvo u 26. minuti, Niko Šerifović izjednačio je u 36., a onda su Mateo Ostović u 49. i Rožajac svojim drugim pogotkom u 54. minuti odveli Omišalj na 3:1. Manuel Poropat smanjio je u 90., a Sanjin Grbac je u drugoj minuti sudačke nadoknade postavio konačnih 4:2.

Krk - Rudar (L) 4:1. Krk je na Josipu Uraviću-Pepiju poveo već u 6. minuti pogotkom Mirka Valenčića, a u 16. je prednost udvostručio autogol Antonija Načinovića. Lovre Travica zabio je dvaput, u 44. minuti i na isteku prvog poluvremena, dok je Patrik Čenaj u 61. bio jedini strijelac Labinjana.

Naprijed (H) - Pazinka-Pazin 1:2. Kolo je otvoreno u 15 sati na Lonji u Hreljinu. Mate Ivetić doveo je Pazinku u vodstvo u 32. minuti, Robert Jandrek izjednačio je u 53., a Nikola Petković je u 73. odlučio susret. Pazinka je posljednjih petnaestak minuta igrala s igračem manje, jer je Gabriel Buršić u 74. minuti dobio drugi žuti karton. Na toj je utakmici podijeljeno osam žutih kartona, najviše u kolu.

Buje - Nehaj 2:1. Na Gradskom stadionu u Bujama sva tri pogotka pala su u razmaku od četiri minute. Lucijan Tomac doveo je Nehaj u vodstvo u 21. minuti, Mateo Maras izjednačio je u 23., a Damir Bartulović je u 25. minuti okrenuo rezultat. Nehaj je time upisao treći poraz zaredom.

Jadran-Poreč - Vinodol 0:1. Vinodol je na Velom Joži došao do prve pobjede u sezoni. Jedini pogodak zabio je Edmar Junior Dos Santos Neves u 55. minuti.

STRIJELCI

Jakob Šprem-Veljavečki iz Pomorca i dalje vodi listu strijelaca sa šest pogodaka, iako u ovom kolu nije zabio. Iza njega su s po pet Ahmed Durmo iz Banjola, David Rožajac iz Omišlja i Marino Matković iz Pomorca, a Rožajac i Matković su upravo u ovom kolu zabili po dva. Dvaput je zabio i Lovre Travica za Krk. S po četiri pogotka slijede Karlo Josipović i Lucijan Tomac. Hat-tricka nije bilo.

LJESTVICA

Pomorac je pobjedom u Brnasima stigao Lokomotivu na vrhu, obje momčadi imaju dvanaest bodova. Riječani su prvi, jer imaju bolju gol razliku i utakmicu manje. Slijede Kraljevica i Pazinka s po deset bodova, Omišalj s devet i Krk s osam. Na dnu su Rovinj i Naprijed s po tri boda.

Najviše su u kolu dobili Krk i Buje, po četiri mjesta. Crikvenica i Vinodol napredovali su po tri, a najviše su izgubili Nehaj i Rudar, po tri mjesta.

ZA SLJEDEĆE KOLO

Šesto kolo propuštaju trojica isključenih: Gabriel Buršić (Pazinka-Pazin) i Andro Depeder (Kraljevica) nakon drugog žutog kartona te Petar Vidović (Crikvenica) nakon crvenog.

Po četiri žuta kartona skupili su Marcelo Suden (Vinodol), Matej Prizmić (Nehaj) i Paulo Kocijan (Kraljevica). Na tri su Andres Camilo De Armas Bracho i Matej Vladišković (Rovinj), Filip Rosić (Banjole), Ivan Lukarić (Crikvenica), Karlo Radošević (Naprijed), Tin Jurica (Krk) i Vedran Radman (Jadran-Poreč).

Raspored šestog kola je na stranici lige.',
  '3. NL Zapad',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-5-kola-3-nl-zapad-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'pregled-5-kola-3-nl-zapad-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-5-kola-3-nl-zapad-2627';


-- =====================================================================
-- PROVJERA LJESTVICE PRIJE OBJAVE
-- =====================================================================
-- Pokazuje koliko utakmica po klubu ima sluzbena ljestvica u bazi.
-- Svih cetrnaest klubova koji su igrali 5. kolo mora imati 5, a
-- Lokomotiva i Banjole 4. Ako nije tako, pokreni scraper pa ponovi.
--
-- select klub ->> 'klub' as klub, klub ->> 'odigrano' as odigrano
-- from public.statistike,
--      lateral jsonb_array_elements(podaci) as klub
-- where sezona = '2026/27' and natjecanje = '3. NL Zapad' and tip = 'tablica'
-- order by (klub ->> 'pozicija')::int;

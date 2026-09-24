-- =====================================================================
-- ČLANAK: NAJAVA 6. KOLA 3. NL ZAPAD 2026/27
-- Igra se u subotu 26.09.2026.; Vinodol - Banjole u utorak 29.09.
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
--   Raspored 6. kola procitan je iz ispisa scrapera (prolazi 19. i 22.9.).
--   Stanje, strijelci, pomaci i iskljucenja iz
--   public.pregled_kola('2026/27','3. NL Zapad',5).
--   Rezultati iz kupa (Pomorac, Omisalj, Kraljevica, Crikvenica,
--   Halubjan, Vinodol, Lokomotiva) iz clanka o 1/16 finala, dakle sa
--   slika koje je poslao Andrej.
--   ANDREJEVO, cega u bazi nema: nova pojacanja Lokomotive (Dino
--   Bradaric iz Grobnicana, Antonio Pejanovic, dugogodisnji strijelac
--   Opatije), promjena trenera u Jadranu (odlazi Vjekoslav Dorcic,
--   dolazi Elvis Kastrati), da je Marko Cop vodio Vinodol i u kupu, te
--   sve ocjene i dosjetke ("Kovari ce morati puno rudariti", "oba daju
--   3+", "uzavreli Senj", "lagani pad forme").
--   Treneri Naprijeda i Vinodola iz pregleda 5. kola, gdje ih je
--   Andrej naveo.
--
-- STADIONI
--   Nema ih u ispisu, pa su po Andrejevoj uputi navedeni oni na kojima su
--   domacini igrali posljednju domacu utakmicu.
--
-- ZUTI KARTONI
--   Andrej je 24.09.2026. potvrdio da je u 3. NL Zapad prag cetiri zuta.
--   Zato Kocijan, Prizmic i Suden, koji su cetvrti zuti dobili u 5. kolu,
--   u tekstu pauziraju, a igraci na tri pisu se kao "jedan od kazne".
--
-- PREMJESTENA UTAKMICA
--   Vinodol - Banjole je s 26.09. premjestena na 29.09.2026. u 16:30.
--
-- LJESTVICA
--   sluzbena_tablica_odstupa je true (Crikvenica ima kaznene bodove), pa
--   se navodi samo vrh i uputa na sluzbenu ljestvicu.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-6-kola-3-nl-zapad-2627',
  'NAJAVA 6. KOLA: DODATNO POJAČANA LOKOMOTIVA VRAĆA SE NAKON STANKE, POMORAC JU JE U MEĐUVREMENU STIGAO',
  'Vodeća Lokomotiva, pojačana s dva nova igrača, nakon jedanaest dana bez utakmice gostuje u Labinu, a Pomorac, koji ju je dok je odmarala stigao na dvanaest bodova, dočekuje Buje. Vinodol i Banjole igraju tek u utorak.',
'Šesto kolo 3. NL Zapad igra se u subotu 26. rujna, i to svih sedam utakmica u 16:30. Susret Vinodol - Banjole premješten je na utorak 29. rujna, također u 16:30.

Rudar (L) - Lokomotiva (R). Lokomotiva se vraća na teren nakon jedanaest dana: posljednju utakmicu odigrala je 15. rujna u Novom Vinodolskom, peto kolo je propustila jer je susret s Banjolama premješten na prosinac, a u kupu je prošla dalje bez igranja, jer je Rikard Benčić predao. U međuvremenu je dovela i dva nova pojačanja: Dina Bradarića, mladog napadača iz Grobničana, i Antonija Pejanovića, dugogodišnjeg strijelca Opatije i dobro poznato, renomirano ime na ovom području. Iz četiri utakmice ima četiri pobjede i gol razliku plus dvanaest, a Karlo Josipović s četiri i Edin Junuzović s tri pogotka predvode njezine strijelce. Rudar je nakon dvije pobjede izgubio dvaput zaredom, od Crikvenice kod kuće i na Krku 4:1, a Lokomotivu dočekuje na Gradskom stadionu u Labinu. Kovari će morati puno rudariti za bodove u ovome susretu.

Pomorac - Buje. Pomorac je, dok je Lokomotiva mirovala, upisao treću pobjedu zaredom, 3:0 u Brnasima uz dva gola Marina Matkovića, i stigao ju na dvanaest bodova. Riječani su ispred zbog bolje gol razlike i utakmice manje. Pomorac ima i dva najbolja strijelca u svojim redovima: Jakob Šprem-Veljavečki vodi ligu sa šest pogodaka, a Matković je s pet među onima odmah iza. U kupu je, doduše, u utorak ispao od Halubjana nakon penala. Buje na pomoćno igralište na Žuknici u Kostreni dolaze nakon pobjede nad Nehajem 2:1, u kojoj su Mateo Maras i Damir Bartulović zabili u razmaku od dvije minute.

Pazinka-Pazin - OŠK Omišalj. Četvrti protiv petog, s bodom razlike, na SC Egidie Marion u Pazinu. Pazinka je bez poraza u posljednje četiri utakmice, a u Hreljinu je slavila 2:1 golovima Mate Ivetića i Nikole Petkovića. U subotu ostaje bez Gabriela Buršića, isključenog nakon drugog žutog kartona. Omišalj je u petom kolu svladao Rovinj 4:2, a David Rožajac je s dva gola stigao do pet u sezoni. U utorak je Omišalj u kupu prošao na Cresu nakon raspucavanja. Kako bi kladioničari rekli, miriši na oba daju 3+.

Kraljevica - Krk. Kraljevica je u laganom padu forme i traži povratak na staze pobjeda. U pet dana dvaput je izgubila 0:1: u Crikvenici je upisala prvi prvenstveni poraz sezone, a u kupu je ispala u Novom Vinodolskom. Na Mintu dočekuje Krk bez dvojice: Andre Depedera, isključenog u Crikvenici nakon drugog žutog kartona, i Paula Kocijana, koji je u istom susretu dobio četvrti žuti karton. Krk je u petom kolu razbio Rudar 4:1 i skočio četiri mjesta, a Lovre Travica zabio je dvaput na samom kraju prvog poluvremena.

Nehaj - Crikvenica. Nehaj je izgubio tri utakmice zaredom, i to sve tri istim rezultatom, 1:2. Lucijan Tomac s četiri pogotka i dalje mu je najbolji strijelac, a na stadionu Nehaj u subotu nema Mateja Prizmića, koji je u Bujama dobio četvrti žuti karton. Crikvenica je u suprotnom nizu: dvije prvenstvene pobjede zaredom, u Labinu i protiv Kraljevice, a u utorak i 4:1 na Krasici u kupu. U Senj ipak putuje bez Petra Vidovića, isključenog nakon nervoznog završetka utakmice protiv Kraljevice. Nervoze bi vrlo lako moglo biti i u uzavrelom Senju.

Rovinj - Halubjan. Susret s dna ljestvice na Valbruni. Rovinj je bez pobjede u posljednje četiri utakmice i u Omišlju je primio četiri gola. Halubjan je u petom kolu izgubio od Pomorca 0:3, ali mu je samo tri dana kasnije, u kupu, uzvratio izbacivanjem nakon penala.

Jadran-Poreč - Naprijed (H). Na Velom Joži obje klupe su nove. Jadran je u međuvremenu promijenio trenera: Vjekoslav Dorčić napustio je klupu, a klub mu se iskreno zahvalio na svemu učinjenom u proteklom razdoblju. Na njegovo mjesto dolazi Elvis Kastrati, 32-godišnji nositelj UEFA A licence, koji je prethodno vodio Funtanu, a uspješne epizode imao je i u omladinskim kategorijama Jadrana, pa ne dolazi u nepoznato. Jadran je izgubio dvaput zaredom, u Pazinu 0:3 i kod kuće od Vinodola 0:1, a Ilija Batrićević ima tri gola. Naprijed je posljednji, s tri boda i gol razlikom minus deset, a s klupe ga od prošlog kola vodi Darko Deranja. Robert Jandrek s tri pogotka mu je najbolji strijelac.

Vinodol - Banjole, u utorak. Otkako je klupu preuzeo Marko Čop, Vinodol je dobio obje utakmice, u Poreču u prvenstvu i protiv Kraljevice u kupu. Na Bahalinu ipak ostaje bez Marcela Sudena, koji je u Poreču dobio četvrti žuti karton. Banjole ne igraju od 15. rujna, jer im je peto kolo odgođeno, a Ahmed Durmo ima pet pogodaka.

LJESTVICA

Lokomotiva i Pomorac vode s po dvanaest bodova, ispred Kraljevice i Pazinke s deset te Omišlja s devet. Službena ljestvica je na stranici lige, jer ona uključuje i kaznene bodove Crikvenice.

KAZNE

Šesto kolo propuštaju Andro Depeder (Kraljevica) i Gabriel Buršić (Pazinka-Pazin), obojica isključeni nakon drugog žutog kartona, te Petar Vidović (Crikvenica), isključen u sudačkoj nadoknadi. Zbog četvrtog žutog kartona pauziraju Paulo Kocijan (Kraljevica), Matej Prizmić (Nehaj) i Marcelo Suden (Vinodol). Na tri žuta kartona, dakle jedan od kazne, su Filip Rosić (Banjole), Ivan Lukarić (Crikvenica), Vedran Radman (Jadran-Poreč), Tin Jurica (Krk), Karlo Radošević (Naprijed) te Andres Camilo De Armas Bracho i Matej Vladišković (Rovinj).',
  '3. NL Zapad',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-6-kola-3-nl-zapad-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-6-kola-3-nl-zapad-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-6-kola-3-nl-zapad-2627';

-- =====================================================================
-- SAŽETAK UZ ZAPISNIK: NK BORAC (Ba) - NK LIŽNJAN 3:2
-- Derbi 3. kola 4. NL NS Rijeka 2026/27, 19.09.2026., Krasica,
-- 50 gledatelja, bez iskljucenja.
-- =====================================================================
-- KAMO OVO IDE
--   U stupac utakmice.tekst_clanka, dakle u sam redak te utakmice, a NE
--   u tablicu clanci. Stranica ga prikazuje ispod zapisnika. Scraper taj
--   stupac ne dira, pa prezivljava svako osvjezavanje.
--
-- KAKO SE KORISTI
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Nema koraka "objava": cim se stupac napuni, tekst je na stranici.
--   Pokretanje se smije ponoviti; drugi put samo prepise isti tekst.
--
-- ODNOS PREMA CLANKU
--   Sazeta verzija clanka iz sql/clanak_borac_liznjan_3_kolo.sql. Isti
--   su izvori: tijek i prilike su Andrejevi s tribine, a rezultat,
--   strijelci, minute pogodaka i gledatelji iz zapisnika.
--
-- AUTOGOL
--   Pogodak u 45+1 HNS je oznacio kao autogol Ivana Golica i pripisao ga
--   Liznjanu, pa rucni unos u utakmice.autogolovi nije potreban.
--
-- DERBI KOLA
--   Utakmica je vec oznacena kao derbi kola, oznaka je stavljena
--   17.09.2026. uz najavu.
-- =====================================================================


-- =====================================================================
-- UPIS SAŽETKA
-- =====================================================================
update public.utakmice
set tekst_clanka =
'Derbi kola na Krasici pripao je domaćinima, a pogoci Borca nose isti rukopis: kontra, izlazak sam na vratara, mirno rješenje. Prvi je pao u 27. minuti, kada je Josip Tkalčević nakon prodora pucao, Luka Jukić je obranio, a odbijenu loptu u praznu mrežu poslao je Filip Jagić.

Ližnjan je izjednačio u sudačkoj nadoknadi prvog poluvremena. Probio je desnu stranu, koju je i prije toga otvarao, a prizemni ubačaj nespretno je skrenut u vlastita vrata. Prije toga su gosti imali dvije dobre prilike, a najbolju u 39., kada je Saša Urošević s dvadesetak metara pogodio vratnicu.

Drugo poluvrijeme počelo je još jačim intenzitetom. U 63. je Tkalčević pobjegao svom čuvaru u kontri nakon kornera Ližnjana, suočio se s vratarom i pogodio u kut za novo vodstvo. Nakon toga se osjetila nervoza i bilo je nekoliko grubljih startova, ali je sudac držao utakmicu pod kontrolom i isključenja nije bilo.

Jukić je držao Ližnjan u igri, sigurno i nogom braneći slobodan udarac Mihaela Šušnjara u 80. te udarac Ivana Golića s tridesetak metara u 84. minuti. Ližnjan nije posustao, ali ništa konkretnije nije stvorio, dok je Borac svakim prelaskom sredine terena bio opasniji.

U 88. je iz kontre Ivan Ferinac ostao sam pred vratarom i zabio od stative za 3:1, no kraj je ipak bio neizvjestan: u četvrtoj minuti nadoknade Luka Pavić pogodio je s 25 metara u rašlje za 3:2. Za preokret više nije bilo vremena i Borac je zasluženo odnio tri boda.'
where natjecanje = '4. NL NS Rijeka'
  and sezona     = '2026/27'
  and kolo       = 3
  and domacin    = 'NK Borac (Ba)'
  and gost       = 'NK Ližnjan'
returning domacin, gost, rezultat, left(tekst_clanka, 60) as pocetak;


-- =====================================================================
-- PROVJERA
-- =====================================================================
select natjecanje, kolo, domacin, gost, rezultat, derbi, gledatelja,
       length(tekst_clanka) as duljina_teksta
from public.utakmice
where natjecanje = '4. NL NS Rijeka'
  and sezona     = '2026/27'
  and kolo       = 3
  and domacin    = 'NK Borac (Ba)'
  and gost       = 'NK Ližnjan';

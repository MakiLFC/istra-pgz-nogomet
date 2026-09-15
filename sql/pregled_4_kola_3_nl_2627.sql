-- =====================================================================
-- ČLANAK: PREGLED 4. KOLA 3. NL ZAPAD 2026/27
-- Odigrano u utorak 15.09.2026., sredinom tjedna.
-- =====================================================================
-- KAKO SE KORISTI: pokreni po redu dva koraka na dnu datoteke.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Prvi korak (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   Zatim ide KORAK 2 (objava).
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- ODAKLE STO
--   Sve u tekstu dolazi iz public.pregled_kola('2026/27','3. NL Zapad',4),
--   dakle iz zapisnika u bazi: rezultati, strijelci, minute, kartoni,
--   gledatelji i pomaci na ljestvici. Nijedna recenica nije dopisana
--   izvan toga, nema opisa tijeka igre ni ocjena, jer taj podatak u bazi
--   ne postoji. Ako zelis dodati ono sto si vidio na terenu, dopisi u
--   tekst prije objave, kao kod pregleda 2. kola.
--
--   JEDINA IZNIMKA je recenica o akciji "Korak za Matiju" uz utakmicu u
--   Labinu. Ona ne dolazi iz baze nego iz nase vlastite najave 4. kola,
--   gdje je akcija najavljena. Zato u tekstu pise da je bila najavljena,
--   a ne kako je prosla, jer toga nemamo. Slobodno je izbaci ako ti se
--   cini suvisnom.
--
-- PROVJERENO PRIJE PISANJA
--   Zbroj strijelaca po stranama slaze se s rezultatom na svih osam
--   utakmica, dakle nema neoznacenog autogola ni pogotka koji u
--   zapisniku fali ili stoji dvaput.
--
--   AUTOGOL u Kraljevici: polje "klub" uz strijelca u pregled_kola()
--   vec nosi momcad kojoj pogodak PRIPADA, ne momcad strijelca (vidi
--   napomenu 11 na vrhu sql/pregled_kola.sql). Pogodak Matije
--   Susterajtera u 17. minuti stoji pod Kraljevicom, dakle Susterajter
--   je igrac Buja. U tekstu mu zato klub nije naveden, samo da je rijec
--   o autogolu. Bez te ispravke zbroj bi davao 1:3, a rezultat je 2:2.
--
-- KARTONI
--   Dva crvena kartona, oba na utakmici u Senju. Simon Simonaj je
--   iskljucen nakon drugog zutog, Luka Lopac je dobio izravan crveni.
--   U tekstu se ne koristi izraz "zuto-crveni karton", nego se opisuje
--   onako kako se govori, kao i dosad.
--
-- ZUTI KARTONI
--   Prag od cetiri zuta kartona NIJE potvrdjen u propozicijama, pa se u
--   tekstu ne tvrdi da cetvrti znaci kaznu. Navedeno je samo koliko tko
--   ima.
--
-- LJESTVICA
--   pregled_kola() racuna tablicu iz utakmica i NE zna za kaznene bodove,
--   a Crikvenica ih ima tri. Zato u tekstu stoje samo vrh ljestvice i
--   pomaci, koje ti bodovi ne mijenjaju, uz uputu na sluzbenu ljestvicu
--   na stranici lige. Dno ljestvice se namjerno ne navodi, jer se ondje
--   kazneni bodovi Crikvenice i osjete.
--
-- KRALJEVICA
--   Derbi Kraljevica - Buje opisan je kratko, samo rezultatom i
--   strijelcima, jer o njemu ide zaseban tekst.
--
-- BEZ FOTOGRAFIJE
--   Clanak nema sliku, pa se na kartici prikazuje zaglavlje 3. NL Zapad,
--   a pri dijeljenju zajednicka slika Lokal-Arene.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'pregled-4-kola-3-nl-zapad-2627',
  'NAPRIJED DO PRVE POBJEDE, LOKOMOTIVA SAMA NA VRHU',
  'Hreljin je u Rovinju zabio prve pogotke sezone i uzeo prve bodove, Kraljevica je u derbiju s Bujama ispustila prve, a Pazinka je skočila šest mjesta.',
'Četvrto kolo 3. NL Zapad odigrano je sredinom tjedna, u utorak 15. rujna. Gosti su odnijeli četiri pobjede, domaćini dvije, a dvije su utakmice završile neriješeno. Palo je 28 pogodaka, u prosjeku tri i pol po utakmici, što je manje nego u prethodnom kolu. Oba crvena kartona u kolu pala su na istoj utakmici, u Senju.

Rovinj - Naprijed (H) 1:3. Najveću vijest kola donio je Hreljin. Naprijed je u prva tri kola izgubio sve i nije zabio nijedan pogodak, jedini takav u ligi, a na Valbruni je zabio tri puta i uzeo prve bodove. Robert Jandrek pogodio je u 7. i 43., Dino Dukađin u 17. minuti, a Niko Šerifović smanjio je za domaće u 49. Rovinj je tako ostao na tri kola bez pobjede.

Vinodol - Lokomotiva (R) 0:4. Vodeća momčad lige upisala je četvrtu pobjedu u četiri kola, ujedno najuvjerljiviju u kolu. Na Bahalinu su zabili Edin Junuzović u 7., Karlo Josipović u 25. te Frano Ivančić u 59. i 70. minuti. Lokomotiva je sada sama na vrhu ljestvice, s gol razlikom plus dvanaest. Vinodol je na četiri kola bez pobjede.

Nehaj - Halubjan 1:2. Po mjestima na ljestvici ovo je bio najveći obrat kola: četvrtoplasirani Nehaj izgubio je kod kuće od četrnaestog Halubjana. Lucijan Tomac doveo je domaće u vodstvo na isteku prvog poluvremena, a onda je Antonio Dedić zabio dvaput, u 64. i 77. minuti. Završnica je bila gruba. Simon Simonaj iz Halubjana isključen je u 84. minuti nakon drugog žutog kartona, a Luka Lopac iz Nehaja dobio je crveni karton u sudačkoj nadoknadi. Halubjan je prekinuo niz od dva poraza.

Pazinka-Pazin - Jadran-Poreč 3:0. Najveći skok kola napravila je Pazinka, šest mjesta, s desetog na četvrto. Mate Ivetić zabio je u 8., Gabriel Buršić u 43., a Entony Pavat u 68. minuti. Pazinka je na tri kola bez poraza, dok je Jadran nakon dvije pobjede zaredom ostao bez pogotka.

Pomorac - OŠK Omišalj 3:1. Na Žuknici je gost poveo već u 5. minuti pogotkom Davida Rožajca, ali je Jakob Šprem-Veljavečki okrenuo rezultat s dva pogotka, u 15. i 39. minuti, a Artem Terletskyi potvrdio je pobjedu u 69. Pomorac je time treći, s devet bodova.

Kraljevica - Buje 2:2. Derbi kola na Minti donio je Kraljevici prve ispuštene bodove ove sezone. Matija Kalizan doveo je Buje u vodstvo u 15. minuti, dvije minute poslije izjednačio je autogol Matije Šusterajtera, Victor Kargbo vratio je gostima prednost u 78., a Franko Bosančić postavio je konačni rezultat u 87. minuti. Kraljevica je i dalje neporažena i druga na ljestvici.

Rudar (L) - Crikvenica 0:2. Crikvenica je u Labinu upisala prvu pobjedu u sezoni. Petar Vidović zabio je u 71., Damjan Mendrila u 81. minuti. Uz tu je utakmicu bila najavljena i humanitarna akcija „Korak za Matiju“, za koju je Rudar najavio da će donirati prihod od prodaje ulaznica.

Banjole - Krk 2:2. Na Prematinki je Ahmed Durmo doveo domaće u vodstvo u 50. minuti, Krk je u razmaku od dvije minute okrenuo pogocima Marka Jelića u 75. i Emanuela Mrakovčića u 77., a Paolo Matteoni izjednačio je u 82. minuti.

STRIJELCI

Jakob Šprem-Veljavečki iz Pomorca sada je sam na vrhu liste strijelaca, sa šest pogodaka, od toga dva u ovom kolu. Slijede ga Ahmed Durmo iz Banjola s pet i Karlo Josipović iz Lokomotive s četiri. Po dva pogotka u kolu zabili su još Antonio Dedić za Halubjan, Frano Ivančić za Lokomotivu i Robert Jandrek za Naprijed. Hat-tricka nije bilo.

LJESTVICA

Lokomotiva je sama na vrhu s dvanaest bodova, Kraljevica ima deset, a Pomorac devet. Pazinka je četvrta sa sedam bodova, a slijede Nehaj, OŠK Omišalj, Rudar i Jadran-Poreč, sva četiri sa šest.

Uz Pazinku, koja je dobila šest mjesta, popeli su se još Halubjan i Crikvenica, po dva. Najviše su izgubili Rovinj i Vinodol, po tri mjesta.

Neporaženi su i dalje samo Lokomotiva i Kraljevica, obje četiri kola.

Službena ljestvica je na stranici lige, jer ona uključuje i kaznene bodove Crikvenice.

GLEDATELJI

Po stotinu gledatelja zabilježeno je u Kraljevici, Senju, Rovinju i Labinu, na Žuknici sedamdeset, a na Prematinki šezdeset. Za utakmice u Novom Vinodolskom i Pazinu podatka o posjećenosti nema.

ZA SLJEDEĆE KOLO

Peto kolo propuštaju Simon Simonaj iz Halubjana, isključen nakon drugog žutog kartona, i Luka Lopac iz Nehaja, koji je dobio crveni karton. Po tri žuta kartona i dalje imaju Paulo Kocijan iz Kraljevice i Marcelo Suden iz Vinodola.

Raspored petog kola je na stranici lige.',
  '3. NL Zapad',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-4-kola-3-nl-zapad-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'pregled-4-kola-3-nl-zapad-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-4-kola-3-nl-zapad-2627';

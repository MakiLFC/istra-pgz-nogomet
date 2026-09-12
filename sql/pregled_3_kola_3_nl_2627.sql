-- =====================================================================
-- ČLANAK: PREGLED 3. KOLA 3. NL ZAPAD 2026/27
-- Odigrano 12.09.2026.
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
--   Sve u tekstu dolazi iz public.pregled_kola('2026/27','3. NL Zapad',3),
--   dakle iz zapisnika u bazi: rezultati, strijelci, minute, gledatelji i
--   pomaci na ljestvici. Nijedna recenica nije dopisana izvan toga, nema
--   opisa tijeka igre ni ocjena, jer taj podatak u bazi ne postoji.
--   Ako zelis dodati ono sto si vidio na terenu, dopisi u tekst prije
--   objave, kao kod pregleda 2. kola.
--
-- PROVJERENO PRIJE PISANJA
--   Zbroj strijelaca po stranama slaze se s rezultatom na svih osam
--   utakmica, dakle u ovom kolu nema neoznacenog autogola ni pogotka
--   koji u zapisniku fali ili stoji dvaput.
--   Crvenih kartona nema nijedan, pa je "suspendirani" prazan.
--   "na_pragu" je takodjer prazan, ali uz pretpostavljeni prag od cetiri
--   zuta kartona, koji jos nije potvrdjen u propozicijama.
--
-- LJESTVICA
--   pregled_kola() racuna tablicu iz utakmica i NE zna za kaznene bodove,
--   a Crikvenica ih ima tri. Zato u tekstu stoje samo vrh ljestvice i
--   pomaci, koje ti bodovi ne mijenjaju, uz uputu na sluzbenu ljestvicu
--   na stranici lige. Dno ljestvice se namjerno ne navodi, jer se ondje
--   kazneni bodovi Crikvenice i osjete.
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
  'pregled-3-kola-3-nl-zapad-2627',
  'PET GOSTUJUĆIH POBJEDA, BANJOLE I POMORAC ZABILI PO PET',
  'Lokomotiva i Kraljevica jedine su s tri pobjede iz tri kola, Nehaj je izgubio prvi put, a kolo je prošlo bez ijednog crvenog kartona.',
'Treće kolo 3. NL Zapad odigrano je u subotu 12. rujna i pripalo je gostima. Od osam utakmica pet je završilo pobjedom gostujuće momčadi, dvije su pripale domaćinima, a jedna je podijelila bodove. Mreže su se zatresle 33 puta, u prosjeku više od četiri pogotka po utakmici, a kolo je prošlo bez ijednog crvenog kartona.

Crikvenica - Banjole 1:5. Najviše golova u kolu vidjelo se na Gradskom stadionu u Crikvenici. Banjole su do poluvremena riješile pitanje pobjednika: Sandi Mofardin zabio je u 19., Ahmed Durmo u 22., Roni Vujičić u 35. minuti. Ivan Giljanović podebljao je prednost u 53., Paolo Brnja ublažio je poraz u 59., a Durmo je svoj drugi pogodak dodao u sudačkoj nadoknadi.

Naprijed (H) - Pomorac 0:5. Istim je omjerom prošao i Pomorac, na Lonji u Hreljinu. Benjamin Lapić otvorio je u 18., Marino Matković povisio u 21., Jakob Šprem-Veljavečki pogodio je na isteku prvog poluvremena, a nakon odmora su se upisali Artem Terletskyi u 57. i ponovno Šprem-Veljavečki u 75. minuti. Naprijed je jedini klub lige koji je izgubio sve tri dosadašnje utakmice.

Krk - Lokomotiva (R) 1:3. Riječani su na otoku upisali treću pobjedu u tri kola. Edin Junuzović zabio je u 14. minuti, Ivan Golemac izjednačio je za domaće u 27., a onda su Karlo Josipović u 78. i Mateo Monjac u sudačkoj nadoknadi odlučili susret.

Halubjan - Kraljevica 1:2. Kraljevica je u Brnasima ostala uz bok Lokomotive, također s tri pobjede iz tri kola. Andro Depeder doveo je goste u vodstvo u 31., Matija Čabrijan povisio je u 37., a Ivan Paurević smanjio je u 43. minuti.

OŠK Omišalj - Nehaj 2:1. Najveći preokret kola dogodio se na Pušći. Nehaj je poveo pogotkom Lucijana Tomca u 12. minuti, ali su domaći u razmaku od dvije minute okrenuli rezultat: David Rožajac zabio je u 32., Domagoj Prtenjača u 34. Nehaj je tako upisao prvi poraz u sezoni.

Jadran-Poreč - Rovinj 3:2. Na Velom Joži se igralo najotvorenije. Domaći su poveli 2:0 pogocima Ilije Batrićevića u 13. i Andreja Pekice u 33. minuti, Masimo Terlević smanjio je u 55., Pekica je svojim drugim pogotkom u 64. vratio dva gola prednosti, a Terlević je u sudačkoj nadoknadi postavio konačnih 3:2. Tu je utakmicu gledalo 170 ljudi, najviše u kolu.

Buje - Rudar (L) 1:2. Labinjani su na Gradskom stadionu u Bujama poveli pogotkom Paola Juričića u 44. minuti, Patrik Čenaj povisio je u 82., a pogodak Damira Bartulovića u 84. stigao je prekasno.

Pazinka-Pazin - Vinodol 2:2. Jedini remi kola odigran je u Pazinu. Badara Seck doveo je goste u vodstvo u 38., Deni Radovčić izjednačio je u 54., Edmar Junior Dos Santos Neves vratio je Vinodolu prednost u 59., a Leo Lenić je u 72. minuti postavio konačni rezultat.

STRIJELCI

Na vrhu liste strijelaca nakon tri kola su Ahmed Durmo iz Banjola i Jakob Šprem-Veljavečki iz Pomorca, obojica s po četiri pogotka i obojica s po dva u ovom kolu. Po dva puta u kolu zabili su još Andrej Pekica za Jadran-Poreč i Masimo Terlević za Rovinj. S po tri pogotka u sezoni prate ih Ilija Batrićević, Karlo Josipović, Marino Matković, Masimo Terlević i Matija Čabrijan. Hat-tricka nije bilo.

LJESTVICA

Bez izgubljenog boda su Lokomotiva i Kraljevica, obje s devet bodova. Lokomotiva ima gol razliku plus osam, Kraljevica plus šest. Slijede Pomorac, Nehaj, OŠK Omišalj, Jadran-Poreč i Rudar, svih pet sa šest bodova.

Najveći skok kola napravili su Rudar i Banjole, po četiri mjesta. Pomorac i Jadran-Poreč dobili su po tri. Najviše je izgubio Krk, pet mjesta, a Rovinj i Buje po četiri.

Službena ljestvica je na stranici lige, jer ona uključuje i kaznene bodove Crikvenice.

ZA SLJEDEĆE KOLO

Kolo je prošlo bez ijednog crvenog kartona, pa zbog njega nitko ne propušta četvrto kolo. Nitko nije ni na pragu žutih.

Raspored četvrtog kola je na stranici lige.',
  '3. NL Zapad',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-3-kola-3-nl-zapad-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'pregled-3-kola-3-nl-zapad-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-3-kola-3-nl-zapad-2627';

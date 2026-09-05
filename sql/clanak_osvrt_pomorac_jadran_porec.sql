-- =====================================================================
-- ČLANAK: OSVRT SA ŽUKNICE, POMORAC - JADRAN POREČ 2:3
-- 2. kolo 3. NL Zapad, 05.09.2026.
-- =====================================================================
-- KAKO SE KORISTI: pokreni po redu tri koraka na dnu datoteke.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Prvi korak (upis) je odmah ispod. Clanak se upisuje s
--   objavljen = false, dakle jos NIJE vidljiv na stranici.
--   Zatim ide KORAK 2 (slika) i KORAK 3 (objava).
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- TEKST je isti kao osvrt uz zapisnik te utakmice
-- (sql/osvrt_pomorac_jadran_porec_2_kolo.sql), po Andrejevoj uputi.
-- Stoji na dva mjesta, pa ako se kasnije mijenja, mijenja se na oba.
--
-- SAZETAK je podnaslov iz skice koju je Andrej odobrio 05.09.2026.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (bez slike, jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, slika_potpis,
   slika_kadar, objavljen, objavljeno_u)
values (
  'osvrt-pomorac-jadran-porec-2-kolo-2627',
  'BATRIĆEVIĆ DVAPUT KAZNIO POMORAC NA ŽUKNICI',
  'Domaćin je dvaput poveo, Jadran Poreč dvaput izjednačio, a onda u 84. minuti stigao do potpunog preokreta.',
'Na suncem okupanoj Žuknici Pomorac je u prvoj domaćoj utakmici ove sezone ugostio Jadran iz Poreča. Utakmica je odigrana na pomoćnom igralištu na umjetnoj travi, zbog radova na glavnom terenu.

Prvi su zaprijetili domaći. U 6. minuti Benčić je opasno ubacio s desne strane, ali je obrana Jadrana izbila u korner. Iz tog kornera Valjan je pucao glavom pored gola.

U 10. minuti Luka Paulinić našao se sam na vrhu šesnaesterca u dobroj prilici, no njegov udarac odlazi visoko iznad gola.

Prvu četvrtinu utakmice obilježila je tvrda igra i taktičko nadmudrivanje. Iz tog razdoblja vrijedi istaknuti još jedino opasan udarac Marka Heraka u 21. minuti s vrha šesnaesterca u okvir vrata, no vratar Pomorca pročitao je udarac i sigurno obranio.

U 29. minuti dolazi do tada najbolje prilike na utakmici. Matković sjajno uposluje Momčilovskog podvalivši mu loptu u prostor s desne strane kaznenog prostora, između dvojice gostujućih obrambenih igrača, no napadač Pomorca puca ravno u vratara.

Ta je prilika kao da je najavila ono što slijedi. Već sljedeće minute domaćin je dobio slobodni udarac s dvadesetak metara s desne strane, a nakon gotovo savršenog ubačaja Šprem Veljavečki glavom precizno pogađa vratnicu od koje se lopta odbija u nebranjeni dio mreže. Vratar Jadrana mogao ju je samo ispratiti pogledom.

Trebalo je vremena da se Jadran oporavi od primljenog gola, a onda je slijedio uraganski gostujući završetak prvog poluvremena.

Prvo je u 38. minuti Marko Herak ušao s lijevog krila na svoju desnu nogu, u stilu pravog "inside forwarda", i s vrha šesnaesterca pucao tik iznad gola.

Nedugo zatim, u 43. minuti, Kodrnja puca s 25 metara u sam kut gola. Vratar Pomorca odbio je loptu najbolje što je mogao, ispred sebe, a Ilija Batrićević ostao je nečuvan ispred vrata i odbijanac posprema u drugu stranu gola za izjednačenje.

Mogao je Jadran do potpunog preokreta već u prvom dijelu. U 46. minuti Jakovčić je lijepim prodorom ušao u kazneni prostor s lijeve strane i još ljepšim ubačajem pronašao Mrvčića, no on pogađa gornji okvir vrata, pa se na odmor odlazi s izjednačenim rezultatom.

Otvaranje drugog poluvremena nije moglo bolje početi za domaćina. U 50. minuti Matković je s desne strane igrališta vrlo lijepim udarcem iznenadio vratara i pogotkom izmamio pljesak s tribina.

Primljeni pogodak nije pokolebao goste, koji su odmah krenuli s kreiranjem šansi. U 53. minuti Paulinić puca po podu, s dvadesetak metara, pored gola.

U 55. minuti Jadran nastavlja s prijetnjama, udarcem glavom nakon ubačaja iz kuta, ali bez potrebe za reakcijom vratara.

U 57. minuti Mrvčić pokušava udarcem iz daljine, po sredini gola, što je lagano za reakciju domaćeg vratara. To razdoblje utakmice obilježila je i nervoza zbog nekoliko dvojbenih sudačkih odluka.

U 65. minuti Pomorac ima vrlo opasan udarac s vrha šesnaesterca kojega vratar odlično skreće u korner.

U 73. minuti počinje preokret gostiju. Nakon polukontre Mrvčić prima loptu na desnoj strani, solo prodorom ulazi u kazneni prostor, odličnim lažnjakom izbacuje dvojicu igrača Pomorca te nakon suočenja s Nicolettijem mirno pogađa suprotni kut gola za novo izjednačenje.

Sljedećih desetak minuta nije donijelo izrazite prilike, ali je pokazalo da se nijedna momčad ne želi zadovoljiti bodom.

A onda i rješenje utakmice. U 84. minuti brzonogi Herak probio se s lijevog krila u kazneni prostor Pomorca i snažno pucao. Nicoletti brani, ali loptu od siline udarca ne uspijeva uhvatiti u potpunosti, već se ona odbija iznad njega. Na pravom mjestu u pravo vrijeme našao se Ilija Batrićević i svojim drugim pogotkom poslao je u praznu mrežu. Tim je golom Jadran upotpunio preokret i odnio kući tri boda.

Domaćin se nije predavao i krenuo je u potpunu ofenzivu, s trojicom u obrani, a Šprem Veljavečki preselio je u napad. To je otvorilo prostor za kontre Jadrana, od kojih se ističe ona u 86. minuti, kada nakon ulaska u kazneni prostor s desne strane dolazi do još jednog opasnog udarca, ali ovog je puta Nicoletti siguran.

Od završnih pokušaja Pomorca valja istaknuti 88. minutu i ubačaj u kazneni prostor, gdje je lopta glavom spuštena na Šprema Veljavečkog, no on nogom puca preko gola.

U konačnici, u 90. minuti isti je igrač izborio slobodni udarac s dvadesetak metara, iz kojeg je Artem Teletskyi pucao preko živog zida, ali i preko gola.

Fantastična utakmica puna preokreta, koja je potvrdila dobar odabir ovog portala za jedan od derbija kola.',
  '3. NL Zapad',
  'Foto: Lokal-Arena',
  '15',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: SLIKA
-- =====================================================================
-- Ucitaj fotografiju u Supabase Storage, spremnik "clanci", pa kopiraj
-- njezinu javnu adresu (Storage -> clanci -> klik na datoteku -> Copy URL).
-- Zalijepi je umjesto ADRESA_SLIKE i pokreni samo ovaj upit.
--
-- Rezanje nije potrebno: stranica sama uklopi sliku u omjer 3:2 u clanku
-- i 16:9 na kartici. Stupac slika_kadar govori koji se dio po visini
-- zadrzava, 0 je vrh, 100 dno. Ovdje je 15, sto zadrzava igraliste i
-- igrace, a odreze visak neba i prednjeg travnjaka. Ako ti se ucini da
-- treba vise neba, stavi 0, ako treba nize, stavi 30.

-- update public.clanci
-- set slika_url   = 'ADRESA_SLIKE',
--     slika_opis  = 'Pomoćno igralište na umjetnoj travi na Žuknici tijekom utakmice Pomorca i Jadrana iz Poreča',
--     slika_kadar = '15'
-- where slug = 'osvrt-pomorac-jadran-porec-2-kolo-2627'
-- returning slug, slika_url, slika_kadar;


-- =====================================================================
-- KORAK 3: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'osvrt-pomorac-jadran-porec-2-kolo-2627'
-- returning slug, naslov, objavljen, slika_url;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'osvrt-pomorac-jadran-porec-2-kolo-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       slika_url, slika_kadar
from public.clanci
where slug = 'osvrt-pomorac-jadran-porec-2-kolo-2627';

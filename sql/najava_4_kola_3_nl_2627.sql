-- =====================================================================
-- ČLANAK: NAJAVA 4. KOLA 3. NL ZAPAD 2026/27
-- Igra se u UTORAK 15.09.2026., sredinom tjedna.
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
--   Termini, stadioni, bodovi, pozicije, forma, serije i zuti kartoni
--   dolaze iz public.najava_kola('2026/27','3. NL Zapad',4).
--   Strijelci po klubovima NE dolaze odande, nego iz
--   public.pregled_kola('2026/27','3. NL Zapad',3), polje
--   strijelci.poredak, jer najava_kola() po klubu vraca samo jednog
--   igraca. Zato su kod Kraljevice navedena trojica, a ne samo Cabrijan.
--   Prosla sezona se spominje samo ondje gdje nesto govori.
--
-- KAZNE
--   Polje "suspendirani" u najava_kola() je uvijek prazno, pa se ne cita.
--   Provjereno je u pregled_kola() 3. kola: ondje nema nijednog crvenog
--   kartona, dakle u 4. kolu nitko ne odradjuje kaznu. To je u tekstu
--   receno izrijekom.
--
-- ZUTI KARTONI
--   Prag od cetiri zuta kartona NIJE potvrdjen u propozicijama, pa se u
--   tekstu ne tvrdi da cetvrti znaci kaznu. Navedeno je samo koliko tko
--   ima. Kad se prag potvrdi, moze se pisati odredjenije.
--
-- LJESTVICA
--   najava_kola() javlja da sluzbena tablica odstupa, zbog kaznenih
--   bodova Crikvenice. Zato je na kraju uputa na sluzbenu ljestvicu.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-4-kola-3-nl-zapad-2627',
  'U UTORAK SE IGRA ČETVRTO KOLO, LOKOMOTIVA I KRALJEVICA BEZ IZGUBLJENOG BODA',
  'Osam utakmica sredinom tjedna, vodeća Lokomotiva gostuje u Novom Vinodolskom, a na Žuknici se sastaju treći i peti.',
'Četvrto kolo 3. NL Zapad igra se sredinom tjedna, u utorak 15. rujna. Sedam utakmica počinje u 17:30, a Pazinka-Pazin i Jadran-Poreč igraju pola sata kasnije, u 18 sati.

Pomorac - OŠK Omišalj. Po mjestima na ljestvici ovo je najjači susret kola. Pomorac je treći, OŠK Omišalj peti, obje momčadi imaju po šest bodova. Kod domaćih na Žuknici igra Jakob Šprem-Veljavečki, koji sa četiri pogotka dijeli vrh liste strijelaca lige, a prati ga Marino Matković s tri. Prošle sezone Pomorac protiv Omišlja nije slavio: u Kostreni je bilo 0:0, a u Omišlju 2:0 za otočane.

Vinodol - Lokomotiva (R). Vodeća momčad lige gostuje na Bahalinu. Lokomotiva je dobila sve tri dosadašnje utakmice, uz gol razliku plus osam, a najefikasniji su Karlo Josipović s tri pogotka te Edin Junuzović i Mateo Monjac s po dva. Vinodol ima jedan bod i još čeka prvu pobjedu. Prošle sezone Lokomotiva je oba ogleda dobila s 3:0.

Kraljevica - Buje. Kraljevica na Minti brani jednak učinak kao Lokomotiva, tri pobjede iz tri kola. Najviše su zabijali Matija Čabrijan, tri pogotka, te Filip Znamenaček i Franko Bosančić s po dva. Buje dolaze s tri boda. Zanimljivo je da su prošle sezone oba međusobna ogleda pripala domaćinima, i to uvjerljivo: Buje su slavile 3:0, a Kraljevica 4:1.

Rudar (L) - Crikvenica. Rudar u Labinu dolazi s dvije pobjede zaredom, Crikvenica s dva poraza. Ipak, prošle sezone je Crikvenica dobila oba susreta, 1:0 kod kuće i 5:2 u Labinu, pa forma ovdje ne znači sve.

Nehaj - Halubjan. Nehaj u Senju dočekuje Halubjan nakon prvog poraza u sezoni, onog u Omišlju. Halubjan je izgubio dva kola zaredom. Ni ovdje prošla sezona ne ide domaćinu u prilog: bilo je 0:0 u Senju i 1:0 za Halubjan.

Rovinj - Naprijed (H). Na Valbruni Rovinj dočekuje momčad koja je izgubila sve tri utakmice i još nije zabila pogodak, jedina takva u ligi. Rovinj je pak poražen u zadnja dva kola, a Masimo Terlević mu je s tri pogotka najbolji strijelac.

Banjole - Krk. Na Prematinki se sastaju osmi i deveti, obje momčadi s po četiri boda. Kod domaćih igra Ahmed Durmo, drugi igrač lige sa četiri pogotka, uz Ronija Vujičića koji ih ima dva.

Pazinka-Pazin - Jadran-Poreč. Kolo se zatvara u Pazinu u 18 sati. Jadran dolazi s dvije pobjede zaredom i s Ilijom Batrićevićem, koji ima tri pogotka, te Andrejem Pekicom i Dominikom-Velinom Mrvčićem s po dva. Pazinka je prošle sezone protiv Jadrana osvojila bod kod kuće i izgubila u Poreču.

KARTONI

U trećem kolu nije bilo nijednog crvenog kartona, pa u utorak nitko ne odrađuje kaznu. Po tri žuta kartona dosad su skupili Paulo Kocijan iz Kraljevice i Marcelo Suden iz Vinodola.

LJESTVICA

Lokomotiva i Kraljevica imaju po devet bodova, a slijedi pet klubova sa šest: Pomorac, Nehaj, OŠK Omišalj, Jadran-Poreč i Rudar. Službena ljestvica je na stranici lige, jer ona uključuje i kaznene bodove Crikvenice.',
  '3. NL Zapad',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-4-kola-3-nl-zapad-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-4-kola-3-nl-zapad-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-4-kola-3-nl-zapad-2627';

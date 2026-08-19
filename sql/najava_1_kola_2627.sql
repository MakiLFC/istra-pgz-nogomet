-- =====================================================================
-- NAJAVE 1. KOLA, SEZONA 2026/27 (3. NL Zapad i 4. NL NS Rijeka)
-- =====================================================================
-- KAKO SE KORISTI:
--   1. Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run
--   2. Oba clanka upisuju se s objavljen = false, dakle NISU vidljivi
--      na stranici. Prvo ih pogledaj u Supabaseu (Table editor -> clanci).
--   3. Kad ih zelis objaviti, pokreni naredbe iz odjeljka OBJAVA na dnu.
--
-- Datum objave (objavljeno_u) namjerno je postavljen na dan uoci kola,
-- jer se taj datum prikazuje na kartici clanka. Slobodno ga promijeni.
--
-- Naredba se pokrece SAMO JEDNOM. Ako je pokrenes dvaput, dobit ces
-- dva ista clanka (ili gresku, ako je slug postavljen kao jedinstven).
-- =====================================================================


-- ---------- 3. NL ZAPAD ----------
insert into public.clanci (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-1-kola-3-nl-zapad-2627',
  'NAJAVA 1. KOLA: 3. NL ZAPAD',
  'Nova sezona 3. NL Zapad počinje u subotu 29. kolovoza. Svih osam susreta igra se u 17:30.',
'Ljetna stanka je gotova. Prvo kolo 3. NL Zapad igra se u subotu 29. kolovoza 2026., a svih osam utakmica počinje u isto vrijeme, u 17:30. U odnosu na prošlu sezonu liga ima jednu izmjenu: Novalja je ispala u 4. NL, a njezino mjesto zauzeo je Rovinj, prvak 4. NL NS Rijeka.

Pazinka-Pazin - Pomorac (SC Egidie Marion, Pazin). Najteži ispit prvog kola dobio je prošlosezonski prvak. Pazinka je sezonu završila sa 61 bodom, deset više od trećeplasiranog Pomorca.

Buje - Lokomotiva (R) (Gradski stadion, Buje). Druga i četvrta momčad prošle sezone. Lokomotiva u novu sezonu ulazi znatno pojačana.

Naprijed (H) - Kraljevica (Lonja, Hreljin). Susret susjeda, a s te utakmice stiže i osvrt na Lokal-Areni. Kraljevica je prošlu sezonu završila peta, Naprijed deseti, uz šest bodova razlike.

Rovinj - Vinodol (Valbruna, Rovinj). Prvi nastup Rovinja u 3. NL nakon osvojene 4. NL, pa ćemo vidjeti kako će se snaći u novom društvu. Vinodol je prošlu sezonu završio sedmi.

Jadran-Poreč - Nehaj (Veli Jože, Poreč). Utakmica koja bi mogla biti tvrda i borbena.

Crikvenica - Krk (Gradski stadion, Crikvenica). Crikvenica sezonu počinje s tri kaznena boda minusa, pa joj svaki osvojeni bod od prvog dana vrijedi dvostruko. Krk je prošle sezone bio osmi.

OŠK Omišalj - Rudar (L) (Pušća, Omišalj). Deveti protiv četrnaestog iz prošle sezone.

Halubjan - Banjole (Brnasi, Viškovo). Prošle sezone završili su jedan do drugoga, Banjole jedanaesti i Halubjan dvanaesti, s tri boda razlike.',
  '3. NL Zapad',
  false,
  '2026-08-27T10:00:00+02:00'
);


-- ---------- 4. NL NS RIJEKA ----------
insert into public.clanci (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-1-kola-4-nl-ns-rijeka-2627',
  'NAJAVA 1. KOLA: 4. NL NS RIJEKA',
  'Prvo kolo 4. NL NS Rijeka na rasporedu je u subotu 5. rujna, tjedan dana nakon starta 3. NL.',
'Prvo kolo 4. NL NS Rijeka igra se u subotu 5. rujna 2026., tjedan dana nakon početka 3. NL, a svih sedam susreta počinje u 17:30. Ligu je napustio prvak Rovinj, koji je izborio 3. NL, a iz nje je stigla Novalja. Rječina i Štinjan novopromovirane su momčadi iz nižih liga.

Žminj - Ližnjan (Kunfin, Rovinjsko Selo). Najzvučniji par kola. Ližnjan je prošlu sezonu završio drugi, odmah iza Rovinja, i sada je bez njega među prvim kandidatima za vrh. Žminj je bio šesti. Domaćin utakmicu igra u Rovinjskom Selu.

Borac (Ba) - Klana (Krasica). Treći protiv petog iz prošle sezone.

Umag-CC Umago - Štinjan (Stella Maris, Umag). Umag je prošlu sezonu završio četvrti, sa 44 boda. Štinjan u ligu ulazi kao novopromovirana momčad, a iza sebe ima solidan pripremni period.

Otočac - Novalja (Gradsko igralište, Otočac). Novalja u 4. NL stiže nakon ispadanja iz 3. NL, gdje je prošle sezone bila posljednja. Otočac, koji je prošlu sezonu završio deseti, u novu ulazi znatno pojačan.

Cres - Rječina (Dari, Cres). Cres je prošle sezone bio osmi, a Rječina je druga novopromovirana momčad u ligi.

Mladost Fažana - Funtana (Oliva, Fažana). Sedmoplasirani dočekuje dvanaestoplasiranog; Fažana je prošlu sezonu završila sa šest bodova više.

Medulin 1921 - Smoljanci Sloboda (Mutila, Medulin). Susret jedanaestog i devetog iz prošle sezone, uz četiri boda razlike.',
  '4. NL NS Rijeka',
  false,
  '2026-09-03T10:00:00+02:00'
);


-- ---------- PROVJERA ----------
-- Očekivano: dva retka, objavljen = false.
select slug, naslov, natjecanje, objavljen, objavljeno_u
from public.clanci
where slug in ('najava-1-kola-3-nl-zapad-2627', 'najava-1-kola-4-nl-ns-rijeka-2627');


-- =====================================================================
-- OBJAVA (pokreni kad zelis da se clanak pojavi na stranici)
-- =====================================================================
-- 3. NL Zapad (npr. u petak 28.08.):
-- update public.clanci set objavljen = true
-- where slug = 'najava-1-kola-3-nl-zapad-2627';
--
-- 4. NL NS Rijeka (npr. u petak 04.09.):
-- update public.clanci set objavljen = true
-- where slug = 'najava-1-kola-4-nl-ns-rijeka-2627';
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false where slug = '...';
--
-- Ispravak teksta:
-- update public.clanci set tekst = 'novi tekst' where slug = '...';
--   (apostrof u tekstu pise se dvaput)
-- =====================================================================

-- =====================================================================
-- PREGLED 1. KOLA, 3. NL ZAPAD, SEZONA 2026/27
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Clanak se upisuje s objavljen = false, dakle NIJE vidljiv na
--   stranici. Kad ga pogledas i zelis objaviti, pokreni naredbu iz
--   odjeljka OBJAVA na dnu.
--
--   Pokrece se SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- IZVOR PODATAKA: public.pregled_kola('2026/27', '3. NL Zapad', 1)
--
-- NAPOMENA O POREČU: rezultat Jadran-Poreč - Nehaj je 1:3, ali su
-- strijelci u bazi rasporedeni 2:2. Uzrok je gotovo sigurno autogol,
-- kojeg scraper zasad pripisuje klubu strijelca umjesto protivniku.
-- Zato je ta utakmica u tekstu navedena samo rezultatom, bez
-- strijelaca. Kad se utvrdi ciji je autogol, recenica se moze dopuniti.
-- =====================================================================

insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'pregled-1-kola-3-nl-zapad-2627',
  'PREGLED 1. KOLA: 3. NL ZAPAD',
  'Krk je s dva gola u sudačkoj nadoknadi uzeo bod u Crikvenici, Omišalj je razbio Rudar 5:0, a prošlogodišnji prvak Pazinka otvorio je sezonu domaćim porazom.',
'Prvo kolo 3. NL Zapad odigrano je u subotu 29. kolovoza, svih osam utakmica u 17:30. Pala su 24 pogotka, a gosti su bili uspješniji od domaćina: četiri pobjede na strani, dvije kod kuće i dva remija.

Najdramatičnije je bilo u Crikvenici. Domaći su od 34. minute igrali s igračem manje, nakon isključenja Damjana Mendrile, pa su ipak poveli 2:0 pogocima Rhaillama Souse Arauja u 68. i Petra Vidovića u 88. minuti. Onda su u sudačkoj nadoknadi stigla dva gostujuća pogotka. Ivan Golemac zabio je u 90+4, Tin Jurica u 90+5, i Krk je otišao s bodom. Ni gosti nisu završili u punom sastavu, Dorijan Jurešić dobio je drugi žuti karton u 75. minuti.

Najuvjerljivije je slavio OŠK Omišalj. Na Pušći je Rudar (L) izgubio 5:0, dvaput je zabio Luka Mijić, po jednom Mateo Vukelić, Mateo Ostović i Matija Brdar. To je i najviše golova na jednoj utakmici u kolu.

Prošlogodišnji prvak Pazinka-Pazin otvorio je sezonu domaćim porazom. Pomorac je u Pazinu slavio 0:2, pogocima Jakoba Šprema-Veljavečkog u 27. i Marina Matkovića u 84. minuti.

Rovinj je prvi nastup u trećem rangu, nakon naslova u 4. NL, pretvorio u pobjedu. Na Valbruni je 1:0 svladao Vinodol golom Masima Terlevića u 44. minuti.

Derbi kola u Hreljinu pripao je Kraljevici. Naprijed je izgubio 0:2, strijelci su bili Matija Čabrijan u 30. i Franko Bosančić u 50. minuti. Na Lonji je bilo 200 gledatelja, najviše u kolu, a cijeli osvrt s te utakmice stoji uz njezin zapisnik.

U Viškovu su Halubjan i Banjole podijelili bodove. Ahmed Durmo dvaput je doveo goste u vodstvo, u 24. i 55. minuti, a Halubjan je oba puta stigao do izjednačenja, preko Marka Tadića u 33. i Frana Kneževića u 87. minuti.

Lokomotiva je u Bujama slavila 0:2, golovima Ivora Weitzera u 4. i Matea Monjca u 38. minuti. Nehaj je u Poreču dobio Jadran 1:3.

Nakon prvog kola ljestvicu strijelaca dijele Ahmed Durmo i Luka Mijić, obojica s po dva pogotka.

Crikvenica je sezonu počela s tri kaznena boda minusa, pa ni s osvojenim bodom u prvom kolu još nije izašla iz minusa.

U drugom kolu neće moći igrati Damjan Mendrila i Dorijan Jurešić, obojica zbog isključenja.

Utakmice prvog kola gledalo je ukupno 737 ljudi, u prosjeku 92 po susretu. Najviše ih je bilo u Hreljinu, 200.',
  '3. NL Zapad',
  false,
  '2026-08-30T10:00:00+02:00'
);


-- ---------- PROVJERA ----------
select slug, naslov, natjecanje, objavljen, objavljeno_u
from public.clanci
where slug = 'pregled-1-kola-3-nl-zapad-2627';


-- ---------- OBJAVA ----------
-- update public.clanci set objavljen = true
-- where slug = 'pregled-1-kola-3-nl-zapad-2627';
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'pregled-1-kola-3-nl-zapad-2627';
-- =====================================================================

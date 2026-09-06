-- =====================================================================
-- ISPRAVAK OSVRTA: Pomorac - Jadran-Poreč 2:3
-- 2. kolo 3. NL Zapad, 05.09.2026.
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Mijenja isti tekst na oba mjesta gdje stoji: u utakmice.tekst_clanka
--   i u clanci.tekst. Ponovno pokretanje ne skodi, jer nakon prvog
--   prolaza vise nema sto zamijeniti.
--
-- STO SE MIJENJA I ZASTO (Andrej, 06.09.2026.)
--   1. "Šprem Veljavečki" -> "Šprem-Veljavečki". U zapisniku HNS-a ime
--      stoji sa spojnicom: Jakob Šprem-Veljavečki. Mijenja se i genitiv,
--      "Šprema Veljavečkog" -> "Šprem-Veljavečkog", jer se kod dvostrukih
--      prezimena sa spojnicom deklinira samo drugi dio.
--   2. Batricevicev prvi pogodak: 43. -> 44. minuta. U tekstu je stajala
--      minuta s tribine, sada ide sluzbena iz zapisnika, po Andrejevoj
--      uputi da svugdje bude ista.
--
--   Zamjena ide preko replace(), pa se dira samo taj dio teksta, a sve
--   ostalo ostaje netaknuto.
-- =====================================================================


-- ---------- 1. OSVRT UZ ZAPISNIK ----------
update public.utakmice
   set tekst_clanka = replace(
         replace(
           replace(tekst_clanka, 'Šprema Veljavečkog', 'Šprem-Veljavečkog'),
           'Šprem Veljavečki', 'Šprem-Veljavečki'),
         'Nedugo zatim, u 43. minuti', 'Nedugo zatim, u 44. minuti')
 where sezona = '2026/27'
   and natjecanje = '3. NL Zapad'
   and kolo = 2
   and domacin = 'NK Pomorac'
   and gost = 'NK Jadran-Poreč';


-- ---------- 2. ČLANAK ----------
update public.clanci
   set tekst = replace(
         replace(
           replace(tekst, 'Šprema Veljavečkog', 'Šprem-Veljavečkog'),
           'Šprem Veljavečki', 'Šprem-Veljavečki'),
         'Nedugo zatim, u 43. minuti', 'Nedugo zatim, u 44. minuti')
 where slug = 'osvrt-pomorac-jadran-porec-2-kolo-2627';


-- ---------- 3. PROVJERA ----------
-- Ocekivano: nula pogodaka na staro ime i na staru minutu, oba retka.
select 'utakmica' as gdje,
       tekst_clanka ilike '%Šprem Veljavečki%' as staro_ime,
       tekst_clanka ilike '%u 43. minuti%'     as stara_minuta,
       tekst_clanka ilike '%Šprem-Veljavečki%' as novo_ime
from public.utakmice
where sezona = '2026/27' and natjecanje = '3. NL Zapad'
  and kolo = 2 and domacin = 'NK Pomorac'
union all
select 'clanak',
       tekst ilike '%Šprem Veljavečki%',
       tekst ilike '%u 43. minuti%',
       tekst ilike '%Šprem-Veljavečki%'
from public.clanci
where slug = 'osvrt-pomorac-jadran-porec-2-kolo-2627';

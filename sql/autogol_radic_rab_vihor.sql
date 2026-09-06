-- =====================================================================
-- AUTOGOL: Mihael Radić, 6. minuta, NK Rab - NK Vihor (B) 4:2
-- 1. kolo 1. ŽNL PGŽ, 05.09.2026., Blato, Rab
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Stupac autogolovi je rucni unos, scraper ga nikad ne dira.
--   Upute o obliku zapisa su u sql/autogolovi.sql.
--
-- ZASTO
--   Zapisnik ima sest pogodaka: Sharbini (Vihor) u 1., Radic (Vihor) u
--   6., Mlacovic (Rab) u 35., Belobrajdic (Rab) u 63., Ferencic (Vihor)
--   u 79. i Fafandel (Rab) u 89. minuti. To daje 3:3, a rezultat je 4:2.
--   Andrej je 06.09.2026. provjerio Semafor i potvrdio da je pogodak
--   Mihaela Radica u 6. minuti autogol. S tim je zbroj tocan.
--
-- STO SE MIJENJA NA STRANICI
--   Takav pogodak se pripisuje PROTIVNIKU strijelca, oznacava se s (ag)
--   i izlazi iz ljestvice strijelaca, jer autogol nije zasluga
--   strijelca. Radic time gubi taj gol s liste strijelaca lige, a tijek
--   utakmice postaje 0:1, 1:1, 2:1, 3:1, 3:2, 4:2.
--
-- TREĆI TAKAV SLUČAJ
--   Prije ovoga: Vedran Radman (Jadran-Poreč - Nehaj, 1. kolo 3. NL) i
--   Štefan Vrhovac (Rudar (L) - Halubjan, 2. kolo 3. NL). HNS autogol
--   ponekad oznaci klasom own_goal, koju scraper prepoznaje sam, a
--   ponekad ne oznaci nikako. Kad ne oznaci, jedini znak je da se zbroj
--   strijelaca ne slaze s rezultatom.
-- =====================================================================


-- ---------- 1. PROVJERA PRIJE UPISA ----------
-- Pogledaj kako tocno stoje ime i minuta u polju strijelci.
-- Ocekivano: "Mihael Radić" i minuta "6'".
select id, domacin, gost, rezultat,
       jsonb_pretty(strijelci) as strijelci
from public.utakmice
where sezona = '2026/27' and natjecanje = '1. ŽNL PGŽ'
  and kolo = 1 and domacin = 'NK Rab';


-- ---------- 2. UPIS ----------
update public.utakmice
   set autogolovi = '[{"igrac": "Mihael Radić", "minuta": "6''"}]'::jsonb
 where sezona = '2026/27' and natjecanje = '1. ŽNL PGŽ'
   and kolo = 1 and domacin = 'NK Rab'
   and gost = 'NK Vihor (B)';


-- ---------- 3. PROVJERA POSLIJE ----------
-- Ocekivano: jedan redak, rezultat 4:2, autogolovi s Radicem.
select domacin, gost, rezultat, autogolovi
from public.utakmice
where sezona = '2026/27' and natjecanje = '1. ŽNL PGŽ'
  and kolo = 1 and domacin = 'NK Rab';


-- ---------- BRISANJE (ako zatreba) ----------
-- update public.utakmice set autogolovi = null
-- where sezona = '2026/27' and natjecanje = '1. ŽNL PGŽ'
--   and kolo = 1 and domacin = 'NK Rab';

-- =====================================================================
-- AUTOGOL: Štefan Vrhovac, 7. minuta, NK Rudar (L) - NK Halubjan 4:0
-- 2. kolo 3. NL Zapad, 05.09.2026.
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Stupac autogolovi je rucni unos, scraper ga nikad ne dira.
--   Upute o obliku zapisa su u sql/autogolovi.sql.
--
-- ZASTO
--   Zapisnik te utakmice ima cetiri pogotka: Vrhovac (Halubjan) u 7.,
--   Juricic u 26., Macan u 57. i Movric u 62. minuti. To daje 3:1, a
--   rezultat je 4:0. Andrej je 06.09.2026. potvrdio da je pogodak u 7.
--   minuti autogol Stefana Vrhovca. Isti je igrac u 43. minuti dobio i
--   crveni karton.
--
-- STO SE MIJENJA NA STRANICI
--   Takav pogodak se pripisuje PROTIVNIKU strijelca, oznacava se s (ag)
--   i izlazi iz ljestvice strijelaca, jer autogol nije zasluga
--   strijelca. Vrhovac time gubi taj gol s liste strijelaca lige.
-- =====================================================================


-- ---------- 1. PROVJERA PRIJE UPISA ----------
-- Pogledaj kako tocno stoje ime i minuta u polju strijelci.
-- Ocekivano: "Štefan Vrhovac" i minuta "7'".
select id, domacin, gost, rezultat,
       jsonb_pretty(strijelci) as strijelci
from public.utakmice
where sezona = '2026/27' and natjecanje = '3. NL Zapad'
  and kolo = 2 and domacin = 'NK Rudar (L)';


-- ---------- 2. UPIS ----------
update public.utakmice
   set autogolovi = '[{"igrac": "Štefan Vrhovac", "minuta": "7''"}]'::jsonb
 where sezona = '2026/27' and natjecanje = '3. NL Zapad'
   and kolo = 2 and domacin = 'NK Rudar (L)'
   and gost = 'NK Halubjan';


-- ---------- 3. PROVJERA POSLIJE ----------
-- Ocekivano: jedan redak, rezultat 4:0, autogolovi s Vrhovcem.
select domacin, gost, rezultat, autogolovi
from public.utakmice
where sezona = '2026/27' and natjecanje = '3. NL Zapad'
  and kolo = 2 and domacin = 'NK Rudar (L)';


-- ---------- BRISANJE (ako zatreba) ----------
-- update public.utakmice set autogolovi = null
-- where sezona = '2026/27' and natjecanje = '3. NL Zapad'
--   and kolo = 2 and domacin = 'NK Rudar (L)';

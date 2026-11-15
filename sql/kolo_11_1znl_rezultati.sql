-- =====================================================================
-- 11. KOLO 1. ŽNL PGŽ: REZULTATI DVIJU UTAKMICA BEZ ZAPISNIKA
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Ponovno pokretanje upiše isto i ne škodi.
--
-- ZAŠTO
--   Zapisnici Lošinj - Risnjak i Turbina - Lovran 15.11.2026. još nisu
--   objavljeni na Semaforu, a posao "Zapisnik u bazu" traži obje
--   postave. Rezultate je javio Andrej, pa se upisuju sami, da ljestvica
--   lige bude potpuna. Stranica utakmice do tada piše "Zapisnik ove
--   utakmice nije objavljen", što je točno.
--
--   Kad zapisnici stignu, upisuju se poslom "Zapisnik u bazu" kao i
--   svaki drugi; on prepiše i rezultat, i dopuni strijelce i postave.
--
-- Nakon pokretanja Claude pokrene "Preračunaj ljestvice" za 1. ŽNL.
-- =====================================================================

update public.utakmice
set rezultat = '4:1'
where natjecanje = '1. ŽNL PGŽ' and sezona = '2026/27' and kolo = 11
  and domacin ilike '%Lošinj%' and gost ilike '%Risnjak%';

update public.utakmice
set rezultat = '5:0'
where natjecanje = '1. ŽNL PGŽ' and sezona = '2026/27' and kolo = 11
  and domacin ilike '%Turbina%' and gost ilike '%Lovran%';

-- PROVJERA: mora vratiti DVA retka, 4:1 i 5:0
select kolo, domacin, gost, rezultat
from public.utakmice
where natjecanje = '1. ŽNL PGŽ' and sezona = '2026/27' and kolo = 11
  and (domacin ilike '%Lošinj%' or domacin ilike '%Turbina%');

-- =====================================================================
-- 13. KOLO 3. NL ZAPAD: SATNICA 14:30 UMJESTO 14:00
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Pokreće se JEDNOM. Ponovno pokretanje ne škodi, jer se upiše isto.
--
-- ZAŠTO POSTOJI
--   Na Semaforu (snimka zaslona od Andreja, 12.11.2026.) svih osam
--   utakmica 13. kola igra se u subotu 14.11.2026. u 14:30, a u bazi
--   stoji 14:00. Termine je dosad osvježavala dnevna "Provjera termina",
--   a ona je ugašena zajedno sa scraperom (pravilo 7 u CLAUDE.md), pa
--   se satnica sada ispravlja ručno. Najava 13. kola već piše 14:30.
-- =====================================================================

-- 1. ŠTO JE SADA U BAZI (pogledaj prije nego išta pokreneš)
select kolo, domacin, gost, datum, vrijeme, rezultat
from public.utakmice
where natjecanje = '3. NL Zapad'
  and sezona = '2026/27'
  and kolo = 13
order by domacin;

-- 2. SATNICA 14:30 ZA SVIH OSAM UTAKMICA
--    Uvjet "rezultat is null" je zaštita: odigrana utakmica se ne dira.
update public.utakmice
set vrijeme = '14:30'
where natjecanje = '3. NL Zapad'
  and sezona = '2026/27'
  and kolo = 13
  and rezultat is null
  and vrijeme is distinct from '14:30';

-- 3. PROVJERA: mora vratiti točno osam redaka, sve u 14:30
select kolo, domacin, gost, datum, vrijeme, rezultat
from public.utakmice
where natjecanje = '3. NL Zapad'
  and sezona = '2026/27'
  and kolo = 13
order by domacin;

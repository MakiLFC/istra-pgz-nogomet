-- =====================================================================
-- 13. KOLO 3. NL ZAPAD: DOMAĆIN JE NAPRIJED, NE LOKOMOTIVA
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Pokreće se JEDNOM. Drugo pokretanje ne radi ništa, jer uvjet traži
--   Lokomotivu kao domaćina, a nje ondje više nema.
--
-- ZAŠTO POSTOJI
--   U bazi je utakmica 13. kola upisana kao Lokomotiva (R) - Naprijed (H),
--   na Kantridi. Andrej je 14.11.2026. javio da Lokomotiva igra u
--   gostima, dakle Naprijed (H) - Lokomotiva (R), na Lonji u Hreljinu.
--   Domaćin i gost su dio ključa utakmice, pa se zamjenjuju u istom
--   retku, a stadion se uzima s posljednje Naprijedove domaće utakmice.
-- =====================================================================

-- 1. ŠTO JE SADA U BAZI
select id, kolo, domacin, gost, datum, vrijeme, stadion, rezultat
from public.utakmice
where natjecanje = '3. NL Zapad'
  and sezona = '2026/27'
  and kolo = 13
  and (domacin like '%Naprijed%' or gost like '%Naprijed%');

-- 2. ZAMJENA DOMAĆINA I GOSTA, STADION NAPRIJEDA
--    U PostgreSQL-u desna strana čita stare vrijednosti, pa
--    "domacin = gost, gost = domacin" zamijeni ta dva stupca.
--    Uvjet "rezultat is null" je zaštita: odigrana utakmica se ne dira.
update public.utakmice u
set domacin = u.gost,
    gost    = u.domacin,
    stadion = coalesce(
      (select s.stadion
       from public.utakmice s
       where s.natjecanje = '3. NL Zapad'
         and s.sezona = '2026/27'
         and s.domacin = u.gost
         and s.stadion is not null
         and s.stadion <> ''
         and s.kolo < 13
       order by s.kolo desc
       limit 1),
      u.stadion)
where u.natjecanje = '3. NL Zapad'
  and u.sezona = '2026/27'
  and u.kolo = 13
  and u.domacin = 'NK Lokomotiva (R)'
  and u.gost like '%Naprijed%'
  and u.rezultat is null;

-- 3. PROVJERA: mora vratiti jedan redak, domaćin Naprijed,
--    gost Lokomotiva, stadion u Hreljinu, subota 14.11.2026. u 14:30
select id, kolo, domacin, gost, datum, vrijeme, stadion, rezultat
from public.utakmice
where natjecanje = '3. NL Zapad'
  and sezona = '2026/27'
  and kolo = 13
  and (domacin like '%Naprijed%' or gost like '%Naprijed%');

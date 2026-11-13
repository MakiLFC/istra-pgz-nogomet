-- =====================================================================
-- 11. KOLO 1. ŽNL PGŽ: NEDJELJNE UTAKMICE U 14:00 UMJESTO 13:30
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Pokreće se JEDNOM. Ponovno pokretanje ne škodi, jer se upiše isto.
--
-- ZAŠTO POSTOJI
--   Na Semaforu (snimka zaslona od Andreja, 13.11.2026.) u nedjelju
--   15.11.2026. u 14:00 igraju Mune - Omladinac Vrata, Turbina - Lovran,
--   Stari grad Rijeka - Rab i Vrbovsko - Zamet, a Lošinj - Risnjak u
--   13:30. U bazi tri od tih četiri utakmice u 14:00 stoje na 13:30
--   (Turbina - Lovran je već dobro). Dnevna "Provjera termina" je ugašena
--   (pravilo 7 u CLAUDE.md), pa se satnica ispravlja ručno.
-- =====================================================================

-- 1. ŠTO JE SADA U BAZI (pogledaj prije nego išta pokreneš)
select kolo, domacin, gost, datum, vrijeme, rezultat
from public.utakmice
where natjecanje = '1. ŽNL PGŽ'
  and sezona = '2026/27'
  and kolo = 11
order by datum, vrijeme, domacin;

-- 2. SATNICA 14:00 ZA TRI NEDJELJNE UTAKMICE
--    Uvjet "rezultat is null" je zaštita: odigrana utakmica se ne dira.
update public.utakmice
set vrijeme = '14:00'
where natjecanje = '1. ŽNL PGŽ'
  and sezona = '2026/27'
  and kolo = 11
  and rezultat is null
  and domacin in ('NK Mune', 'NK Stari grad Rijeka', 'NK Vrbovsko')
  and vrijeme is distinct from '14:00';

-- 3. PROVJERA: Mune, Turbina, Stari grad i Vrbovsko u 14:00,
--    Lošinj u 13:30, subotnje dvije u 13:30
select kolo, domacin, gost, datum, vrijeme, rezultat
from public.utakmice
where natjecanje = '1. ŽNL PGŽ'
  and sezona = '2026/27'
  and kolo = 11
order by datum, vrijeme, domacin;

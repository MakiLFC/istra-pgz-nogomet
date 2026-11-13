-- =====================================================================
-- 10. KOLO 2. ŽNL PGŽ: GOMIRJE - GORANKA JE ODGOĐENA
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Pokreće se JEDNOM. Ponovno pokretanje ne škodi.
--
-- ZAŠTO POSTOJI
--   Na Semaforu i u glasniku saveza br. 10 utakmica Gomirje - Goranka
--   (10. kolo, 15.11.2026.) stoji kao ODGOĐENA, a novi termin nije
--   poznat. U bazi i dalje ima datum i sat, pa bi je naslovnica pod
--   "Sljedeće kolo" prikazivala kao da se igra. Bez datuma je stranica
--   lige označi kao odgođenu (ODG.), a naslovnica je preskoči.
--   Kad se dozna novi termin, upiše se istim putem u datum i vrijeme.
-- =====================================================================

-- 1. ŠTO JE SADA U BAZI
select kolo, domacin, gost, datum, vrijeme, datum_rucno, vrijeme_rucno, rezultat
from public.utakmice
where natjecanje = '2. ŽNL PGŽ'
  and sezona = '2026/27'
  and kolo = 10
order by domacin;

-- 2. BRISANJE TERMINA ODGOĐENE UTAKMICE
--    Uvjet "rezultat is null" je zaštita: odigrana utakmica se ne dira.
update public.utakmice
set datum = null, vrijeme = null, datum_rucno = null, vrijeme_rucno = null
where natjecanje = '2. ŽNL PGŽ'
  and sezona = '2026/27'
  and kolo = 10
  and domacin = 'NK Gomirje'
  and gost = 'NK Goranka'
  and rezultat is null;

-- 3. PROVJERA: Gomirje - Goranka bez datuma i sata,
--    druge dvije utakmice 15.11.2026. u 14:00
select kolo, domacin, gost, datum, vrijeme, datum_rucno, vrijeme_rucno, rezultat
from public.utakmice
where natjecanje = '2. ŽNL PGŽ'
  and sezona = '2026/27'
  and kolo = 10
order by domacin;

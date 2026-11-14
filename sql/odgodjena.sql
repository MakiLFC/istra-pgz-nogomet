-- =====================================================================
-- OZNAKA ODGODE: stupac utakmice.odgodjena (14.11.2026.)
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Pokreće se JEDNOM; ponovno pokretanje ne škodi.
--
-- ZAŠTO
--   Stranica lige utakmicu bez rezultata prepoznaje kao odgođenu samo
--   kad NEMA datuma ili kad je datum prošao prije više od četiri dana.
--   Odgođena utakmica kojoj je poznat NOVI termin zato je izgledala kao
--   svaka buduća, s "?:?" umjesto "ODG.". Prvi slučaj: Željezničar (M) -
--   Mrkopalj, 10. kolo 2. ŽNL PGŽ, odgođena zbog zimskih uvjeta, igra se
--   22.11.2026. u 14:00.
--
--   S oznakom stranica lige piše "ODG." i "Utakmica je odgođena. Novi
--   termin: 22.11.2026. u 14:00.", a isto stoji i na stranici utakmice.
--   Čim utakmica dobije rezultat, oznaka više ništa ne mijenja.
--
-- KASNIJE: oznaka se postavlja poslom "Termin u bazu", polje odgoda
-- "da". Datum "-" u istom poslu sam označi odgodu.
--
-- Novi STUPAC u postojećoj tablici ne treba grant; prava vrijede za
-- cijelu tablicu.
-- =====================================================================

-- 1. STUPAC
alter table public.utakmice
  add column if not exists odgodjena boolean not null default false;

-- 2. ODGOĐENE UTAKMICE OVOG TJEDNA (po Andrejevim podacima, 14.11.2026.)
update public.utakmice
set odgodjena = true
where sezona = '2026/27'
  and rezultat is null
  and (
    -- 2. ŽNL PGŽ, 10. kolo: novi termin 22.11. u 14:00, Moravice
    (natjecanje = '2. ŽNL PGŽ' and kolo = 10
       and domacin ilike '%Željezničar%' and gost ilike '%Mrkopalj%')
    -- 2. ŽNL PGŽ, 10. kolo: novi termin nije poznat
    or (natjecanje = '2. ŽNL PGŽ' and kolo = 10
       and domacin ilike '%Gomirje%' and gost ilike '%Goranka%')
    -- 4. NL NS Rijeka, 11. kolo: novi termin 17.11. u 19:00, Valkane
    or (natjecanje = '4. NL NS Rijeka' and kolo = 11
       and domacin ilike '%Štinjan%' and gost ilike '%Smoljanci%')
    -- 4. NL NS Rijeka, 11. kolo: novi termin nije poznat
    or (natjecanje = '4. NL NS Rijeka' and kolo = 11
       and domacin ilike '%Borac%' and gost ilike '%Žminj%')
  );

-- 3. PROVJERA: mora vratiti ČETIRI retka
select natjecanje, kolo, domacin, gost, datum, vrijeme, odgodjena
from public.utakmice
where sezona = '2026/27' and odgodjena
order by natjecanje, kolo;

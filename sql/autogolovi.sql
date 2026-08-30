-- =====================================================================
-- AUTOGOLOVI - novi stupac u tablici utakmice
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Pokreće se JEDNOM ("if not exists", ponovno pokretanje ne škodi).
--
-- ZAŠTO POSTOJI
--   HNS u zapisniku autogol ispisuje kao i svaki drugi pogodak, pod
--   imenom igrača koji ga je zabio. Stranica strijelca pripisuje klubu
--   u čijoj se postavi nalazi, pa autogol završi na krivoj strani.
--
--   Prvi takav slučaj: Jadran-Poreč - Nehaj 1:3, 1. kolo 3. NL Zapad,
--   29.08.2026. Zbroj strijelaca davao je 2:2, jer je pogodak Vedrana
--   Radmana u 16. minuti bio autogol.
--
--   Ovaj stupac je RUČNI unos, kao derbi, tekst_clanka i slika_url.
--   Scraper ga nikad ne dira, pa preživi svako osvježavanje.
--
-- OBLIK ZAPISA
--   Popis pogodaka, svaki s imenom i minutom TOČNO kako stoje u polju
--   strijelci iste utakmice (minuta uključuje apostrof):
--     [{"igrac": "Vedran Radman", "minuta": "16'"}]
-- =====================================================================

alter table public.utakmice
  add column if not exists autogolovi jsonb;

comment on column public.utakmice.autogolovi is
  'Ručni popis autogolova: [{"igrac": "...", "minuta": "16''"}]. '
  'Scraper ga ne dira. Prikaz takav pogodak pripisuje protivniku '
  'strijelca i označava ga s (ag).';


-- ---------------------------------------------------------------------
-- PRVI UNOS: Jadran-Poreč - Nehaj, 1. kolo 2026/27
-- ---------------------------------------------------------------------
-- Prije upisa pogledaj kako točno stoji ime i minuta u zapisniku:
select id, domacin, gost, rezultat,
       jsonb_pretty(strijelci) as strijelci
from public.utakmice
where sezona = '2026/27' and natjecanje = '3. NL Zapad'
  and kolo = 1 and domacin ilike '%Jadran%';

-- Pa upiši:
update public.utakmice
   set autogolovi = '[{"igrac": "Vedran Radman", "minuta": "16''"}]'::jsonb
 where sezona = '2026/27' and natjecanje = '3. NL Zapad'
   and kolo = 1 and domacin ilike '%Jadran%';


-- ---------------------------------------------------------------------
-- PROVJERA
-- ---------------------------------------------------------------------
-- Očekivano: jedan redak, rezultat 1:3, autogolovi s Radmanom.
select domacin, gost, rezultat, autogolovi
from public.utakmice
where sezona = '2026/27' and natjecanje = '3. NL Zapad'
  and kolo = 1 and domacin ilike '%Jadran%';


-- ---------------------------------------------------------------------
-- KAKO UPISATI BUDUĆI AUTOGOL
-- ---------------------------------------------------------------------
-- Jedan autogol:
--   update public.utakmice
--      set autogolovi = '[{"igrac": "Ime Prezime", "minuta": "37''"}]'::jsonb
--    where id = 12345;
--
-- Dva u istoj utakmici:
--   update public.utakmice
--      set autogolovi = '[{"igrac": "Prvi Igrač",  "minuta": "12''"},
--                         {"igrac": "Drugi Igrač", "minuta": "77''"}]'::jsonb
--    where id = 12345;
--
-- Poništavanje:
--   update public.utakmice set autogolovi = null where id = 12345;
--
-- Apostrof u minuti piše se DVAPUT, jer je cijela vrijednost u
-- apostrofima: "16''" u SQL-u postane 16' u bazi.
-- =====================================================================

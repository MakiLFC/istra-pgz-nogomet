-- =====================================================================
-- RUČNI TERMIN - kad HNS zaostaje s premještanjem utakmice
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Pokreće se JEDNOM ("if not exists", ponovno pokretanje ne škodi).
--
-- ZAŠTO POSTOJI
--   Termin utakmice na stranici dolazi s retka rasporeda na HNS Semaforu
--   i scraper ga osvježava pri svakom pokretanju. To je dobro dok je HNS
--   u pravu. Kad se utakmica premjesti, a Semafor to još nije upisao,
--   ručni ispravak u stupcu datum ne bi preživio: prvo sljedeće
--   pokretanje vratilo bi stari termin.
--
--   Zato postoje datum_rucno i vrijeme_rucno. Scraper ih NIKAD ne dira,
--   kao ni derbi, tekst_clanka, slika_url i autogolovi, a dok su
--   ispunjeni, u stupce datum i vrijeme upisuje njihovu vrijednost. Na
--   stranici se zato ništa ne mijenja - ona i dalje čita datum i vrijeme.
--
-- OBLIK ZAPISA
--   Točno kao u stupcima datum i vrijeme, jer ih zamjenjuju:
--     datum_rucno   '04.09.2026.'   (s točkom na kraju)
--     vrijeme_rucno '17:30'         (ili NULL ako se mijenja samo datum)
--
-- KAD SE BRIŠE
--   Čim HNS pokaže isti termin, scraper na kraju pokretanja ispiše da se
--   ručni termin poklapa i da se može obrisati. Tada se postavi na NULL
--   (zadnja naredba na dnu datoteke), da opet vrijedi ono što piše na
--   Semaforu.
-- =====================================================================

alter table public.utakmice
  add column if not exists datum_rucno text;

alter table public.utakmice
  add column if not exists vrijeme_rucno text;

comment on column public.utakmice.datum_rucno is
  'Ručni termin, npr. ''04.09.2026.''. Ima prednost pred datumom s HNS-a. '
  'Scraper ga ne dira. Obrisati kad HNS upiše isti termin.';

comment on column public.utakmice.vrijeme_rucno is
  'Ručno vrijeme, npr. ''17:30''. Ima prednost pred vremenom s HNS-a. '
  'Scraper ga ne dira. Obrisati kad HNS upiše isti termin.';


-- ---------------------------------------------------------------------
-- PRIMJER UPISA
-- ---------------------------------------------------------------------
-- Prvo pogledaj redak, da vidiš točne nazive klubova i što sada piše:
--
--   select kolo, domacin, gost, datum, vrijeme, datum_rucno, vrijeme_rucno
--   from public.utakmice
--   where sezona = '2026/27'
--     and natjecanje = '4. NL NS Rijeka'
--     and domacin ilike '%Žminj%';
--
-- Pa upiši ručni termin (ovdje: utakmica se igra 04.09. umjesto 05.09.):
--
--   update public.utakmice
--   set datum_rucno = '04.09.2026.'
--   where sezona = '2026/27'
--     and natjecanje = '4. NL NS Rijeka'
--     and domacin ilike '%Žminj%'
--     and gost ilike '%Ližnjan%'
--   returning kolo, domacin, gost, datum, datum_rucno;
--
-- Stupac datum se popuni tek pri sljedećem pokretanju scrapera. Ako
-- stranica mora biti točna odmah, upiši i njega:
--
--   update public.utakmice
--   set datum = '04.09.2026.', datum_rucno = '04.09.2026.'
--   where ...;
--
-- ---------------------------------------------------------------------
-- BRISANJE (kad HNS upiše isti termin)
-- ---------------------------------------------------------------------
--   update public.utakmice
--   set datum_rucno = null, vrijeme_rucno = null
--   where sezona = '2026/27'
--     and natjecanje = '4. NL NS Rijeka'
--     and domacin ilike '%Žminj%'
--     and gost ilike '%Ližnjan%'
--   returning kolo, domacin, gost, datum, datum_rucno;

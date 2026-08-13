-- =====================================================================
-- RASPORED NEODIGRANIH UTAKMICA - JEDNOKRATNA MIGRACIJA
-- =====================================================================
-- Ovo pokreni JEDNOM u Supabase SQL Editoru, prije prvog pokretanja
-- novog scrapera (onog koji sad uz odigrane utakmice sprema i raspored
-- budućih kola).
--
-- KAKO:
--   1. Supabase -> SQL Editor -> New query
--   2. Zalijepi CIJELU ovu datoteku -> Run
--   3. Ako sve prođe bez greške, gotovo je - ništa dalje ne treba raditi
--      ovdje, scraper radi ostatak sam.
--
-- ŠTO RADI:
--   1. Dodaje tri nova stupca za buduće utakmice: datum, vrijeme, stadion
--      (odvojeno od "stadion_datum" koji se i dalje puni tek kad se
--      utakmica odigra i postoji zapisnik).
--   2. "hns_url" više ne mora postojati za svaku utakmicu (neodigrane
--      nemaju poveznicu na zapisnik) - skida se ta obaveza.
--   3. Dodaje pravilo jedinstvenosti po (natjecanje, sezona, kolo,
--      domaćin, gost) - to je novi ključ po kojem se utakmice
--      prepoznaju i ažuriraju (raniji ključ hns_url ne postoji za
--      buduće utakmice, pa sam po sebi više nije dovoljan).
-- =====================================================================

alter table public.utakmice
  add column if not exists datum text,
  add column if not exists vrijeme text,
  add column if not exists stadion text;

alter table public.utakmice
  alter column hns_url drop not null;

alter table public.utakmice
  add constraint utakmice_prirodni_kljuc
  unique (natjecanje, sezona, kolo, domacin, gost);

-- =====================================================================
-- Ako gornji "add constraint" javi grešku o dupliciranim vrijednostima,
-- to znači da već u bazi postoje dva retka s istim natjecanjem, sezonom,
-- kolom, domaćinom i gostom (npr. stara pogreška ili ručni unos). U tom
-- slučaju javi se prije nastavka - ne briši ništa sam.
-- =====================================================================

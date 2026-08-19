-- =====================================================================
-- POTPIS AUTORA ISPOD ČLANAKA - novi stupac "autor" u tablici clanci
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Pokreće se JEDNOM. Ponovno pokretanje ne škodi ("if not exists" i
--   uvjet "autor is null"), ali nije potrebno.
--
-- RLS postavke se NE diraju.
--
-- Dok se ovo ne pokrene, stranica radi normalno: članak tada nema
-- autora pa se ispod naslova prikazuje samo datum.
-- =====================================================================

alter table public.clanci
  add column if not exists autor text default 'Andrej Malnar';

update public.clanci set autor = 'Andrej Malnar' where autor is null;


-- PROVJERA: očekivano su svi članci potpisani.
select slug, naslov, autor from public.clanci order by objavljeno_u desc;


-- =====================================================================
-- Kasnije, ako neki članak potpisuje netko drugi:
--   update public.clanci set autor = 'Ime Prezime' where slug = '...';
--
-- Ako članak treba ostati bez potpisa (prikazat će se samo datum):
--   update public.clanci set autor = null where slug = '...';
-- =====================================================================

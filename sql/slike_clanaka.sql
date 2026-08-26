-- =====================================================================
-- FOTOGRAFIJA UZ ČLANAK - dva nova stupca u tablici clanci i spremište
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Pokreće se JEDNOM. Ponovno pokretanje ne škodi ("if not exists"
--   i "on conflict"), ali nije potrebno.
--
-- Stupac "slika_url" VEĆ POSTOJI i već se koristi, ovdje se ne dira.
-- Nova su samo dva:
--   slika_opis    - opis fotografije, za čitače ekrana i za slučaj da
--                   se slika ne učita; ide i u oznaku za dijeljenje
--   slika_potpis  - potpis ispod fotografije, npr. "Foto: Lokal-Arena"
--
-- Oba smiju ostati prazna, pa stariji članci nastavljaju raditi
-- neizmijenjeni: bez opisa slika i dalje stoji, bez potpisa nema
-- retka ispod nje.
--
-- RLS na tablici clanci se NE dira. Postojeća politika
-- "clanci_javno_citanje" i dalje pušta samo objavljene članke.
-- =====================================================================

alter table public.clanci
  add column if not exists slika_opis text;

alter table public.clanci
  add column if not exists slika_potpis text;


-- =====================================================================
-- SPREMIŠTE ZA FOTOGRAFIJE
-- =====================================================================
-- Spremnik "clanci" je JAVAN za čitanje, jer se slike prikazuju svima
-- koji otvore stranicu. Pisanje ostaje samo servisnom ključu, dakle
-- tebi kroz Supabase dashboard; posjetitelj stranice ne može ništa
-- postaviti ni obrisati, jer se za pisanje ne dodaje nijedna politika.
--
-- Ograničenja su tu da spriječe slučajan upload goleme datoteke ili
-- nečega što nije slika:
--   - najviše 5 MB po datoteci
--   - samo JPEG, PNG i WebP
-- =====================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'clanci',
  'clanci',
  true,
  5242880,                                        -- 5 MB
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
  set public = true,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;


-- =====================================================================
-- PROVJERA
-- =====================================================================
-- 1. Oba stupca postoje i smiju biti prazna.
select column_name as stupac, data_type as tip, is_nullable as smije_biti_prazno
from information_schema.columns
where table_schema = 'public' and table_name = 'clanci'
  and column_name in ('slika_url', 'slika_opis', 'slika_potpis')
order by column_name;

-- 2. Spremnik je javan, s ograničenjima.
select id, public as javan, file_size_limit as najvise_bajtova, allowed_mime_types as dopusteni_tipovi
from storage.buckets
where id = 'clanci';

-- 3. Nijedna politika za PISANJE po spremištu ne smije postojati za
--    javne uloge. Očekivano: prazan ispis ili samo politike koje si
--    sam svjesno dodao.
select policyname as politika, cmd as naredba, roles as uloge
from pg_policies
where schemaname = 'storage' and tablename = 'objects'
order by policyname;


-- =====================================================================
-- ADRESA SLIKE
-- =====================================================================
-- Nakon uploada kroz dashboard, javna adresa izgleda ovako:
--
--   https://<projekt>.supabase.co/storage/v1/object/public/clanci/<datoteka>
--
-- Tu adresu upisuješ u stupac slika_url, na primjer:
--
--   update public.clanci
--      set slika_url    = 'https://xxxx.supabase.co/storage/v1/object/public/clanci/naprijed-kraljevica-2026-08-29.jpg',
--          slika_opis   = 'Igrači Naprijeda slave pogodak pred tribinom',
--          slika_potpis = 'Foto: Lokal-Arena'
--    where slug = 'derbi-naprijed-kraljevica';
-- =====================================================================

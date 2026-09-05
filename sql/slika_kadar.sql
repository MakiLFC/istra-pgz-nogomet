-- =====================================================================
-- SLIKA_KADAR - okomiti kadar fotografije uz clanak
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Pokrece se JEDNOM ("if not exists", ponovno pokretanje ne skodi).
--
-- ZASTO POSTOJI
--   Fotografije uz clanke stizu s mobitela, u svakom omjeru, najcesce
--   uspravne. Stranica ih zato od 05.09.2026. uvijek prikazuje u okviru
--   stalnog omjera, 3:2 u clanku i 16:9 na kartici, a visak odreze. Time
--   nijedna slika ne moze zauzeti pola ekrana ni razbiti red kartica, i
--   nista se ne mora rezati prije ucitavanja.
--
--   Reze se iz sredine, sto je dobro u vecini slucajeva. Kad je vazno
--   bas ono gore ili dolje, ovaj stupac pomice kadar, bez diranja same
--   datoteke i bez ponovnog ucitavanja.
--
-- OBLIK ZAPISA
--   'vrh'      zadrzi gornji dio slike
--   'sredina'  isto kao prazno, rezanje iz sredine
--   'dno'      zadrzi donji dio slike
--   '0' do '100'  precizno, u postotku: 0 je vrh, 100 je dno
--
--   Prazno polje znaci sredina, pa se za vecinu clanaka nista ne upisuje.
--   Ovo je rucni unos, scraper tablicu clanci ionako ne dira.
-- =====================================================================

alter table public.clanci
  add column if not exists slika_kadar text;

comment on column public.clanci.slika_kadar is
  'Okomiti kadar fotografije kad se reze na omjer okvira: vrh, sredina, '
  'dno ili broj 0 do 100 (0 je vrh). Prazno znaci sredina.';


-- ---------------------------------------------------------------------
-- PRIMJERI
-- ---------------------------------------------------------------------
-- Zadrzi gornji dio slike (npr. kad je vazna tribina ili semafor):
--   update public.clanci set slika_kadar = 'vrh' where slug = '...';
--
-- Malo ispod sredine (kao kod fotografije s Kantride 04.09.2026.):
--   update public.clanci set slika_kadar = '60' where slug = '...';
--
-- Natrag na sredinu:
--   update public.clanci set slika_kadar = null where slug = '...';
--
-- Pregled svih clanaka sa slikom i zadanim kadrom:
--   select slug, slika_kadar, slika_url from public.clanci
--   where slika_url is not null order by objavljeno_u desc;

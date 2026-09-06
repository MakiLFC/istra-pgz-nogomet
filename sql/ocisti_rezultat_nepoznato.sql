-- =====================================================================
-- ČIŠĆENJE: rezultat koji nije brojka, npr. riječ "Nepoznato"
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Prvo pogledaj ispis prvog upita, pa tek onda pokreni drugi.
--
-- ZASTO
--   06.09.2026. HNK Goranin - NK Stari grad Rijeka (1. kolo 1. ZNL PGZ)
--   imala je na HNS-u poveznicu na zapisnik, ali u njemu jos nije bilo
--   rezultata. Scraper je tada u polje rezultata upisivao rijec
--   "Nepoznato", pa je stranica tu rijec prikazivala kao rezultat.
--
--   Scraper je popravljen: kad se rezultat ne procita, kljuc se uopce ne
--   salje u upsert, pa polje ostaje prazno i vec upisan rezultat se ne
--   moze prebrisati. Cuva test_rezultat_bez_brojki.py.
--
--   Ovaj SQL cisti ono sto je vec upisano. Prazno polje je tocno: dok
--   rezultata nema, utakmica se prikazuje kao neodigrana.
-- =====================================================================


-- ---------- 1. STO CE SE PROMIJENITI ----------
-- Ocekivano: samo Goranin - Stari grad Rijeka. Ako se pojavi jos koja,
-- pogledaj je na Semaforu prije nego pokrenes drugi upit.
select id, sezona, natjecanje, kolo, domacin, gost, rezultat, hns_url
from public.utakmice
where rezultat is not null
  and rezultat !~ '^\d+:\d+$'
order by sezona, natjecanje, kolo;


-- ---------- 2. CISCENJE ----------
update public.utakmice
   set rezultat = null
 where rezultat is not null
   and rezultat !~ '^\d+:\d+$'
returning sezona, natjecanje, kolo, domacin, gost;


-- ---------- 3. PROVJERA ----------
-- Ocekivano: nula redaka.
select count(*) as preostalo
from public.utakmice
where rezultat is not null
  and rezultat !~ '^\d+:\d+$';

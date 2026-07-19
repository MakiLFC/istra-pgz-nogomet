-- =====================================================================
-- DERBI KOLA - TJEDNI PREDLOŽAK
-- =====================================================================
-- KAKO SE KORISTI (svaki vikend, ~2 minute):
--   1. Otvori ovu datoteku u Notepadu
--   2. Za ligu u kojoj označavaš derbi: u KORAKU 2 upiši imena klubova
--      (točno kako pišu na stranici!) i svoj sažetak
--   3. Kopiraj OBA koraka za tu ligu u Supabase SQL Editor -> Run
--   4. Provjeri ispis: druga naredba mora javiti "1 row" - ako javi 0,
--      imena klubova ne odgovaraju bazi (provjeri točan zapis, npr.
--      "NK Lokomotiva (R)" ima razmak i zagrade)
--
-- Sezonu promijeni na jednom mjestu dolje kad krene 2026/27.
-- Ne moraš koristiti sve četiri lige svaki tjedan - samo one koje želiš.
-- =====================================================================


-- ================== 3. NL ZAPAD ==================
-- KORAK 1: ugasi prošlotjedni derbi ove lige
update public.utakmice
set derbi = false
where derbi = true and natjecanje = '3. NL Zapad' and sezona = '2025/26';

-- KORAK 2: označi novi derbi + upiši sažetak
update public.utakmice
set derbi = true,
    tekst_clanka = 'OVDJE UPIŠI SVOJ SAŽETAK UTAKMICE.'
where natjecanje = '3. NL Zapad' and sezona = '2025/26'
  and domacin = 'IME DOMAĆINA'
  and gost = 'IME GOSTA'
  and kolo = 0;   -- <- upiši broj kola (sigurnosna mreža ako su klubovi
                  --    igrali više puta u sezoni)


-- ================== 1. ŽNL PGŽ ==================
update public.utakmice
set derbi = false
where derbi = true and natjecanje = '1. ŽNL PGŽ' and sezona = '2025/26';

update public.utakmice
set derbi = true,
    tekst_clanka = 'OVDJE UPIŠI SVOJ SAŽETAK UTAKMICE.'
where natjecanje = '1. ŽNL PGŽ' and sezona = '2025/26'
  and domacin = 'IME DOMAĆINA'
  and gost = 'IME GOSTA'
  and kolo = 0;


-- ================== 2. ŽNL PGŽ ==================
update public.utakmice
set derbi = false
where derbi = true and natjecanje = '2. ŽNL PGŽ' and sezona = '2025/26';

update public.utakmice
set derbi = true,
    tekst_clanka = 'OVDJE UPIŠI SVOJ SAŽETAK UTAKMICE.'
where natjecanje = '2. ŽNL PGŽ' and sezona = '2025/26'
  and domacin = 'IME DOMAĆINA'
  and gost = 'IME GOSTA'
  and kolo = 0;


-- ================== 4. NL NS RIJEKA ==================
update public.utakmice
set derbi = false
where derbi = true and natjecanje = '4. NL NS Rijeka' and sezona = '2025/26';

update public.utakmice
set derbi = true,
    tekst_clanka = 'OVDJE UPIŠI SVOJ SAŽETAK UTAKMICE.'
where natjecanje = '4. NL NS Rijeka' and sezona = '2025/26'
  and domacin = 'IME DOMAĆINA'
  and gost = 'IME GOSTA'
  and kolo = 0;


-- =====================================================================
-- BONUS - korisne pomoćne naredbe:
--
-- Vidi koje su utakmice trenutno označene kao derbi:
--   select natjecanje, kolo, domacin, gost, rezultat
--   from public.utakmice where derbi = true;
--
-- Ugasi SVE probne derbije odjednom (npr. prije početka nove sezone):
--   update public.utakmice set derbi = false, tekst_clanka = null
--   where derbi = true;
--   (pazi: briše i sažetke! bez ", tekst_clanka = null" gasi samo oznake)
--
-- Dodaj fotografiju uz sažetak (URL slike):
--   update public.utakmice set slika_url = 'https://...'
--   where derbi = true and natjecanje = '3. NL Zapad';
-- =====================================================================

-- =====================================================================
-- JEDNOKRATNO ČIŠĆENJE: probni sažetak na utakmici Jadran - Lokomotiva
-- =====================================================================
-- ŠTO OVO RADI:
--   Briše probni tekst ("probni sažetak") i oznaku derbija s utakmice
--   30. kola 3. NL Zapad: NK Jadran-Poreč - NK Lokomotiva (R).
--   To je bila proba iz prošle sezone i više ne treba stajati na stranici.
--
-- KAKO SE KORISTI:
--   1. Supabase -> SQL Editor
--   2. Kopiraj KORAK 1, klikni Run, pogledaj ispis (ništa se ne mijenja)
--   3. Ako ispis pokazuje tu i samo tu utakmicu, kopiraj KORAK 2 i Run
--   4. KORAK 3 je provjera da je tekst nestao
--
-- Ovo se pokreće SAMO JEDNOM. Za tjedno označavanje derbija koristi
-- datoteku derbi_tjedni_predlozak.sql.
-- =====================================================================


-- KORAK 1: pogledaj što će se promijeniti (ne mijenja ništa)
-- Očekivano: JEDAN redak, sezona 2025/26, s probnim tekstom.
select id, sezona, kolo, domacin, gost, rezultat, derbi, tekst_clanka
from public.utakmice
where natjecanje = '3. NL Zapad'
  and kolo = 30
  and domacin ilike '%Jadran%'
  and gost    ilike '%Lokomotiva%';


-- KORAK 2: obriši probni tekst i oznaku derbija
-- Mora javiti "1 row". Ako javi 0, imena u KORAKU 1 nisu pogodila
-- utakmicu; ako javi više od 1, prvo suzi uvjet (npr. dodaj sezonu).
update public.utakmice
set derbi = false,
    tekst_clanka = null
where natjecanje = '3. NL Zapad'
  and kolo = 30
  and domacin ilike '%Jadran%'
  and gost    ilike '%Lokomotiva%';

-- Ako je uz probni tekst bila stavljena i probna fotografija, makni i nju.
-- (Nije nužno: slika se prikazuje samo zajedno s tekstom, pa je bez teksta
-- ionako nitko ne vidi. Zato je ovaj redak zakomentiran.)
-- update public.utakmice
-- set slika_url = null
-- where natjecanje = '3. NL Zapad' and kolo = 30
--   and domacin ilike '%Jadran%' and gost ilike '%Lokomotiva%';


-- KORAK 3: provjera (tekst_clanka mora biti prazan, derbi = false)
select sezona, kolo, domacin, gost, derbi, tekst_clanka
from public.utakmice
where natjecanje = '3. NL Zapad'
  and kolo = 30
  and domacin ilike '%Jadran%'
  and gost    ilike '%Lokomotiva%';

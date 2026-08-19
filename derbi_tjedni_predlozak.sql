-- =====================================================================
-- DERBI KOLA - TJEDNI PREDLOŽAK
-- =====================================================================
-- Rad ide u dva navrata, jer se derbi označava PRIJE utakmice, a sažetak
-- se piše POSLIJE nje:
--
--   PRIJE KOLA   -> KORAK A (nađi točna imena) + KORAK B (označi derbi)
--   POSLIJE KOLA -> KORAK C (upiši svoj sažetak, po želji i fotografiju)
--
-- Sve se pokreće u Supabaseu: SQL Editor -> zalijepi -> Run.
-- Svaka naredba mora javiti "1 row". Ako javi 0, imena klubova ne
-- odgovaraju bazi - zato prvo ide KORAK A, koji ispiše točne nazive.
--
-- Sezona je postavljena na 2026/27. Kad krene 2027/28, zamijeni sve
-- pojave '2026/27' (u Notepadu: Ctrl+H, Zamijeni sve).
-- Ne moraš koristiti sve četiri lige svaki tjedan - samo one koje želiš.
-- =====================================================================


-- =====================================================================
-- KORAK A: ispiši utakmice kola s TOČNIM imenima klubova
-- =====================================================================
-- Promijeni ligu i broj kola, pa Run. Iz ispisa prepiši "domacin" i
-- "gost" u KORAK B - tako se ne može promašiti zapis imena
-- (npr. "NK Lokomotiva (R)" ima razmak i zagrade).
select kolo, domacin, gost, datum, vrijeme, stadion, rezultat, derbi
from public.utakmice
where sezona = '2026/27'
  and natjecanje = '3. NL Zapad'   -- <- liga
  and kolo = 1                     -- <- broj kola
order by datum, vrijeme;


-- =====================================================================
-- KORAK B: označi derbi kola (PRIJE utakmice, bez sažetka)
-- =====================================================================
-- Sažetak se ovdje NE upisuje - utakmica još nije odigrana. Dok teksta
-- nema, na stranici stoji samo žuta oznaka "Derbi" i poveznica na kolo.

-- ---------- 3. NL ZAPAD ----------
-- B1: ugasi prošlotjedni derbi ove lige
update public.utakmice
set derbi = false
where derbi = true and natjecanje = '3. NL Zapad' and sezona = '2026/27';

-- B2: označi novi derbi
update public.utakmice
set derbi = true
where natjecanje = '3. NL Zapad' and sezona = '2026/27'
  and domacin = 'IME DOMAĆINA'
  and gost    = 'IME GOSTA'
  and kolo = 0;   -- <- upiši broj kola (sigurnosna mreža ako su klubovi
                  --    igrali više puta u sezoni)

-- ---------- 4. NL NS RIJEKA ----------
update public.utakmice
set derbi = false
where derbi = true and natjecanje = '4. NL NS Rijeka' and sezona = '2026/27';

update public.utakmice
set derbi = true
where natjecanje = '4. NL NS Rijeka' and sezona = '2026/27'
  and domacin = 'IME DOMAĆINA'
  and gost    = 'IME GOSTA'
  and kolo = 0;

-- ---------- 1. ŽNL PGŽ ----------
-- (liga još nije objavljena za 26/27 - preskoči dok se ne pojavi)
update public.utakmice
set derbi = false
where derbi = true and natjecanje = '1. ŽNL PGŽ' and sezona = '2026/27';

update public.utakmice
set derbi = true
where natjecanje = '1. ŽNL PGŽ' and sezona = '2026/27'
  and domacin = 'IME DOMAĆINA'
  and gost    = 'IME GOSTA'
  and kolo = 0;

-- ---------- 2. ŽNL PGŽ ----------
-- (liga još nije objavljena za 26/27 - preskoči dok se ne pojavi)
update public.utakmice
set derbi = false
where derbi = true and natjecanje = '2. ŽNL PGŽ' and sezona = '2026/27';

update public.utakmice
set derbi = true
where natjecanje = '2. ŽNL PGŽ' and sezona = '2026/27'
  and domacin = 'IME DOMAĆINA'
  and gost    = 'IME GOSTA'
  and kolo = 0;


-- =====================================================================
-- KORAK C: upiši sažetak (POSLIJE utakmice)
-- =====================================================================
-- Pogađa utakmicu koja je u toj ligi trenutno označena kao derbi, pa ne
-- moraš ponovno upisivati imena klubova. Promijeni samo naziv lige i
-- tekst. Sažetak se pojavi na stranici lige, ispod te utakmice.
--
-- VAŽNO: u tekstu se apostrof piše DVOSTRUKO -> 'Sudac''i prekid...'
update public.utakmice
set tekst_clanka = 'OVDJE UPIŠI SVOJ SAŽETAK UTAKMICE.'
where derbi = true
  and natjecanje = '3. NL Zapad'   -- <- liga
  and sezona = '2026/27';

-- Fotografija uz sažetak (URL slike). Prikazuje se samo ako postoji tekst.
-- update public.utakmice
-- set slika_url = 'https://...'
-- where derbi = true and natjecanje = '3. NL Zapad' and sezona = '2026/27';


-- =====================================================================
-- BONUS - korisne pomoćne naredbe:
--
-- Vidi koje su utakmice trenutno označene kao derbi:
--   select natjecanje, kolo, domacin, gost, rezultat, tekst_clanka
--   from public.utakmice where derbi = true;
--
-- Ispravi sažetak koji si već upisao: samo ponovi KORAK C s novim tekstom
-- (stari se prepiše).
--
-- Ugasi SVE oznake derbija odjednom (sažetci ostaju):
--   update public.utakmice set derbi = false where derbi = true;
--
-- Obriši sažetak s jedne utakmice (oznaka derbija ostaje):
--   update public.utakmice set tekst_clanka = null
--   where natjecanje = '3. NL Zapad' and sezona = '2026/27' and kolo = 0
--     and domacin = 'IME DOMAĆINA' and gost = 'IME GOSTA';
-- =====================================================================

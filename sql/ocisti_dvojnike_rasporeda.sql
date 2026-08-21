-- =====================================================================
-- JEDNOKRATNO ČIŠĆENJE: dvojnici utakmica iz sekcije "Klubovi u natjecanju"
-- =====================================================================
-- ŠTO SE DOGODILO:
--   Scraper je raspored čitao do kraja stranice umjesto do kraja sekcije
--   rasporeda, pa je pokupio i sekciju "Klubovi u natjecanju", u kojoj se
--   svaka utakmica pojavljuje po drugi put. Ondje nema naslova "X. kolo",
--   pa je tim redcima pripisano ZADNJE viđeno kolo (15. za 3. NL Zapad,
--   13. za 4. NL NS Rijeka), dok su datum i klubovi ostali točni.
--
--   Posljedica: 15. kolo 3. NL imalo je 120 redaka umjesto 8, a 13. kolo
--   4. NL 91 umjesto 7. Traka "Sljedeće kolo" na naslovnici grupira po
--   datumu, pa je zbrajala prave utakmice i njihove dvojnike.
--
--   Uzrok je popravljen u scraper_supabase.py (parsiranje sada staje na
--   naslovu "Ljestvica" / "Statistika" / "Klubovi u natjecanju"), pa se
--   dvojnici više neće stvarati. Ovo čisti one koji su već upisani.
--
-- KAKO SE KORISTI:
--   1. KORAK 1 pokaži i prebroji što se briše (ništa ne mijenja)
--   2. Ako brojke odgovaraju, pokreni KORAK 2
--   3. KORAK 3 je provjera
--
-- KAKO SE PREPOZNAJE DVOJNIK:
--   Isti par (domaćin, gost) u istoj ligi i sezoni pojavljuje se u
--   rasporedu točno jednom, jer se dvokružna liga igra jednom kod jednog
--   i jednom kod drugog kluba. Zato je redak u zadnjem kolu čiji isti par
--   postoji i u nekom ranijem kolu sigurno dvojnik.
--
--   PAZI ako ovo ikad primjenjuješ na drugu ligu: u malim županijskim
--   ligama koje se igraju trokružno isti par MOŽE dvaput imati istog
--   domaćina, pa ovo pravilo ondje ne vrijedi. Zato su lige i kola
--   ispod izričito nabrojani, a ne pogađaju se sami.
--
--   Dodatna zaštita: redci u kojima stoji tvoj unos (oznaka derbija,
--   sažetak ili slika) ne brišu se ni u kojem slučaju.
-- =====================================================================


-- KORAK 1: što bi se obrisalo (ne mijenja ništa)
-- Očekivano: 112 redaka za 3. NL Zapad i 84 za 4. NL NS Rijeka.
select u.natjecanje, count(*) as za_brisanje
from public.utakmice u
where u.sezona = '2026/27'
  and (   (u.natjecanje = '3. NL Zapad'     and u.kolo = 15)
       or (u.natjecanje = '4. NL NS Rijeka' and u.kolo = 13))
  and u.derbi is not true
  and u.tekst_clanka is null
  and u.slika_url is null
  and exists (
    select 1 from public.utakmice v
    where v.sezona     = u.sezona
      and v.natjecanje = u.natjecanje
      and v.domacin    = u.domacin
      and v.gost       = u.gost
      and v.kolo       < u.kolo
  )
group by u.natjecanje;


-- KORAK 2: brisanje
delete from public.utakmice u
where u.sezona = '2026/27'
  and (   (u.natjecanje = '3. NL Zapad'     and u.kolo = 15)
       or (u.natjecanje = '4. NL NS Rijeka' and u.kolo = 13))
  and u.derbi is not true
  and u.tekst_clanka is null
  and u.slika_url is null
  and exists (
    select 1 from public.utakmice v
    where v.sezona     = u.sezona
      and v.natjecanje = u.natjecanje
      and v.domacin    = u.domacin
      and v.gost       = u.gost
      and v.kolo       < u.kolo
  );


-- KORAK 3: provjera
-- Očekivano: 3. NL Zapad 8 redaka u svakom kolu od 1 do 15 (ukupno 120),
-- 4. NL NS Rijeka 7 u svakom kolu od 1 do 13 (ukupno 91).
select natjecanje, kolo, count(*) as redaka
from public.utakmice
where sezona = '2026/27'
group by natjecanje, kolo
order by natjecanje, kolo;

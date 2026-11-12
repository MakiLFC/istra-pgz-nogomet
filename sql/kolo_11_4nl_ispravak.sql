-- =====================================================================
-- 11. KOLO 4. NL NS RIJEKA: BRISANJE DVA STARA PARA I ISPRAVAK SATNICE
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Pokreće se JEDNOM. Ponovno pokretanje ne škodi: brisanje tada ne
--   nađe ništa, a satnica se upiše ista.
--
-- ZAŠTO POSTOJI
--   HNS je prije zabrane automatskog preuzimanja (pravilo 7 u CLAUDE.md)
--   dvaput presložio parove 11. kola. Domaćin i gost ulaze u ključ za
--   upsert, pa se okrenuti par upisao kao NOVA utakmica, a stara je
--   ostala kao duh. Zato 11. kolo u bazi ima osam utakmica umjesto šest
--   i stranica lige ih sve prikazuje.
--
--   Dnevna "Provjera termina" to je i javila, 08. i 09.11.2026., ali
--   ona je ugašena zajedno sa scraperom, pa brisanja nema tko odraditi.
--
--   Pravi raspored, sa Semafora 12.11.2026.:
--     Mladost Fažana - Rječina        Oliva, Fažana
--     Borac (Ba) - Žminj              Krasica
--     Klana - Otočac                  Grašćina
--     Funtana - Medulin 1921          Kamp NK Jadran-Poreč, Poreč
--     Ližnjan - Umag-CC Umago         Šaraja
--     Štinjan - Smoljanci Sloboda     Fortin
--
--   Duhovi su dakle Žminj - Borac (Ba) i Smoljanci Sloboda - Štinjan.
--   Uz to je na Semaforu satnica 14:30, a u bazi stoji 14:00.
-- =====================================================================

-- 1. ŠTO JE SADA U BAZI (pogledaj prije nego išta pokreneš)
select kolo, domacin, gost, datum, vrijeme, rezultat
from public.utakmice
where natjecanje = '4. NL NS Rijeka'
  and sezona = '2026/27'
  and kolo = 11
order by domacin;

-- 2. BRISANJE DVA STARA PARA
--    Uvjet "rezultat is null" je zaštita: utakmica koja se odigrala
--    ostaje u bazi što god piše ovdje.
delete from public.utakmice
where natjecanje = '4. NL NS Rijeka'
  and sezona = '2026/27'
  and kolo = 11
  and rezultat is null
  and (domacin, gost) in (
        ('NK Žminj', 'NK Borac (Ba)'),
        ('NK Smoljanci Sloboda', 'NK Štinjan')
      );

-- 3. SATNICA 14:30 ZA ŠEST PRAVIH UTAKMICA
update public.utakmice
set vrijeme = '14:30'
where natjecanje = '4. NL NS Rijeka'
  and sezona = '2026/27'
  and kolo = 11
  and datum = '14.11.2026.'
  and vrijeme is distinct from '14:30';

-- 4. PROVJERA: mora vratiti točno šest redaka, sve u 14:30
select kolo, domacin, gost, datum, vrijeme, rezultat
from public.utakmice
where natjecanje = '4. NL NS Rijeka'
  and sezona = '2026/27'
  and kolo = 11
order by domacin;

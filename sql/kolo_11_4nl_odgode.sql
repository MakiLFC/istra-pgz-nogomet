-- =====================================================================
-- 11. KOLO 4. NL NS RIJEKA: DVIJE ODGODE I PREMJEŠTAJ NA NEDJELJU
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Pokreće se JEDNOM; ponovno pokretanje upiše isto i ne škodi.
--
-- ŠTO SE MIJENJA (stanje sa Semafora, 14.11.2026.)
--   Borac (Ba) - Žminj            odgođeno, novi termin nije poznat
--   Štinjan - Smoljanci Sloboda   odgođeno, novi termin nije poznat
--   Mladost Fažana - Rječina      nedjelja 15.11.2026. u 13:30
--
--   Ostale tri (Klana - Otočac, Funtana - Medulin 1921, Ližnjan -
--   Umag-CC Umago) igraju u subotu u 14:30 i ne diraju se.
--
-- ZAŠTO SE ODGOĐENIMA BRIŠE TERMIN
--   Stranica lige utakmicu bez rezultata prikazuje kao odgođenu kad
--   nema datuma (`odgodjena` u components/StranicaLige.tsx). Tada na
--   mjestu rezultata piše "ODG." i ispod stoji rečenica "Utakmica je
--   odgođena, novi termin još nije poznat.". Dok datum stoji, pisalo
--   bi "?:?" sve do 18.11., kad datum ostari više od četiri dana.
--   Kad HNS objavi nove termine, samo se upišu u datum i vrijeme.
-- =====================================================================

-- 1. ŠTO JE SADA U BAZI
select kolo, domacin, gost, datum, vrijeme, stadion, rezultat
from public.utakmice
where natjecanje = '4. NL NS Rijeka'
  and sezona = '2026/27'
  and kolo = 11
order by domacin;

-- 2. DVIJE ODGOĐENE: briše se termin, pa stranica piše ODG.
update public.utakmice
set datum = null,
    vrijeme = null
where natjecanje = '4. NL NS Rijeka'
  and sezona = '2026/27'
  and kolo = 11
  and rezultat is null
  and (domacin, gost) in (
        ('NK Borac (Ba)', 'NK Žminj'),
        ('NK Štinjan', 'NK Smoljanci Sloboda')
      );

-- 3. MLADOST FAŽANA - RJEČINA: nedjelja 15.11.2026. u 13:30
update public.utakmice
set datum = '15.11.2026.',
    vrijeme = '13:30'
where natjecanje = '4. NL NS Rijeka'
  and sezona = '2026/27'
  and kolo = 11
  and domacin = 'NK Mladost Fažana'
  and gost = 'NK Rječina';

-- 4. NEOBAVEZNO: igralište Funtane i Medulina
--    Semafor za tu utakmicu pokazuje kamp NK Jadran-Poreč u Poreču, a
--    u bazi stoji Funtana. Nisi to tražio, pa stoji zakomentirano;
--    makni dvije crtice ispred update ako hoćeš da se i to ispravi.
-- update public.utakmice
-- set stadion = 'Kamp NK Jadran-Poreč, Poreč'
-- where natjecanje = '4. NL NS Rijeka'
--   and sezona = '2026/27'
--   and kolo = 11
--   and domacin = 'NK Funtana'
--   and gost = 'NK Medulin 1921';

-- 5. PROVJERA: dva retka bez datuma, Mladost 15.11. u 13:30, ostale tri
--    u subotu u 14:30
select kolo, domacin, gost, datum, vrijeme, stadion, rezultat
from public.utakmice
where natjecanje = '4. NL NS Rijeka'
  and sezona = '2026/27'
  and kolo = 11
order by domacin;

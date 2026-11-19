-- 12. kolo 4. NL NS Rijeka: dva para su na Semaforu okrenuta u odnosu
-- na ono sto je u bazi, a satnica je razlicita od one koju je scraper
-- zatekao. Provjereno na Semaforu 19.11.2026. (snimka zaslona).
--
-- Semafor, subota 21.11.2026.:
--   12:15  Cres - Smoljanci Sloboda      Dari, Cres
--   14:00  Rjecina - Stinjan             Fran Juretic Bekarov, Drazice
--   14:00  Liznjan - Medulin 1921        Saraja, Liznjan          <- okrenuto
--   14:00  Zminj - Klana                 NK "Zminj", Zminj
--   14:00  Mladost Fazana - Borac (Ba)   Oliva, Fazana
--   16:00  Funtana - Otocac              Kamp NK Jadran-Porec, Porec  <- okrenuto
--
-- Posao "Termin u bazu" mijenja datum, vrijeme i stadion, ali ne moze
-- zamijeniti domacina i gosta, pa ta dva retka idu ovim SQL-om.

-- 1) Medulin 1921 - Liznjan  POSTAJE  Liznjan - Medulin 1921
update utakmice
   set domacin = 'NK Ližnjan',
       gost    = 'NK Medulin 1921',
       stadion = 'Šaraja, Ližnjan',
       vrijeme = '14:00'
 where natjecanje = '4. NL NS Rijeka'
   and sezona     = '2026/27'
   and kolo       = 12
   and domacin    = 'NK Medulin 1921'
   and gost       = 'NK Ližnjan'
   and rezultat is null;

-- 2) Otocac - Funtana  POSTAJE  Funtana - Otocac
update utakmice
   set domacin = 'NK Funtana',
       gost    = 'NK Otočac',
       stadion = 'Kamp NK Jadran-Poreč, Poreč',
       vrijeme = '16:00'
 where natjecanje = '4. NL NS Rijeka'
   and sezona     = '2026/27'
   and kolo       = 12
   and domacin    = 'NK Otočac'
   and gost       = 'NK Funtana'
   and rezultat is null;

-- 3) satnica ostalih cetiri utakmica
update utakmice set vrijeme = '12:15'
 where natjecanje = '4. NL NS Rijeka' and sezona = '2026/27' and kolo = 12
   and domacin = 'NK Cres' and gost = 'NK Smoljanci Sloboda';

update utakmice set vrijeme = '14:00'
 where natjecanje = '4. NL NS Rijeka' and sezona = '2026/27' and kolo = 12
   and domacin in ('NK Rječina', 'NK Žminj', 'NK Mladost Fažana');

-- provjera
select kolo, domacin, gost, datum, vrijeme, stadion
  from utakmice
 where natjecanje = '4. NL NS Rijeka' and sezona = '2026/27' and kolo = 12
 order by vrijeme, domacin;

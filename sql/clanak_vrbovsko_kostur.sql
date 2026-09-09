-- =====================================================================
-- KOSTUR ČLANKA: NK VRBOVSKO U NOVOJ SEZONI
-- Omladinac Vrata - Vrbovsko, 1. kolo 1. ŽNL PGŽ
-- srijeda 09.09.2026. u 17:30, Gmajna, Vrata
-- =====================================================================
-- OVO JOŠ NIJE ZA POKRETANJE.
--   U tekstu su prazna mjesta u UGLATIM ZAGRADAMA. Dok su ona unutra,
--   članak se ne upisuje. Kad rezultat bude poznat, popuni ih (ili mi
--   javi rezultat pa ih popunim ja) i tek onda pokreni KORAK 1.
--
-- ŠTO JE VEĆ GOTOVO
--   Dio o novom treneru i pojačanjima napisan je do kraja, po
--   Andrejevim podacima od 09.09.2026. Taj dio se ne mijenja ovisno o
--   rezultatu, pa je namjerno napisan unaprijed.
--
-- ŠTO SE DOPUNJAVA POSLIJE UTAKMICE
--   1. naslov, koji se piše prema rezultatu
--   2. sažetak, isto prema rezultatu
--   3. uvodni odlomak s rezultatom
--   4. odlomak o tijeku utakmice, strijelcima i minutama
--
-- ODAKLE ŠTO
--   Trener, pojačanja i njihovi podaci: Andrej, 09.09.2026.
--   Termin, mjesto i sljedeći susret: baza (raspored 1. ŽNL PGŽ 26/27).
--   Rezultat i strijelci: iz zapisnika, nakon utakmice.
--   Ništa drugo nije dodano: nema izjava, ocjena forme ni očekivanja.
--
-- BEZ FOTOGRAFIJE ZASAD
--   Ako bude fotografije, ide poslom "Fotografija za članak" na
--   GitHubu, sa slugom ovog članka.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS ČLANKA (još nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, slika_potpis,
   slika_kadar, objavljen, objavljeno_u)
values (
  'vrbovsko-novi-trener-i-pojacanja-2627',

  -- NASLOV se piše tek kad se zna rezultat, i nosi ono što je utakmicu
  -- odlučilo: strijelca, preokret, brojku. Pojačanja i trener idu u
  -- tekst, ne u naslov.
  '[NASLOV, prema rezultatu]',

  '[SAŽETAK, prema rezultatu: jedna rečenica s ishodom i onim što ga je odlučilo.]',

'[UVOD: rezultat i mjesto. Na primjer: Nogometaši Vrbovskog otvorili su
sezonu u 1. ŽNL PGŽ gostovanjem kod Omladinca u Vratima, gdje je na
Gmajni bilo X:Y.]

Utakmicom u Vratima Vrbovsko je krenulo u sezonu u kojoj se u klubu
promijenilo dosta toga. Momčad vodi novi trener Igor Cindrić, a popis
pojačanja duži je nego što se u ovom rangu obično viđa.

Petorica su stigla iz NK Ogulina. Obranu pojačavaju defanzivac Vedran
Kratofil, s 20 godina, i iskusni bek Dino Brozović. Iz istog kluba
stižu i braća Mateo i Fran Vukelja, od kojih je Mateo defanzivac. Mate
Cindrić dolazi nakon redovnog zabijanja u Ogulinu.

Josip Sabo, 19-godišnjak, dijete je NK Ogulina, a u Vrbovsko dolazi iz
malog nogometa, nakon duže pauze zbog ozljede.

Napad su pojačala još dvojica. Patrik Poljak prekaljeni je strijelac s
prvoligaškim iskustvom, a Živko Blagojević, 30-godišnji napadač, dolazi
iz Slovenije.

[TIJEK UTAKMICE: kako je tekla, tko je zabio i u kojoj minuti, tko je
od novih igrača zaigrao i kako. Ovdje ide ono što stoji u zapisniku i
što si vidio. Ako ne budeš na utakmici, dovoljni su strijelci i minute
iz zapisnika, pa se odlomak napiše kraće.]

Vrbovsko već u nedjelju igra ponovno. U 2. kolu, 13.09. u 16:30, na
svom terenu dočekuje Goranin, susret koji će Lokal-Arena ovaj vikend
označiti kao derbi kola te s njega donijeti detaljni sažetak.',

  '1. ŽNL PGŽ',
  null,
  null,
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'vrbovsko-novi-trener-i-pojacanja-2627'
-- returning slug, naslov, objavljen, slika_url;
--
-- Skidanje sa stranice (članak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'vrbovsko-novi-trener-i-pojacanja-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       slika_url, slika_kadar
from public.clanci
where slug = 'vrbovsko-novi-trener-i-pojacanja-2627';

-- =====================================================================
-- KOSTUR ČLANKA: NK VRBOVSKO U NOVOJ SEZONI
-- Omladinac Vrata - Vrbovsko, 1. kolo 1. ŽNL PGŽ
-- srijeda 09.09.2026. u 17:30, Gmajna, Vrata
-- =====================================================================
-- STANJE 09.09.2026. NAVEČER
--   Rezultat je poznat, 4:2 za Omladinac Vrata, i upisan je u tekst.
--   Ostalo je JEDNO prazno mjesto u uglatim zagradama, za strijelce i
--   minute. HNS je otvorio zapisnik, ali u njemu još nema ni rezultata
--   ni strijelaca, pa se čeka da ga dopuni.
--   Dok je uglata zagrada u tekstu, članak se ne upisuje.
--
-- ŠTO JE VEĆ GOTOVO
--   Dio o novom treneru i pojačanjima napisan je do kraja, po
--   Andrejevim podacima od 09.09.2026. Taj dio se ne mijenja ovisno o
--   rezultatu, pa je namjerno napisan unaprijed.
--
-- ŠTO SE DOPUNJAVA POSLIJE UTAKMICE
--   1. strijelci i minute, čim HNS dopuni zapisnik
--   2. naslov se tada može zaoštriti, ako neki pogodak to zasluži
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

  -- Naslov se može zaoštriti kad budu poznati strijelci.
  'HLADAN TUŠ ZA NOVO VRBOVSKO: 4:2 U VRATIMA',

  'Omladinac Vrata, prošle sezone pretposljednji, svladao je Vrbovsko koje je sezonu prije završilo treće.',

'Nogometaši Vrbovskog otvorili su sezonu u 1. ŽNL PGŽ porazom. Na Gmajni
u Vratima Omladinac je slavio 4:2.

Rezultat pomalo iznenađuje s obzirom na prošlu sezonu, u kojoj je
Omladinac Vrata bio pretposljednji, a Vrbovsko treće.

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

[STRIJELCI I MINUTE: čim HNS dopuni zapisnik, ovdje idu strijelci obiju
momčadi s minutama, i tko je od novih igrača zaigrao.]

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

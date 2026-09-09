-- =====================================================================
-- ČLANAK: NK VRBOVSKO U NOVOJ SEZONI
-- Omladinac Vrata - Vrbovsko 4:2, 1. kolo 1. ŽNL PGŽ
-- srijeda 09.09.2026. u 17:30, Gmajna, Vrata
-- =====================================================================
-- TEKST JE GOTOV. Pokreni po redu dva koraka na dnu datoteke.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Prvi korak upisuje članak s objavljen = false, dakle još NIJE
--   vidljiv na stranici. Objavljuje se KORAKOM 2.
--
--   Upis se pokreće SAMO JEDNOM. Drugo pokretanje javlja grešku zbog
--   jedinstvenog sluga, što znači da je prvo prošlo.
--
-- ODAKLE ŠTO
--   Trener i pojačanja: Andrej, 09.09.2026.
--   Mjesta na ljestvici prošle sezone: Andrej, 09.09.2026.
--   Rezultat, strijelci i minute: zapisnik s HNS-a, preko
--   public.pregled_kola('2026/27','1. ŽNL PGŽ',1).
--   Termin sljedećeg susreta: raspored u bazi.
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

  'DVOSTRUKI ŽIC SRUŠIO NOVO VRBOVSKO U VRATIMA',

  'Omladinac Vrata, prošle sezone pretposljednji, poveo je 4:1, a Vrbovsko je u prvom nastupu s novim trenerom i osam pojačanja stiglo tek do 4:2.',

'Nogometaši Vrbovskog otvorili su sezonu u 1. ŽNL PGŽ porazom. Na
Gmajni u Vratima Omladinac je slavio 4:2.

Rezultat pomalo iznenađuje s obzirom na prošlu sezonu, u kojoj je
Omladinac Vrata bio pretposljednji, a Vrbovsko treće.

Do pred kraj prvog poluvremena pogodaka nije bilo. Onda je u 43. minuti
Mateo Tomić doveo domaće u vodstvo, a Zorko Tomljenović je odmah po
povratku s odmora, u 47., povisio na 2:0. Josip Matovina smanjio je u
53. minuti, no Diego Žic je pogocima u 61. i 69. odveo Omladinac na
4:1. Konačnih 4:2 postavio je u 87. minuti Živko Blagojević, jedno od
ljetnih pojačanja Vrbovskog.

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
iz Slovenije i već se upisao među strijelce.

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

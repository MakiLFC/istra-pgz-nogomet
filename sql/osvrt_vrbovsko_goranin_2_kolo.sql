-- =====================================================================
-- ČLANAK: OSVRT VRBOVSKO - GORANIN 2:0, DERBI 2. KOLA 1. ŽNL PGŽ 2026/27
-- Odigrano 13.09.2026.
-- =====================================================================
-- KAKO SE KORISTI: pokreni po redu dva koraka na dnu datoteke.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Prvi korak (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   Zatim ide KORAK 2 (objava).
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- ODAKLE STO
--   Rezultat, strijelci, minute, oznaka derbija i pomaci na ljestvici
--   dolaze iz public.pregled_kola('2026/27','1. ZNL PGZ',2), dakle iz
--   zapisnika u bazi.
--
--   Drugi odlomak je ANDREJEV, prenesen po onome sto je cuo o utakmici:
--   cvrsta i borbena utakmica, visok ritam, prvi pogodak iz kornera,
--   drugi nakon dubinske lopte i istrcavanja protivnickog vratara.
--   Toga u zapisniku nema i nije nase zapazanje. Prepisano je u trece
--   lice, jer je izvorno bilo u prvom licu mnozine ("postizemo"), a to
--   bi u nasem tekstu zvucalo kao da pisemo iz kluba.
--
-- KARTONI
--   U zapisniku nema nijednog iskljucenja, ni crvenog ni zuto-crvenog.
--   Zuti kartoni po utakmici ne izlaze iz pregled_kola(), koja ih daje
--   samo kao zbroj za sezonu, pa se u tekstu ne navode. Ako ih zelis
--   dodati, citaju se iz postava te utakmice (upit je poslan Andreju
--   13.09.2026.).
--
-- BEZ FOTOGRAFIJE
--   Clanak nema sliku, pa se na kartici prikazuje zaglavlje lige, a pri
--   dijeljenju zajednicka slika Lokal-Arene.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'osvrt-vrbovsko-goranin-2-kolo-2627',
  'VRBOVSKO SLAVILO U DERBIJU I SKOČILO ŠEST MJESTA',
  'Mihael Jardas i Patrik Poljak zabili su za prvu pobjedu Vrbovskog u sezoni, a Goranin je nakon poraza pao pet mjesta.',
'Derbi 2. kola 1. ŽNL PGŽ odigran je u nedjelju 13. rujna u Vrbovskom i pripao je domaćinima. Mihael Jardas doveo je Vrbovsko u vodstvo u 21. minuti, a Patrik Poljak je u 61. postavio konačnih 2:0.

Čvrsta, tvrda i borbena utakmica, kao i uvijek između ove dvije momčadi. Visok ritam od samog početka, a domaći su prvi pogodak postigli iz kornera, dok je drugi pao nakon dubinske lopte i istrčavanja protivničkog vratara.

Nijedna momčad nije ostala s igračem manje, u zapisniku nema isključenja.

Vrbovskom je to prva pobjeda u sezoni. Na ljestvici je skočilo šest mjesta, s dvanaestog na šesto, i to je najveći skok kola. Goranin je istim porazom pao pet mjesta, sa šestog na jedanaesto, i ostao na jednom bodu.

Vrbovsko u trećem kolu gostuje kod Risnjaka u Lokvama, a Goranin dočekuje Zamet.',
  '1. ŽNL PGŽ',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'osvrt-vrbovsko-goranin-2-kolo-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'osvrt-vrbovsko-goranin-2-kolo-2627';


-- =====================================================================
-- NEOBAVEZNO: POVEZNICA IZ PREGLEDA KOLA NA OVAJ OSVRT
-- =====================================================================
-- Pokreni SAMO ako zelis da pregled 2. kola uputi na ovaj clanak. Isti
-- obrazac je koristen i kod pregleda 2. kola 3. NL.
--
-- update public.clanci
-- set tekst = replace(
--       tekst,
--       'dok je Goranin pao pet mjesta.',
--       'dok je Goranin pao pet mjesta. Poseban osvrt na taj susret je u zasebnom clanku na ovoj stranici.'
--     )
-- where slug = 'pregled-2-kola-1-znl-pgz-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'osvrt-vrbovsko-goranin-2-kolo-2627';

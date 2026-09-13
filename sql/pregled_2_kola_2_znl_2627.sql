-- =====================================================================
-- ČLANAK: PREGLED 2. KOLA 2. ŽNL PGŽ 2026/27
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
--   Sve dolazi iz public.pregled_kola('2026/27','2. ZNL PGZ',2), dakle
--   iz zapisnika u bazi: rezultati, strijelci, minute, crveni kartoni i
--   pomaci na ljestvici. Podatak da je Snjeznik - Mrkopalj iz 1. kola
--   odgodjen je Andrejev; u bazi ta utakmica samo nema rezultat.
--
--   Nitko od nas nije bio ni na jednoj utakmici, pa u tekstu NEMA opisa
--   tijeka igre ni ocjena. Samo ono sto stoji u zapisniku.
--
-- PROVJERENO PRIJE PISANJA
--   Zbroj strijelaca po stranama slaze se s rezultatom na sve tri
--   utakmice.
--   Funkcija javlja da sluzbena tablica NE odstupa.
--
-- NEJEDNAK BROJ ODIGRANIH UTAKMICA
--   Mrkopalj i Snjeznik odigrali su po jednu utakmicu, jer im je susret
--   1. kola odgodjen. To je u tekstu receno naglas, inace tablica ne
--   izgleda smisleno.
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
  'pregled-2-kola-2-znl-pgz-2627',
  'ČETIRI GOLA ŠIME BOŽIĆA U SEDMICI GORANKE',
  'Goranka je razbila Snježnik 7:0, Gomirje ostalo stopostotno protiv devetorice Željezničara, a Mrkopalj slavio u Skradu.',
'Drugo kolo 2. ŽNL PGŽ odigrano je u nedjelju 13. rujna i donijelo je 15 pogodaka u tri utakmice, dakle pet po utakmici. Domaćini su slavili dvaput, gosti jednom, remija nije bilo.

Goranka - Snježnik 7:0. Najviše golova palo je u Ravnoj Gori, a najzaslužniji je Šime Božić s četiri pogotka. Tihomir Cindrić otvorio je u 12., Mateo Gorupić povisio u 15., a Božić je prvi put pogodio u 28. minuti. U nastavku je zabio još tri, u 52., 58. i 59., dakle tri gola u sedam minuta. Davor Baroš postavio je konačnih 7:0 u 80. minuti. Božić je time preuzeo i vrh liste strijelaca lige.

Gomirje - Željezničar (M) 3:1. Gomirje je u Kraju Dobre poveo već u 1. minuti, pogotkom Antonija Fenova, a Ivan Petrović je u 4. minuti povisio. Petrović je tako zabio drugo kolo zaredom. Gosti su ostali s igračem manje u 37. minuti, nakon crvenog kartona Doriana Majstorovića, pa je Goran Milanović u 39. ipak smanjio. Milan Lončar vratio je domaćima dva gola prednosti u 50., a Željezničar je u 55. minuti ostao i bez Zorana Mamule, isključenog crvenim kartonom, pa je utakmicu završio s devet igrača.

Polet (Sk) - Mrkopalj 1:3. U Skradskoj Dragi je Aleksandar Ilić doveo goste u vodstvo u 21. minuti, David Ožbolt izjednačio je u 42., a onda je Antonio Krištof pogocima u 59. i 64. minuti odlučio susret. Mrkoplju je to prva utakmica u sezoni i odmah pobjeda.

STRIJELCI

Novi vodeći strijelac lige je Šime Božić iz Goranke, sa četiri pogotka, sva četiri iz ovog kola. Slijede Antonio Krištof iz Mrkoplja te Ivan Petrović i Milan Lončar iz Gomirja, svi s po dva. Božićeva četvorka jedini je takav učinak u kolu.

LJESTVICA

Gomirje je jedino sa stopostotnim učinkom, šest bodova iz dvije utakmice. Goranka ima četiri, a najbolju gol razliku u ligi, plus sedam. Mrkopalj je treći s tri boda.

Treba reći da broj odigranih utakmica nije jednak. Mrkopalj i Snježnik odigrali su po jednu, jer je njihov susret iz 1. kola odgođen, pa će se poredak još slagati kad se odigra.

ZA SLJEDEĆE KOLO

Željezničar će treće kolo igrati bez Doriana Majstorovića i Zorana Mamule, obojice isključenih u Gomirju. Nitko nije na pragu žutih.

Treće kolo otvara se u subotu 19. rujna susretom Mrkopalj - Goranka, a u nedjelju 20. rujna igraju Željezničar - Polet i Snježnik - Gomirje.',
  '2. ŽNL PGŽ',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-2-kola-2-znl-pgz-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'pregled-2-kola-2-znl-pgz-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-2-kola-2-znl-pgz-2627';

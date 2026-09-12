-- =====================================================================
-- ČLANAK: PREGLED 2. KOLA 4. NL NS RIJEKA 2026/27
-- Odigrano 12.09.2026.
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
--   Sve u tekstu dolazi iz
--   public.pregled_kola('2026/27','4. NL NS Rijeka',2), dakle iz
--   zapisnika u bazi: rezultati, strijelci, minute, crveni kartoni i
--   pomaci na ljestvici. Podatak o tome tko je slobodan u 3. kolu dolazi
--   s rasporeda u bazi. Nijedna recenica nije dopisana izvan toga, nema
--   opisa tijeka igre ni ocjena, jer taj podatak u bazi ne postoji.
--   Ako zelis dodati ono sto si vidio na terenu, dopisi u tekst prije
--   objave, kao kod pregleda 2. kola 3. NL.
--
-- PROVJERENO PRIJE PISANJA
--   Zbroj strijelaca po stranama slaze se s rezultatom na svih sest
--   utakmica, dakle u ovom kolu nema neoznacenog autogola ni pogotka
--   koji u zapisniku fali ili stoji dvaput.
--   "na_pragu" je prazan, ali uz pretpostavljeni prag od cetiri zuta
--   kartona, koji jos nije potvrdjen u propozicijama.
--
-- POSJECENOST SE NE SPOMINJE
--   Dvije utakmice nemaju podatak o gledateljima, a dvije imaju isti
--   broj, pa bi svaka tvrdnja o najposjecenijoj utakmici kola bila
--   nategnuta.
--
-- LJESTVICA
--   pregled_kola() racuna tablicu iz utakmica i NE zna za kaznene bodove,
--   a funkcija javlja da sluzbena tablica odstupa. Zato u tekstu stoje
--   samo vrh ljestvice i pomaci, uz uputu na sluzbenu ljestvicu na
--   stranici lige. Dno se namjerno ne navodi.
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
  'pregled-2-kola-4-nl-ns-rijeka-2627',
  'DVA HAT-TRICKA U ISTOM KOLU',
  'Antonijo Vujičić i Boško Babić zabili su po tri pogotka, Ližnjan, Cres i Borac ostali su bez izgubljenog boda, a Otočac je u prvoj utakmici sezone slavio s pet golova.',
'Drugo kolo 4. NL NS Rijeka odigrano je u subotu 12. rujna i donijelo je 24 pogotka u šest utakmica, četiri po utakmici. Domaćini su slavili četiri puta, gosti dva, remija nije bilo. Slobodan je bio Žminj. Kolo su obilježila dva hat-tricka i dva crvena kartona.

Smoljanci Sloboda - Otočac 1:5. Otočac je na Suhači odigrao prvu utakmicu u sezoni, jer je u prvom kolu bio slobodan, i odmah zabio pet. Antonijo Vujičić poveo je goste već u 5. minuti, Matija Ostović povisio je u 32., Mauro Mišan smanjio je u 39., a nakon odmora je Vujičić pogodio još dvaput, u 53. i 75. minuti, i tako došao do hat-tricka. Konačnih 1:5 postavio je Frane Radošević u 83. minuti. To je ujedno i utakmica s najviše golova u kolu.

Cres - Umag-CC Umago 4:1. Drugi hat-trick kola pao je u Cresu, a potpisao ga je Boško Babić, pogocima u 35., 44. i 65. minuti. Umag je u 60. minuti ostao bez Leona Čička, koji je dobio crveni karton. Jamu Akou Arum Iluya smanjio je u 90. minuti, ali je Vito Crnković u sudačkoj nadoknadi vratio razliku od tri gola.

Ližnjan - Mladost Fažana 3:0. Ližnjan je na Šaraji upisao drugu pobjedu u dva kola i još uvijek nije primio gol. Hisa Ramadani zabio je u 39. minuti, a Saša Urošević i Marko Kontošić pogodili su u razmaku od jedne minute, u 51. i 52. Gosti su u 78. minuti ostali bez Jana Lazarevića, isključenog crvenim kartonom.

Štinjan - Medulin 1921 3:0. Štinjan je na Fortinu pitanje pobjednika riješio do poluvremena. Antonio Gračić zabio je u 6., Stefan Antanasković u 22., a Ismar Hairlahović u 35. minuti. Nakon poraza u prvom kolu Štinjan je tako došao do prvih bodova.

Rječina - Klana 3:1. U Dražicama je Jeton Imeraj doveo domaće u vodstvo u 37. minuti, Tymur Merezhko izjednačio je za goste u 72., a onda su Luka Ratin u 83. i Imeraj u 85. minuti odlučili susret.

Funtana - Borac (Ba) 1:2. Najkasnije odigrana utakmica kola odlučena je u sudačkoj nadoknadi. Robert Vlizlo doveo je domaće u vodstvo u 27. minuti, Filip Jagić izjednačio je u 79., a Ivan Ferinac je u 90. minuti donio Borcu drugu pobjedu u dva kola.

STRIJELCI

Na vrhu liste strijelaca nakon dva kola su Antonijo Vujičić iz Otočca i Boško Babić iz Cresa, obojica s po tri pogotka, i obojica su ih zabila u istoj utakmici. Po dva gola u sezoni imaju Jamu Akou Arum Iluya, Jeton Imeraj, Marko Kontošić, Mihael Šušnjar, Robert Vlizlo, Saša Urošević i Željko Tomić. Osim dvojice s hat-trickom, u ovom je kolu dvaput zabio još Jeton Imeraj za Rječinu.

LJESTVICA

Bez izgubljenog boda su Ližnjan, Cres i Borac, sve tri sa šest bodova. Ližnjan ima gol razliku plus osam, Cres plus pet, Borac plus četiri. Slijede Otočac i Štinjan s po tri boda.

Najveći skok kola napravio je Štinjan, pet mjesta, a Rječina je dobila tri. Po tri mjesta izgubili su Umag-CC Umago, Mladost Fažana, Medulin 1921, Smoljanci Sloboda i Funtana.

Službena ljestvica je na stranici lige, jer izračunata tablica ne poznaje kaznene bodove.

ZA SLJEDEĆE KOLO

Zbog crvenih kartona kaznu odrađuju Leon Čičak iz Umag-CC Umaga i Jan Lazarević iz Mladosti Fažane. Mladost Fažana u trećem kolu ne igra, jer je slobodna. Nitko nije na pragu žutih.

Treće kolo na rasporedu je u subotu 19. rujna u 17 sati.',
  '4. NL NS Rijeka',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-2-kola-4-nl-ns-rijeka-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'pregled-2-kola-4-nl-ns-rijeka-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-2-kola-4-nl-ns-rijeka-2627';

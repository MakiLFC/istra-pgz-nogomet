-- =====================================================================
-- ČLANAK: PREGLED 4. KOLA 4. NL NS RIJEKA 2026/27
-- Odigrano 26.09.2026., pet od sest utakmica.
-- =====================================================================
-- KAKO SE KORISTI: pokreni po redu dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   Zatim ide KORAK 2 (objava).
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- KOLO NIJE ZAVRSENO, I TO TAKO PISE U TEKSTU
--   Liznjan - Klana igra se u UTORAK 29.09.2026. u 17:00, pa je od sest
--   utakmica odigrano pet. Borac (Ba) je bio slobodan.
--   Andrej je 26.09. odlucio da pregled ide odmah, za pet utakmica, a
--   da dopuna s utorkovom utakmicom dolazi nakon nje. Zato tekst na dva
--   mjesta izricito kaze da se ta utakmica jos igra, da citatelj ne
--   pomisli da je ispustena.
--   PRI DOPUNI se mijenja i odjeljak LJESTVICA, jer Liznjan i Klana
--   tada dobivaju jos jednu utakmicu.
--
-- ODAKLE STO
--   Rezultati, strijelci s minutama, kartoni, gledatelji i stadioni
--   dolaze iz zapisnika sa Semafora, procitanih poslom "Ispis kola"
--   (Actions, 26.09.2026. u 19:08 po nasem). Isti su zapisnici istu
--   vecer usli i u bazu, punim prolazom scrapera.
--   Ljestvica i pomaci su izracunati iz rezultata sva cetiri kola, uz
--   kaznene bodove Umaga (vidi nize).
--   Sve ostalo je iz tih podataka: nema izjava ni opisa tijeka igre.
--
-- NOVO: UMAG IMA TRI KAZNENA BODA
--   Sluzbena ljestvica od 26.09.2026. pokazuje "NK Umag-CC Umago (-3)".
--   Umag je u cetiri kola skupio 2-1-1, dakle sedam bodova, a u tablici
--   stoji na cetiri. To je PRVI put da 4. NL NS Rijeka ima kaznene
--   bodove: najava 4. kola je Umagu pripisala cetiri boda, sto je tocno
--   1-1-1 bez kazne, pa su bodovi oduzeti izmedu 3. i 4. kola.
--   RAZLOG NIJE POZNAT i u tekstu se ne nagadja, navodi se samo da
--   tablica pokazuje tri kaznena boda. Praktična posljedica je da je
--   Umag pobijedio, a na ljestvici ostao sesti.
--   Odatle i recenica "Sluzbena ljestvica je na stranici lige", ista
--   kao kod Crikvenice u 3. NL Zapad.
--
-- PROVJERENO PRIJE PISANJA
--   Zbroj strijelaca po stranama slaze se s rezultatom na svih pet
--   utakmica. Autogola u ovom kolu nema.
--   Izracun uz kaznene bodove Umaga poklapa se sa sluzbenom tablicom na
--   svih trinaest mjesta, i po bodovima i po broju odigranih utakmica.
--   Izracunata ljestvica nakon 3. kola daje Cres i Borac na devet, uz
--   Cres ispred po gol razlici, Otocac cetvrti sa sest i utakmicom
--   manje, Liznjan s najboljom gol razlikom plus sedam i Funtanu bez
--   boda, tocno kako je stajalo u najavi 4. kola.
--
-- NOVALJA JE OPET U TABLICI
--   Sluzbena ljestvica ima cetrnaest redaka, jer HNS ondje ponovno
--   prikazuje NK Novalju, s nulama u svim stupcima. Klub je napustio
--   natjecanje 02.09.2026. Tablica se scrapa i ne ispravlja, kako pise
--   u CLAUDE.md, pa taj redak stoji i na nasoj stranici. U tekstu se
--   Novalja ne spominje, a "trinaest klubova" se odnosi na one koji
--   igraju.
--
-- POMACI NA LJESTVICI
--   Racunati su iz sluzbenog stanja: nakon 3. kola Umag je imao cetiri
--   boda bez kazne, nakon 4. kola cetiri boda s kaznom, pa mu je
--   mjesto ostalo isto (sesto). Kazna se NE pripisuje unatrag, jer bi
--   se time izmislio pomak kojeg nije bilo.
--
-- KAZNE
--   Dva iskljucenja: Tomas Dadic (Stinjan), crveni karton u 15. minuti,
--   i Goran Urosevic (Mladost Fazana), drugi zuti u 82.
--   Zuti kartoni se navode kao brojka, bez rijeci o tome sto slijedi.
--
-- BEZ FOTOGRAFIJE
--   Clanak nema sliku, pa se na kartici prikazuje zaglavlje 4. NL NS
--   Rijeka, a pri dijeljenju zajednicka slika Lokal-Arene.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'pregled-4-kola-4-nl-ns-rijeka-2627',
  'CRES ČETIRI OD ČETIRI, FUNTANA I SMOLJANCI DO PRVIH POBJEDA',
  'Cres je pobjedom nad Otočcem ostao jedini bez izgubljenog boda. Funtana je u Dražicama do prve pobjede stigla s dva pogotka Roberta Vlizla u dvije minute, Smoljanci Sloboda svladali su Mladost 4:1, a Žminj je slavio u Štinjanu. Ližnjan - Klana igra se u utorak.',
'Četvrto kolo 4. NL NS Rijeka igralo se u subotu 26. rujna, ali još nije završeno: Ližnjan - Klana na rasporedu je u utorak 29. rujna u 17 sati. Slobodan je bio Borac (Bakar). U pet odigranih utakmica palo je 15 pogodaka, tri po susretu, a remija nije bilo. Domaćini su slavili tri puta, gosti dva.

Cres - Otočac 3:1. Susret kola odigran je na Dariju pred 80 gledatelja. Željko Tomić doveo je Cres u vodstvo u 19. minuti, Josip Smolčić izjednačio je u 51., a onda su Demis Seo Salihović u 54. i Vito Crnković u 86. minuti odlučili susret. Cres je time upisao četvrtu pobjedu iz četiri kola i ostao jedini klub lige bez izgubljenog boda.

Rječina - Funtana 1:2. U Dražicama je bilo 100 gledatelja, najviše u kolu, a Funtana je došla do prve pobjede u sezoni. Luka Orešković doveo je Rječinu u vodstvo u 15. minuti, a onda je Robert Vlizlo zabio dvaput u dvije minute, u 70. i 71., i okrenuo rezultat. Vlizlo je time stigao na četiri pogotka i podijelio vrh liste strijelaca.

Smoljanci Sloboda - Mladost Fažana 4:1. Na Suhači u Svetvinčentu domaćini su upisali prvu pobjedu sezone, i to nakon zaostatka. Toni Nišević doveo je Mladost u vodstvo u 12. minuti, a onda su Ivan Banović u 33., Mauro Mišan u 59., Mike Amachi Ezemonye u 77. i Matija Buršić u 89. minuti okrenuli rezultat. Mladost je posljednjih desetak minuta igrala s igračem manje, jer je Goran Urošević u 82. minuti dobio drugi žuti karton.

Štinjan - Žminj 0:1. Na Fortinu je Štinjan od 15. minute igrao s desetoricom, nakon crvenog kartona Tomasa Dadića. Sandi Burić zabio je jedini pogodak u 61. minuti. Žminj je tom pobjedom skočio pet mjesta, najviše u kolu, i došao na peto.

Umag-CC Umago - Medulin 1921 2:0. Na Stella Marisu je Leon Miličević zabio na samom početku drugog poluvremena, u 46. minuti, a Kristian Boglić potvrdio je pobjedu u 87. Umag je time skupio sedam bodova, ali je na ljestvici ostao šesti, jer službena tablica sada uz njegovo ime pokazuje tri kaznena boda. Medulin je ostao na jednom bodu i na dnu ljestvice.

STRIJELCI

Vrh liste strijelaca dijele trojica s po četiri pogotka: Antonijo Vujičić iz Otočca, Robert Vlizlo iz Funtane i Željko Tomić iz Cresa. Vlizlo je jedini koji je u ovom kolu zabio više od jednom. S po tri pogotka slijede Boško Babić iz Cresa, Jamu Akou Arum Iluya iz Umaga i Tymur Merezhko iz Klane.

LJESTVICA

Cres vodi s dvanaest bodova i jedini je bez izgubljenog boda. Borac (Bakar) ima devet bodova iz tri utakmice, a slijede Ližnjan, Otočac i Žminj s po šest. Na dnu je Medulin 1921 s jednim bodom.

Najviše je u kolu dobio Žminj, pet mjesta, a Smoljanci Sloboda četiri. Najviše su izgubili Štinjan i Mladost Fažana, po tri mjesta.

Službena ljestvica je na stranici lige, jer ona uključuje i tri kaznena boda Umaga. Klubovi pritom nemaju isti broj odigranih utakmica, jer u ligi s trinaest klubova svako kolo jedan ne igra.

ZA SLJEDEĆE KOLO

Peto kolo propuštaju Tomas Dadić (Štinjan) nakon crvenog kartona i Goran Urošević (Mladost Fažana) nakon drugog žutog. Najviše žutih kartona u sezoni ima Diego Vlacci iz Smoljanaca Slobode, tri.

Prije petog kola u utorak se igra Ližnjan - Klana, posljednja utakmica ovog kola. Raspored je na stranici lige.',
  '4. NL NS Rijeka',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-4-kola-4-nl-ns-rijeka-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'pregled-4-kola-4-nl-ns-rijeka-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-4-kola-4-nl-ns-rijeka-2627';

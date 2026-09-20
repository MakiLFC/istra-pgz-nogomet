-- =====================================================================
-- ČLANAK: PREGLED 3. KOLA 1. ŽNL PGŽ 2026/27
-- Odigrano 19. i 20.09.2026.
-- =====================================================================
-- KAKO SE KORISTI: pokreni po redu dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   Zatim ide KORAK 2 (objava).
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- ODAKLE STO
--   Rezultati, strijelci s minutama, kartoni, gledatelji i stadioni
--   dolaze iz zapisnika sa Semafora, procitanih poslom "Ispis kola"
--   (Actions, 20.09.2026. u 18:57 po nasem). Isti su zapisnici istu
--   vecer usli i u bazu, punim prolazom scrapera.
--   Ljestvica i pomaci su izracunati iz rezultata sva tri kola. U 1. ŽNL
--   nema kaznenih bodova, pa izracun i sluzbena tablica moraju dati isto,
--   i daju (vidi nize).
--   Sve ostalo je iz tih podataka: nema izjava ni opisa tijeka igre.
--
--   ANDREJEVO, cega u bazi nema i sto je upisano po njegovoj izricitoj
--   uputi (20.09.2026.):
--     - Lovran - Losinj je derbi, pa se naglasava vaznost pogotka za 2:1
--       i ostanak na prvom mjestu
--     - Karlo Sneler je iskusno krilo Muna, a Patrik Bonicioli je s
--       drugog krila bio jednako opasan
--     - Risnjak ove sezone nece biti samo promatrac nego tezak suparnik
--       svakome
--   To su Andrejeve ocjene, ne nase, i takve su i zapisane. Bez njegove
--   upute takve recenice ne bi smjele stajati (pravilo 5).
--
-- PROVJERENO PRIJE PISANJA
--   Zbroj strijelaca po stranama slaze se s rezultatom na svih sedam
--   utakmica. Turbina - Vihor 3:1 se slaze tek s autogolom: Turbina ima
--   dva strijelca, a treci pogodak je autogol Ante Zunica iz 48. minute,
--   koji je scraper sam prepoznao po klasi own_goal.
--   Sluzbena ljestvica je OVAJ PUT bila cjelovita: svih cetrnaest
--   klubova ima 3 odigrane utakmice i poklapa se s izracunom na svih
--   cetrnaest mjesta. Zato u tekstu stoji uputa na stranicu lige.
--   (Za razliku od 5. kola 3. NL, gdje je tablica bila na pola posla.
--   Vidi CLAUDE.md, "HNS ne osvjezi sve dijelove stranice odjednom".)
--   Izracunata ljestvica nakon 2. kola daje Lovran 6 bodova i gol
--   razliku plus osam te Risnjak jedan bod i minus sedam, tocno kako je
--   stajalo u najavi 3. kola. To je provjera da racun nije promasen.
--
-- KAZNE
--   U ovom kolu nema nijednog crvenog kartona ni drugog zutog, pa zbog
--   njega nitko ne propusta 4. kolo.
--   Zuti kartoni se navode kao brojka, bez rijeci o tome sto slijedi.
--   Prag jos nije potvrdjen u propozicijama, a nitko i nije blizu:
--   najvise ih itko ima dva.
--
-- NA STO PAZITI KOD SLJEDECE NAJAVE
--   Cetvorica su vec odradila kaznu iz ranijih kola (Mihael Gazdek,
--   Stipe Kordic, Alen Smolic, Miroslav Dukic), pa se za 4. kolo ne
--   navode kao suspendirani.
--
-- BEZ FOTOGRAFIJE
--   Clanak nema sliku, pa se na kartici prikazuje zaglavlje 1. ŽNL PGŽ,
--   a pri dijeljenju zajednicka slika Lokal-Arene.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'pregled-3-kola-1-znl-pgz-2627',
  'LOVRAN OSTAO JEDINI BEZ IZGUBLJENOG BODA, ŠNELER ZABIO TRI',
  'Lovran je pogotkom Tina Sankovića u 87. minuti svladao Lošinj i zadržao maksimalan učinak. Karlo Šneler zabio je tri za Mune, Risnjak je do prve pobjede došao u sudačkoj nadoknadi, a Rab je u Vratima ispustio prve bodove.',
'Treće kolo 1. ŽNL PGŽ odigrano je u subotu 19. i nedjelju 20. rujna. Palo je 21 pogodaka u sedam utakmica, točno tri po susretu. Domaćini su slavili pet puta, gosti jednom, a jedna je utakmica završila bez pobjednika i bez pogotka. Crvenih kartona nije bilo.

Lovran - Lošinj 2:1. Derbi kola odigran je na Lokvi pred 45 gledatelja i spojio je dvije momčadi koje su kolo otvorile pri vrhu. Vitorio Antoninić doveo je Lošinj u vodstvo već u 5. minuti, Mateo Srok izjednačio je u 36., a onda je Tin Sanković u 87. minuti zabio najvažniji pogodak kola. Tri minute prije kraja, u derbiju, za 2:1 i za ostanak na vrhu ljestvice. Lovran je tako ostao jedini klub lige bez izgubljenog boda, s tri pobjede iz tri kola.

Mune - Draga 4:0. Najuvjerljivija pobjeda kola pala je na Crikvenoj dragi. Karlo Šneler, iskusno krilo Muna, zabio je tri puta, u 30., 43. i 75. minuti, a s drugog krila je jednako opasan bio Patrik Bonicioli, koji je u 63. dodao četvrti pogodak. Munama je to prva pobjeda sezone, a Draga je nakon tri kola pala na dvanaesto mjesto.

Risnjak - Vrbovsko 2:1. U Lokvama se odlučivalo do zadnje minute. Mihael Malnar doveo je Risnjak u vodstvo u 64., Roko Kasun izjednačio je za Vrbovsko u 88., a Karlo Rupe je u trećoj minuti sudačke nadoknade zabio za prvu pobjedu Risnjaka u sezoni. Risnjak je time pokazao da ove sezone neće biti samo promatrač, nego težak suparnik svakome.

Turbina - Vihor (B) 3:1. Na Gradskom stadionu u Crikvenici Luka Sirić zabio je u 5. minuti, Mazen Sharbini izjednačio je u 12., a onda je Turbina povela autogolom Ante Žunića u 48. i pogotkom Marina Ribarića u 50. minuti. Vihor je jedina momčad lige koja nakon tri kola još nema bod.

Rikard Benčić - Stari grad Rijeka 1:3. Jedina gostujuća pobjeda kola. Na Belvederu je Luka Majetić zabio za Stari grad u 15. minuti, Marko Cvijanović izjednačio je u 30., Mateo Pendić vratio je gostima vodstvo u 41., a Marin Baković je u 86. potvrdio pobjedu. Stari grad je time upisao prvu pobjedu i skočio na peto mjesto, a Rikard Benčić je ostao na jednom bodu.

Goranin - Zamet 2:1. U Delnicama je bilo 100 gledatelja, najviše u kolu. Rok Stipaničić zabio je u 44., Antonio Frlan u 68., a Mislav Grgurić smanjio je za Zamet u 83. minuti. Goranin je time došao do prve pobjede, a ujedno i do prvih pogodaka u sezoni, jer u prva dva kola nije zabio nijedan.

Omladinac Vrata - Rab 0:0. Jedini susret kola bez pogotka odigran je na Gmajni. Rab je tako ispustio prve bodove ove sezone i ostao na drugom mjestu.

STRIJELCI

Patrik Vidmar iz Lovrana i dalje je prvi strijelac lige sa šest pogodaka, iako u ovom kolu nije zabio. Karlo Šneler iz Muna došao je hat-trickom na četiri i sada je drugi. S po tri pogotka slijede Kristijan Kurti iz Drage i Mazen Sharbini iz Vihora. Šneler je jedini koji je u ovom kolu zabio više od jednom.

LJESTVICA

Lovran vodi s devet bodova i gol razlikom plus devet. Slijede Rab sa sedam, Turbina i Lošinj s po šest te Stari grad Rijeka s pet. Na dnu su Rikard Benčić s jednim bodom i Vihor (B), jedini još bez osvojenog boda.

Najviše su u kolu dobili Stari grad Rijeka, Mune, Goranin i Risnjak, svi po četiri mjesta. Najviše je izgubila Draga, pet mjesta, a Vrbovsko četiri.

Cijela ljestvica je na stranici lige.

ZA SLJEDEĆE KOLO

Kolo je prošlo bez ijednog crvenog kartona, pa zbog njega nitko ne propušta četvrto kolo. Nitko nije ni blizu pragu žutih: najviše ih itko ima dva.

Raspored četvrtog kola je na stranici lige.',
  '1. ŽNL PGŽ',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-3-kola-1-znl-pgz-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'pregled-3-kola-1-znl-pgz-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-3-kola-1-znl-pgz-2627';

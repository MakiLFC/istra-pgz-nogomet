-- =====================================================================
-- ČLANAK: NAJAVA 3. KOLA 4. NL NS RIJEKA 2026/27
-- Igra se u subotu 19.09.2026.
-- =====================================================================
-- KAKO SE KORISTI: dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   KORAK 2 (objava) je zakomentiran na dnu.
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- SLUG MORA POCETI S "najava-"
--   Traka "Ovaj vikend" na naslovnici po tome prepoznaje najavu tog kola.
--
-- ODAKLE STO
--   Termini, forma, ljestvica i medjusobni ogledi iz prosle sezone iz
--   public.najava_kola('2026/27','4. NL NS Rijeka',3), a strijelci po
--   klubovima, crveni kartoni i pomaci iz
--   public.pregled_kola('2026/27','4. NL NS Rijeka',2).
--   ANDREJEVO: da je Borac - Liznjan derbi kola i da ce s njega biti
--   izvjestaj na stranici.
--
-- IME KLUBA
--   U bazi je klub upisan kao "NK Borac (Ba)", jer tako stoji na HNS-u.
--   U TEKSTU se po Andrejevoj uputi pise "Borac (Bakar)". Kljucevi u
--   SQL-u ispod moraju ostati onakvi kakvi su u bazi, dakle "(Ba)".
--
-- SLOBODAN KLUB
--   Liga ima trinaest klubova otkad je NK Novalja odustala, pa svako
--   kolo jedan ne igra. U trecem kolu slobodna je Mladost Fazana.
--
-- LJESTVICA
--   sluzbena_tablica_odstupa je true, pa se navodi samo vrh i uputa na
--   sluzbenu ljestvicu na stranici lige.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-3-kola-4-nl-ns-rijeka-2627',
  'BORAC I LIŽNJAN, OGLED MOMČADI S DVIJE POBJEDE',
  'Na Krasici se sastaju prvi i treći, obojica sa stopostotnim učinkom. Otočac u prvom domaćem nastupu sezone dočekuje Štinjan, a Klana i Funtana traže prve bodove.',
'Treće kolo 4. NL NS Rijeka igra se u subotu 19. rujna. Medulin 1921 - Cres počinje u 15:30 na Mutili, a ostalih pet utakmica u 17 sati. Slobodna je Mladost Fažana.

Borac (Bakar) - Ližnjan. Derbi kola, s kojeg će na ovoj stranici biti detaljan izvještaj. Ližnjan je prvi s dvije pobjede i gol razlikom plus osam, Borac treći s istim brojem bodova i plus četiri. Ližnjan je posljednji nastup otvorio s 3:0 protiv Mladosti iz Fažane, a Borac je u Funtani preokrenuo za 2:1 golovima Filipa Jagića u 79. i Ivana Ferinca u drugoj minuti sudačke nadoknade. Prošle sezone svaki je slavio kod kuće, i to uvjerljivo: Ližnjan 3:0, Borac 4:0.

Medulin 1921 - Cres. Cres je drugi, s dvije pobjede, a Boško Babić je u 4:1 protiv Umaga zabio tri gola i sada dijeli vrh liste strijelaca lige. Medulin je deveti s jednim bodom i porazom 0:3 u Štinjanu. Njihovi su ogledi prošle sezone bili golijade: Cres je kod kuće slavio 7:2, a Medulin 6:0.

Otočac - Štinjan. Otočac je prvo kolo bio slobodan, pa mu je ovo tek druga utakmica u sezoni i prva kod kuće. U njoj je razbio Smoljance 5:1, a Antonijo Vujičić zabio je tri gola i s Babićem dijeli prvo mjesto među strijelcima. Štinjan je nakon uvodnog poraza pobijedio Medulin 3:0 i skočio pet mjesta, i tu bi moglo biti svega.

Umag-CC Umago - Rječina. Oba su kluba na tri boda. Umag je na Cresu izgubio 4:1 i ostao bez Leona Čičaka, isključenog u 60. minuti, pa on ovo kolo propušta. Rječina je kod kuće svladala Klanu 3:1, a Jeton Imeraj zabio je dva pogotka, jedan u 37. i drugi u 85. minuti.

Žminj - Smoljanci Sloboda. Žminj je u drugom kolu bio slobodan, pa iza sebe ima samo poraz od Ližnjana i još nije zabio gol. Smoljanci su na jednom bodu, nakon 1:5 protiv Otočca. Prošle sezone Smoljanci su slavili u oba susreta, 4:2 i 1:0.

Klana - Funtana. Dva kluba bez osvojenog boda, jedanaesti i dvanaesti na ljestvici. Klana je izgubila oba susreta, posljednji u Dražicama, a Funtana je kod kuće ispustila vodstvo protiv Borca. Prošle sezone Klana je dobila oba ogleda, 3:0 kod kuće i 2:0 u Funtani.

LJESTVICA

Vode Ližnjan, Cres i Borac, sva tri sa šest bodova, a razlikuje ih gol razlika. Službena ljestvica je na stranici lige.

KAZNE

Crvene kartone u drugom kolu dobili su Leon Čičak (Umag-CC Umago) i Jan Lazarević (Mladost Fažana), pa Umag u subotu igra bez Čičaka, dok je Mladost Fažana slobodna. Na pragu žutih nema nikoga.',
  '4. NL NS Rijeka',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-3-kola-4-nl-ns-rijeka-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-3-kola-4-nl-ns-rijeka-2627';


-- =====================================================================
-- DERBI KOLA: NK Borac (Ba) - NK Liznjan, 3. kolo
-- =====================================================================
-- Prvo se gasi prethodni derbi te lige, pa se oznacava novi. Bez toga bi
-- na naslovnici zuti okvir imale dvije utakmice.
-- update public.utakmice set derbi = false
-- where derbi = true and natjecanje = '4. NL NS Rijeka' and sezona = '2026/27'
-- returning kolo, domacin, gost;
--
-- update public.utakmice set derbi = true
-- where natjecanje = '4. NL NS Rijeka' and sezona = '2026/27'
--   and kolo = 3
--   and domacin = 'NK Borac (Ba)'
--   and gost    = 'NK Ližnjan'
-- returning kolo, domacin, gost, datum, vrijeme, derbi;


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-3-kola-4-nl-ns-rijeka-2627';

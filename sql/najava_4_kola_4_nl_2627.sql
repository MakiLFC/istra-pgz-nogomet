-- =====================================================================
-- ČLANAK: NAJAVA 4. KOLA 4. NL NS RIJEKA 2026/27
-- Igra se u subotu 26.09.2026.; Liznjan - Klana u utorak 29.09.
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
--   Raspored, termini i rezultati prva tri kola iz ispisa scrapera
--   (puni prolaz 23.09. i provjera termina 24.09. navecer, koja je
--   uhvatila da Cres - Otocac pocinje u 16 sati).
--   Stanje, strijelci i iskljucenja iz
--   public.pregled_kola('2026/27','4. NL NS Rijeka',3).
--   Rezultati iz kupa (Cres, Rjecina, Klana, Borac) iz clanka o 1/16
--   finala, dakle sa slika koje je poslao Andrej.
--
-- BABIC IMA TRI, NE CETIRI
--   HNS je nakon 20.09. ispravio zapisnik Medulin 1921 - Cres: drugi gol
--   Cresa u 35. minuti zabio je Zeljko Tomic, ne Bosko Babic. Andrej je
--   to uocio, a redak u bazi potvrdio. Vujicic zato sam vodi s cetiri, a
--   Babic je s tri, i to sva tri protiv Umaga. Objavljeni pregled 3.
--   kola ispravljen je istog dana, vidi sql/pregled_3_kola_4_nl_2627.sql.
--
-- SLOBODAN KLUB
--   Trinaest klubova, pa jedan ne igra. U 4. kolu to je Borac (Ba), u
--   tekstu Borac (Bakar), po Andrejevoj uputi.
--
-- ZUTI KARTONI
--   Prag za 4. NL nije potvrden, pa se o igracima na pragu ne pise.
--   na_pragu je ionako prazan.
--
-- LJESTVICA
--   sluzbena_tablica_odstupa je true, pa se navodi samo vrh i uputa na
--   sluzbenu ljestvicu.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-4-kola-4-nl-ns-rijeka-2627',
  'NAJAVA 4. KOLA: OTOČAC NA DARIJU MOŽE STIĆI VRH',
  'Vodeći Cres u subotu dočekuje Otočac, koji pobjedom može stići Cres i Borac na devet bodova. Borac (Bakar) je slobodan, a Ližnjan i Klana igraju tek u utorak.',
'Četvrto kolo 4. NL NS Rijeka igra se u subotu 26. rujna. Cres - Otočac počinje u 16 sati, a ostale četiri subotnje utakmice u 16:30. Susret Ližnjan - Klana igra se u utorak 29. rujna u 17 sati. Slobodan je Borac (Bakar), koji s Cresom dijeli prvo mjesto.

Cres - Otočac. Susret kola na Dariju. Cres je jedini s tri pobjede iz tri utakmice i ispred Borca je samo zbog bolje gol razlike. Otočac je četvrti sa šest bodova, ali s utakmicom manje, jer je u prvom kolu bio slobodan. Obje dosadašnje utakmice je dobio: 5:1 kod Smoljanaca Slobode i 3:1 protiv Štinjana. U njegovim redovima je Antonijo Vujičić, koji s četiri gola sam vodi listu strijelaca lige. Kod Cresa je Boško Babić s tri pogotka, sva tri zabijena Umagu. Cres je prošlog utorka u kupu ispao od Omišlja tek nakon sedam serija penala, uz 4:4 u regularnom dijelu, a Babić je svoj udarac pretvorio. Pobjedom bi Cres Borcu pobjegao na tri boda, a Otočac bi pobjedom stigao obojicu na devet.

Rječina - Funtana. Rječina je nakon poraza na Cresu u prvom kolu nepobijeđena: svladala je Klanu 3:1 i remizirala u Umagu 1:1. Prošlog utorka je u kupu izbacila Naprijed iz Hreljina, 2:1, a pobjednički pogodak zabio je Jeton Imeraj, koji u prvenstvu ima dva gola. Funtana u Dražice dolazi kao jedina momčad bez boda, nakon tri poraza. Najbolji strijelac joj je Robert Vlizlo s dva pogotka.

Smoljanci Sloboda - Mladost Fažana. Smoljanci Sloboda još traže prvu pobjedu: nakon remija s Medulinom u prvom kolu izgubili su dvaput, od Otočca 1:5 i u Žminju 0:1. Na Suhači u Svetvinčentu ostaju bez Antonija Ivančića i Sanjina Puha, isključenih u 90. minuti u Žminju. Mladost je u prošlom kolu bila slobodna. Ima tri boda iz dvije utakmice: u prvom kolu pobijedila je Funtanu, a u drugom izgubila u Ližnjanu 0:3.

Štinjan - Žminj. Dvije momčadi s po tri boda na Fortinu. Štinjan je jedinu pobjedu upisao protiv Medulina, 3:0, a izgubio je u Umagu i u Otočcu, gdje je pogodio Antonio Gračić, sada s dva gola u sezoni. Žminj je u prošlom kolu došao do prvih bodova i prvog pogotka u sezoni, 1:0 protiv Smoljanaca Slobode golom Marka Lepinjice. Kao i Otočac, i Žminj ima utakmicu manje, jer je u drugom kolu bio slobodan.

Umag-CC Umago - Medulin 1921. Umag ima četiri boda, a Jamu Akou Arum Iluya je s tri pogotka među najboljim strijelcima lige. U prošlom kolu protiv Rječine zabio je već u 2. minuti. Medulin je nakon remija u prvom kolu izgubio dvaput, u Štinjanu 0:3 i kod kuće od Cresa 1:2, i na Stella Marisu traži prvu pobjedu.

Ližnjan - Klana, u utorak. Ližnjan je nakon dvije uvjerljive pobjede, 5:0 u Žminju i 3:0 protiv Mladosti, prvi put izgubio, u derbiju na Krasici 2:3. Unatoč tome ima najbolju gol razliku u ligi, plus sedam. Klana je u prošlom kolu došla do prvih bodova, 3:0 protiv Funtane, a Tymur Merezhko je s dva gola stigao do tri u sezoni. U kupu je 22. rujna izgubila od Orijenta, kluba iz drugog ranga, 0:4. Na Šaraji se igra od 17 sati.

Borac (Bakar) ovo kolo odmara. U prvenstvu je bez poraza, a u kupu je prošlog utorka ispao od Crikvenice 1:4.

LJESTVICA

Cres i Borac vode s po devet bodova, ispred Ližnjana i Otočca sa šest. Otočac, Žminj i Mladost Fažana odigrali su utakmicu manje od ostalih. Službena ljestvica je na stranici lige.

KAZNE

Četvrto kolo propuštaju Antonio Ivančić i Sanjin Puh iz Smoljanaca Slobode, obojica isključeni u 90. minuti protiv Žminja.',
  '4. NL NS Rijeka',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-4-kola-4-nl-ns-rijeka-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-4-kola-4-nl-ns-rijeka-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-4-kola-4-nl-ns-rijeka-2627';

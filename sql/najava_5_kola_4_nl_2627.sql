-- =====================================================================
-- ČLANAK: NAJAVA 5. KOLA 4. NL NS RIJEKA 2026/27
-- Igra se u subotu 03.10.2026., svih sest utakmica u 15 sati.
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
--   Traka "Ovaj vikend" na naslovnici po tome prepoznaje najavu tog kola
--   i pokazuje poveznicu "Najava". Vidi components/OvajVikend.tsx.
--
-- ODAKLE STO
--   Raspored, ljestvica i rang-liste procitani su poslom "Ispis kola"
--   (Actions, 01.10.2026. u 18:43 po nasem), dakle sa Semafora.
--   Ucinci kod kuce i u gostima izracunati su iz rezultata sva cetiri
--   kola, kako najava i trazi (vidi CLAUDE.md, "Najava gleda UNAPRIJED").
--   Iskljucenja za ovo kolo dolaze iz pregleda 4. kola.
--
--   ANDREJEVO, cega u bazi nema i sto je upisano po njegovoj izricitoj
--   uputi (javio 28.09.2026., ide doslovno):
--     Funtana ima novog trenera, Ivana Kukucku, koji dolazi s dugim
--     iskustvom rada u istarskom nogometu, ukljucujuci vodjenje
--     seniorskih momcadi Jadrana iz Poreca, Rovinja, Medulina 1921,
--     Novigrada i pulskog Uljanika.
--
-- PROVJERENO PRIJE PISANJA
--   Izracun iz rezultata poklapa se sa sluzbenom tablicom na svih
--   trinaest mjesta, i po bodovima i po broju odigranih utakmica, uz
--   kaznene bodove Umaga.
--   Vlizlovi pogoci: Funtana je zabila cetiri gola (stupac "dani" u
--   tablici), a Vlizlo ih ima cetiri, pa su to svi pogoci kluba. Zato se
--   to smije napisati, za razliku od tvrdnje "jedini strijelac" koja se
--   inace ne pise (vidi CLAUDE.md).
--
-- UMAG IMA TRI KAZNENA BODA
--   Sluzbena ljestvica pokazuje "NK Umag-CC Umago (-3)". Umag je u cetiri
--   kola osvojio sedam bodova, a u tablici stoji na cetiri. Razlog nije
--   poznat i NE nagadja se, navodi se samo da tablica pokazuje kaznu.
--
-- SLOBODAN KLUB
--   Trinaest klubova, pa jedan ne igra. U 5. kolu to je Klana.
--
-- ZUTI KARTONI
--   Navodi se samo brojka, bez rijeci o posljedici. Prag je potvrdjen
--   SAMO za 3. NL Zapad (cetiri), za ovu ligu nije (vidi CLAUDE.md).
--   Najvise ih ima Diego Vlacci iz Smoljanaca Slobode, tri.
--
-- NOVALJA U TABLICI
--   Sluzbena ljestvica ima cetrnaest redaka, jer HNS ondje prikazuje i
--   NK Novalju s nulama. Klub je napustio natjecanje 02.09.2026. U tekstu
--   se ne spominje, a "trinaest klubova" su oni koji igraju.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-5-kola-4-nl-ns-rijeka-2627',
  'NAJAVA 5. KOLA: CRES ČUVA MAKSIMALAN UČINAK U ŽMINJU',
  'Vodeći Cres u subotu gostuje u Žminju kao jedini klub lige bez izgubljenog boda, a Borac (Bakar) i Ližnjan, oba s devet bodova, čekaju njegov prvi posrtaj. Funtana prvi put izlazi s novim trenerom Ivanom Kukučkom, a Klana je slobodna.',
'Peto kolo 4. NL NS Rijeka igra se u subotu 3. listopada, svih šest utakmica u 15 sati. Slobodna je Klana.

Žminj - Cres. Susret kola. Cres je jedini klub lige koji još nije izgubio bod, dvanaest iz četiri kola, i pobjedom bi stigao na petnaest. Žminj je peti sa šest bodova iz tri utakmice i pobjedom bi se izjednačio s Borcem i Ližnjanom na devet. Zanimljiv je po tome kako je te bodove skupio: dvije pobjede, oba puta 1:0, i ukupno samo dva zabijena gola, najmanje u ligi zajedno s Medulinom. Kod kuće ima jednu pobjedu i jedan poraz, a taj poraz je 0:5 od Ližnjana u prvom kolu. Cres je u gostima dosad igrao jednom i dobio, 2:1 u Medulinu, a Željko Tomić mu je s četiri pogotka među trojicom najboljih strijelaca lige.

Borac (Bakar) - Smoljanci Sloboda. Borac je treći s devet bodova i uz Cres jedini je još bez poraza, a ima i utakmicu manje od njega. Pobjedom bi stigao na dvanaest, koliko Cres ima sada. Na svom terenu je bez izgubljenog boda, dvije pobjede i gol razlika 6:2, a u trećem kolu je ondje slomio Ližnjan 3:2. Smoljanci Sloboda su osmi s četiri boda i u gostima su igrali samo jednom, poraz 0:1 u Žminju. Prošlo kolo im je bilo najbolje dosad, 4:1 protiv Mladosti, i to nakon zaostatka.

Funtana - Ližnjan. Funtana prvi put izlazi s novim trenerom. Klupu je preuzeo Ivan Kukučka, koji u Funtanu dolazi s dugim iskustvom rada u istarskom nogometu, uključujući vođenje seniorskih momčadi Jadrana iz Poreča, Rovinja, Medulina 1921, Novigrada i pulskog Uljanika. Zadatak na početku nije lagan: Funtana je jedanaesta s tri boda, kod kuće je igrala jednom i izgubila, a dolazi Ližnjan, drugi na ljestvici s devet bodova i gol razlikom plus osam, najboljom u ligi zajedno s Cresovom. Ližnjan je u gostima zabio sedam golova u dvije utakmice. Kod domaćih je Robert Vlizlo s četiri pogotka među trojicom najboljih strijelaca lige, a to su ujedno svi pogoci koje je Funtana ove sezone zabila.

Otočac - Umag-CC Umago. Otočac je četvrti sa šest bodova i ima utakmicu manje od Umaga, pa bi pobjedom stigao na devet i izjednačio se s Borcem i Ližnjanom. Kod kuće je igrao jednom, pobjeda 3:1 protiv Štinjana, a Antonijo Vujičić mu je s četiri pogotka među trojicom najboljih strijelaca lige. Umag je šesti s četiri boda, ali je u četiri kola osvojio sedam, jer službena tablica uz njegovo ime pokazuje tri kaznena boda. U gostima je igrao jednom i izgubio 1:4 na Cresu, a Jamu Akou Arum Iluya ima tri pogotka.

Mladost Fažana - Štinjan. Izravan dvoboj dviju momčadi s po tri boda, s time da Mladost ima utakmicu manje. Oba kluba igraju bez igrača koji odrađuju kazne iz prošlog kola: Mladost bez Gorana Uroševića, isključenog nakon drugog žutog kartona protiv Smoljanaca Slobode, a Štinjan bez Tomasa Dadića, koji je protiv Žminja dobio crveni karton već u 15. minuti. Mladost je kod kuće igrala jednom i dobila, 2:1 protiv Funtane u prvom kolu. Štinjan je u gostima izgubio oba susreta, uz gol razliku 1:5.

Medulin 1921 - Rječina. Medulin je trinaesti i jedini klub lige koji još nije pobijedio: jedan bod iz četiri kola i dva zabijena gola, najmanje u ligi zajedno sa Žminjem. Pobjedom bi se odmaknuo od dna. Zanimljivo je da je od četiri odigrane utakmice samo jednu igrao kod kuće, i to poraz 1:2 od Cresa. Rječina je sedma s četiri boda i pobjedom ide na sedam, a u gostima još nije dobila: remi u Umagu i poraz na Cresu.

LJESTVICA

Cres vodi s dvanaest bodova, slijede Ližnjan i Borac (Bakar) s po devet, pa Otočac i Žminj s po šest. Na dnu je Medulin 1921 s jednim bodom.

Službena ljestvica je na stranici lige, jer ona uključuje i tri kaznena boda Umaga. Klubovi pritom nemaju isti broj odigranih utakmica, jer u ligi s trinaest klubova svako kolo jedan ne igra.

KAZNE

Peto kolo propuštaju Tomas Dadić (Štinjan) nakon crvenog kartona i Goran Urošević (Mladost Fažana) nakon drugog žutog, a obojica su iz istog susreta ovog kola. Najviše žutih kartona u sezoni ima Diego Vlacci iz Smoljanaca Slobode, tri.',
  '4. NL NS Rijeka',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-5-kola-4-nl-ns-rijeka-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-5-kola-4-nl-ns-rijeka-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-5-kola-4-nl-ns-rijeka-2627';

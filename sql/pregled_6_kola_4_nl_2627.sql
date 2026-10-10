-- =====================================================================
-- ČLANAK: PREGLED 6. KOLA 4. NL NS RIJEKA 2026/27
-- Odigrano 10.10.2026., pet od sest utakmica.
-- =====================================================================
-- KAKO SE KORISTI: dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   KORAK 2 (objava) je zakomentiran na dnu.
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- PRIJE OBJAVE POKRENI SCRAPER JOS JEDNOM
--   Sluzbena ljestvica u trenutku pisanja NE UKLJUCUJE ovo kolo. Prolaz
--   je isao u 18:05 po nasem, a utakmice su zavrsile oko 17:50.
--   Provjereno klub po klub: sluzbena tablica se na svih trinaest mjesta
--   poklapa s izracunom NAKON 5. KOLA, dakle cijela zaostaje za jedno
--   kolo. Rang-liste strijelaca i kartona su pritom svjeze, jer se
--   zbrajaju iz zapisnika (vidi CLAUDE.md, "HNS ne osvjezi sve dijelove
--   stranice odjednom").
--   Brojke u tekstu su tocne, jer su racunate iz rezultata, ali dok
--   tablica ne dostigne kolo, stranica lige i clanak govorit ce
--   razlicito. Zato: Actions -> "Scraper HNS Semafor" -> Run workflow,
--   pa provjeri da klubovi koji su igrali imaju sest odigranih utakmica.
--
-- ODAKLE STO
--   Rezultati, strijelci s minutama, kartoni, gledatelji i stadioni
--   dolaze iz zapisnika sa Semafora, procitanih poslom "Ispis kola"
--   (Actions, 10.10.2026. u 18:10 po nasem).
--   Ljestvica i pomaci su izracunati iz rezultata svih sest kola, uz tri
--   kaznena boda Umaga.
--   Sve ostalo je iz tih podataka: nema izjava ni opisa tijeka igre.
--
-- PROVJERENO PRIJE PISANJA
--   Zbroj strijelaca po stranama slaze se s rezultatom na svih pet
--   utakmica. Autogola u ovom kolu nema.
--   Izracun nakon 5. kola poklapa se sa sluzbenom tablicom na svih
--   trinaest mjesta (vidi gore), pa je racun potvrdjen.
--
-- NIJE ODIGRANO CIJELO KOLO
--   Cres - Mladost Fazana premjesten je na 05.12.2026. u 13:30, pa je od
--   sest utakmica odigrano pet. Slobodna je bila Funtana. Zato Cres
--   ostaje na vrhu bez da je igrao.
--
-- KAZNE
--   Dva iskljucenja: Hisa Ramadani (Liznjan), crveni u 77. minuti, i
--   Dario Pajdakovic (Otocac), crveni u 63.
--   Zuti kartoni se navode kao brojka, bez rijeci o posljedici. Prag je
--   potvrdjen SAMO za 3. NL Zapad, za ovu ligu nije (vidi CLAUDE.md).
--   Najvise ih ima Ivan Golic iz Borca, cetiri.
--
-- NOVALJA U TABLICI
--   Sluzbena ljestvica ima cetrnaest redaka, jer HNS ondje prikazuje i
--   NK Novalju s nulama. Klub je napustio natjecanje 02.09.2026. U tekstu
--   se ne spominje, a "trinaest klubova" su oni koji igraju.
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
  'pregled-6-kola-4-nl-ns-rijeka-2627',
  'ŠTINJAN 4:0 SRUŠIO NEPORAŽENI BORAC, PET POBJEDA DOMAĆINA',
  'Borac (Bakar) je na Fortinu doživio prvi poraz sezone, uz dva pogotka Antonija Gračića, koji je stigao na vrh liste strijelaca. Medulin 1921 je protiv Otočca upisao prvu pobjedu, Rječina je svladala Ližnjan, a sve utakmice pripale su domaćinima. Cres je ostao na vrhu bez da je igrao.',
'Šesto kolo 4. NL NS Rijeka odigrano je u subotu 10. listopada, a od šest utakmica odigrano je pet: Cres - Mladost Fažana premješten je na 5. prosinca. Slobodna je bila Funtana. Kolo je pripalo domaćinima, i to svih pet puta, pa nije bilo ni remija ni gostujuće pobjede. Palo je trinaest pogodaka, a dvojica igrača završila su susret prije kraja.

Štinjan - Borac (Ba) 4:0. Najveći rezultat kola pao je na Fortinu, pred 70 gledatelja, najviše u kolu. George Davone Clarington otvorio je u 37. minuti, Antonio Gračić povisio u 43., Marin Filipović u 51., a Gračić je svojim drugim pogotkom u 56. minuti zaključio posao. Borac (Bakar) je time doživio prvi poraz sezone, nakon četiri pobjede iz četiri kola, i to najtežim rezultatom.

Rječina - Ližnjan 1:0. U Dražicama se dugo nije probijalo, a onda je sve odlučila jedna minuta. Ližnjan je u 77. ostao s igračem manje, nakon crvenog kartona Hise Ramadanija, a već u 78. Jeton Imeraj zabio je jedini pogodak. Sudac je na toj utakmici podijelio devet žutih kartona, najviše u kolu.

Medulin 1921 - Otočac 3:1. Na Mutili je Medulin upisao prvu pobjedu u sezoni. Manuel Bulešić zabio je u 16., Stefan Stošić u 24., a Otočac je od 63. minute igrao s desetoricom, nakon crvenog kartona Darija Pajdakovića. Stošić je svojim drugim pogotkom u 68. doveo domaće na 3:0, a Filip Bogdanić je u 73. ublažio poraz.

Umag-CC Umago - Žminj 1:0. Na Petroviji je bilo dovoljno devet minuta: Jamu Akou Arum Iluya zabio je jedini pogodak i Umagu donio treću pobjedu sezone.

Smoljanci Sloboda - Klana 2:1. Na Suhači u Svetvinčentu domaćini su riješili pitanje pobjednika u tri minute. Mauro Mišan zabio je u 23., Mike Amachi Ezemonye u 26., a Vid Vlaše je u 44. minuti smanjio. Susret je gledalo dvadeset ljudi, najmanje u kolu.

STRIJELCI

Vrh liste strijelaca sada dijele Antonio Gračić iz Štinjana i Željko Tomić iz Cresa, obojica s po pet pogodaka, a Gračić je dva dodao upravo u ovom kolu. S po četiri slijede Antonijo Vujičić iz Otočca, Jamu Akou Arum Iluya iz Umaga i Robert Vlizlo iz Funtane. Dvaput su u kolu zabili Gračić i Stefan Stošić iz Medulina.

LJESTVICA

Cres je ostao na vrhu s petnaest bodova, a da nije igrao. Ližnjan i Borac (Bakar) imaju po dvanaest, s time da Ližnjan ima odigranu utakmicu više. Slijede Otočac i Štinjan s po devet, pa četvorica s po sedam bodova: Umag-CC Umago, Medulin 1921, Rječina i Smoljanci Sloboda. Na dnu su Klana, Funtana i Mladost Fažana s po tri boda.

Najviše je u kolu dobio Medulin 1921, dva mjesta, a Umag i Smoljanci Sloboda po jedno. Najviše je izgubio Žminj, četiri mjesta, jer je ostao na pet odigranih utakmica dok su ga ostali prestigli.

Ljestvica je izračunata iz rezultata i uključuje tri kaznena boda Umaga. Klubovi nemaju isti broj odigranih utakmica, jer u ligi s trinaest klubova svako kolo jedan ne igra, a ovom kolu je uz to jedna utakmica premještena.

ZA SLJEDEĆE KOLO

Sedmo kolo propuštaju Hisa Ramadani (Ližnjan) i Dario Pajdaković (Otočac), obojica nakon crvenog kartona. Najviše žutih kartona u sezoni ima Ivan Golić iz Borca, četiri.

Raspored sedmog kola je na stranici lige.',
  '4. NL NS Rijeka',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-6-kola-4-nl-ns-rijeka-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'pregled-6-kola-4-nl-ns-rijeka-2627';


-- =====================================================================
-- PROVJERA LJESTVICE PRIJE OBJAVE
-- =====================================================================
-- Klubovi koji su igrali 6. kolo moraju imati 6 odigranih utakmica.
-- Cres i Mladost Fazana ostaju na 5, odnosno 4, jer im je utakmica
-- premjestena, a Funtana na 5, jer je bila slobodna.
--
-- select klub ->> 'klub' as klub, klub ->> 'odigrano' as odigrano
-- from public.statistike,
--      lateral jsonb_array_elements(podaci) as klub
-- where sezona = '2026/27' and natjecanje = '4. NL NS Rijeka'
--   and tip = 'tablica'
-- order by (klub ->> 'pozicija')::int;


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-6-kola-4-nl-ns-rijeka-2627';

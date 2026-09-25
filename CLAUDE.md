# Lokal-Arena

Stranica s rezultatima nižih nogometnih liga na prostoru Primorsko-goranske
županije. Radi je jedna osoba (Andrej), nije komercijalni projekt.

Javno: lokalarena.com (hosting Vercel). Stara adresa
istra-pgz-nogomet.vercel.app trajno se preusmjerava preko `proxy.ts`.
Podaci: HNS Semafor (semafor.hns.family), scrapeani u Supabase.

---

## ⚠️ PRAVILA KOJA SE NE KRŠE

**1. Nema oglašavanja ni monetizacije.**
HNS je dao pisano dopuštenje za javni prikaz podataka, ali izričito zabranio
komercijalizaciju u bilo kojem obliku (prava drži SuperSport). Nikad ne
predlaži AdSense, bannere, sponzore ni affiliate. Ako korisnik to zatraži,
podsjeti ga na uvjet dopuštenja.

**2. Atribucija mora ostati vidljiva.**
Komponenta `components/IzvorPodataka.tsx` navodi HNS Semafor kao izvor i
prikazuje se preko `app/layout.tsx`. To je uvjet dopuštenja — ne uklanjaj je.

**3. Prije svakog pusha pokreni `npm run build`.**
`npm run dev` NE hvata greške tipova; Vercel ih hvata i build padne.
Ovo se već dogodilo (uži tip vs. `Utakmica` na naslovnici).

**4. ID-jevi natjecanja se NIKAD ne pogađaju po nazivu.**
Nazivi "1. ŽNL" i "2. ŽNL" koriste se u svim županijama. Jednom je po nazivu
greškom upisana bjelovarsko-bilogorska liga. Provjera ide isključivo preko
popisa klubova na stranici natjecanja.

**5. NIKAD se ne izmišljaju podaci.**
U najavama, osvrtima i člancima piše se samo ono što stoji u bazi ili što je
Andrej izričito rekao. Bez izjava trenera, ozljeda, atmosfere, vremenskih
uvjeta, forme s priprema i očekivanja. Ako podatka nema, susret se opiše
kraće ili se pita Andreja. Izuzetak postoji samo uz njegovu izričitu uputu
(npr. "napiši da je Otočac znatno pojačan").

**6. NIKAD se ne koriste crtice u tekstu.**
Ni duga (em) ni srednja (en). Vrijedi za sve tekstove za stranicu i za
odgovore Andreju. Parovi klubova pišu se s običnim spojnicom i razmacima:
"Naprijed (H) - Kraljevica". Gdje bi crtica dijelila rečenicu, rečenica se
prepiše ili se stavi zarez, dvotočka ili točka.

---

## Tehnologija

- **Frontend:** Next.js (App Router) + TypeScript + Tailwind v4, hosting Vercel
- **Baza:** Supabase (PostgreSQL)
- **Scraper:** Python (`requests` + `BeautifulSoup`), bez Playwrighta
- **Automatizacija:** GitHub Actions
  - `.github/workflows/scraper.yml` (puni prolaz: raspored, zapisnici,
    rang-liste) petkom, subotom, nedjeljom i srijedom navečer, i to
    DVAPUT, ranije i kasnije, te ponedjeljkom ujutro (petkom jer se dio
    kola igra u petak, srijedom zbog utakmica zakazanih sredinom tjedna)
  - `.github/workflows/termini.yml` (samo termini s rasporeda) svaki dan
    ujutro i poslijepodne; kad je koja utakmica premještena, otvori issue
    na GitHubu, pa o tome stigne e-pošta
  - `.github/workflows/provjere.yml` (pyflakes i testovi koji ne diraju
    internet ni bazu) na svaki push i pull request
  - `.github/workflows/fotografija.yml` ("Fotografija za članak") samo
    ručno: skine fotografiju s njezine adrese, uspravi je, smanji, učita
    u Supabase Storage i upiše u članak. Zamjenjuje ručni put preko
    Supabase dashboarda i radi s mobitela.
  - `.github/workflows/slika.yml` ("Izreži sliku") samo ručno, kad se
    želi točno odabrani izrez spremljen u repozitorij; za obične
    fotografije uz članke više nije potreban

## Struktura

```
app/
  layout.tsx            fontovi (next/font), metadata
  globals.css           paleta, animacije, tipografija
  icon.svg              favicon
  page.tsx              naslovnica (hero + rezultati + lijevi stupac)
  liga/[slug]/page.tsx  stranica lige (tablica, kola, utakmice, bočni stupac)
  klub/[slug]/page.tsx  stranica kluba (raspored, rezultati, statistika)
  utakmica/[slug]/page.tsx  stranica utakmice (zapisnik s postavama)
  igrac/[slug]/page.tsx  stranica igrača (golovi, kartoni, minute)
  novosti/page.tsx      popis članaka
  novosti/[slug]/page.tsx  pojedini članak
  impresum/page.tsx  kontakt/page.tsx  sitemap.ts  robots.ts
components/
  Navigacija, Podnozje, Grb, Hero, PregledKola, TablicaLige, SidebarLiga,
  Postava, KarticaClanka, PoveznicaKluba, PoveznicaIgraca, Ikone, Brojka,
  Otkrivanje, ZaglavljeStranice, IzvorPodataka
lib/
  supabase.ts  lige.ts  kolo.ts  statistike.ts  clanci.ts  slug.ts
  klubovi.ts  igraci.ts  utakmice.ts  tablica.ts  posjecenost.ts  metapodaci.ts
  slike.ts     kadriranje fotografija uz članke (stupac slika_kadar)
sql/
  najava_kola.sql   funkcija public.najava_kola() za najavu kola
  pregled_kola.sql  funkcija public.pregled_kola() za osvrt nakon kola
  slike_clanaka.sql jednokratno: stupci za fotografiju i spremnik
  autogolovi.sql    jednokratno: stupac utakmice.autogolovi
  termin_rucno.sql  jednokratno: stupci datum_rucno i vrijeme_rucno
  slika_kadar.sql   jednokratno: stupac clanci.slika_kadar
  (ostale .sql datoteke su jednokratni zahvati nad podacima)
alati/
  fotografija.py    fotografija s mobitela do slike na članku, u jednom
                    potezu; pokreće ga posao "Fotografija za članak"
  najave/     predložak i generator naslovnih slika za najave kola
  transferi/  isto, za članke o prijelaznom roku
  zaglavlja/  slike zaglavlja liga
  zapisnik_html.py  ispis HTML-a događaja iz jednog zapisnika, kad
                    treba vidjeti kako HNS nešto označava
  izrezi_sliku.py   rezanje fotografije na zadani omjer i sažimanje;
                    pokreće ga posao "Izreži sliku" na GitHubu
scraper_supabase.py     glavni scraper
natjecanja.json         referenca ID-jeva natjecanja po sezonama
derbi_tjedni_predlozak.sql  SQL predložak za tjedno označavanje derbija
raspored_migracija.sql  jednokratna migracija (već pokrenuta 08/2026)
```

## Tablice u Supabaseu

- **`utakmice`** — jedan redak po utakmici, odigranoj i neodigranoj.
  Ključ za upsert: (`natjecanje`, `sezona`, `kolo`, `domacin`, `gost`).
  Polja koja scraper NE dira: `derbi`, `tekst_clanka`, `slika_url`,
  `autogolovi`. Ručni termin (`datum_rucno`, `vrijeme_rucno`) također je
  korisnikov unos, ali ga scraper obriše kad HNS upiše isti termin
  (to su korisnikovi unosi i moraju preživjeti svako osvježavanje).
  `datum` / `vrijeme` / `stadion` dolaze s retka rasporeda i postoje i
  prije odigravanja; `stadion_datum` se puni tek iz zapisnika.
- **`statistike`** — tablica/strijelci/kartoni po ligi i sezoni (`jsonb`).
  Jedinstveno po (`sezona`, `natjecanje`, `tip`).
- **`clanci`** — novosti. Vidljivi su samo oni s `objavljen = true` (RLS).
  Fotografija ide u četiri stupca: `slika_url` (adresa), `slika_opis` (opis
  za čitače ekrana i za dijeljenje), `slika_potpis` (npr. "Foto: Lokal-Arena")
  i `slika_kadar` (okomiti kadar pri rezanju, prazno je sredina).
  Slike stoje u Supabase Storageu, spremnik `clanci`, javan za čitanje i
  bez ijedne politike za pisanje, pa upload ide samo kroz dashboard.
  Preporuka za upload: JPEG, širina 1600, do 300 KB. Na stranici ih
  prikazuje `next/image`, pa vanjska adresa mora odgovarati uzorku iz
  `next.config.ts`.

---

## Naučeno na teži način (ne ponavljati)

**Tipovi događaja u postavi čitaju se IZ HTML-a, ne pogađaju se.**
Svaki događaj je `<li>` unutar `div.matchEvents` i nosi tip u klasi i u
`title` atributu ikone (`yellow`, `red`, `substitutionOut`, `substitutionIn`,
`goal`). Ranije se pogrešno mislilo da to renderira JavaScript i da treba
Playwright — ne treba.

**Kod vratara stupac `goals` znači PRIMLJENE golove, ne zabijene.**
Provjereno: vratar Turbine ima 50, a Turbina je po tablici primila 50.
Vratari se zato izbacuju iz liste strijelaca (u kartonima ostaju).

**Nastupi i minute stoje u `apps` i `minutes`, ne u `apps_minutes`.**
U sastavima klubova, gdje su SVI igrači lige (oko 500 po ligi), podatak
je u dva odvojena bloka. Blok `apps_minutes` postoji, ali samo u kratkoj
rang-listi od pet igrača. Prva verzija čitala je samo njega i iz 503
igrača izvukla nula, bez ijedne poruke o grešci.

**Minute se pišu s točkom kao razdjelnikom tisućica: "2.700" znači 2700.**
Obično čitanje brojeva iz tog zapisa daje 2 i 700, pa je ispalo da su
najbolji igrači lige odigrali dvije minute. Provjera: 30 kola po 90
minuta je točno 2700, pa taj broj mora izlaziti kod igrača koji su
odigrali sve.

**Broj gledatelja je tekst, ne broj.**
U zapisniku stoji "Nepoznato", prazno ili broj s točkom kao razdjelnikom
tisućica ("1.250"). Ljestvica posjećenosti (`lib/posjecenost.ts`) zato
čita brojeve preko `brojGledatelja` iz `lib/kolo.ts` i preskače sve što
nije veće od nule. Nula znači "nema podatka", ne prazan stadion.
Gledatelji se pripisuju samo domaćinu, jer su došli na njegov stadion.

**Tablica `statistike` ima ograničenje na stupcu `tip`.**
Dopušteni su `tablica`, `strijelci`, `kartoni` i `nastupi`. Kad je scraper
u kolovozu 2026. dobio i nastupe s minutama, `nastupi` nije bio na tom
popisu, pa je baza svaki takav upis odbijala. Nitko to nije primijetio
mjesec dana, jer je greška bila uhvaćena u `try/except`, samo ispisana, a
pokretanje je svejedno završavalo zeleno s porukom "Grešaka: 0". Minute
zato nisu ušle ni za 2025/26.

Popravljeno 25.08.2026. proširenjem ograničenja, a scraper od tada broji
i greške u statistikama te završava neuspjehom kad išta padne, da GitHub
takvo pokretanje označi crveno.

Rupa u prošloj sezoni popunjava se naknadno, zastavicom `--samo-statistike`
uz `--sezona` i `--url` prošlosezonske lige (adrese su u `natjecanja.json`,
odjeljak `prethodne_sezone`). Time se dohvaćaju samo rang-liste, u nekoliko
sekundi, bez diranja utakmica. Za 2025/26 napravljeno je 25.08.2026.:
3. NL Zapad 503 igrača (vrh 2700 minuta, 30 kola po 90) i 4. NL NS Rijeka
431 igrač (vrh oko 2340, 26 kola po 90). Županijske lige tada nisu bile
popunjene, jer ih scraper još nije poznavao; od 27.08.2026. ih poznaje, pa
se isti zahvat može napraviti i za njih. Pouka je općenitija od ovog slučaja: ako
se greška hvata da ne sruši ostatak posla, mora se barem prebrojati i
prijaviti na kraju.

**Naziv i adresa natjecanja na Semaforu znaju biti krivi; ID nije.**
1. ŽNL PGŽ za 2026/27 objavljena je 27.08.2026. pod naslovom "1. ŽNL
SENIORI 25/26" i s adresom koja završava na `-2526`, iako je u podnaslovu
stajalo 2026/2027, a klubovi i raspored bili novosezonski. Provjera koja
to razrješava je ID: sva natjecanja za 25/26 imaju ID oko 100 do 101
milijun, a za 26/27 oko 114 do 115 milijuna. Sporno natjecanje ima
115499925, prošlosezonsko 101555188.

Pouka je ista kao kod pravila o ID-jevima: natjecanje se potvrđuje popisom
klubova i redom veličine ID-ja, nikad nazivom ili slugom. Adresa iz
`natjecanja.json` ne smije se "ispravljati" zato što slug ne odgovara
sezoni.

**Autogol nosi klasu `own_goal`, a "goal" je njezin podniz.**
Strijelci u zapisniku nemaju klub, pa se pripisuju momčadi u čijoj su
postavi; autogol time završi na krivoj strani. Otkriveno 30.08.2026. na
Jadran-Poreč - Nehaj 1:3 (1. kolo 2026/27), gdje su strijelci davali 2:2,
a autogol je bio pogodak Vedrana Radmana u 16. minuti.

Kako HNS to označava, provjereno u stvarnom HTML-u (alat
`alati/zapisnik_html.py`):

```
traka strijelaca:  <div class="event own_goal"><div class="icon" title="Autogol">
uz igrača u postavi:  <li class="own_goal"><div class="icon" title="Autogol">
```

Iz toga slijede dvije zamke, obje su bile aktivne:

- U traci strijelaca provjera je tražila TOČNO klasu `goal`, pa je autogol
  ispadao iz popisa strijelaca.
- U postavi je provjera tražila podniz, a `goal` JEST podniz od `own_goal`,
  pa je autogol ondje prolazio kao običan gol. Zato u
  `odredi_tip_dogadjaja` autogol mora ići PRIJE gola.

Scraper sada autogol prepoznaje sam i zapisuje ga kao `"autogol": true` uz
tog strijelca, te kao tip `autogol` uz igrača u postavi. Prikaz i
`pregled_kola()` takav pogodak pripišu PROTIVNIKU strijelca, označe ga s
(ag) i izbace ga iz ljestvica strijelaca, jer autogol nije zasluga
strijelca. Čuva `test_autogol.py`, pisan po stvarnom HTML-u.

Ručni stupac `utakmice.autogolovi` ostaje kao popravak, ravnopravan
automatskoj oznaci: za utakmice odigrane prije nego je prepoznavanje
dodano, i za slučaj da HNS pogodak nije označio. Scraper ga ne dira, kao
ni `derbi`, `tekst_clanka` i `slika_url`. Upute su u `sql/autogolovi.sql`.

Scraper uspoređuje i zbroj golova po stranama s rezultatom, uzimajući
autogole u obzir, pa ispisuje upozorenje kad se ne slažu
(`provjeri_zbroj_golova`). Upozorenja se broje i ispisuju na kraju, ali NE
ruše pokretanje: podatak s HNS-a je takav kakav je, ovo je znak da
utakmicu treba pogledati. Upravo je ta provjera i otkrila ovaj slučaj.

Zapaženo, ali namjerno neiskorišteno: u traci strijelaca domaći pogodak ima
`div.playerName` PRIJE `div.event`, a gostujući obrnuto. Viđeno na jednom
zapisniku i presentacijske je naravi, pa se klub i dalje određuje po
postavi.

**Termin se zna promijeniti bilo kojeg dana, i to bez najave.**
HNS premještanje utakmice ne objavljuje nigdje; samo tiho prepiše redak
rasporeda. NK Žminj - NK Ližnjan (1. kolo 4. NL NS Rijeka) tako je s
05.09. prebačen na 04.09.2026., a stranica je i dalje pokazivala stari
datum, jer je puni scraper zadnji put išao u ponedjeljak ujutro.

Puni prolaz otvara svaki zapisnik i traje dvadesetak minuta po ligi, pa se
ne može vrtjeti svaki dan. Zato postoji `--samo-raspored`: čita SAMO retke
rasporeda (jedna stranica po ligi, nekoliko sekundi) i osvježava datum,
vrijeme i stadion. Rezultati, postave i rang-liste se ne diraju.
`.github/workflows/termini.yml` to pokreće svaki dan ujutro i
poslijepodne, pa se premještaj uhvati isti dan, bez ručne provjere na
Semaforu.

Promjena termina nije ni greška ni upozorenje, ali se ne smije progutati:
scraper uspoređuje termin s onim u bazi, promjene ispisuje na kraju
(`PROMIJENJENI TERMINI`), a uz `--izvjestaj-promjena` ih zapiše u datoteku
od koje GitHub napravi issue. Time se vidi treba li ispraviti već napisanu
najavu kola.

Dva pravila uz to, oba čuva `test_termini.py`:

- Prazan termin s HNS-a NE briše onaj u bazi. Ako se redak rasporeda
  jednom ne pročita kako treba, bolje je zadržati zadnji poznati termin
  nego stranicu ostaviti bez njega. Ispiše se kao napomena.
- Ručni termin (`datum_rucno`, `vrijeme_rucno`, vidi `sql/termin_rucno.sql`)
  ima prednost pred HNS-om, za slučaj da Semafor zaostaje. Dok se od
  Semafora razlikuje, scraper ga ne dira, nego njegovu vrijednost upisuje
  u `datum` i `vrijeme`, pa stranica ostaje nepromijenjena. Čim HNS upiše
  isti termin, scraper sam obriše ručni unos. To je jedina iznimka od
  pravila da ručne stupce ne dira, i postoji zato što bi zaboravljen ručni
  termin kasnije zaustavio pravu promjenu s HNS-a, bez ijedne poruke.
  Briše se samo kad je jednak onome što HNS pokazuje, pa se ništa ne gubi.

**HNS ne odgovori uvijek iz prve, i to nije naša greška.**
03.09.2026. pala je dnevna "Provjera termina" s porukom
`ReadTimeout: Read timed out (read timeout=15)`, već na prvom dohvatu
stranice lige. Jedan neuspjeli dohvat srušio je cijelo pokretanje, pa su
i ostale tri lige ostale neosvježene, a na e-poštu je stigla obavijest o
grešci koje u našem kodu nije bilo.

Otud dvije stvari:

- `dohvati_stranicu` je jedini put prema Semaforu: čeka 30 sekundi i
  pokušava tri puta, s pauzom 15 pa 45 sekundi. Tek ako ni treći put ne
  uspije, greška ide dalje. Čuva `test_ponavljanje.py`.
- Liga čija se stranica ne može pročitati ispada iz tog prolaza, ali
  ostale se svejedno obrade. Greška se broji i pokretanje na kraju
  svejedno završava crveno, jer podatak stvarno nedostaje.

Lažno crveno je skupo: obavijest koju se nauči preskakati ne vrijedi
ništa. Zato se ponavlja prije nego se prijavi, ali se i dalje prijavljuje.

**HNS ne zakaže samo istekom vremena, nego i greškom 500.**
13.09.2026. u 23:12 palo je večernje zakazano pokretanje s porukom
`500 Server Error: Internal Server Error`, i to na stranicama 3. NL Zapad
i 4. NL NS Rijeka. Petsto znači da se pokvarilo kod njih, ne kod nas.
Obje županijske lige su u istom prolazu prošle uredno, pa je jasno da je
ispad bio kratak i vezan uz te dvije adrese.

Ponavljanje je odradilo svoje: svaka stranica je pokušana tri puta, HNS
je i treći put vratio istu grešku, te dvije lige su preskočene, ostale
obrađene, a pokretanje je završilo crveno. Tako i treba. Ništa nije
izgubljeno, jer je prolaz dva sata ranije prošao do kraja, kao i onaj
sutradan ujutro.

Dvije stvari otud:

- Istek vremena i greška 500 idu kroz ISTI put, jer
  `raise_for_status()` diže `HTTPError`, koji je i sam
  `RequestException`. Ne treba im zasebno hvatanje. Čuva to i
  `test_ponavljanje.py`, koji od 14.09.2026. ima i slučaj s 500.
- PAUZE SU PRODULJENE s 5 i 10 na 15 i 45 sekundi. S prijašnjima je cijelo
  ponavljanje trajalo petnaestak sekundi, pa je zastoj koji potraje minutu
  svejedno rušio pokretanje. Sada se čeka do minute. Cijena je da liga
  koju se ne može dohvatiti oduzme minutu prolaza, i to samo kad HNS
  doista ne radi.

**Zakazani poslovi na GitHubu kasne, redovito jedan do tri sata.**
GitHub cron nije obećanje nego red čekanja: zakazano vrijeme je NAJRANIJE
kad posao može krenuti, a na besplatnim izvođačima se stvarno pokretanje
čeka dok se ne oslobodi mjesto. Nikad ne krene ranije, a zna zakasniti i
puno više od sata.

Izmjereno na našim poslovima, kraj kolovoza i početak rujna 2026.:

```
Scraper HNS Semafor (cron 19:00 UTC)
  29.08. subota    +2 h 28
  30.08. nedjelja  +2 h 46
  02.09. srijeda   +2 h 27
  05.09. subota    +1 h 54
Scraper, ponedjeljak ujutro (cron 06:00 UTC)
  24.08.           +55 min
  31.08.           +6 h 46
Scraper, petak navečer (cron 20:00 UTC)
  04.09.           +2 h 16
Provjera termina (cron 05:00 i 15:00 UTC)
  03.09. do 05.09. +1 h 59 do +4 h 17, na svih šest pokretanja
```

Dakle poslovi se izvršavaju, svi do jednoga, samo kasnije nego što u
datoteci piše. Praktična posljedica: večernji prolaz zakazan u 19:00 UTC
(21:00 po našem) stvarno završi negdje između 22 i 24 sata, pa rezultati
subotnjeg kola nisu na stranici u deset navečer.

Iz toga slijede dva pravila:

- Kad rezultat treba ranije, posao se pokrene ručno (Actions -> "Scraper
  HNS Semafor" -> Run workflow, ili preko API-ja). Ručna pokretanja kreću
  odmah, u sekundi, jer ne idu kroz isti red čekanja. Dva prolaza ne
  smetaju: sve ide preko istog retka u bazi, pa drugi prolaz samo pokupi
  ono što je HNS u međuvremenu dopunio.
- Prazan popis pokretanja NIJE dokaz da posao nije krenuo, nego da još
  nije. Prije nego se traži greška, pogleda se povijest zakazanih
  pokretanja (`event: schedule`) za taj workflow. 05.09.2026. je zaključeno
  da subotnji cron "uopće nije krenuo", a krenuo je 114 minuta kasnije.

Riješeno 07.09.2026. tako da se ne pomiče postojeći prolaz, nego se
DODAJE rani. Mjerenjem se pokazalo da su zapisnici na HNS-u gotovi
otprilike sat do sat i pol nakon zadnjeg zvižduka: 05.09. su utakmice
završile oko 19:20, a u 20:19 su svi zapisnici 3. NL i 4. NL bili
potpuni; 06.09. su završile oko 18:50, u 19:44 ih je bilo pet od šest, a
šesti je stigao do 20:24.

Zato sada petkom, subotom, nedjeljom i srijedom idu po dva prolaza. Rani
je zakazan za 17:00 UTC (18:00 petkom, jer se ondje igra kasnije), pa uz
uobičajeno kašnjenje padne između 20 i 22 sata po našem, taman kad su
zapisnici gotovi. Kasni ostaje na 19:00, odnosno 20:00 UTC, kao mreža za
ono što HNS naknadno dopuni.

Pomicanje POSTOJEĆEG crona ranije namjerno nije napravljeno: kašnjenje
nije stalno, pa bi se time riskiralo da jedini prolaz ode prije nego HNS
išta upiše. Ovako najgori ishod ranog prolaza je da ne zatekne ništa
novo, što ne šteti.

Kad se satnica u kasnu jesen pomakne na 13:30, rani prolaz smije ići još
ranije, jer su podaci tada gotovi već oko 16 sati.

Cijena je da se HNS dohvaća dvaput navečer. Zasad je to nekoliko minuta,
jer je odigrano tridesetak utakmica. Kad ih u studenome bude tristotinjak
i prolaz potraje dvadesetak minuta, treba dodati zastavicu koja otvara
samo zapisnike utakmica bez rezultata u bazi, pa da rani prolaz traje
sekunde. Mi smo na Semaforu gosti i to se ne smije zaboraviti.


**HNS ne osvježi sve dijelove stranice odjednom, nego dio po dio.**
12.09.2026. navečer, nakon 3. kola 3. NL Zapad, prolaz u 20:08 po našem
zatekao je stranicu natjecanja na pola posla. Tablica poretka bila je
svježa (Lokomotiva 9 bodova, odigrano 3), a golovi i kartoni po igraču
nisu: Ahmed Durmo je stajao na dva gola, iako ih je po zapisnicima imao
četiri, jer je dva zabio baš u tom kolu. Zapisnici svih osam utakmica
bili su pritom potpuni i uredno pročitani.

Ljestvica strijelaca na stranici zato je izgledala zaglavljeno, a
zapravo je vjerno pokazivala ono što je HNS u tom trenutku imao. Potvrda
je i samoprovjera scrapera, koja uspoređuje našu agregaciju sa službenom
rang-listom: javila je da se poklapa, dakle oba HNS-ova mjesta govorila
su isto.

Novi prolaz sutradan ujutro sve je popravio, bez ijedne izmjene u kodu:
Durmo je dobio svoja četiri gola, a lista nastupa narasla je s 331 na
345 igrača. To zadnje je i ključ: nastupi su sinoć izgledali svježi
(netko s tri nastupa i 270 minuta), pa se činilo da su golovi i nastupi
iz istog retka nekako razdvojeni. Nisu. HNS je jednostavno još punio
podatke, pa je dio igrača već imao treće kolo, a dio ne.

Otud tri stvari:

- Kad tablica i rang-liste govore različito, prvo se pogleda SAT. Puni
  zapisnici ne znače da su rang-liste gotove; one zaostaju i sat i više.
- Rang-liste se pri svakom prolazu prepisuju u cijelosti (upsert po
  sezoni, natjecanju i tipu), pa je lijek uvijek isti i besplatan: novo
  pokretanje. Ništa se ne popravlja ručno i ništa se ne mijenja u kodu.
- Ponedjeljak ujutro (cron 06:00 UTC) upravo zato postoji. Ovaj slučaj
  je njegova prva potvrđena korist: da nitko ništa nije dirao, ljestvica
  bi se sama posložila u ponedjeljak.

Lista kartona pritom nije bila u krivu iako je izgledala nepromijenjeno.
Poredak ide po crvenima pa po žutima, a u 3. kolu nije bilo nijednog
crvenog, pa je na vrhu ostao isti igrač. Promjene su bile niže na
listi. Nepromijenjen vrh liste nije dokaz da lista nije osvježena.

DOPUNJENO 15.09.2026.: strijelci i kartoni se od tada ne čekaju od HNS-a
nego se ZBRAJAJU IZ ZAPISNIKA koji su već u bazi. Podatak je cijelo
vrijeme bio kod nas, u postavama, uz svakog igrača i njegove događaje;
nitko ga nije zbrojio. Sada ljestvice budu ažurne u istom trenutku kad i
rezultati, a ne sat i više kasnije.

Kako radi (`ucinci_iz_zapisnika` u `scraper_supabase.py`):

- igrač pripada momčadi u čijoj je POSTAVI, a ime kluba se uzima s retka
  utakmice, dakle isto ono koje stranica već koristi za poveznice
- autogol ne ulazi u golove, ni onaj koji scraper sam prepozna ni onaj iz
  ručnog stupca `utakmice.autogolovi`
- drugi žuti karton broji se kao crveni, a žuti prije njega je zaseban
  događaj u zapisniku i broji se sam
- vratar koji zabije ima gol. To nije proturječje s pravilom da se vratari
  izbacuju iz strijelaca: ono vrijedi za SASTAVE na stranici natjecanja,
  gdje stupac golova kod vratara znači primljene. U zapisniku gol znači gol.

Lista sa stranice natjecanja nije ukinuta nego ostaje kočnica: ona iz
zapisnika objavljuje se SAMO kad nigdje ne zaostaje za njom
(`zaostaje_za_sluzbenom`). Ispred smije biti, jer HNS kasni; iza ne smije,
jer to znači da nam fali zapisnik. Ispis pokretanja u oba slučaja kaže
odakle je lista koja je otišla na stranicu.

DOPUNJENO 24.09.2026.: kočnica je jednom radila naopako. HNS je nakon
20.09. ispravio zapisnik Medulin 1921 - Cres i gol u 35. minuti s Boška
Babića prepisao na Željka Tomića. Naš zbroj iz zapisnika spustio je
Babića na tri, a stranica natjecanja danima je i dalje pokazivala
četiri, pa je kočnica na stranicu vraćala HNS-ovu zastarjelu listu.
Sada se manjak GOLOVA oprašta kad ga potvrdi sam zapisnik
(`potvrdjeno_zapisnikom`): svaka odigrana utakmica ima postave u bazi,
a traka strijelaca za tog igrača kaže isto što i zbroj iz postava. Prvi
uvjet čuva slučaj kad zapisnik fali, jer tada nestanu i traka i postave
pa bi se slagale u krivom broju. Oprošteni manjak ispisuje se na kraju
pokretanja. Za kartone traka ne postoji, pa ondje kočnica ostaje ista.

Tablica poretka i nastupi se i dalje SAMO scrapaju: tablica zbog kaznenih
bodova, nastupi zato što zapisnik ne kaže koliko je tko bio na terenu.

Zbog toga je rang-liste u prolazu trebalo pomaknuti IZA zapisnika. Prije
su išle prve, pa bi se sada slagale od jučerašnjeg stanja i kolo pročitano
maloprije ušlo bi tek u sljedeći prolaz. Čuva `test_rang_liste_iz_zapisnika.py`.

DOPUNJENO 19.09.2026.: isto se dogodilo i LJESTVICI, ne samo rang-listama.
Nakon 5. kola 3. NL Zapad prolaz u 19:10 po našem, dakle odmah nakon
zadnjeg zvižduka, zatekao je tablicu u kojoj je peto kolo bilo upisano za
šest klubova koji su igrali, a za osam nije. Zapisnici svih sedam utakmica
bili su pritom potpuni i uredno pročitani.

Provjera se radi klub po klub, usporedbom broja odigranih utakmica i
golova sa zbrojem stvarnih rezultata:

```
ukljucuje 5. kolo:      Pomorac, Pazinka, Krk, Rudar, Halubjan, Naprijed
pokazuje stanje po 4.:  Kraljevica, Nehaj, Omišalj, Jadran-Poreč,
                        Buje, Rovinj, Crikvenica, Vinodol
nisu ni igrali:         Lokomotiva, Banjole
```

Tablica se scrapa i ne računa, zbog kaznenih bodova, pa je takva
polovična ušla u bazu i takva se prikazala na stranici lige. Lijek je isti
kao i za rang-liste i jednako je besplatan: novo pokretanje scrapera. Ne
dira se ni kod ni podatak ručno.

Praktična pouka je za pisanje članaka: BROJKE ZA PREGLED KOLA NE PREPISUJU
SE S LJESTVICE dok se ne provjeri da svi klubovi koji su igrali imaju isti
broj odigranih utakmica. Bodovi, gol razlika i pomaci računaju se iz
rezultata, što je aritmetika nad podacima koji su u bazi, a ne procjena.
Račun se provjerava tako da se izračuna i stanje nakon prethodnog kola i
usporedi s onim što je pisalo u najavi tog kola. Za 5. kolo je to dalo
Lokomotiva 12, Kraljevica 10, Pomorac 9, točno kao u najavi.

Otud i pravilo kad se objavljuje: pregled kola se ne objavljuje s prvog
prolaza nakon utakmica, nego se prije objave pokrene scraper još jednom i
pogleda ima li ljestvica sve klubove na istom broju kola.


**Događaj bez minute je događaj, a scraper ga je bacao.**
Prvo pokretanje s rang-listama iz zapisnika, 15.09.2026., pokazalo je da
strijelci prolaze u sve četiri lige, a kartoni u tri padaju natrag na
listu sa Semafora. Razlika je svaki put bila jedan žuti karton: Doni
Tanković i Ivan Rojnić (Pazinka), Admir Haznadar (Otočac) i Bakir Delić
(Rikard Benčić).

Uzrok se nije pogađao nego pogledao, alatom `dijagnostika_kartoni.py`
(ručni posao "Dijagnostika kartona" na GitHubu, uz kvačicu za sirovi
HTML). Karton je u zapisniku bio, ali bez minute:

```
<div class="matchEvents"><ul class="events">
  <li class="yellow"><div class="icon" title="Žuti karton"></div></li>
</ul></div>
```

Kod Haznadara je u istom bloku izmjena imala minutu, a karton nije, pa se
vidi da minuta fali samo pojedinom događaju, ne cijelom zapisniku.

Scraper je takav redak PRESKAKAO, jer je minuta bila uvjet za upis
(`if not m: continue`). Događaj je time tiho nestajao: nije ga bilo ni u
postavi na stranici utakmice, ni na stranici igrača, ni u zbroju kartona.
Sada se upisuje s praznom minutom, a prikaz tada ispiše samo ikonu.

Tri stvari uz to:

- Isto je vrijedilo i za traku strijelaca, pa je i ondje maknut uvjet.
- Nadopuna strijelaca iz postave uspoređivala je po minuti. Gol koji u
  traci ima minutu, a u postavi je bez nje, tako bi ušao dvaput. Kad
  minute nema, uspoređuje se BROJ pogodaka igrača, ne minuta. Ista
  zamka i isti popravak su i u `components/Postava.tsx`, gdje je
  sigurnosna mreža dopisivala drugu loptu.
- Kad tip događaja nije prepoznat, a minute nema, ne pogađa se ništa:
  provjera preko liste strijelaca bez minute nema po čemu raditi.

Pouka je ista kao kod autogola: kad se dva izvora ne slažu, gleda se
stvarni HTML, ne pretpostavka. I ovdje je kočnica napravila svoje, jer se
kriva lista nije objavila. Čuva `test_dogadjaj_bez_minute.py`, pisan po
stvarnom HTML-u s ta dva zapisnika.


**HNS zna odgovoriti uredno, a vratiti nepotpunu stranicu.**
23. i 24.09.2026. HNS je u više navrata vraćao stranice natjecanja bez
rasporeda i bez ljestvice, pa i zapisnike bez rezultata i postava. Nije
bilo ni isteka vremena ni greške 500, pa ponavljanje iz
`dohvati_stranicu` nije ni krenulo. Scraper je to čitao kao "nema
ničega" i svaki put završio zeleno, s porukom "Grešaka: 0":

- 23.09. navečer, provjera termina: nije osvježila ništa, a izgledalo je
  kao da promjena termina nema.
- 24.09. navečer, dva ručna puna prolaza: u bazu je upisana PRAZNA
  ljestvica i prazni nastupi, prvi put za sve četiri lige, drugi put za
  tri. Uz to su tri zapisnika 3. kola 4. NL NS Rijeka (Borac - Ližnjan,
  Klana - Funtana, Žminj - Smoljanci Sloboda) stigla bez rezultata i
  postava. Rezultat je preživio, jer se prazan ne šalje, ali postave i
  strijelci otišli su u bazu kao prazni popisi.

Popravljeno istog dana, na dva mjesta:

- `dohvati_potpunu_stranicu`: stranica natjecanja bez rasporeda, odnosno
  bez ljestvice, tretira se kao neodgovor. Pokuša se još dvaput, s istim
  pauzama (15 i 45 s), a ako ni treći put nije cijela, diže se greška.
  Liga ispada iz prolaza, NIŠTA se ne upisuje i pokretanje je crveno.
  Zadnji dobri podaci ostaju u bazi.
- `bez_praznog_kad_nema_rezultata`: kad zapisnik nema rezultata, ne šalje
  se nijedan PRAZAN stupac zapisnika (strijelci, postave, suci,
  gledatelji). Ono što jest pročitano ide normalno, pa postava upisana
  prije kraja utakmice i dalje stiže na stranicu. Zapisnik S rezultatom
  šalje se cijeli, jer 0:0 stvarno nema strijelaca.

Čuva `test_nepotpuna_stranica.py`. Šteta se popravlja jednim uspješnim
punim prolazom, jer se ljestvica, nastupi i zapisnici prepisuju svaki put.

Pouka je ista kao kod statistika koje baza odbija: prazno nije isto što i
"nema podatka". Kad izvor koji uvijek nešto ima odjednom nema ništa, to je
kvar izvora, a ne vijest, i ne smije prepisati ono što već znamo.

Uz to, nikad ne pokretati scraper više puta zaredom dok HNS šteka: svaki
prolaz sa starim kodom radio je novu štetu. Prvo zaštita, pa pokretanje.

**Ime upotrijebljeno dvaput za dvije stvari ruši scraper tek u pogonu.**
02.09.2026. pao je posao "Provjera termina" s porukom
`TypeError: 'str' object is not callable`. U petlji po utakmicama stajala
je varijabla `opis_utakmice`, isto kao funkcija dodana iznad, pa je od tog
retka to ime značilo tekst.

Testovi to nisu mogli uhvatiti: pozivaju funkciju izravno, a u suhom testu
nema veze prema bazi, pa se do spornog retka ni ne dođe. Pyflakes je to
javljao kao `redefinition of unused 'opis_utakmice' from line 690`.

Zato postoji `.github/workflows/provjere.yml`: na svaki push i pull request
pokrene pyflakes nad svim Python datotekama i one testove koji ne diraju
internet ni bazu. Verzija pyflakesa je zakovana, da novo izdanje ne
pocrveni posao samo od sebe. Testovi koji dohvaćaju Semafor
(`test_raspored.py`, `test_tablica.py`, `scraper_test.py`,
`dijagnostika_*.py`) namjerno nisu ondje: padali bi kad god HNS ne
odgovori, a to nije greška u našem kodu.

**Klub zna napustiti natjecanje, a scraper zna samo dodavati.**
NK Novalja je 02.09.2026., dan prije 1. kola, napustila 4. NL NS Rijeka.
HNS je i dalje pokazivao cijeli raspored s njom, uključujući NK Otočac -
NK Novalja u 1. kolu, pa bi stranica najavljivala susret koji se neće
odigrati.

Dublji problem je što upsert samo dodaje i mijenja. Kad HNS te utakmice
makne, u bazi bi ostale zauvijek, a kad presloži parove za ligu s jednim
klubom manje, uz nove bi se prikazivali i svi stari.

Odatle dvije stvari u `scraper_supabase.py`:

- `KLUBOVI_IZVAN_NATJECANJA`: popis odustalih klubova po natjecanju i
  sezoni. Scraper njihove utakmice preskače pri čitanju rasporeda i briše
  im retke iz baze, ali SAMO one bez rezultata. Odigrana utakmica se
  dogodila i njezin zapisnik ostaje. Ako se odluka o odustajanju pokaže
  netočnom, dovoljno je maknuti stavku s popisa: dok HNS te utakmice
  pokazuje, vratit će se same.
- `nestale_s_rasporeda`: utakmice koje su u bazi, a HNS ih na rasporedu
  više ne pokazuje, ispisuju se na kraju (`NA RASPOREDU IH VIŠE NEMA`) i
  ulaze u dnevnu obavijest. NIŠTA se ne briše samo od sebe, jer bi jedno
  loše pročitano čitanje stranice obrisalo cijelu ligu. Uspoređuju se samo
  kola koja su u tom prolazu stvarno pročitana, pa uz `--kolo` ostala kola
  ne ispadnu nestala. Kad se u prijavi vidi da im u bazi doista nije
  mjesto, briše ih `--obrisi-nestale`, i to samo one bez rezultata. U
  poslu "Provjera termina" to je kvačica pri ručnom pokretanju; dnevna
  pokretanja nikad ne brišu.

Prva takva prijava, 02.09.2026., pokazala je i staru zamku: HNS je u
1. kolu 4. NL NS Rijeka jednom pokazivao NK Medulin 1921 - NK Smoljanci
Sloboda, pa par okrenuo. Kako domaćin i gost ulaze u ključ za upsert,
okrenuti par se upisao kao NOVA utakmica, a stara je ostala kao duh. Zato
je važno da se nestale utakmice uopće prijavljuju: bez toga se to vidi tek
kao kolo s previše utakmica.

Popis klubova stoji i u `natjecanja.json`, u polju
`klubovi_izvan_natjecanja`. Čuva `test_odustali_klub.py`.

Ljestvica se ne dira: ona se scrapa s HNS-a i pokazivat će odustali klub
dok ga HNS ne makne. To je službena tablica, njezin sadržaj nije naša
procjena.

**Klub igrača se čita iz bloka kluba, ne iz najbliže poveznice.**
05.09.2026. Andrej je javio da na listama strijelaca i kartona ispod
igrača stoje krivi klubovi: Karlu Josipoviću je pisalo da igra za
Halubjan, a igra za Lokomotivu, dok su strijelci Ližnjana bili upisani kao
igrači Otočca. Usporedba sa Semaforom potvrdila je da je greška naša.

Uzrok je pravilo kojim se klub uzimao kao najbliža PRETHODNA poveznica
kluba u dokumentu. U sekciji "Klubovi u natjecanju" svaki klub ima svoj
blok u kojem prvo stoji popis NJEGOVIH utakmica, pa tek onda sastav, tako
da je najbliža poveznica zapravo protivnik iz posljednje utakmice tog
kluba. Lokomotivi je posljednja Lokomotiva - Halubjan, Ližnjanu
Ližnjan - Otočac. Zato je pogađalo otprilike svaki drugi klub: kad je
klub u posljednjoj utakmici gost, ime je slučajno ispalo točno.

Prava struktura, provjerena alatom `dijagnostika_klub_igraca.py`:

```
<div class="block w1280 clubs_in_competition">
  <li class="active" data-id="1507">NK Banjole</li>   kartice klubova
  <li data-id="2334">NK Buje</li>
  <div class="club_competition_details" data-id="1507">  blok jednog kluba
      popis njegovih utakmica, pa sastav
```

Klub se zato od sada čita iz bloka u kojem redak sastava stoji: `data-id`
bloka se preko kartica preslika u ime kluba (`klub_igraca`). Ako kartice
jednom nestanu, rezerva je redak utakmice unutar istog bloka, onaj čiji se
`data-id` poklapa s blokovim. Kad se klub ne može utvrditi, upisuje se
prazno, nikad pogađanje, a pokretanje to prijavi kao upozorenje. Čuva
`test_klub_igraca.py`, pisan po stvarnom HTML-u.

Podaci se ispravljaju sami: rang-liste se pri svakom prolazu prepisuju
(upsert po sezoni, natjecanju i tipu), pa je dovoljno jedno pokretanje
scrapera, i to `--samo-statistike`, bez diranja utakmica.

**Funkcija u bazi ne prati datoteku u repozitoriju sama od sebe.**
06.09.2026. ispis `public.pregled_kola()` pokazao je da su na Rab -
Vihor (B) 4:2 strijelci dali 3:3, uz Radićev pogodak upisan kao običan
gol Vihora. Iz toga je zaključeno da je posrijedi neoznačen autogol, kao
kod Radmana i Vrhovca, i napisan je ručni unos u stupac `autogolovi`.

Provjera stvarnog retka u bazi pokazala je da je zaključak bio kriv:
pogodak je već nosio oznaku `"autogol": true`, koju je scraper sam
prepoznao iz klase `own_goal`. Zato ni `provjeri_zbroj_golova` nije ništa
javio, i to s pravom: uz tu oznaku zbroj je bio točno 4:2. Scraper i
stranica bili su ispravni cijelo vrijeme.

Krivo je bilo posredovanje: `sql/pregled_kola.sql` je od kolovoza 2026.
naučen čitati i tu automatsku oznaku, ali datoteka nakon te izmjene nije
ponovno pokrenuta u Supabaseu, pa je ondje i dalje živjela starija
verzija koja poznaje samo ručni stupac. Isto vrijedi i za `najava_kola()`
i sve druge funkcije: izmjena u repozitoriju NIJE izmjena u bazi dok se
datoteka ne pokrene.

Otud dva pravila:

- Kad se `sql/*.sql` s definicijom funkcije promijeni, u istoj poruci
  Andreju piše da je treba ponovno pokrenuti. Inače ispis izgleda
  vjerodostojno, a zaostaje.
- Kad ispis funkcije i ponašanje scrapera govore različito, prvo se
  pogleda REDAK U BAZI, pa tek onda mijenja kod. Da je to napravljeno
  odmah, ne bi nastao suvišan ručni unos autogola.

Zbog istog povoda je `provjeri_zbroj_golova` dobila drugu razinu: kad
zapisnik nema postave, ne zna se kojoj strani koji pogodak pripada, ali
se zna koliko ih ukupno mora biti, pa se uspoređuje broj strijelaca sa
zbrojem golova iz rezultata. Tako se hvata gol koji u zapisniku fali ili
je upisan dvaput. Krivu podjelu po momčadima ta razina ne može uhvatiti,
i to je namjerno rečeno naglas, da se ne stekne dojam veće zaštite nego
što postoji. Prazan popis strijelaca i dalje ne okida uzbunu, jer
utakmica predana bez borbe ima rezultat, a nema strijelaca. Čuva
`test_zbroj_bez_postava.py`.

Uz taj popravak dotjerana je i samoprovjera strijelaca. Uspoređivala je
prva tri mjesta u NIZU, pa je javljala "NE POKLAPA SE" i kad su imena i
brojke bili isti, samo drugim redom (Durmo, Josipović, Mijić prema Durmo,
Mijić, Josipović, sva trojica s po dva gola). Sada se gleda broj golova PO
IGRAČU, za svakog sa službene liste, pa poredak i duljina naše liste ne
okidaju uzbunu, a krivo zbrojen gol ili igrač koji je ispao i dalje se
prijavljuju. Vrijedi isto pravilo kao kod ponavljanja prema HNS-u: lažna
uzbuna je skupa jednako kao propuštena. Čuva `test_provjera_strijelaca.py`.

**Tablica poretka se scrapa, ne računa.**
Službena tablica već uključuje kaznene bodove (npr. "NK Crikvenica (-3)").
Vlastiti izračun bi bio kriv.

**Stranica natjecanja ima i sekciju "Klubovi u natjecanju"** u kojoj svaki
klub ima svoj popis utakmica BEZ naslova kola. Parsiranje rasporeda mora
stati na naslovu "Ljestvica" / "Statistika" / "Klubovi u natjecanju", inače
nastaju duplikati s krivim kolom.

Ovo se jednom već dogodilo, u kolovozu 2026.: prekida nije bilo, pa je 15.
kolo 3. NL imalo 120 redaka umjesto 8 (dvojnicima se pripisivalo zadnje
viđeno kolo, a datum je ostajao točan). Otkriveno je tek preko trake
"Sljedeće kolo" na naslovnici, koja grupira po datumu i pokazivala je 16
utakmica umjesto 8. Prekid sada čuva `test_kraj_rasporeda.py`; pokreni ga
kad god dirneš parsiranje rasporeda.

Popravak je potvrđen 24.08.2026.: nakon prvog vikenda sa scraperom koji
poštuje prekid, upit po kolima vratio je točno 8 redaka po kolu za 3. NL
Zapad i 7 za 4. NL NS Rijeka. Dvojnici više ne nastaju.

Zaštita od duplikata u scraperu ide po ključu (kolo, domaćin, gost), i to
namjerno ne po samo (domaćin, gost): male županijske lige znaju se igrati
trokružno, pa isti par ondje dvaput ima istog domaćina.

**Neodigrane utakmice nemaju poveznicu na zapisnik** — na mjestu rezultata
stoji samo `- : -`. Raspored se zato čita s retka na stranici lige.

**Utakmica se prepoznaje po ligi + sezoni + kolu + klubovima, ne po
`hns_url`.** Neodigrane utakmice nemaju adresu zapisnika, pa bi upsert po
`hns_url` napravio duplikat čim utakmica dobije zapisnik. Zato se domaćin
i gost UVIJEK uzimaju s retka rasporeda, i onda kad zapisnik postoji —
naziv kluba u naslovu zapisnika zna se sitno razlikovati, a to bi razbilo
ključ i redak bi se udvostručio umjesto nadopunio.

**Poruka "predana bez borbe" smije se prikazati samo kad utakmica IMA
rezultat, a nema zapisnik.** Prije se prikazivala za sve bez detalja, pa bi
je od uvođenja rasporeda dobila svaka buduća utakmica.

**Na stranici lige zadano kolo je zadnje ODIGRANO, ne zadnje u nizu.**
Otkad raspored ide do kraja polusezone, "zadnje kolo" je ono iz studenoga
i stranica bi se otvarala prazna.

**Performanse dolaze od sužavanja upita, ne od keširanja.**
Naslovnica je nekad dohvaćala `select("*")` bez limita (~4,4 MB po otvaranju,
uključujući postave koje ne prikazuje). Sad dohvaća samo potrebne stupce
(~100 KB), a stranica lige samo prikazano kolo. `revalidate = 300`.

**Bočni stupac se renderira na poslužitelju.** Prije se dohvaćao u pregledniku
preko `useEffect` i vidno je "uskakao" nakon učitavanja.

**Postavke veze na bazu provjeravaju se pri gradnji, u `lib/supabase.ts`.**
U kolovozu 2026., dok se postavljala domena, `NEXT_PUBLIC_SUPABASE_URL` u
Vercelu je greškom prepisan adresom same stranice. Build je prošao, objava
je uspjela, a stranica je ostala prazna: upiti su išli na
lokalarena.com/rest/v1/... i vraćali njezinu 404 stranicu, koju kod uhvati
kao grešku i vrati prazan popis. Izgledalo je kao da su podaci nestali, a
bili su netaknuti.

Zato kriva adresa, ključ koji ne izgleda kao ključ i service_role ključ u
javnoj varijabli sada ruše build. Vercel u tom slučaju ostavlja zadnju
ispravnu verziju na zraku. Adresa stranice ide u `NEXT_PUBLIC_SITE_URL`,
nikad u `NEXT_PUBLIC_SUPABASE_URL`.

**Fotografija se ne prilagođava stranici, stranica se prilagođava njoj.**
Fotografije uz članke stižu s mobitela, u svakom omjeru, najčešće
uspravne. Prije 05.09.2026. slika se u članku prikazivala cijela, u svom
omjeru, pa je uspravna zauzimala gotovo cijeli ekran, a na kartici je bila
odrezana na 16:9 iz sredine, često baš preko onoga što je važno. Andrej je
zbog toga svaku fotografiju morao rezati prije učitavanja.

Od tada slika u članku ide u okvir stalnog omjera 3:2, s rezanjem viška
(`object-cover`), kao što je na kartici već bilo 16:9. Znači svejedno je u
kojem se formatu fotografija učita: stranica je sama uklopi i nijedna ne
može zauzeti pola ekrana ni razbiti red kartica.

Reže se iz sredine, a kad je važno ono gore ili dolje, okomiti kadar se
pomiče stupcem `clanci.slika_kadar` ("vrh", "sredina", "dno" ili broj 0 do
100). Isti kadar vrijedi i u članku i na kartici, pa se namjesti jednom.
Računa ga `lib/slike.ts`, upute su u `sql/slika_kadar.sql`.

Alat `alati/izrezi_sliku.py` i posao "Izreži sliku" time postaju
neobavezni. Korisni su i dalje, kad se želi točno odabrani kadar ili
manja datoteka, ali stranica bez njih izgleda uredno.

**Fotografija ide na stranicu jednim potezom, ne kroz dashboard.**
Do 07.09.2026. je uz svaku fotografiju išlo: otvori Supabase na
računalu, Storage, spremnik clanci, učitaj, kopiraj adresu, zalijepi u
SQL, pokreni SQL. Andrej objavljuje petkom, subotom i nedjeljom navečer,
često s mobitela, pa je to bilo predugo i tražilo računalo.

Sada to radi posao "Fotografija za članak"
(`.github/workflows/fotografija.yml`, alat `alati/fotografija.py`):
skine fotografiju s adrese, uspravi je, smanji na širinu 1600 i do
300 KB, učita u Storage pod `godina/mjesec/slug.jpg` i, ako je zadan
slug, odmah upiše `slika_url`, `slika_opis`, `slika_potpis` i
`slika_kadar` u članak.

Adresa fotografije s mobitela dobiva se preko GitHuba: Issues, New
issue, fotografija se povuče u polje za tekst, GitHub je odmah učita i
ubaci cijeli redak oblika `![ime](https://github.com/user-attachments/
assets/...)`, a obrazac se zatvori bez otvaranja prijave. Repozitorij je
javan, pa je ta poveznica javno dohvatljiva i posao je može skinuti.

PRIJAVA SE MORA OTVORITI, gumbom Create. Dok nije otvorena, fotografija
je nacrt vidljiv samo onome tko je učitava, a poslu vraća 404. Najlakše
je nakon otvaranja desnom tipkom kliknuti na sliku i odabrati "Kopiraj
adresu slike"; prima se i cijeli redak `<img ... />`.

Prvi dan, 07.09.2026., alat je pao četiri puta zaredom, i svaki put iz
drugog razloga: dva znaka s kraja adrese završila su na početku pri
označavanju mišem; GitHub ubacuje HTML oznaku bez navodnika, ne markdown
redak; prijava nije bila otvorena pa je adresa vraćala 404; zalijepljena
je adresa STRANICE prijave umjesto adrese slike.

Zajednička pouka nije o korisniku nego o alatu: svaka uputa koja traži
da se mišem pogodi točan komad teksta je poziv na grešku. Zato
`procisti_adresu` prihvaća što god je zalijepljeno i iz toga izvuče prvu
adresu, a kad je nema, poruka kaže što se očekivalo, umjesto dotadašnjeg
`No connection adapters were found`.

Druga pouka je o redoslijedu rada: alat je bio pušten u upotrebu a da
nijednom nije pokrenut od početka do kraja. Testovi su pokrivali dijelove,
ali nijedan nije mogao dodirnuti Storage, pa su greške izlazile jedna po
jedna, i to preko korisnika. Kad se gradi ovakav lanac, prvo pokretanje
radi se sa svoje grane i svojim podacima, pa tek onda predaje.

Dvije stvari koje su se pokazale bitnima:

- EXIF ORIJENTACIJA. Mobitel bočno snimljenu fotografiju sprema uspravno
  uz oznaku "zakreni pri prikazu". Alat koji tu oznaku ne poštuje dobije
  sliku položenu na stranu, pa `pripremi` radi `ImageOps.exif_transpose`.
- IME DATOTEKE. Nastavak se skida PRIJE čišćenja imena, inače točka iz
  ".jpg" postane spojnica i ime završi kao "...-jpg.jpg". To je uhvatio
  test pri prvom pokretanju, prije nego je alat ijednom upotrijebljen.
- SMANJIVANJE IDE PO DUŽOJ STRANICI, ne po širini. Uspravna fotografija
  1500x2000 ima širinu ispod granice od 1600, pa je s pravilom po širini
  prolazila nesmanjena i završavala na 322 KB, iznad ograničenja.
- STORAGE TRAŽI OBA ZAGLAVLJA s ključem, `apikey` i `Authorization`. Bez
  prvog odgovara s 403 "Invalid Compact JWS", što zvuči kao da je ključ
  neispravan, a zapravo fali zaglavlje.

Rezanje se i dalje ne radi unaprijed: stranica sama uklopi sliku, a
`slika_kadar` govori koji se dio po visini zadrži. Čuva
`test_fotografija.py`, koji slike stvara u memoriji, bez interneta.

**Za objavu na Facebooku s opisom i označavanjem ne koristi se naš gumb.**
03.09.2026. najava 1. kola 4. NL nije se dala objaviti: Facebookov
prozorčić ostao je na vrtećem krugu desetak minuta. Članak se pritom
uredno otvarao u anonimnom prozoru, a Facebookov alat za provjeru
(`developers.facebook.com/tools/debug/`) javljao je samo da nedostaje
`fb:app_id`. Ta oznaka služi aplikacijama koje koriste Facebook prijavu i
statistiku, za dijeljenje ne treba i nije bila uzrok.

Gumb u `components/Dijeljenje.tsx` šalje najjednostavniji mogući oblik,
samo adresu (`sharer.php?u=...`), i s naše strane nema se što zaglaviti.
Zaglavio se Facebookov skraćeni uređivač: u njemu je pisan opis i označen
klub, a označavanje ondje zna ostati na vrtećem krugu. Objava izravno s
Facebooka prošla je iz prve.

Pravilo je otud: naš gumb služi za brzo dijeljenje bez opisa. Kad objava
ima tekst ili označene klubove, ide se u pravi uređivač na Facebooku:
zalijepi se adresa, pričeka pregled sa slikom, obriše zalijepljeni tekst
adrese, pa se piše opis i označava.

Druga zamka je Facebookovo pamćenje. Neobjavljen članak stranica ne
prikazuje (RLS pušta samo `objavljen = true`), pa adresa vraća "nije
pronađeno". Ako Facebook stranicu pročita u tom trenutku, to zapamti i
kasnija objava ne pomaže sama od sebe. Rješenje je gumb "Scrape Again" u
gornjem alatu, koji ga natjera da pročita iznova. Isto vrijedi kad se
zamijeni slika, a ime datoteke ostane isto.

**Vercelov Deployment Storage mjeri potrosnju kroz trideset dana, ne
trenutacno stanje.** 08.09.2026. je stigla obavijest da je popunjeno 75
posto od 10 GB, a 11.09. je brojka bila 10,48 GB, i to nakon sto su
rucno obrisani svi deploymenti stariji od 28.08. Brisanje nije pomoglo
jer na stranici Usage stoji raspon "Last 30 Days": ono sto je
potroseno nekog dana ostaje u brojci dok taj dan ne ispadne iz prozora.
Brisanjem se ne vraca unatrag.

IZMJERENO 13.09.2026., da se vise ne pokusava: obrisano je petnaestak
deploymenata i brojka se NIJE pomaknula ni za megabajt. Vercel to i sam
pise u prozoru koji trazi potvrdu brisanja: "Deployments that are not
actively receiving any traffic do not generate any costs nor count
towards any limits." Dakle stari deploymenti u tu brojku uopce ne ulaze
i brisanje je cisto gubljenje vremena.

Zavodi na krivi put racunica koja se lijepo poklopi: 248 buildova u
trideset dana puta cetrdesetak megabajta po Next.js buildu daje upravo
onih 10,5 GB. Poklapanje je slucajno i ne znaci da brojka prati ono sto
stoji spremljeno. Ona mjeri potrosnju kroz prozor od trideset dana.

Jedino sto brojku spusta je da skupi dani ispadnu iz prozora. Za 2026.
to je znacilo da se pad ceka od 27. rujna, jer je sve skupljeno izmedu
28. kolovoza i 9. rujna.

Pri brisanju, ako se svejedno brise radi urednosti: NIKAD deployment s
oznakom Current, jer on jedini drzi stranicu na zraku. Uz njega je
pametno ostaviti i jedan noviji ispravan, kao rezervu za povratak.

Uzrok nije velicina stranice (cijeli `public` je 2,7 MB, repozitorij s
poviescu 6,5 MB) nego broj buildova. Isti ekran je pokazivao i Build CPU
Minutes 13 h 44 u trideset dana. Svaki push na bilo koju granu radio je
deployment, a vecina pusheva mijenja samo `sql/`, `alati/` i tekstove.

Lijek je zato jedini moguci: praviti manje buildova. `vercel.json` ima
`ignoreCommand` koji pokrece `vercel-preskoci-build.sh`, a ta skripta
gradi samo kad je grana `main` I kad je izmedu proslog objavljenog i
ovog commita dirnuto nesto od `app`, `components`, `lib`, `public`,
`package.json`, `package-lock.json`, `next.config.ts`, `tsconfig.json`,
`postcss.config.mjs`, `eslint.config.mjs`, `next-env.d.ts`, `proxy.ts`,
`vercel.json` i same skripte.

Skripta vraca iskljucivo 0 (preskoci) ili 1 (gradi), jer Vercel druge
kodove ne priznaje, i svaka nejasnoca zavrsava gradnjom: preskocen build
ostavlja zadnju objavljenu verziju na zraku, a propusten build znaci
zastarjelu stranicu, sto je gore.

Time se gubi preview build na radnoj grani, koji je bio mreza za greske
tipova. Nadoknaduje ga pravilo 3 (prije svakog pusha `npm run build`), a
i kad bi nesto proslo, Vercel pri padu ostavlja zadnju ispravnu verziju.
Gasi se brisanjem `vercel.json`.

Prvi pokusaj je pao jer je cijela naredba bila upisana u `vercel.json`:
`ignoreCommand` smije imati najvise 256 znakova, a imala je oko 330.
Poruka Vercela je to rekla doslovno. Otud i skripta.

Pouka sire od ovog slucaja: kad brojka na tudjem sustavu ne reagira na
ono sto radis, prvo pogledaj na koje se RAZDOBLJE odnosi, pa tek onda
trazi uzrok u svom radu.

**Vercel ima DVA ograničenja i ne miješaju se.** Deployment Storage
troši GRADNJA, a Fluid Active CPU troši POSLUŽIVANJE stranica
posjetiteljima. Kad stigne obavijest, prvo se pročita koje je od ta dva,
jer lijek nema ništa zajedničko. Skripta `vercel-preskoci-build.sh`
pomaže samo kod prvoga.

13.09.2026. je stigla obavijest o 75 posto potrošenih besplatnih četiri
sata Fluid Active CPU, a pri sto posto Vercel zaustavlja projekt.
Observability je za dvanaest sati pokazao 2800 zahtjeva, 1700 pokretanja
funkcija i 2400 pokretanja middlewarea. Stotinjak tisuća renderiranja
mjesečno, uz desetinku sekunde procesora po komadu, daje upravo ta tri
sata.

Uzroci su bila dva, oba glupa:

- `revalidate = 0` na stranici članka. Nula znači "nikad ne keširaj", pa
  se svako otvaranje renderiralo iznova. Ta je stranica jedina koja NE
  čita parametre iz adrese, dakle nula ju je jedina držala dinamičnom, a
  ujedno je to stranica koja se dijeli na Facebooku i dobiva tisuće
  otvaranja u nekoliko sati. Sada je 60 sekundi. Novi članak se i dalje
  pojavljuje odmah, jer njegov slug nije u popisu unaprijed pripremljenih
  stranica; tih 60 sekundi tiče se samo izmjena već objavljenog članka i
  odgovora "nije pronađeno" ako netko adresu otvori prije objave.
- `proxy.ts`, koji je preusmjeravao staru vercel.app adresu. Pokretao se
  na gotovo svakom zahtjevu da bi u svim slučajevima osim jednoga ne
  napravio ništa. Isto preusmjeravanje sada stoji u `next.config.ts` među
  `redirects`, uz uvjet `has: [{ type: "host", ... }]`, pa ga rješava
  Vercelov usmjerivač bez ijednog pokretanja funkcije. Provjereno nakon
  objave: stara adresa i dalje vodi na domenu.

Uz to su produljeni intervali ondje gdje se podaci mijenjaju najviše
dvaput dnevno, koliko puta ide scraper: naslovnica 15 minuta, stranica
utakmice i stranica igrača sat vremena. Tih zadnjih je najviše
(nekoliko stotina utakmica i nekoliko tisuća igrača), sve su u sitemapu
i tražilice ih redom obilaze.

Dvije pouke šire od ovog slučaja:

- ISPIS `npm run build` KAŽE ŠTO SE RENDERIRA. Oznaka `ƒ` znači da se
  stranica renderira pri svakom otvaranju, `○` i `●` da je gotova
  unaprijed. To je najjeftinija provjera i radi se prije objave, ne
  poslije računa.
- STRANICA KOJA ČITA `searchParams` JE UVIJEK DINAMIČNA, koliko god
  `revalidate` bio. Zato `/liga/[slug]` i `/novosti` i dalje stoje na
  `ƒ`: čitaju `kolo`, `sezonu` i `ligu` iz adrese. Ako potrošnja ikad
  opet naraste, ondje se traži dalje, a lijek nije brojka nego
  preseljenje biranja kola u preglednik.

**Od 19.09.2026. projekt je na Vercelovom Pro planu.**
Andrej ga je kupio za 25 eura mjesečno (dvadeset dolara plus hrvatski
PDV), svojom odlukom, da ne mora pratiti brojke usred vikenda i da se
nove mogućnosti ne vagaju prema minutama procesora.

Što se time NE mijenja:

- Sve izmjene odozgo ostaju. Naslovnica je na 30 minuta, stranica članka
  na 180 sekundi, stranica utakmice i kluba na sat, stranica igrača i
  sitemap na dan. Te su brojke i bez ograničenja razumne, jer scraper
  ide najviše dvaput dnevno.

  PROMIJENJENO 25.09.2026., na Andrejev zahtjev: naslovnica, stranica
  utakmice i stranica kluba na 5 minuta, članak na 60 sekundi, igrač na
  sat, sitemap ostaje na dan. Razlog nije scraper nego RUČNE izmjene iz
  SQL Editora (derbi, sažetak uz zapisnik, obrisan termin odgođene
  utakmice): Andrej ih pokrene i očekuje da se vide odmah, a naslovnica
  ih je pokazivala tek nakon pola sata, pa je izgledalo da upit nije
  prošao. Oznaka derbija Kraljevica - Krk bila je povod. Potrošnja se
  prati na nadolazećem računu (Settings, Billing, Invoices); ako ikad
  naraste, prvo se produlji stranica utakmice i igrača, jer njih
  tražilice obilaze u tisućama.
- `vercel-preskoci-build.sh` ostaje. Manje buildova je uredno samo po
  sebi i čuva povijest objava preglednom.
- Pravilo 3 i dalje vrijedi: prije svakog pusha `npm run build`.
- Ispis buildova se i dalje čita. Oznaka `ƒ` i dalje znači renderiranje
  pri svakom otvaranju i dalje je to podatak, samo više nije alarm.

Što se mijenja: `/liga/[slug]` više nije hitan slučaj. Preseljenje
biranja kola u preglednik ostaje dobra ideja, ali se radi kad dođe na
red, a ne pod pritiskom.

Brojke pri kupnji, da se zna od čega se krenulo: Fluid Active CPU 3h31
od besplatnih 4h, Deployment Storage 10,92 GB od 10 GB, ISR Writes 111K
od 200K, sve mjereno kroz prozor od trideset dana.

**Upozorenje ne nestaje čim se plati.** Istog dana, nekoliko sati nakon
kupnje, na Usage stranici je i dalje stajalo 3h33 od 4h, pa je
izgledalo da plaćanje nije primljeno. Bilo je primljeno.

Dvije stvari otud, obje se provjeravaju tim redom:

- PLAN IDE UZ SCOPE (TIM), NE UZ PROJEKT. Gore lijevo, pokraj imena
  scopea, stoji oznaka plana. Kod nas ondje piše MakiLFC i Pro, a
  projekt je unutar tog scopea, pa je sve na svom mjestu. Kad bi ondje
  pisalo Hobby, značilo bi da je Pro kupljen na drugom scopeu, a projekt
  ostao na besplatnom. To je česta zamka i prvo što treba pogledati.
- BROJKA I DALJE MJERI PROZOR OD TRIDESET DANA, pa u sebi nosi i ono
  potrošeno dok je plan bio Hobby. Ne pada zbog plaćanja, nego kad skupi
  dani ispadnu iz prozora, dakle od 27.09. nadalje. Isto je bilo i s
  Deployment Storageom, gdje ni brisanje deploymenata nije pomaknulo
  brojku.

Uz to, na Pro planu onih 4 sata više nisu zid. Potrošnja se vuče iz
mjesečnog kredita koji pokriva sve resurse zajedno, a preko njega se
naplaćuje po potrošnji. Sto posto zaustavlja projekt samo na Hobbyju.

Isti dan je zbunilo i to što banka nije provela transakciju i što nije
stigla potvrda e-poštom, pa je izgledalo da kupnja nije ni prošla.
Razriješila ju je stranica Settings, Billing, Invoices, i to je mjesto
na koje se ide odmah kad se sumnja u plan:

```
September 2026: Monthly Pro Plan
Total Due $20.00   [Upcoming Payment]
This invoice will continue updating until the end of your
billing period on October 19.
```

Račun je NADOLAZEĆI i naplaćuje se na kraju obračunskog razdoblja, dakle
19. listopada. Tek tada stiže i teret na kartici i potvrda e-poštom.
Izostanak jednog i drugog u danu kupnje nije znak da nešto nije u redu.
Razlika između dvadeset dolara na računu i 25 eura viđenih pri kupnji je
PDV.

Na istom računu stoji i potrošnja od kupnje naovamo, dakle mjerena po
Pro uvjetima: 189 zahtjeva, 927 pokretanja funkcija, 630 milisekundi
dodatnog procesora, ukupno dva centa i to pokriveno kreditom. To je
prava mjera koliko stranica košta. Kartica Usage na naslovnici scopea i
dalje gleda unatrag kroz trideset dana i miješa Hobby razdoblje, pa
zbunjuje. Kad treba stvarna slika, gleda se nadolazeći račun, ne ona
kartica.

Pouka je ista kao kod Deployment Storagea: kad brojka na tuđem sustavu
ne reagira na ono što si napravio, prvo se pogleda na koje se RAZDOBLJE
odnosi, pa tek onda traži uzrok.

**U CSS-u svi `@import` moraju biti prije `@import "tailwindcss"`.**
Tailwind se razmota u stotine redaka i svaki `@import` iza njega ruši build.

---

## Dizajn

Paleta **"Lučka"** — riječka lučko-industrijska scena, ne generički zeleni
travnjak. Sve boje su CSS varijable u `globals.css`:

- `--pitch` `#0d3b40` duboka petrolej-tirkizna (glavna)
- `--chalk` `#dde2db` kamena podloga
- `--paper` `#f7faf6` kartice
- `--oxide` `#b5502a` hrđa (naglasak, koristi se štedljivo)
- `--oxide-light` `#e08a55` hrđa za tamne podloge
- `--card-yellow` / `--card-red` kartoni

Tipografija: **Archivo** (naslovi, težina 800, stisnut razmak), **Inter**
(tekst), **JetBrains Mono** (brojke), **Playfair Display italic** samo za
jednu naglašenu riječ u velikom naslovu (klasa `.naglasak`).

Potpisi stranice: grb = mini teren s kožnom loptom (`Grb.tsx`, lopta pada
1,8 s nakon učitavanja), animirani naslov Lokal–Arena, rezultat kao pločica
semafora (`.semafor`), nadnaslovi sekcija (`.oznaka-sekcije`), otkrivanje
sadržaja pri skrolanju (`Otkrivanje.tsx`), brojke koje se odbroje
(`Brojka.tsx`).

**Ikone moraju biti čitljive na 11–14 px** — pune plohe i jak kontrast.
Tanki potezi ispod ~1 px se na telefonima izglade i ikona postane kružić.

Prije promjena izgleda provjeri kontrast. Ranije su kartica i podloga imale
omjer 1,02 (praktički ista boja), pa je sve djelovalo plošno.

---

## Sezone

HNS svake sezone generira NOVE ID-jeve natjecanja (slug završava npr. `-2627`).
Prijelaz na novu sezonu:

1. semafor.hns.family → **Sezona: 2026/27 (ovo prvo!)** → Razina → Natjecanje → Traži
2. provjeri da su na stranici naši klubovi
3. upiši u `NATJECANJA` i `SEZONA` u `scraper_supabase.py`
4. promijeni sezonu u `derbi_tjedni_predlozak.sql`
5. ažuriraj `natjecanja.json`

Stara sezona ostaje u bazi. Naslovnica sama prepoznaje najnoviju sezonu i
broji samo odigrane utakmice, a stranica lige nudi birač sezona.

**Stanje 27.08.2026.:** sve četiri lige upisane su u scraper za 26/27.
3. NL Zapad (`114647051`, 15 kola) i 4. NL NS Rijeka (`114651788`, 13 kola)
imaju cijeli raspored u bazi, prvo kolo 3. NL 29.08.2026., a 4. NL
04.09.2026. Bilo je 211 utakmica; od 03.09.2026. ih je 198, jer je NK
Novalja napustila 4. NL NS Rijeka i njezinih 13 utakmica je obrisano.
Županijske su objavljene 27.08.2026.: 1. ŽNL PGŽ (`115499925`, 14 klubova)
i 2. ŽNL PGŽ (`115502657`, 6 klubova). Popisi klubova stoje u
`natjecanja.json` i po njima se natjecanje potvrđuje.

Migracija baze (`raspored_migracija.sql`) vrijedi za cijelu tablicu i ne
ponavlja se.

---

## U planu

Dogovoreno 19.09.2026., ovim redoslijedom. Prve dvije stvari idu čim se
Andrej vrati s puta, u četvrtak ili petak.

**1. Klik na rezultat na naslovnici.** Sada je klikabilan samo derbi, i
to vodi na kolo na stranici lige. Svaki redak rezultata treba voditi
izravno na stranicu TE utakmice, gdje već stoji zapisnik s postavama.
To je bolje od vođenja na ligu, jer ne traži drugo traženje. Posao je
mali i ne košta ništa, jer je stranica utakmice pripremljena unaprijed.

**2. Imena igrača u postavama kao poveznice.** `PoveznicaIgraca` već
postoji, ali se u `components/Postava.tsx` ime ispisuje kao običan
tekst. Stranicu ima gotovo svaki igrač, jer se popis gradi i iz rang
liste nastupa (250 do 500 imena po ligi). VAŽNO: ime se pretvara u
poveznicu samo kad stranica stvarno postoji, inače ostaje običan tekst.
Bez te provjere se s vremenom nakupe mrtve poveznice, jer se igrač
prepoznaje po imenu.

**3. Tražilica na naslovnici**, za igrače i klubove. Popis se priprema
pri gradnji kao jedna datoteka, a pretraživanje ide u pregledniku, pa
ne troši ništa na poslužitelju. Datoteka je stotinjak kilobajta, pa se
učitava tek kad korisnik klikne u polje, ne odmah s naslovnicom.

**4. Momčad kola, ponedjeljkom.** Izvedivo, ali NE automatski. U bazi
nema ocjena igrača, obrana ni asistencija, pa računalo ne može znati
tko je bio najbolji; automatski izbor bi bio popis strijelaca
pobjedničkih momčadi, što nije isto. Zato se radi ovako: iz podataka se
pripremi popis KANDIDATA (strijelci kola, vratari momčadi bez
primljenog gola, igrači pobjedničkih momčadi, isključeni otpadaju),
Andrej odabere jedanaestoricu, a stranica ih prikaže na terenu u
formaciji, s grbovima i poveznicama na igrače. Ovo je jedini od četiri
zahvata koji traži novu tablicu u bazi.

NOVA TABLICA TREBA GRANT. Supabase je 23.09.2026. javio e-poštom da od
30.10.2026. nove tablice u shemi `public` više ne dobivaju pristup
preko Data API-ja sami od sebe. Postojeće tablice ostaju kakve jesu.
Bez `grant` naredbe stranica i scraper novu tablicu ne vide (API vraća
"permission denied"). Zato u ISTU datoteku koja stvara tablicu ide i:

```
grant select on public.<tablica> to anon, authenticated;
grant select, insert, update, delete on public.<tablica> to service_role;
```

Primjer iz Supabaseova maila daje i `insert, update, delete` ulozi
`authenticated`. To se kod nas namjerno NE radi: na stranicu se nitko
ne prijavljuje, upis ide samo kroz SQL Editor ili scraper
(`service_role`), pa pravo pisanja ne treba otvarati nikome drugom.
Uz grant ide i RLS s politikom samo za čitanje, kao kod `clanci`.

Nijedna od ove četiri stvari nije tražila Pro plan. Zapisano da se
kasnije ne pomiješa: Pro je kupljen radi mira, a ne zato što se ovo
drukčije ne bi dalo napraviti.

- Proširenje na druge lokalne sportove

Trofej Terzić-Strukan (ljestvica strijelaca svih liga) više nije u planu;
Andrej ga je 24.08.2026. skinuo s popisa. Ne predlagati ga ponovno.

**Veće izmjene se ne objavljuju subotom i nedjeljom**, dok se igra.
Ponedjeljak ili utorak, da eventualna greška ne padne usred kola.

## Pisanje najava i pregleda

**Nova sezona je zanimljivija od prošle.** Do 07.09.2026. su najave bile
pretrpane međusobnim ogledima iz prošle sezone. Andrej je tražio obrnuto:
težište je na dosadašnjim rezultatima momčadi u tekućoj sezoni, a
prošlosezonski susreti se spominju samo kad stvarno nešto govore. Ne mora
biti riječ o međusobnim ogledima.

**Najava gleda UNAPRIJED, ne prepričava prošlo kolo.** 25.09.2026.
Andrej je prvu verziju najave 4. kola 1. ŽNL vratio s napomenom da
odlomci "ispadaju kao pregled a ne najava": svaki je počinjao nizanjem
rezultata i strijelaca iz prošlog kola. Prepisana verzija je prošla uz
"takve najave piši i ubuduće u tom stilu". Kako izgleda:

- Odlomak počinje onim što je NA KOCKI u tom susretu: što pobjeda znači
  za poredak ("pobjedom bi preskočio gosta", "može pobjeći na pet
  bodova", "izravan dvoboj za gornju polovicu").
- Forma se daje kao UČINAK KOD KUĆE ILI U GOSTIMA, izračunat iz rezultata
  sezone ("na Gradskom stadionu ove sezone ne gubi: dvije utakmice, dvije
  pobjede, uz gol razliku 6:1", "jedinu pobjedu upisala je upravo u
  gostima"). To je aritmetika nad bazom, ne procjena.
- Prošlo kolo ide najviše jednom rečenicom, i to kao povod ("dolazi
  nabrijan nakon prve pobjede, izborene u trećoj minuti nadoknade").
- Kad netko ne igra (slobodan, odgođeno), kaže se što to znači za
  ostale ("dok Rab ovaj vikend ne igra").
- I dalje vrijedi pravilo 5: ništa što nije u bazi ili od Andreja.
- Precizno kod usporedbi: dva kluba s istim brojem pobjeda nisu "isti"
  ako jedan ima bod više, pa se to kaže ("po jednu pobjedu, a Risnjak
  bod više").

Primjer je `sql/najava_4_kola_1_znl_2627.sql`.

**Vodeći strijelac iz `najava_kola()` nije cijela slika.** Ta funkcija po
klubu vraća SAMO JEDNOG igrača, onog s najviše pogodaka. Kraljevica je
07.09.2026. imala trojicu s po dva pogotka (Znamenaček, Bosančić,
Čabrijan), a najava je spomenula samo prvoga, pa je ispalo neprecizno.
Puni popis strijelaca po klubu stoji u `pregled_kola()`, u polju
`strijelci.poredak`, i odande se uzima.

Iz istog razloga se ne tvrdi da je netko "jedini strijelac" kluba: najava
o tome nema podatak.

**Polje `suspendirani` u `najava_kola()` je uvijek prazno.** Funkcija
gleda unaprijed i ne može znati isključenja. Isključeni igrači za sljedeće
kolo dolaze iz `pregled_kola()` prošlog kola, iz
`posljedice_za_sljedece_kolo`.

**U ligi s neparnim brojem klubova reci tko je slobodan.** Otkad je NK
Novalja napustila 4. NL NS Rijeka, ostalo je trinaest klubova, pa svako
kolo jedan ne igra. Najava 2. kola 2026/27 to nije spomenula, iako je
Otoččevo slobodno prvo kolo bilo tema. Slobodan klub se vidi tako da se
iz popisa klubova lige izbaci onih dvanaest koji su na rasporedu tog
kola. U 2. kolu je slobodan bio NK Žminj.

**Ne piše se "žuto-crveni karton".** Taj izraz Andrej ne koristi; kaže
da ne postoji. Drugi žuti karton opisuje se onako kako se i govori:
"nakon drugog žutog kartona" ili "igrač je isključen". Funkcija
`pregled_kola()` u polju `crveni_kartoni` vraća vrstu "žuto-crveni
karton", ali to je oznaka u podacima, a ne tekst za stranicu, pa se pri
pisanju prevodi.

**Žuti kartoni po pojedinoj utakmici ne izlaze iz `pregled_kola()`.**
Ona vraća samo isključenja, a žute daje kao zbroj za cijelu sezonu, u
`statistike`. Za sažetak jedne utakmice čitaju se iz postava, upitom nad
`postava_domacin` i `postava_gost` (primjer stoji na dnu datoteke
`sql/sazetak_vrbovsko_goranin_2_kolo.sql`).

**Prag žutih kartona u 3. NL Zapad je četiri.** Andrej je to potvrdio
24.09.2026. Funkcije `najava_kola()` i `pregled_kola()` i prije su
računale s četiri, ali kao zadanom vrijednošću, pa se u tekstovima pisao
samo broj kartona, bez posljedice. Za 3. NL Zapad sada se piše izravno:
četvrti žuti znači pauzu u sljedećem prvenstvenom kolu, a tri znači
"jedan od kazne". Za ostale tri lige prag još nije potvrđen, pa ondje i
dalje stoji samo broj. Pazi i na to da polje `na_pragu` u
`pregled_kola()` pokazuje samo igrače s TRI žuta; oni koji su baš u tom
kolu dobili četvrti ne ulaze ni u `na_pragu` ni u `suspendirani`, pa ih
treba naći usporedbom s prošlom najavom ili pregledom.

**Sažetak uz zapisnik NIJE članak.** Kratak osvrt na pojedinu utakmicu,
onaj koji stoji ispod zapisnika na stranici utakmice, ide u stupac
`utakmice.tekst_clanka`, dakle u redak te utakmice. Tablica `clanci` je
za novosti, koje imaju svoju stranicu i karticu. Ovo je 13.09.2026.
jednom već zamijenjeno, pa je osvrt na derbi bio napisan kao zaseban
članak umjesto kao sažetak uz utakmicu.

**Nemoj pisati "klubovi se u našoj bazi dosad nisu sastali".** Čitatelja
naša baza ne zanima. Kad međusobnih susreta nema, o njima se jednostavno
ne piše, ili se, ako je klub nov u rangu, to kaže kao vijest.

## Stil rada s korisnikom

Andrej nije programer. Objašnjavaj bez žargona i uvijek reci **u koju točno
mapu ide koja datoteka** (tri različite datoteke se zovu `page.tsx`).
Kad nešto ne radi, prvo dijagnosticiraj pa tek onda mijenjaj — nekoliko puta
se dogodilo da je "popravak" bez dijagnoze pokvario drugu stvar.

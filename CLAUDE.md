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
    rang-liste) petkom, subotom i nedjeljom navečer, ponedjeljkom ujutro
    i srijedom navečer (petkom jer se dio kola igra u petak, srijedom
    zbog utakmica zakazanih sredinom tjedna)
  - `.github/workflows/termini.yml` (samo termini s rasporeda) svaki dan
    ujutro i poslijepodne; kad je koja utakmica premještena, otvori issue
    na GitHubu, pa o tome stigne e-pošta
  - `.github/workflows/provjere.yml` (pyflakes i testovi koji ne diraju
    internet ni bazu) na svaki push i pull request
  - `.github/workflows/slika.yml` ("Izreži sliku") samo ručno, kad
    fotografiju treba izrezati i sažeti prije nego ode na stranicu

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
  pokušava tri puta, s pauzom 5 pa 10 sekundi. Tek ako ni treći put ne
  uspije, greška ide dalje. Čuva `test_ponavljanje.py`.
- Liga čija se stranica ne može pročitati ispada iz tog prolaza, ali
  ostale se svejedno obrade. Greška se broji i pokretanje na kraju
  svejedno završava crveno, jer podatak stvarno nedostaje.

Lažno crveno je skupo: obavijest koju se nauči preskakati ne vrijedi
ništa. Zato se ponavlja prije nego se prijavi, ali se i dalje prijavljuje.

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

- Proširenje na druge lokalne sportove

Trofej Terzić-Strukan (ljestvica strijelaca svih liga) više nije u planu;
Andrej ga je 24.08.2026. skinuo s popisa. Ne predlagati ga ponovno.

## Stil rada s korisnikom

Andrej nije programer. Objašnjavaj bez žargona i uvijek reci **u koju točno
mapu ide koja datoteka** (tri različite datoteke se zovu `page.tsx`).
Kad nešto ne radi, prvo dijagnosticiraj pa tek onda mijenjaj — nekoliko puta
se dogodilo da je "popravak" bez dijagnoze pokvario drugu stvar.

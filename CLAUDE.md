# Lokal-Arena

Stranica s rezultatima nižih nogometnih liga na prostoru Primorsko-goranske
županije. Radi je jedna osoba (Andrej), nije komercijalni projekt.

Javno: lokalarena.com (hosting Vercel). Stara adresa
istra-pgz-nogomet.vercel.app trajno se preusmjerava preko `middleware.ts`.
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
- **Automatizacija:** GitHub Actions (`.github/workflows/scraper.yml`),
  pokreće se subotom i nedjeljom navečer te ponedjeljkom ujutro

## Struktura

```
app/
  layout.tsx            fontovi (next/font), metadata
  globals.css           paleta, animacije, tipografija
  icon.svg              favicon
  page.tsx              naslovnica (hero + rezultati + lijevi stupac)
  liga/[slug]/page.tsx  stranica lige (kola, utakmice, bočni stupac)
  novosti/page.tsx      popis članaka
  novosti/[slug]/page.tsx  pojedini članak
components/
  Navigacija, Grb, Hero, PregledKola, SidebarLiga, Postava,
  KarticaClanka, Ikone, Brojka, Otkrivanje, IzvorPodataka
lib/
  supabase.ts  lige.ts  kolo.ts  statistike.ts  clanci.ts
scraper_supabase.py     glavni scraper
natjecanja.json         referenca ID-jeva natjecanja po sezonama
derbi_tjedni_predlozak.sql  SQL predložak za tjedno označavanje derbija
raspored_migracija.sql  jednokratna migracija (već pokrenuta 08/2026)
```

## Tablice u Supabaseu

- **`utakmice`** — jedan redak po utakmici, odigranoj i neodigranoj.
  Ključ za upsert: (`natjecanje`, `sezona`, `kolo`, `domacin`, `gost`).
  Polja koja scraper NE dira: `derbi`, `tekst_clanka`, `slika_url`
  (to su korisnikovi unosi i moraju preživjeti svako osvježavanje).
  `datum` / `vrijeme` / `stadion` dolaze s retka rasporeda i postoje i
  prije odigravanja; `stadion_datum` se puni tek iz zapisnika.
- **`statistike`** — tablica/strijelci/kartoni po ligi i sezoni (`jsonb`).
  Jedinstveno po (`sezona`, `natjecanje`, `tip`).
- **`clanci`** — novosti. Vidljivi su samo oni s `objavljen = true` (RLS).

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

**Stanje 13.08.2026.:** 3. NL Zapad (`114647051`, 15 kola) i 4. NL NS Rijeka
(`114651788`, 13 kola) objavljene za 26/27 i cijeli raspored je u bazi —
211 utakmica, prvo kolo 29.08.2026. Županijske (1. i 2. ŽNL PGŽ) još nisu
objavljene; NS PGŽ ih unosi kasnije, u scraperu stoje zakomentirane.

Kad se pojave, uz korake gore pokreni scraper — migracija baze
(`raspored_migracija.sql`) vrijedi za cijelu tablicu i ne ponavlja se.

---

## U planu

- Trofej Terzić-Strukan (ljestvica strijelaca svih liga) — čeka dopuštenje
  osobe koja je vodi
- Proširenje na druge lokalne sportove

## Otvoreno, podsjeti Andreja

**Od ponedjeljka 24.08.2026.: provjeriti da dvojnici u rasporedu više ne
nastaju.** Vikend 22. i 23.08. prvo je pokretanje scrapera s popravljenim
prekidom parsiranja. Kola se tad ne igraju, pa novih rezultata neće biti,
ali će scraper svejedno proći raspored. Kad Andrej sljedeći put radi na
projektu, podsjeti ga da u Supabaseu pokrene:

```sql
select natjecanje, kolo, count(*) as redaka
from public.utakmice
where sezona = '2026/27'
group by natjecanje, kolo
order by natjecanje, kolo;
```

Mora biti 8 redaka po kolu za 3. NL Zapad i 7 za 4. NL NS Rijeka. Ako
negdje bude više, popravak nije uhvatio sve i vraćamo se na parsiranje.
Kad se potvrdi da je uredu, obriši ovaj odjeljak.

## Stil rada s korisnikom

Andrej nije programer. Objašnjavaj bez žargona i uvijek reci **u koju točno
mapu ide koja datoteka** (tri različite datoteke se zovu `page.tsx`).
Kad nešto ne radi, prvo dijagnosticiraj pa tek onda mijenjaj — nekoliko puta
se dogodilo da je "popravak" bez dijagnoze pokvario drugu stvar.

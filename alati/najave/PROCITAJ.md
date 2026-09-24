# Slike najava kola

Predložak kojim se rade naslovne slike za članke "NAJAVA n. KOLA".
Gotove slike stoje u `public/slike/najave/`, a u članak se stavljaju
upisom putanje u polje `slika_url` tablice `clanci`.

U upotrebi je stil **ploca**: tamna ploča s rasporedom cijelog kola u
dva stupca, imena klubova u Playfair kurzivu, derbi kola označen žutom.

Od 6. kola 3. NL Zapad 2026/27 postoji i stil **stitovi**: jedan par po
retku, satnica lijevo, domaćin sa svojim štitom lijevo, gost sa svojim
desno, kao raspored na Semaforu. Kolo ga dobije upisom `"stil": "stitovi"`
u `kola.json`, a svaki par tada nosi i svoj `termin` (npr. "SUB 16:30").
Kolo bez polja `stil` crta se kao ploča.

U predlošku stoji i treći stil, **horizont** (kvarnerski obzor kao na
zaglavljima liga). Ne koristi se, ali je ostavljen ako zatreba: dopuni
popis `stilovi` u `generiraj.mjs`.

## Grbovi klubova

Pravi klupski grbovi se NE koriste. Nisu dio dopuštenja koje je HNS dao
za prikaz podataka, a i sami su tuđi znakovi. Ako klub sam pošalje svoj
grb i dopusti korištenje, to se rješava zasebno. Do tada u slici stoje
samo imena klubova.

Stil **stitovi** zato ne koristi grbove nego jednostavan štit u bojama
kluba, s troslovnom oznakom. Boje i uzorak po klubu stoje u
`klubovi.json` (uzorci: puno, glava, koso, okomito, pojas). Klub kojeg
ondje nema dobije neutralan štit u boji stranice, pa slika ne pada.

## Kako pokrenuti

```
npm install --no-save playwright sharp @fontsource/archivo @fontsource/inter \
  @fontsource/jetbrains-mono @fontsource/playfair-display
```

Fontove kopiraj u mapu `fonts/` pokraj ove datoteke (`.woff2` iz
`node_modules/@fontsource/...`). Poslužitelj se diže u mapi `alati`,
jedan katalog više, jer odande fontove uzima i alat za transfere:

```
cd alati
python3 -m http.server 8099
```

Pa u drugom prozoru:

```
cd alati/najave
node generiraj.mjs
```

Slike izlaze u `izlaz/`. Sažmi ih prije nego ih preseliš u `public`:
`sharp(put).png({ palette: true, colours: 160 })` (oko 70% manje).

## Što se gdje mijenja

- parovi, datum, oznaka lige i derbi kola: `kola.json`
- izgled, boje, raspored: `najava.html`
- koji se stil crta: polje `stil` uz kolo u `kola.json`
- boje štitova: `klubovi.json`
- samo jedno kolo: `node generiraj.mjs 3-nl-zapad-kolo-6`

Za novo kolo dopuni `kola.json` novim unosom (`dat` je ime datoteke) i
pokreni skriptu iznova.

# Slike najava kola

Predložak kojim se rade naslovne slike za članke "NAJAVA n. KOLA".
Gotove slike stoje u `public/slike/najave/`, a u članak se stavljaju
upisom putanje u polje `slika_url` tablice `clanci`.

Dva stila, isti podaci:

- **ploca** — tamna ploča s rasporedom cijelog kola, svi parovi u mreži,
  derbi kola označen žutom. Informativna, čita se kao semafor.
- **horizont** — kvarnerski obzor (isti krajolik kao zaglavlja liga),
  a uz donji rub niz pločica sa svim klubovima kola. Atmosferska.

## Grbovi klubova

Pravi klupski grbovi se NE koriste. Nisu dio dopuštenja koje je HNS dao
za prikaz podataka, a i sami su tuđi znakovi. Umjesto njih se crtaju
pločice s troslovnom kraticom kluba, u bojama stranice. Ako klub sam
pošalje svoj grb i dopusti korištenje, to se rješava zasebno.

## Kako pokrenuti

```
npm install --no-save playwright sharp @fontsource/archivo @fontsource/inter \
  @fontsource/jetbrains-mono @fontsource/playfair-display
```

Fontove kopiraj u mapu `fonts/` pokraj ove datoteke (`.woff2` iz
`node_modules/@fontsource/...`), zatim u ovoj mapi:

```
python3 -m http.server 8099
node generiraj.mjs
```

Slike izlaze u `izlaz/`. Sažmi ih prije nego ih preseliš u `public`:
`sharp(put).png({ palette: true, colours: 160 })` (oko 70% manje).

## Što se gdje mijenja

- parovi, datum, oznaka lige i derbi kola: `kola.json`
- izgled, boje, raspored: `najava.html`
- koji se stilovi crtaju: popis `stilovi` u `generiraj.mjs`

Za novo kolo dopuni `kola.json` novim unosom (`dat` je ime datoteke) i
pokreni skriptu iznova.

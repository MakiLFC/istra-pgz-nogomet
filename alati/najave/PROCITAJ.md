# Slike najava kola

Predložak kojim se rade naslovne slike za članke "NAJAVA n. KOLA".
Gotove slike stoje u `public/slike/najave/`, a u članak se stavljaju
upisom putanje u polje `slika_url` tablice `clanci`.

U upotrebi je stil **ploca**: tamna ploča s rasporedom cijelog kola u
dva stupca, imena klubova u Playfair kurzivu, derbi kola označen žutom.

U predlošku stoji i drugi stil, **horizont** (kvarnerski obzor kao na
zaglavljima liga). Ne koristi se, ali je ostavljen ako zatreba: dopuni
popis `stilovi` u `generiraj.mjs`.

## Grbovi klubova

Pravi klupski grbovi se NE koriste. Nisu dio dopuštenja koje je HNS dao
za prikaz podataka, a i sami su tuđi znakovi. Ako klub sam pošalje svoj
grb i dopusti korištenje, to se rješava zasebno. Do tada u slici stoje
samo imena klubova.

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
- koji se stilovi crtaju: popis `stilovi` u `generiraj.mjs`

Za novo kolo dopuni `kola.json` novim unosom (`dat` je ime datoteke) i
pokreni skriptu iznova.

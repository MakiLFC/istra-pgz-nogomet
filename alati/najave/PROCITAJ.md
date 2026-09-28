# Slike najava kola

Predložak kojim se rade naslovne slike za članke "NAJAVA n. KOLA".
Gotove slike stoje u `public/slike/najave/`, a u članak se stavljaju
upisom putanje u polje `slika_url` tablice `clanci`.

U upotrebi je stil **ploca**: tamna ploča s rasporedom cijelog kola u
dva stupca, imena klubova u Playfair kurzivu, derbi kola označen žutom.

Od 6. kola 3. NL Zapad 2026/27 postoji i stil **redovi**: jedan par po
retku, satnica lijevo, imena klubova složena oko sredine. Kolo ga dobije
upisom `"stil": "redovi"`
u `kola.json`, a svaki par tada nosi i svoj `termin` (npr. "SUB 16:30").
Kolo bez polja `stil` crta se kao ploča.

U predlošku stoji i treći stil, **horizont** (kvarnerski obzor kao na
zaglavljima liga). Ne koristi se, ali je ostavljen ako zatreba: dopuni
popis `stilovi` u `generiraj.mjs`.

## Grbovi klubova

ODLUKA 28.09.2026.: Andrej je odlučio da se pravi grbovi klubova KORISTE,
izričito na svoju odgovornost ("ići ću na svoju odgovornost"), uz vlastitu
obradu: okvir, izbočenje, sjena. Upozoren je da to nije dio dopuštenja
koje je HNS dao i da je izmijenjen grb i dalje znak tog kluba. Grbove
skida `preuzmi_grbove.py` (posao "Grbovi klubova" na GitHubu) u mapu
`grbovi/`. Ispod je zapisano pravilo koje je vrijedilo prije te odluke.

Do 28.09.2026.: pravi klupski grbovi se NE koriste. Nisu dio dopuštenja koje je HNS dao
za prikaz podataka, a i sami su tuđi znakovi. Ako klub sam pošalje svoj
grb i dopusti korištenje, to se rješava zasebno. Do tada u slici stoje
samo imena klubova.

Probani su i štitovi u bojama klubova umjesto grbova (24.09.2026.), ali
su izgledali jeftino i Andrej ih je odbio. Ne predlagati ponovno.

Na njegovo traženje 28.09.2026. napravljen je bolji PRIJEDLOG, zasad samo
na ogledu: `grbovi.js` crta znak kluba s obrubom, sjenčanjem i simbolom
izvedenim iz imena ili mjesta (sidro, kula, grozd...), a boje, oblik i
simbol po klubu stoje u `klubovi.json`. Kolo ga dobije poljem
`"znakovi": true`. Ogled svih znakova radi `ogled-grbova.html`.

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
- samo jedno kolo: `node generiraj.mjs 3-nl-zapad-kolo-6`

Za novo kolo dopuni `kola.json` novim unosom (`dat` je ime datoteke) i
pokreni skriptu iznova.

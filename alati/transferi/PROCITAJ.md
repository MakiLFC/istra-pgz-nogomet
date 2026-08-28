# Naslovne slike za članke o transferima

Predložak kojim se rade naslovne slike za članke o prijelaznom roku.
Gotove slike stoje u `public/slike/`, a u članak se stavljaju upisom
putanje u polje `slika_url` tablice `clanci`.

Izgled je isti kao na prve dvije takve slike iz kolovoza 2026.
(`transferi-3-nl-zapad.png`, `transferi-4-nl-ns-rijeka.png`), koje su
tada rađene ručno: tamna podloga s oznakama terena, naslov lijevo i
dvije kartice desno, zelena za dolaske i crvena za odlaske.

Naslov je NIZ redaka, pa ista slika radi i za jednu ligu i za dvije.
Kod dva retka font se sam smanjuje.

## Grbovi klubova

Isto pravilo kao kod najava kola: pravi klupski grbovi se NE koriste.
Nisu dio dopuštenja koje je HNS dao za prikaz podataka, a i sami su
tuđi znakovi.

## Kako pokrenuti

Fontovi se ne dupliraju, uzimaju se iz `alati/najave/fonts`, pa se
poslužitelj diže u mapi `alati`, ne u ovoj:

```
cd alati
python3 -m http.server 8099
```

Pa u drugom prozoru:

```
cd alati/transferi
node generiraj.mjs
```

Slike izlaze u `izlaz/`, koja se ne sprema u repozitorij. Sažmi ih
prije nego ih preseliš u `public/slike`:

```js
sharp(put).png({ palette: true, colours: 160 })
```

Zadnji put je time 178 KB palo na 63 KB.

## Što se gdje mijenja

- naslov, oznaka i podnaslov: `slike.json`
- izgled, boje, raspored: `transferi.html`

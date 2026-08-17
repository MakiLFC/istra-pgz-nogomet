# Zaglavlja stranica (slike)

Ovdje je predložak kojim su napravljene slike u `public/slike/zaglavlja/`.
Treba ti SAMO kad mijenjaš izgled ili tekst na njima.

**Zašto ovo postoji:** u slike je upisana sezona ("SEZONA 2026/27"), pa ih
za sezonu 2027/28 treba napraviti iznova. Bez predloška bi se crtale ručno.

## Kako pokrenuti

```
npm install --no-save playwright sharp @fontsource/playfair-display @fontsource/inter
node generiraj.mjs
```

Skripta traži fontove u mapi `fonts/` pokraj sebe (kopiraj `.woff2`
datoteke iz `node_modules/@fontsource/...`) i lokalni poslužitelj na
portu 8098 (`python3 -m http.server 8098`).

## Što se gdje mijenja

- tekst i položaj sunca po ligama: popis `set` na vrhu `generiraj.mjs`
- boje, slog i slojevi planina: `zaglavlje.html`
- dva formata (široki za računalo, viši za mobitel): objekt `formati`

Nakon generiranja slike sažmi (oko 70% manje, bez vidljive razlike):
`sharp(put).png({ palette: true, colours: 128 })`.

## Zašto PNG, a ne SVG

Slova u SVG-u trebala bi Playfair, a kad se SVG učita kroz `<img>` ne
vidi fontove stranice pa bi pao na Georgiju. Zato PNG, uz `@2x` inačicu
za ekrane veće gustoće.

// lib/metapodaci.ts — zajedničke vrijednosti za oznake dijeljenja.

/**
 * Zadana slika za dijeljenje na društvenim mrežama (1200x630).
 *
 * PAZI: kad stranica u svojoj metadata definira `openGraph`, ta ZAMJENJUJE
 * onu iz app/layout.tsx, ne nadopunjuje je. Zato svaka stranica koja ima
 * vlastiti `openGraph` mora izričito navesti i sliku, inače se dijeli bez
 * nje. Dogodilo se točno to kad su lige dobile vlastite naslove.
 */
export const SLIKA_DIJELJENJE = {
  url: "/slike/dijeljenje.png",
  width: 1200,
  height: 630,
  alt: "Lokal-Arena, lokalni nogomet Istre i Primorsko-goranske županije",
};

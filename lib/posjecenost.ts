// lib/posjecenost.ts — ljestvica posjećenosti po klubovima.
//
// Broj gledatelja stoji u zapisniku svake odigrane utakmice i dosad se
// nigdje nije koristio. Broji se SAMO na domaćem terenu: gledatelji su
// došli na stadion domaćina, pa se gostu ne pripisuju.
//
// Zapis je tekst i zna biti "Nepoznato" ili prazan, a veći brojevi imaju
// točku kao razdjelnik tisućica ("1.250"). Oboje rješava brojGledatelja
// iz lib/kolo.

import { brojGledatelja } from "@/lib/kolo";
import { kljucKluba } from "@/lib/slug";

export type UtakmicaZaPosjecenost = {
  kolo: number | null;
  domacin: string;
  gost: string;
  gledatelja: string | null;
};

export type RedPosjecenosti = {
  klub: string;
  /** Prosjek po utakmici na domaćem terenu, zaokružen. */
  prosjek: number;
  ukupno: number;
  /** Koliko domaćih utakmica ima upisan broj gledatelja. */
  utakmica: number;
  najbolja: { gledatelja: number; gost: string; kolo: number | null } | null;
};

export type Posjecenost = {
  redci: RedPosjecenosti[];
  /** Prosjek cijele lige po utakmici. */
  prosjekLige: number;
  /** Najposjećenija utakmica lige. */
  vrhunac: {
    gledatelja: number;
    domacin: string;
    gost: string;
    kolo: number | null;
  } | null;
};

export function posjecenostKlubova(
  utakmice: UtakmicaZaPosjecenost[]
): Posjecenost {
  const mapa = new Map<string, RedPosjecenosti>();
  let zbrojLige = 0;
  let brojLige = 0;
  let vrhunac: Posjecenost["vrhunac"] = null;

  for (const u of utakmice) {
    const koliko = brojGledatelja(u.gledatelja);
    // Nula se ne broji: to je zapis "nema podatka", ne prazan stadion.
    if (koliko == null || koliko <= 0) continue;
    const domacin = u.domacin?.trim();
    if (!domacin) continue;

    zbrojLige += koliko;
    brojLige += 1;

    if (!vrhunac || koliko > vrhunac.gledatelja) {
      vrhunac = { gledatelja: koliko, domacin, gost: u.gost, kolo: u.kolo };
    }

    const kljuc = kljucKluba(domacin);
    let red = mapa.get(kljuc);
    if (!red) {
      red = { klub: domacin, prosjek: 0, ukupno: 0, utakmica: 0, najbolja: null };
      mapa.set(kljuc, red);
    }
    red.ukupno += koliko;
    red.utakmica += 1;
    if (!red.najbolja || koliko > red.najbolja.gledatelja) {
      red.najbolja = { gledatelja: koliko, gost: u.gost, kolo: u.kolo };
    }
  }

  const redci = Array.from(mapa.values())
    .map((r) => ({ ...r, prosjek: Math.round(r.ukupno / r.utakmica) }))
    .sort((a, b) => b.prosjek - a.prosjek || b.ukupno - a.ukupno);

  return {
    redci,
    prosjekLige: brojLige ? Math.round(zbrojLige / brojLige) : 0,
    vrhunac,
  };
}

/** 1250 -> "1.250", po hrvatskom zapisu. */
export function brojHr(n: number): string {
  return n.toLocaleString("hr-HR");
}

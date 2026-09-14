// lib/statistike.ts — dohvat tablice/strijelaca/kartona NA POSLUŽITELJU.
// Prije se dohvaćalo u pregledniku (useEffect), pa je bočni stupac
// vidno "uskakao" nakon učitavanja stranice.

import { supabase } from "@/lib/supabase";

export type RedTablice = {
  pozicija: string; klub: string; odigrano: string; pobjede: string;
  remiji: string; porazi: string; golovi_dani: string;
  golovi_primljeni: string; gol_razlika: string; bodovi: string;
};
export type RedStrijelca = { pozicija: string; igrac: string; klub: string; golovi: string };
export type RedKartona = {
  pozicija: string; igrac: string; klub: string; zuti: string; crveni: string;
};
// Nastupi i odigrane minute. Vrijednost može biti prazna, jer stranica
// natjecanja taj podatak ne nudi uvijek.
export type RedNastupa = {
  pozicija: string; igrac: string; klub: string; nastupi: string; minute: string;
};

export type StatistikeLige = {
  tablica: RedTablice[];
  strijelci: RedStrijelca[];
  kartoni: RedKartona[];
  nastupi: RedNastupa[];
};

/** Svi tipovi koje tablica "statistike" poznaje. */
export type TipStatistike = "tablica" | "strijelci" | "kartoni" | "nastupi";

const SVI_TIPOVI: TipStatistike[] = ["tablica", "strijelci", "kartoni", "nastupi"];

/**
 * Dohvaća statistike lige. Bez trećeg argumenta vraća sve, kao i prije.
 *
 * ZAŠTO POSTOJI TREĆI ARGUMENT
 * Redak s tipom "nastupi" je daleko najveći: za 3. NL Zapad ima oko 350
 * igrača u tekućoj i preko 500 u prošloj sezoni. Stranica lige i stranica
 * kluba taj popis NE prikazuju, a ipak su ga dohvaćale i raspakiravale pri
 * svakom otvaranju.
 *
 * To se vidjelo na računu. Vercelov Observability je 14.09.2026. pokazao da
 * su baš te dvije rute najskuplje po procesorskom vremenu, /liga/[slug] na
 * prvom mjestu s velikom razlikom. Sada obje traže samo ono što prikazuju.
 *
 * Ista pouka kao kod naslovnice: performanse dolaze od sužavanja upita.
 */
export async function dohvatiStatistike(
  natjecanje: string,
  sezona: string,
  tipovi: TipStatistike[] = SVI_TIPOVI
): Promise<StatistikeLige> {
  const prazno: StatistikeLige = { tablica: [], strijelci: [], kartoni: [], nastupi: [] };

  const { data, error } = await supabase
    .from("statistike")
    .select("tip, podaci")
    .eq("natjecanje", natjecanje)
    .eq("sezona", sezona)
    .in("tip", tipovi);

  if (error || !data) return prazno;

  const rez = { ...prazno };
  for (const red of data) {
    if (red.tip === "tablica") rez.tablica = red.podaci as RedTablice[];
    if (red.tip === "strijelci") rez.strijelci = red.podaci as RedStrijelca[];
    if (red.tip === "kartoni") rez.kartoni = red.podaci as RedKartona[];
    if (red.tip === "nastupi") rez.nastupi = red.podaci as RedNastupa[];
  }
  return rez;
}

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

export async function dohvatiStatistike(
  natjecanje: string,
  sezona: string
): Promise<StatistikeLige> {
  const prazno: StatistikeLige = { tablica: [], strijelci: [], kartoni: [], nastupi: [] };

  const { data, error } = await supabase
    .from("statistike")
    .select("tip, podaci")
    .eq("natjecanje", natjecanje)
    .eq("sezona", sezona);

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

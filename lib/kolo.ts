// lib/kolo.ts — izračuni za pregled zadnjeg odigranog kola po ligi.
// Čiste funkcije (bez Reacta) da se mogu testirati odvojeno.

export type UtakmicaMin = {
  id?: number | string;
  natjecanje: string;
  kolo: number | null;
  domacin: string;
  gost: string;
  rezultat: string | null;
  gledatelja?: string | null;
  derbi?: boolean | null;
  tekst_clanka?: string | null;
  postava_domacin?: { dogadjaji?: { tip: string }[] }[] | null;
  postava_gost?: { dogadjaji?: { tip: string }[] }[] | null;
};

/** "3:4" -> [3,4]; "?:?" i sve neispravno -> null */
export function golovi(rezultat: string | null | undefined): [number, number] | null {
  if (!rezultat) return null;
  const m = rezultat.match(/^\s*(\d{1,2})\s*:\s*(\d{1,2})\s*$/);
  return m ? [parseInt(m[1], 10), parseInt(m[2], 10)] : null;
}

/** "1.250" / "150 " -> 1250 / 150; "Nepoznato" -> null */
export function brojGledatelja(v: string | null | undefined): number | null {
  if (!v) return null;
  const c = v.replace(/[^\d]/g, "");
  return c ? parseInt(c, 10) : null;
}

/** Zadnje kolo lige u kojem postoji barem jedan upisan rezultat */
export function zadnjeKolo(utakmice: UtakmicaMin[], liga: string): number | null {
  const kola = utakmice
    .filter((u) => u.natjecanje === liga && u.kolo != null && golovi(u.rezultat))
    .map((u) => u.kolo as number);
  return kola.length ? Math.max(...kola) : null;
}

export function utakmiceKola(
  utakmice: UtakmicaMin[],
  liga: string,
  kolo: number | null
): UtakmicaMin[] {
  if (kolo == null) return [];
  return utakmice.filter((u) => u.natjecanje === liga && u.kolo === kolo);
}

function crveniUUtakmici(u: UtakmicaMin): number {
  const svi = [...(u.postava_domacin ?? []), ...(u.postava_gost ?? [])];
  let n = 0;
  for (const igrac of svi)
    for (const d of igrac.dogadjaji ?? [])
      if (d.tip === "karton_crveni" || d.tip === "karton_zutocrveni") n++;
  return n;
}

export type SazetakKola = {
  kolo: number;
  brojUtakmica: number;
  ukupnoGolova: number;
  crveni: number;
  najviseGolova: { u: UtakmicaMin; zbroj: number } | null;
  najuvjerljivija: { u: UtakmicaMin; razlika: number } | null;
};

export function sazetakKola(
  utakmice: UtakmicaMin[],
  liga: string
): SazetakKola | null {
  const kolo = zadnjeKolo(utakmice, liga);
  if (kolo == null) return null;
  const lista = utakmiceKola(utakmice, liga, kolo).filter((u) => golovi(u.rezultat));
  if (!lista.length) return null;

  let ukupno = 0, crveni = 0;
  let najvise: { u: UtakmicaMin; zbroj: number } | null = null;
  let najuvj: { u: UtakmicaMin; razlika: number } | null = null;

  for (const u of lista) {
    const g = golovi(u.rezultat)!;
    const zbroj = g[0] + g[1];
    const razlika = Math.abs(g[0] - g[1]);
    ukupno += zbroj;
    crveni += crveniUUtakmici(u);
    if (!najvise || zbroj > najvise.zbroj) najvise = { u, zbroj };
    if (razlika > 0 && (!najuvj || razlika > najuvj.razlika)) najuvj = { u, razlika };
  }

  return {
    kolo,
    brojUtakmica: lista.length,
    ukupnoGolova: ukupno,
    crveni,
    najviseGolova: najvise,
    najuvjerljivija: najuvj,
  };
}

/** Najposjećenija utakmica zadnjeg kola te lige */
export function najposjecenija(
  utakmice: UtakmicaMin[],
  liga: string
): { u: UtakmicaMin; gledatelja: number } | null {
  const kolo = zadnjeKolo(utakmice, liga);
  let naj: { u: UtakmicaMin; gledatelja: number } | null = null;
  for (const u of utakmiceKola(utakmice, liga, kolo)) {
    if (!golovi(u.rezultat)) continue; // neodigrane ne ulaze u izbor
    const n = brojGledatelja(u.gledatelja);
    if (n != null && (!naj || n > naj.gledatelja)) naj = { u, gledatelja: n };
  }
  return naj;
}

/** Označeni derbi te lige (ako ih je greškom više, uzima prvi) */
export function derbiLige(utakmice: UtakmicaMin[], liga: string): UtakmicaMin | null {
  return utakmice.find((u) => u.natjecanje === liga && u.derbi) ?? null;
}

/** Skrati tekst na cca `granica` znakova, na granici riječi */
export function skrati(tekst: string, granica = 120): string {
  const t = tekst.trim();
  if (t.length <= granica) return t;
  const rez = t.slice(0, granica);
  return rez.slice(0, rez.lastIndexOf(" ")).replace(/[.,;:!?-]$/, "") + "…";
}

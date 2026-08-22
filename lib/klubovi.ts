// lib/klubovi.ts — popis klubova izveden iz tablice "utakmice".
//
// Klubovi nemaju vlastitu tablicu: postoje samo kao imena u stupcima
// "domacin" i "gost". Ovdje se iz njih slaže popis, sa slugom za adresu
// i podatkom u kojim se ligama i sezonama klub pojavljuje.

import { cache } from "react";
import { supabase } from "@/lib/supabase";

export type Klub = {
  /** Dio adrese: /klub/<slug> */
  slug: string;
  /** Ime točno kako stoji u bazi, npr. "NK Jadran-Poreč". */
  naziv: string;
  /** Natjecanja u kojima se klub pojavljuje, najnovije prvo. */
  lige: string[];
  /** Sezone u kojima se klub pojavljuje, najnovija prva. */
  sezone: string[];
  /** Koliko utakmica kluba stoji u bazi (odigranih i neodigranih). */
  brojUtakmica: number;
};

// Slova koja se ne razlažu u osnovno slovo i znak (đ je jedan znak, ne
// d s crticom), pa ih zamjenjujemo ručno.
const POSEBNA: Record<string, string> = { đ: "d", Đ: "d" };

/**
 * "NK Jadran-Poreč" -> "nk-jadran-porec"
 * "OŠK Omišalj"     -> "osk-omisalj"
 * "NK Naprijed (H)" -> "nk-naprijed-h"
 */
export function slugKluba(naziv: string): string {
  return naziv
    .replace(/[đĐ]/g, (z) => POSEBNA[z])
    // NFD razlaže č, ć, ž, š na osnovno slovo i dijakritički znak, koji
    // se onda ukloni.
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

type RedUtakmice = {
  natjecanje: string | null;
  sezona: string | null;
  domacin: string | null;
  gost: string | null;
};

/**
 * Dohvaća sve retke, u komadima po tisuću.
 *
 * Supabase po zadanom vraća najviše tisuću redaka po upitu, a utakmica
 * kroz sve sezone ima i više. Bez ovoga bi popis klubova tiho ostao
 * nepotpun, i to bez ijedne poruke o grešci.
 */
async function sviRedci(): Promise<RedUtakmice[]> {
  const KOMAD = 1000;
  const NAJVISE_KOMADA = 50; // sigurnosna granica, oko 50 tisuća utakmica
  const redci: RedUtakmice[] = [];

  for (let i = 0; i < NAJVISE_KOMADA; i++) {
    const od = i * KOMAD;
    const { data, error } = await supabase
      .from("utakmice")
      .select("natjecanje, sezona, domacin, gost")
      .order("id", { ascending: true })
      .range(od, od + KOMAD - 1);

    if (error) {
      console.error("Klubovi: greška kod dohvaćanja utakmica:", error.message);
      break;
    }
    if (!data?.length) break;

    redci.push(...(data as RedUtakmice[]));
    if (data.length < KOMAD) break;
  }

  return redci;
}

/**
 * Svi klubovi koji se pojavljuju u bazi, poredani po imenu.
 *
 * Omotano u cache() jer se pri iscrtavanju jedne stranice zove dvaput,
 * iz generateMetadata i iz same stranice. Bez toga bi se cijeli popis
 * utakmica dohvaćao dvaput po stranici.
 */
export const dohvatiKlubove = cache(async function dohvatiKlubove(): Promise<Klub[]> {
  let redci: RedUtakmice[];
  try {
    redci = await sviRedci();
  } catch (e) {
    console.error("Klubovi: dohvat nije uspio:", e);
    return [];
  }

  // slug -> klub u nastajanju
  const mapa = new Map<
    string,
    { naziv: string; lige: Set<string>; sezone: Set<string>; broj: number }
  >();

  const dodaj = (naziv: string | null, r: RedUtakmice) => {
    const ime = naziv?.trim();
    if (!ime) return;
    const slug = slugKluba(ime);
    if (!slug) return;

    let klub = mapa.get(slug);
    if (!klub) {
      klub = { naziv: ime, lige: new Set(), sezone: new Set(), broj: 0 };
      mapa.set(slug, klub);
    }
    if (r.natjecanje) klub.lige.add(r.natjecanje);
    if (r.sezona) klub.sezone.add(r.sezona);
    klub.broj += 1;
  };

  for (const r of redci) {
    dodaj(r.domacin, r);
    dodaj(r.gost, r);
  }

  return Array.from(mapa.entries())
    .map(([slug, k]) => ({
      slug,
      naziv: k.naziv,
      lige: Array.from(k.lige).sort(),
      sezone: Array.from(k.sezone).sort().reverse(),
      brojUtakmica: k.broj,
    }))
    .sort((a, b) => a.naziv.localeCompare(b.naziv, "hr"));
});

/** Jedan klub po slugu, ili null ako ga nema. */
export async function dohvatiKlub(slug: string): Promise<Klub | null> {
  const klubovi = await dohvatiKlubove();
  return klubovi.find((k) => k.slug === slug) ?? null;
}

// ---------------------------------------------------------------------
// Utakmice kluba
// ---------------------------------------------------------------------

export type UtakmicaKluba = {
  id: number;
  natjecanje: string;
  sezona: string | null;
  kolo: number | null;
  domacin: string;
  gost: string;
  rezultat: string | null;
  datum: string | null;
  vrijeme: string | null;
  stadion: string | null;
};

const STUPCI =
  "id, natjecanje, sezona, kolo, domacin, gost, rezultat, datum, vrijeme, stadion";

/**
 * Sve utakmice kluba u zadanoj sezoni, odigrane i nadolazeće.
 *
 * Namjerno dva odvojena upita umjesto jednog s "ili": imena klubova
 * sadrže zagrade ("NK Naprijed (H)"), a one u PostgRESTovu "or" filtru
 * imaju posebno značenje i razbile bi upit.
 */
export async function dohvatiUtakmiceKluba(
  naziv: string,
  sezona: string
): Promise<UtakmicaKluba[]> {
  try {
    const upit = (stupac: "domacin" | "gost") =>
      supabase
        .from("utakmice")
        .select(STUPCI)
        .eq(stupac, naziv)
        .eq("sezona", sezona);

    const [doma, vani] = await Promise.all([upit("domacin"), upit("gost")]);

    if (doma.error || vani.error) {
      console.error(
        "Klub: greška kod dohvaćanja utakmica:",
        doma.error?.message ?? vani.error?.message
      );
      return [];
    }

    const svi = [
      ...((doma.data ?? []) as UtakmicaKluba[]),
      ...((vani.data ?? []) as UtakmicaKluba[]),
    ];

    // Klub protiv samoga sebe ne postoji, ali ako se ista utakmica ikad
    // nađe u oba popisa, neka uđe jednom.
    const poId = new Map<number, UtakmicaKluba>();
    for (const u of svi) poId.set(u.id, u);
    return Array.from(poId.values());
  } catch (e) {
    console.error("Klub: dohvat utakmica nije uspio:", e);
    return [];
  }
}

/** "29.08.2026." -> Date, ili null. Stupac datum je tekst, ne datum. */
export function uDatum(tekst: string | null): Date | null {
  if (!tekst) return null;
  const m = tekst.match(/^(\d{2})\.(\d{2})\.(\d{4})\./);
  if (!m) return null;
  return new Date(Date.UTC(+m[3], +m[2] - 1, +m[1]));
}

const DANI = [
  "ned", "pon", "uto", "sri", "čet", "pet", "sub",
];

/** "29.08.2026." -> "sub 29.08." */
export function datumKratko(tekst: string | null): string | null {
  const d = uDatum(tekst);
  if (!d) return null;
  const dan = DANI[d.getUTCDay()];
  const dd = String(d.getUTCDate()).padStart(2, "0");
  const mm = String(d.getUTCMonth() + 1).padStart(2, "0");
  return `${dan} ${dd}.${mm}.`;
}

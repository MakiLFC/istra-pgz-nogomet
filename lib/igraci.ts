// lib/igraci.ts — profili igrača iz onoga što je u bazi.
//
// Igrači, kao ni klubovi, nemaju svoju tablicu. Postoje na dva mjesta:
// u rang-listama strijelaca i kartona (tablica "statistike") i u postavama
// pojedinih utakmica (stupci postava_domacin i postava_gost).
//
// ŠTO OVDJE NEMA: minute odigrane. U zapisniku stoje minute golova,
// kartona i izmjena, ali ne i koliko je tko bio na terenu. HNS tu
// rang-listu ima, scraper je zasad ne čita.

import { cache } from "react";
import { supabase, type IgracPostave, type Utakmica } from "@/lib/supabase";
import { slugKluba } from "@/lib/slug";

/** Adresa igrača nastaje iz imena, istim pravilima kao kod klubova. */
export const slugIgraca = slugKluba;

export type UcinakSezone = {
  sezona: string;
  natjecanje: string;
  klub: string;
  golovi: number;
  zuti: number;
  crveni: number;
};

export type Igrac = {
  slug: string;
  ime: string;
  /** Klubovi za koje se pojavljuje, najnoviji prvi. */
  klubovi: string[];
  sezone: string[];
  golovi: number;
  zuti: number;
  crveni: number;
  poSezoni: UcinakSezone[];
};

function broj(v: unknown): number {
  const c = String(v ?? "").replace(/[^\d-]/g, "");
  if (!c) return 0;
  const n = parseInt(c, 10);
  return isNaN(n) ? 0 : n;
}

type RedStatistike = {
  natjecanje: string;
  sezona: string;
  tip: string;
  podaci: { igrac?: string; klub?: string; golovi?: string; zuti?: string; crveni?: string }[];
};

/**
 * Svi igrači koji se pojavljuju u rang-listama strijelaca ili kartona.
 *
 * Namjerno se NE prolazi kroz postave svih utakmica: one su najteži dio
 * baze (nekoliko megabajta) i dohvaćati ih zbog popisa imena značilo bi
 * vući ih pri svakom otvaranju. Rang-liste su male, a pokrivaju upravo
 * igrače koje netko i traži po imenu.
 */
export const dohvatiIgrace = cache(async function dohvatiIgrace(): Promise<Igrac[]> {
  try {
    const { data, error } = await supabase
      .from("statistike")
      .select("natjecanje, sezona, tip, podaci")
      .in("tip", ["strijelci", "kartoni"]);

    if (error) {
      console.error("Igrači: greška kod dohvaćanja rang-lista:", error.message);
      return [];
    }

    // slug -> igrač u nastajanju; unutar njega ključ sezona|liga|klub
    const mapa = new Map<string, { ime: string; ucinci: Map<string, UcinakSezone> }>();

    for (const red of (data ?? []) as RedStatistike[]) {
      for (const stavka of red.podaci ?? []) {
        const ime = stavka.igrac?.trim();
        const klub = stavka.klub?.trim();
        // Prazan klub označava pomoćne rang-liste unutar kluba, koje
        // scraper ionako preskače; ako neka prođe, ovdje ispada.
        if (!ime || !klub) continue;

        const slug = slugIgraca(ime);
        if (!slug) continue;

        let igrac = mapa.get(slug);
        if (!igrac) {
          igrac = { ime, ucinci: new Map() };
          mapa.set(slug, igrac);
        }

        const kljuc = `${red.sezona}|${red.natjecanje}|${klub}`;
        let u = igrac.ucinci.get(kljuc);
        if (!u) {
          u = {
            sezona: red.sezona,
            natjecanje: red.natjecanje,
            klub,
            golovi: 0,
            zuti: 0,
            crveni: 0,
          };
          igrac.ucinci.set(kljuc, u);
        }

        if (red.tip === "strijelci") u.golovi = broj(stavka.golovi);
        if (red.tip === "kartoni") {
          u.zuti = broj(stavka.zuti);
          u.crveni = broj(stavka.crveni);
        }
      }
    }

    return Array.from(mapa.entries())
      .map(([slug, i]) => {
        const poSezoni = Array.from(i.ucinci.values()).sort((a, b) =>
          b.sezona.localeCompare(a.sezona)
        );
        return {
          slug,
          ime: i.ime,
          klubovi: Array.from(new Set(poSezoni.map((u) => u.klub))),
          sezone: Array.from(new Set(poSezoni.map((u) => u.sezona))),
          golovi: poSezoni.reduce((z, u) => z + u.golovi, 0),
          zuti: poSezoni.reduce((z, u) => z + u.zuti, 0),
          crveni: poSezoni.reduce((z, u) => z + u.crveni, 0),
          poSezoni,
        };
      })
      .sort((a, b) => a.ime.localeCompare(b.ime, "hr"));
  } catch (e) {
    console.error("Igrači: dohvat nije uspio:", e);
    return [];
  }
});

/** Jedan igrač po slugu, ili null. */
export async function dohvatiIgraca(slug: string): Promise<Igrac | null> {
  const svi = await dohvatiIgrace();
  return svi.find((i) => i.slug === slug) ?? null;
}

// ---------------------------------------------------------------------
// Nastupi
// ---------------------------------------------------------------------

export type NastupIgraca = {
  utakmica: Pick<
    Utakmica,
    "id" | "natjecanje" | "sezona" | "kolo" | "domacin" | "gost" | "rezultat" | "datum"
  >;
  /** Klub za koji je igrač nastupio u toj utakmici. */
  klub: string;
  /** Je li bio na klupi (i eventualno ušao). */
  pricuvni: boolean;
  dogadjaji: IgracPostave["dogadjaji"];
};

const STUPCI_NASTUPA =
  "id, natjecanje, sezona, kolo, domacin, gost, rezultat, datum, postava_domacin, postava_gost";

/**
 * Utakmice u kojima se igrač nalazi u postavi.
 *
 * Filtrira se u bazi, preko jsonb sadržavanja, pa se dohvaćaju samo
 * njegove utakmice, a ne sve postave u ligi.
 */
export async function dohvatiNastupe(ime: string): Promise<NastupIgraca[]> {
  try {
    // Uvjet se predaje kao JSON NIZ ZNAKOVA, ne kao polje objekata.
    // Kad se preda polje, supabase-js ga pretvori u zapis polja za
    // Postgres i objekti u njemu postanu "[object Object]", pa upit ne
    // nađe ništa, a greške nema: vrati se prazan popis.
    const uvjet = JSON.stringify([{ igrac: ime }]);
    const upit = (stupac: "postava_domacin" | "postava_gost") =>
      supabase.from("utakmice").select(STUPCI_NASTUPA).contains(stupac, uvjet);

    const [doma, vani] = await Promise.all([upit("postava_domacin"), upit("postava_gost")]);

    if (doma.error || vani.error) {
      console.error(
        "Igrač: greška kod dohvaćanja nastupa:",
        doma.error?.message ?? vani.error?.message
      );
      return [];
    }

    const nastupi: NastupIgraca[] = [];

    const dodaj = (redci: unknown[], strana: "domacin" | "gost") => {
      for (const r of redci as (Utakmica & Record<string, unknown>)[]) {
        const postava =
          strana === "domacin" ? r.postava_domacin : r.postava_gost;
        const igrac = (postava ?? []).find((i) => i.igrac === ime);
        if (!igrac) continue;

        nastupi.push({
          utakmica: {
            id: r.id,
            natjecanje: r.natjecanje,
            sezona: r.sezona,
            kolo: r.kolo,
            domacin: r.domacin,
            gost: r.gost,
            rezultat: r.rezultat,
            datum: r.datum,
          },
          klub: strana === "domacin" ? r.domacin : r.gost,
          pricuvni: Boolean(igrac.pricuvni),
          dogadjaji: igrac.dogadjaji ?? [],
        });
      }
    };

    dodaj(doma.data ?? [], "domacin");
    dodaj(vani.data ?? [], "gost");

    return nastupi.sort((a, b) => {
      const s = (b.utakmica.sezona ?? "").localeCompare(a.utakmica.sezona ?? "");
      if (s !== 0) return s;
      return (b.utakmica.kolo ?? 0) - (a.utakmica.kolo ?? 0);
    });
  } catch (e) {
    console.error("Igrač: dohvat nastupa nije uspio:", e);
    return [];
  }
}

/** Je li igrač te utakmice bio na terenu (u početnoj postavi ili ušao). */
export function jeIgrao(n: NastupIgraca): boolean {
  if (!n.pricuvni) return true;
  return n.dogadjaji.some((d) => d.tip === "izmjena_ulazak");
}

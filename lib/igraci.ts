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
import { dohvatiStatistike, type StatistikeLige } from "@/lib/statistike";

/** Adresa igrača nastaje iz imena, istim pravilima kao kod klubova. */
export const slugIgraca = slugKluba;

export type UcinakSezone = {
  sezona: string;
  natjecanje: string;
  klub: string;
  golovi: number;
  zuti: number;
  crveni: number;
  /** Službeni broj nastupa; null kad stranica natjecanja to ne nudi. */
  nastupi: number | null;
  /** Odigrane minute; null kad ih nema. */
  minute: number | null;
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
  /** Zbroj službenih nastupa, null ako ih nema ni za jednu sezonu. */
  nastupi: number | null;
  /** Zbroj odigranih minuta, null ako ih nema. */
  minute: number | null;
  poSezoni: UcinakSezone[];
};

/** Zbroj vrijednosti; null kad nijedna nije poznata, da se ne prikaže 0. */
function zbroj(vrijednosti: (number | null)[]): number | null {
  const poznate = vrijednosti.filter((v): v is number => v != null);
  return poznate.length ? poznate.reduce((z, v) => z + v, 0) : null;
}

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
  podaci: {
    igrac?: string;
    klub?: string;
    golovi?: string;
    zuti?: string;
    crveni?: string;
    nastupi?: string;
    minute?: string;
  }[];
};

/**
 * Svi igrači koji se pojavljuju u rang-listama strijelaca ili kartona.
 *
 * Namjerno se NE prolazi kroz postave svih utakmica: one su najteži dio
 * baze (nekoliko megabajta) i dohvaćati ih zbog popisa imena značilo bi
 * vući ih pri svakom otvaranju. Rang-liste su male, a pokrivaju upravo
 * igrače koje netko i traži po imenu.
 */
/**
 * Profili igrača iz redaka rang-lista.
 *
 * Izdvojeno iz dohvatiIgrace 20.10.2026., da isti račun služi i brzom
 * putu preko funkcije u bazi, koji dobiva samo stavke jednog igrača.
 */
function igraciIzRedova(redovi: RedStatistike[]): Igrac[] {
  {
    // slug -> igrač u nastajanju; unutar njega ključ sezona|liga|klub
    const mapa = new Map<string, { ime: string; ucinci: Map<string, UcinakSezone> }>();

    for (const red of redovi) {
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
            nastupi: null,
            minute: null,
          };
          igrac.ucinci.set(kljuc, u);
        }

        if (red.tip === "strijelci") u.golovi = broj(stavka.golovi);
        if (red.tip === "kartoni") {
          u.zuti = broj(stavka.zuti);
          u.crveni = broj(stavka.crveni);
        }
        if (red.tip === "nastupi") {
          // Prazan zapis znači "nema podatka", pa ostaje null umjesto nule.
          if (stavka.nastupi) u.nastupi = broj(stavka.nastupi);
          if (stavka.minute) u.minute = broj(stavka.minute);
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
          nastupi: zbroj(poSezoni.map((u) => u.nastupi)),
          minute: zbroj(poSezoni.map((u) => u.minute)),
          poSezoni,
        };
      })
      .sort((a, b) => a.ime.localeCompare(b.ime, "hr"));
  }
}

export const dohvatiIgrace = cache(async function dohvatiIgrace(): Promise<Igrac[]> {
  try {
    const { data, error } = await supabase
      .from("statistike")
      .select("natjecanje, sezona, tip, podaci")
      .in("tip", ["strijelci", "kartoni", "nastupi"]);

    if (error) {
      console.error("Igrači: greška kod dohvaćanja rang-lista:", error.message);
      return [];
    }

    return igraciIzRedova((data ?? []) as RedStatistike[]);
  } catch (e) {
    console.error("Igrači: dohvat nije uspio:", e);
    return [];
  }
});

/**
 * Slugovi igrača jedne lige i sezone koji imaju svoju stranicu.
 *
 * Stranica igrača postoji točno za one koje vraća dohvatiIgrace, a on ih
 * skuplja iz rang-lista strijelaca, kartona i nastupa (uz uvjet da je
 * upisan klub). Ovdje se čitaju iste liste, ali samo za ligu i sezonu
 * utakmice: to je nekoliko stotina imena umjesto cijele baze. Igrač koji
 * na ovim listama nije, a stranicu ima iz druge lige ili sezone, u
 * postavi ostaje običan tekst. Obrnuto se ne može dogoditi, pa poveznica
 * nikad ne vodi na "nije pronađeno".
 */
export async function slugoviIgracaLige(
  natjecanje: string,
  sezona: string
): Promise<Set<string>> {
  // BRZI PUT: baza vrati samo imena, a ne cijele rang-liste s nastupima,
  // minutama i klubovima. Popis nastupa jedne lige ima i preko 400
  // stavki, a ovoj provjeri treba samo ime. Vidi sql/igraci_rpc.sql.
  try {
    const { data, error } = await supabase.rpc("imena_igraca_lige", {
      p_natjecanje: natjecanje,
      p_sezona: sezona,
    });

    if (!error && Array.isArray(data) && data.length) {
      const slugovi = new Set<string>();
      for (const red of data as { ime: string | null }[]) {
        const slug = slugIgraca((red.ime ?? "").trim());
        if (slug) slugovi.add(slug);
      }
      if (slugovi.size) return slugovi;
    }
  } catch (e) {
    console.error("Igrači lige: brzi put nije uspio, ide se rang-listama:", e);
  }

  // REZERVA, dok funkcija u bazi ne postoji ili ne vrati ništa.
  const st = await dohvatiStatistike(natjecanje, sezona, ["strijelci", "kartoni", "nastupi"]);
  return slugoviIzStatistika(st);
}

/**
 * Isto kao slugoviIgracaLige, ali iz lista koje je stranica već dohvatila
 * (stranica lige ih ionako čita), pa bez još jednog upita.
 */
export function slugoviIzStatistika(
  st: Pick<StatistikeLige, "strijelci" | "kartoni" | "nastupi">
): Set<string> {
  const slugovi = new Set<string>();
  for (const red of [...st.strijelci, ...st.kartoni, ...st.nastupi]) {
    const ime = red.igrac?.trim();
    if (!ime || !red.klub?.trim()) continue;
    const slug = slugIgraca(ime);
    if (slug) slugovi.add(slug);
  }
  return slugovi;
}

/**
 * Jedan igrač po slugu, ili null.
 *
 * BRZI PUT: funkcija `ucinci_igraca` u bazi (vidi sql/igraci_rpc.sql)
 * vrati samo stavke tog igrača, dakle nekoliko redaka. Prije se ovdje
 * dohvaćalo SVE rang-liste svih liga i obiju sezona, oko 3850 stavki, i
 * tek se onda u kodu tražio jedan igrač. Tih stranica ima nekoliko
 * tisuća i tražilice ih redom obilaze, pa je to bilo glavno mjesto na
 * kojem je odlazni promet Supabasea otišao preko kvote (19.10.2026.).
 *
 * REZERVA: ako funkcije u bazi nema, ako javi grešku ili ne nađe nikoga,
 * ide se starim putem. Razlog je i taj što slug u bazi i slug u kodu
 * računaju dvije odvojene izvedbe istog pravila; ako se za neko ime
 * raziđu, igrač se svejedno nađe, samo skupljim putem.
 */
export async function dohvatiIgraca(slug: string): Promise<Igrac | null> {
  try {
    const { data, error } = await supabase.rpc("ucinci_igraca", { p_slug: slug });

    if (!error && Array.isArray(data) && data.length) {
      const redovi: RedStatistike[] = (
        data as { natjecanje: string; sezona: string; tip: string; stavka: unknown }[]
      ).map((r) => ({
        natjecanje: r.natjecanje,
        sezona: r.sezona,
        tip: r.tip,
        podaci: [r.stavka as RedStatistike["podaci"][number]],
      }));

      const igrac = igraciIzRedova(redovi).find((i) => i.slug === slug);
      if (igrac) return igrac;
    }
  } catch (e) {
    console.error("Igrač: brzi put nije uspio, ide se punim dohvatom:", e);
  }

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

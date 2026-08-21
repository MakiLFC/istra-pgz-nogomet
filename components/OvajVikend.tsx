// OvajVikend.tsx — kratka traka iznad novosti: što se igra ovaj vikend.
//
// SERVERSKA komponenta (nema "use client"): podaci se dohvaćaju na
// poslužitelju, pa ništa ne "uskače" nakon učitavanja stranice.
//
// Nije zamjena za članak-najavu, nego signal koji radi i onda kad najava
// tog tjedna nije napisana.

import Link from "next/link";
import { supabase } from "@/lib/supabase";
import { LIGE } from "@/lib/lige";
import { golovi } from "@/lib/kolo";
import { sBrojem } from "@/lib/hrvatski";

/** Redak utakmice - samo stupci koje traka stvarno treba. */
type RedUtakmice = {
  natjecanje: string;
  kolo: number | null;
  datum: string | null;
  vrijeme: string | null;
  rezultat: string | null;
};

const DANI = [
  "nedjelja", "ponedjeljak", "utorak", "srijeda",
  "četvrtak", "petak", "subota",
];

const MJESECI = [
  "siječnja", "veljače", "ožujka", "travnja", "svibnja", "lipnja",
  "srpnja", "kolovoza", "rujna", "listopada", "studenoga", "prosinca",
];

/**
 * "29.08.2026." -> Date (ponoć UTC toga dana).
 * Stupac `datum` je tekst, pa se po njemu ne može ni sortirati ni
 * uspoređivati u bazi - zato pretvorba ovdje.
 */
function uDatum(tekst: string | null): Date | null {
  if (!tekst) return null;
  const m = tekst.match(/^(\d{2})\.(\d{2})\.(\d{4})\./);
  if (!m) return null;
  return new Date(Date.UTC(+m[3], +m[2] - 1, +m[1]));
}

/** Ponoć današnjeg dana, za usporedbu "je li datum prošao". */
function danas(): Date {
  const s = new Date();
  return new Date(Date.UTC(s.getUTCFullYear(), s.getUTCMonth(), s.getUTCDate()));
}

type RedakLige = {
  liga: { naziv: string; slug: string };
  kolo: number | null;
  datum: Date;
  vrijeme: string | null;
  brojUtakmica: number;
  odigrano: boolean;
  slugNajave: string | null;
};

export default async function OvajVikend() {
  // 1. Tekuća sezona. Ista logika kao na ostatku stranice: najveća
  //    vrijednost, jer su sezone zapisane kao "2026/27".
  const { data: sezone } = await supabase
    .from("utakmice")
    .select("sezona")
    .order("sezona", { ascending: false })
    .limit(1);

  const sezona = sezone?.[0]?.sezona;
  if (!sezona) return null;

  // 2. Utakmice te sezone - samo potrebni stupci, s limitom.
  const { data: sirovo } = await supabase
    .from("utakmice")
    .select("natjecanje, kolo, datum, vrijeme, rezultat")
    .eq("sezona", sezona)
    .limit(1000);

  if (!sirovo?.length) return null;

  const utakmice = sirovo as RedUtakmice[];
  const granica = danas();

  // 3. Za svaku ligu: najbliži datum koji nije prošao, i sve utakmice
  //    tog dana. Lige bez nadolazećih utakmica se preskaču.
  const redovi: RedakLige[] = [];

  for (const liga of LIGE) {
    const nadolazece = utakmice
      .filter((u) => u.natjecanje === liga.naziv)
      .map((u) => ({ ...u, d: uDatum(u.datum) }))
      .filter((u): u is RedUtakmice & { d: Date } => u.d !== null && u.d >= granica)
      .sort((a, b) => a.d.getTime() - b.d.getTime());

    if (!nadolazece.length) continue;

    const prvi = nadolazece[0].d.getTime();
    const togDana = nadolazece.filter((u) => u.d.getTime() === prvi);

    redovi.push({
      liga,
      kolo: togDana[0].kolo,
      datum: togDana[0].d,
      vrijeme: togDana[0].vrijeme,
      brojUtakmica: togDana.length,
      // Nedjeljom navečer utakmice tog dana već imaju rezultat: tada se
      // umjesto vremena pokazuje da je kolo odigrano.
      odigrano: togDana.some((u) => golovi(u.rezultat) !== null),
      slugNajave: null,
    });
  }

  // 4. Nijedna liga nema nadolazećih utakmica -> jedan redak s početkom
  //    sezone. Ako se ni to ne može odrediti, ne prikazuje se ništa
  //    (nikad prazan okvir s naslovom).
  if (!redovi.length) {
    const sviDatumi = utakmice
      .map((u) => uDatum(u.datum))
      .filter((d): d is Date => d !== null)
      .sort((a, b) => a.getTime() - b.getTime());

    if (!sviDatumi.length) return null;

    const p = sviDatumi[0];
    return (
      <Okvir naslov="Sljedeće kolo">
        <p className="font-sans text-sm" style={{ color: "var(--ink-muted)" }}>
          Sezona {sezona} počinje {p.getUTCDate()}. {MJESECI[p.getUTCMonth()]}.
        </p>
      </Okvir>
    );
  }

  // 5. Poveznica na najavu: najnoviji objavljeni članak te lige kojemu
  //    naslov sadrži "najav". Ako takvog nema, gumb se ne prikazuje.
  const { data: najave } = await supabase
    .from("clanci")
    .select("slug, natjecanje, objavljeno_u")
    .eq("objavljen", true)
    .ilike("naslov", "%najav%")
    .order("objavljeno_u", { ascending: false })
    .limit(20);

  for (const red of redovi) {
    red.slugNajave =
      najave?.find((c) => c.natjecanje === red.liga.naziv)?.slug ?? null;
  }

  redovi.sort((a, b) => a.datum.getTime() - b.datum.getTime());

  // 6. Naslov trake ovisi o tome koliko je najbliži termin daleko.
  const razmak =
    (redovi[0].datum.getTime() - granica.getTime()) / 86_400_000;
  const naslov = razmak <= 7 ? "Ovaj vikend" : "Sljedeće kolo";

  return (
    <Okvir naslov={naslov}>
      <ul className="space-y-1.5">
        {redovi.slice(0, 4).map((r) => (
          <li key={r.liga.slug} className="flex flex-wrap items-baseline gap-x-2 gap-y-1">
            <Link
              href={`/liga/${r.liga.slug}${r.kolo ? `?kolo=${r.kolo}` : ""}`}
              className="font-sans text-sm font-medium hover:underline"
              style={{ color: "var(--pitch)" }}
            >
              {r.liga.naziv}
              {r.kolo ? `, ${r.kolo}. kolo` : ""}
            </Link>

            <span className="font-sans text-sm" style={{ color: "var(--ink-muted)" }}>
              · {DANI[r.datum.getUTCDay()]}{" "}
              {String(r.datum.getUTCDate()).padStart(2, "0")}.
              {String(r.datum.getUTCMonth() + 1).padStart(2, "0")}.
              {r.odigrano
                ? ` · ${sBrojem(r.brojUtakmica, [
                    "odigrana utakmica",
                    "odigrane utakmice",
                    "odigranih utakmica",
                  ])}`
                : `${r.vrijeme ? ` u ${r.vrijeme}` : ""} · ${sBrojem(r.brojUtakmica, [
                    "utakmica",
                    "utakmice",
                    "utakmica",
                  ])}`}
            </span>

            {r.slugNajave && (
              <Link
                href={`/novosti/${r.slugNajave}`}
                className="font-sans text-xs font-medium hover:underline"
                style={{ color: "var(--oxide)" }}
              >
                Najava →
              </Link>
            )}
          </li>
        ))}
      </ul>
    </Okvir>
  );
}

/** Diskretan okvir: oksidna crtica lijevo, bez velike kartice. */
function Okvir({
  naslov,
  children,
}: {
  naslov: string;
  children: React.ReactNode;
}) {
  return (
    <section className="mb-10 pl-4" style={{ borderLeft: "3px solid var(--oxide)" }}>
      <p className="oznaka-sekcije mb-2">{naslov}</p>
      {children}
    </section>
  );
}

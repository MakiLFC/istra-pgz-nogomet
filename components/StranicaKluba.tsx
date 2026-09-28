// components/StranicaKluba.tsx — sadržaj stranice pojedinog kluba.
//
// Ime i natjecanje, poredak i forma, strijelci i kartoni, pa popis svih
// utakmica u sezoni, razdvojen na nadolazeće i odigrane.
//
// Klubovi nemaju svoju tablicu u bazi, izvode se iz imena u utakmicama;
// vidi lib/klubovi.ts.
//
// Zašto je sadržaj ovdje, a ne u app/klub/[slug]/page.tsx: istu stranicu
// koriste dvije adrese, ona bez sezone i ona sa sezonom u putanji. Isti
// razlog i isti raspored kao kod components/StranicaLige.tsx.

import Link from "next/link";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import Navigacija from "@/components/Navigacija";
import Podnozje from "@/components/Podnozje";
import Otkrivanje from "@/components/Otkrivanje";
import { IkonaTeren } from "@/components/Ikone";
import StatistikaKluba from "@/components/StatistikaKluba";
import PoveznicaKluba from "@/components/PoveznicaKluba";
import {
  dohvatiKlub,
  dohvatiUtakmiceKluba,
  datumKratko,
  formaKluba,
  uDatum,
  adresaKluba,
  type UtakmicaKluba,
} from "@/lib/klubovi";
import { dohvatiStatistike } from "@/lib/statistike";
import { golovi } from "@/lib/kolo";
import { slugUtakmice } from "@/lib/slug";
import { LIGE, sezonaIzAdrese } from "@/lib/lige";
import { sBrojem } from "@/lib/hrvatski";
import { SLIKA_DIJELJENJE } from "@/lib/metapodaci";

/** Parametri iz adrese: sezona dolazi kao "2025-26", u bazi je "2025/26". */
export function parametriKluba(p: { slug: string; sezona?: string }): {
  slug: string;
  sezona: string | null;
} {
  return {
    slug: p.slug,
    sezona: p.sezona ? sezonaIzAdrese(p.sezona) : null,
  };
}

function opisKluba(naziv: string, lige: string[]): string {
  const uLigama = lige.length ? ` u natjecanju ${lige.join(", ")}` : "";
  return `Rezultati, raspored, poredak i strijelci kluba ${naziv}${uLigama}. Podaci s HNS Semafora, osvježeni svakog vikenda.`;
}

export async function metapodaciKluba(
  slug: string,
  sezona: string | null = null
): Promise<Metadata> {
  const klub = await dohvatiKlub(slug);
  if (!klub) return { title: "Klub nije pronađen" };

  const opis = opisKluba(klub.naziv, klub.lige);
  const adresa = adresaKluba(klub.slug, sezona);
  const naslov = sezona ? `${klub.naziv}, sezona ${sezona}` : klub.naziv;

  return {
    title: naslov,
    description: opis,
    alternates: { canonical: adresa },
    openGraph: {
      title: naslov,
      description: opis,
      url: adresa,
      type: "website",
      locale: "hr_HR",
      images: [SLIKA_DIJELJENJE],
    },
  };
}

/**
 * Jedan redak utakmice.
 *
 * Redak namjerno NIJE jedna velika poveznica: unutar poveznice ne smije
 * stajati druga poveznica, a ovdje ih treba dvije. Broj kola vodi na
 * zapisnik te utakmice, a ime protivnika na njegovu stranicu.
 */
function Redak({ u, klub }: { u: UtakmicaKluba; klub: string }) {
  const rezultat = golovi(u.rezultat);
  const termin = [datumKratko(u.datum), u.vrijeme].filter(Boolean).join(" u ");

  const ime = (naziv: string) =>
    naziv === klub ? (
      <span className="font-bold">{naziv}</span>
    ) : (
      <PoveznicaKluba naziv={naziv} className="font-medium" />
    );

  return (
    <div
      className="flex items-center gap-3 bg-white px-4 py-3"
      style={{ border: "1px solid var(--line)" }}
    >
      <IkonaTeren />

      <Link
        href={`/utakmica/${slugUtakmice(u)}`}
        className="w-16 shrink-0 font-mono text-[11px] hover:underline"
        style={{ color: "var(--ink-muted)" }}
      >
        {u.kolo ? `${u.kolo}. kolo` : "utakmica"}
      </Link>

      <p className="min-w-0 flex-1 font-sans text-[15px] leading-snug">
        {ime(u.domacin)}{" "}
        {rezultat ? (
          <span className="semafor text-sm">{u.rezultat}</span>
        ) : (
          <span className="font-mono text-xs" style={{ color: "var(--oxide)" }}>
            vs
          </span>
        )}{" "}
        {ime(u.gost)}
      </p>

      {termin && (
        <span
          className="ml-auto shrink-0 font-mono text-[11px]"
          style={{ color: "var(--ink-muted)" }}
        >
          {termin}
        </span>
      )}
    </div>
  );
}

function Blok({
  naslov,
  dodatak,
  utakmice,
  klub,
}: {
  naslov: string;
  dodatak?: string;
  utakmice: UtakmicaKluba[];
  klub: string;
}) {
  if (!utakmice.length) return null;

  return (
    <section className="mt-10">
      <Otkrivanje>
        <div className="pb-3">
          <p className="oznaka-sekcije">{naslov}</p>
          {dodatak && (
            <p className="mt-1.5 font-mono text-xs" style={{ color: "var(--ink-muted)" }}>
              {dodatak}
            </p>
          )}
        </div>
      </Otkrivanje>

      <div className="space-y-2">
        {utakmice.map((u, idx) => (
          <Otkrivanje key={u.id} kasnjenje={Math.min(idx, 6) * 40}>
            <Redak u={u} klub={klub} />
          </Otkrivanje>
        ))}
      </div>
    </section>
  );
}

export default async function StranicaKluba({
  slug,
  sezona: sezonaIzAdreseKluba,
}: {
  slug: string;
  sezona: string | null;
}) {
  const klub = await dohvatiKlub(slug);
  if (!klub) notFound();

  // Zadana je najnovija sezona u kojoj klub ima utakmice.
  const sezona =
    sezonaIzAdreseKluba && klub.sezone.includes(sezonaIzAdreseKluba)
      ? sezonaIzAdreseKluba
      : klub.sezone[0];

  const utakmice = sezona ? await dohvatiUtakmiceKluba(klub.naziv, sezona) : [];

  // Statistika se vodi po natjecanju. Klub je u sezoni u pravilu u jednoj
  // ligi; ako ih je više, uzima se ona u kojoj te sezone ima utakmice.
  const ligaSezone =
    utakmice[0]?.natjecanje ?? klub.lige[0] ?? null;
  const statistike =
    ligaSezone && sezona
      // Bez "nastupi": stranica kluba taj popis ne prikazuje, a najveći je
      // od sva četiri retka. Vidi lib/statistike.ts.
      ? await dohvatiStatistike(ligaSezone, sezona, ["tablica", "strijelci", "kartoni"])
      : { tablica: [], strijelci: [], kartoni: [], nastupi: [] };

  const forma = formaKluba(utakmice, klub.naziv);

  const odigrane = utakmice
    .filter((u) => golovi(u.rezultat))
    .sort((a, b) => (b.kolo ?? 0) - (a.kolo ?? 0));

  // Nadolazeće idu po datumu, jer se kola znaju igrati izvan redoslijeda.
  const nadolazece = utakmice
    .filter((u) => !golovi(u.rezultat))
    .sort((a, b) => {
      const da = uDatum(a.datum)?.getTime() ?? Infinity;
      const db = uDatum(b.datum)?.getTime() ?? Infinity;
      if (da !== db) return da - db;
      return (a.kolo ?? 0) - (b.kolo ?? 0);
    });

  return (
    <div className="min-h-screen" style={{ background: "var(--chalk)" }}>
      <Navigacija />

      <main className="mx-auto max-w-4xl px-6 py-14">
        <Otkrivanje>
          <p className="oznaka-sekcije">Klub</p>
          <h1 className="font-display mt-3 text-4xl uppercase tracking-tight sm:text-5xl">
            {klub.naziv}
          </h1>

          <p className="mt-4 flex flex-wrap items-baseline gap-x-2 font-sans text-sm">
            {klub.lige.map((naziv) => {
              const liga = LIGE.find((l) => l.naziv === naziv);
              return liga ? (
                <Link
                  key={naziv}
                  href={`/liga/${liga.slug}`}
                  className="font-medium hover:underline"
                  style={{ color: "var(--pitch)" }}
                >
                  {naziv}
                </Link>
              ) : (
                <span key={naziv} className="font-medium">
                  {naziv}
                </span>
              );
            })}
            {sezona && (
              <span className="font-mono text-xs" style={{ color: "var(--ink-muted)" }}>
                · sezona {sezona}
              </span>
            )}
          </p>
        </Otkrivanje>

        {/* Birač sezone se pojavljuje tek kad klub ima više od jedne. */}
        {klub.sezone.length > 1 && (
          <Otkrivanje kasnjenje={60}>
            <div className="mt-5 flex flex-wrap gap-1.5">
              {klub.sezone.map((s) => (
                <Link
                  key={s}
                  href={adresaKluba(klub.slug, s === klub.sezone[0] ? null : s)}
                  className="font-mono px-3 py-1.5 text-xs"
                  style={
                    s === sezona
                      ? { background: "var(--pitch)", color: "var(--chalk)" }
                      : { border: "1px solid var(--line)", background: "var(--paper)" }
                  }
                >
                  {s}
                </Link>
              ))}
            </div>
          </Otkrivanje>
        )}

        <StatistikaKluba naziv={klub.naziv} statistike={statistike} forma={forma} />

        <Blok
          naslov="Raspored"
          dodatak={
            nadolazece.length
              ? sBrojem(nadolazece.length, [
                  "utakmica koja se tek igra",
                  "utakmice koje se tek igraju",
                  "utakmica koje se tek igraju",
                ])
              : undefined
          }
          utakmice={nadolazece}
          klub={klub.naziv}
        />

        <Blok
          naslov="Rezultati"
          dodatak={
            odigrane.length
              ? sBrojem(odigrane.length, [
                  "odigrana utakmica",
                  "odigrane utakmice",
                  "odigranih utakmica",
                ])
              : undefined
          }
          utakmice={odigrane}
          klub={klub.naziv}
        />

        {!utakmice.length && (
          <p className="mt-10 font-sans text-sm" style={{ color: "var(--ink-muted)" }}>
            Za ovu sezonu još nema utakmica ovog kluba u bazi.
          </p>
        )}
      </main>

      <Podnozje />
    </div>
  );
}

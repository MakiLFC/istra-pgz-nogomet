// app/klub/[slug]/page.tsx — stranica pojedinog kluba.
//
// Drugi korak: uz ime i natjecanje, popis svih utakmica kluba u sezoni,
// razdvojen na nadolazeće i odigrane. Statistika dolazi u sljedećem koraku.
//
// Klubovi nemaju svoju tablicu u bazi, izvode se iz imena u utakmicama;
// vidi lib/klubovi.ts.

import Link from "next/link";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import Navigacija from "@/components/Navigacija";
import Podnozje from "@/components/Podnozje";
import Otkrivanje from "@/components/Otkrivanje";
import { IkonaTeren } from "@/components/Ikone";
import {
  dohvatiKlub,
  dohvatiKlubove,
  dohvatiUtakmiceKluba,
  datumKratko,
  uDatum,
  type UtakmicaKluba,
} from "@/lib/klubovi";
import { golovi } from "@/lib/kolo";
import { LIGE } from "@/lib/lige";
import { sBrojem } from "@/lib/hrvatski";
import { SLIKA_DIJELJENJE } from "@/lib/metapodaci";

export const revalidate = 300;

/**
 * Adrese se pripremaju pri gradnji, da ih tražilice zateknu gotove.
 * Ako baza tada nije dostupna, popis je prazan i stranice se grade na
 * zahtjev; nijedna se ne gubi.
 */
export async function generateStaticParams() {
  try {
    const klubovi = await dohvatiKlubove();
    return klubovi.map((k) => ({ slug: k.slug }));
  } catch {
    return [];
  }
}

function opisKluba(naziv: string, lige: string[]): string {
  const uLigama = lige.length ? ` u natjecanju ${lige.join(", ")}` : "";
  return `Rezultati i raspored kluba ${naziv}${uLigama}. Podaci s HNS Semafora, osvježeni svakog vikenda.`;
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const klub = await dohvatiKlub(slug);
  if (!klub) return { title: "Klub nije pronađen" };

  const opis = opisKluba(klub.naziv, klub.lige);
  const adresa = `/klub/${klub.slug}`;

  return {
    title: klub.naziv,
    description: opis,
    alternates: { canonical: adresa },
    openGraph: {
      title: klub.naziv,
      description: opis,
      url: adresa,
      type: "website",
      locale: "hr_HR",
      images: [SLIKA_DIJELJENJE],
    },
  };
}

/** Jedan redak utakmice. Klub čija je ovo stranica ispisan je podebljano. */
function Redak({ u, klub }: { u: UtakmicaKluba; klub: string }) {
  const rezultat = golovi(u.rezultat);
  const ligaSlug = LIGE.find((l) => l.naziv === u.natjecanje)?.slug;
  const termin = [datumKratko(u.datum), u.vrijeme].filter(Boolean).join(" u ");

  const ime = (naziv: string) => (
    <span className={naziv === klub ? "font-bold" : "font-medium"}>{naziv}</span>
  );

  const sadrzaj = (
    <>
      <IkonaTeren />
      <span
        className="w-16 shrink-0 font-mono text-[11px]"
        style={{ color: "var(--ink-muted)" }}
      >
        {u.kolo ? `${u.kolo}. kolo` : ""}
      </span>

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
    </>
  );

  const razred = "flex items-center gap-3 bg-white px-4 py-3";
  const obrub = { border: "1px solid var(--line)" };

  // Poveznica vodi na kolo te utakmice na stranici lige, gdje stoje
  // zapisnik, strijelci i postave.
  return ligaSlug ? (
    <Link
      href={`/liga/${ligaSlug}${u.kolo ? `?kolo=${u.kolo}` : ""}`}
      className={`${razred} transition-opacity hover:opacity-80`}
      style={obrub}
    >
      {sadrzaj}
    </Link>
  ) : (
    <div className={razred} style={obrub}>
      {sadrzaj}
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
  params,
  searchParams,
}: {
  params: Promise<{ slug: string }>;
  searchParams: Promise<{ sezona?: string }>;
}) {
  const { slug } = await params;
  const { sezona: sezonaIzUrl } = await searchParams;

  const klub = await dohvatiKlub(slug);
  if (!klub) notFound();

  // Zadana je najnovija sezona u kojoj klub ima utakmice.
  const sezona = sezonaIzUrl && klub.sezone.includes(sezonaIzUrl)
    ? sezonaIzUrl
    : klub.sezone[0];

  const utakmice = sezona ? await dohvatiUtakmiceKluba(klub.naziv, sezona) : [];

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
                  href={`/klub/${klub.slug}?sezona=${encodeURIComponent(s)}`}
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

// app/klub/[slug]/page.tsx — stranica pojedinog kluba.
//
// Prvi korak: samo ime kluba i natjecanja u kojima se pojavljuje.
// Rezultati, raspored i statistika dolaze u sljedećim koracima.
//
// Klubovi nemaju svoju tablicu u bazi, izvode se iz imena u utakmicama;
// vidi lib/klubovi.ts.

import Link from "next/link";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import Navigacija from "@/components/Navigacija";
import Podnozje from "@/components/Podnozje";
import Otkrivanje from "@/components/Otkrivanje";
import { dohvatiKlub, dohvatiKlubove } from "@/lib/klubovi";
import { LIGE } from "@/lib/lige";
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
  return `Klub ${naziv}${uLigama}. Podaci s HNS Semafora, osvježeni svakog vikenda.`;
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

export default async function StranicaKluba({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const klub = await dohvatiKlub(slug);
  if (!klub) notFound();

  return (
    <div className="min-h-screen" style={{ background: "var(--chalk)" }}>
      <Navigacija />

      <main className="mx-auto max-w-4xl px-6 py-14">
        <Otkrivanje>
          <p className="oznaka-sekcije">Klub</p>
          <h1 className="font-display mt-3 text-4xl uppercase tracking-tight sm:text-5xl">
            {klub.naziv}
          </h1>
        </Otkrivanje>

        <Otkrivanje kasnjenje={80}>
          <div
            className="mt-8 space-y-4 p-5"
            style={{ background: "var(--paper)", border: "1px solid var(--line)" }}
          >
            <div>
              <p className="oznaka-sekcije">Natjecanje</p>
              <ul className="mt-2 space-y-1">
                {klub.lige.map((naziv) => {
                  const liga = LIGE.find((l) => l.naziv === naziv);
                  return (
                    <li key={naziv} className="font-sans text-[15px]">
                      {liga ? (
                        <Link
                          href={`/liga/${liga.slug}`}
                          className="font-medium hover:underline"
                          style={{ color: "var(--pitch)" }}
                        >
                          {naziv}
                        </Link>
                      ) : (
                        <span className="font-medium">{naziv}</span>
                      )}
                    </li>
                  );
                })}
              </ul>
            </div>

            <div style={{ borderTop: "1px solid var(--line)" }} className="pt-4">
              <p className="oznaka-sekcije">Sezone</p>
              <p className="mt-2 font-mono text-sm">{klub.sezone.join(" · ")}</p>
            </div>
          </div>
        </Otkrivanje>
      </main>

      <Podnozje />
    </div>
  );
}

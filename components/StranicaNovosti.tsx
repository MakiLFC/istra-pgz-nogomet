// components/StranicaNovosti.tsx — sadržaj popisa novosti.
//
// Ista komponenta služi adresi bez filtra (/novosti) i onoj s ligom u
// putanji (/novosti/liga/3-nl-zapad), po uzoru na StranicaLige.tsx.
//
// Do 28.09.2026. je filtar bio upit (?liga=3.%20NL%20Zapad), pa se popis
// renderirao pri SVAKOM otvaranju, koliko god revalidate bio. Stare
// adrese preusmjerava next.config.ts.

import Link from "next/link";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import Navigacija from "@/components/Navigacija";
import PopisNovosti from "@/components/PopisNovosti";
import Podnozje from "@/components/Podnozje";
import ZaglavljeStranice from "@/components/ZaglavljeStranice";
import { dohvatiClanke } from "@/lib/clanci";
import { LIGE, ligaPoSlugu, adresaNovosti } from "@/lib/lige";
import { SLIKA_DIJELJENJE } from "@/lib/metapodaci";

const OPIS =
  "Transferi, najave i osvrti iz nižih nogometnih liga Istre i Primorsko-goranske županije.";

export function metapodaciNovosti(ligaSlug?: string | null): Metadata {
  const liga = ligaSlug ? ligaPoSlugu(ligaSlug) : undefined;
  const naslov = liga ? `Novosti, ${liga.naziv}` : "Novosti";
  const opis = liga
    ? `Transferi, najave i osvrti, natjecanje ${liga.naziv}.`
    : OPIS;
  const adresa = adresaNovosti(liga?.slug);

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

export default async function StranicaNovosti({
  ligaSlug = null,
}: {
  ligaSlug?: string | null;
}) {
  // Nepoznat slug u adresi je stranica koje nema, a ne popis svih članaka:
  // inače bi svaka izmišljena adresa vraćala punu stranicu s kodom 200.
  const liga = ligaSlug ? ligaPoSlugu(ligaSlug) : undefined;
  if (ligaSlug && !liga) notFound();

  const clanci = await dohvatiClanke({ liga: liga?.naziv });

  return (
    <div className="min-h-screen" style={{ background: "var(--chalk)" }}>
      <Navigacija />

      <main className="mx-auto max-w-4xl px-6 py-14">
        <ZaglavljeStranice slika="novosti" naslov="Novosti" />

        {/* filtar po ligama */}
        <div className="flex flex-wrap gap-1.5 pb-5" style={{ borderBottom: "1px solid var(--line)" }}>
          <Link
            href={adresaNovosti()}
            className="font-sans px-3 py-1.5 text-xs font-medium"
            style={
              !liga
                ? { background: "var(--pitch)", color: "var(--chalk)" }
                : { border: "1px solid var(--line)", background: "var(--paper)" }
            }
          >
            Sve
          </Link>
          {LIGE.map((l) => (
            <Link
              key={l.slug}
              href={adresaNovosti(l.slug)}
              className="font-sans px-3 py-1.5 text-xs font-medium"
              style={
                liga?.slug === l.slug
                  ? { background: "var(--pitch)", color: "var(--chalk)" }
                  : { border: "1px solid var(--line)", background: "var(--paper)" }
              }
            >
              {l.naziv}
            </Link>
          ))}
        </div>

        {clanci.length === 0 ? (
          <p className="mt-6 font-sans text-sm" style={{ color: "var(--ink-muted)" }}>
            {liga
              ? "Za ovu ligu još nema objavljenih članaka."
              : "Još nema objavljenih članaka."}
          </p>
        ) : (
          // key veže popis uz odabranu ligu: bez njega bi se, pri
          // prebacivanju s kartice na karticu, zadržalo koliko je kartica
          // bilo otkriveno na prethodnoj.
          <PopisNovosti key={liga?.slug ?? "sve"} clanci={clanci} />
        )}
      </main>

      <Podnozje />
    </div>
  );
}

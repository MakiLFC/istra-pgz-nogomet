// app/novosti/page.tsx — popis svih objavljenih članaka

import Link from "next/link";
import type { Metadata } from "next";
import Navigacija from "@/components/Navigacija";
import KarticaClanka from "@/components/KarticaClanka";
import { dohvatiClanke } from "@/lib/clanci";
import { LIGE } from "@/lib/lige";
import Otkrivanje from "@/components/Otkrivanje";

export const revalidate = 0;

export const metadata: Metadata = {
  title: "Novosti — Lokal-Arena",
  description:
    "Transferi, najave i osvrti iz nižih nogometnih liga Primorsko-goranske županije.",
};

export default async function StranicaNovosti({
  searchParams,
}: {
  searchParams: Promise<{ liga?: string }>;
}) {
  const { liga } = await searchParams;
  const clanci = await dohvatiClanke({ liga });

  return (
    <div className="min-h-screen" style={{ background: "var(--chalk)" }}>
      <Navigacija />

      <main className="mx-auto max-w-4xl px-6 py-14">
        <p className="oznaka-sekcije">Uredništvo</p>
        <h1 className="font-display mt-1.5 text-3xl uppercase">Novosti</h1>
        <p className="mt-2 font-sans text-sm" style={{ color: "var(--ink-muted)" }}>
          Transferi, najave i osvrti
        </p>

        {/* filtar po ligama */}
        <div className="mt-5 flex flex-wrap gap-1.5 pb-5" style={{ borderBottom: "1px solid var(--line)" }}>
          <Link
            href="/novosti"
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
              href={`/novosti?liga=${encodeURIComponent(l.naziv)}`}
              className="font-sans px-3 py-1.5 text-xs font-medium"
              style={
                liga === l.naziv
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
          <div className="mt-8 grid grid-cols-1 gap-3 sm:grid-cols-2">
            {clanci.map((c, idx) => (
              <Otkrivanje key={c.id} kasnjenje={Math.min(idx, 6) * 45}>
                <KarticaClanka clanak={c} />
              </Otkrivanje>
            ))}
          </div>
        )}
      </main>

      <footer
        className="px-6 py-5 text-center font-sans text-xs"
        style={{ borderTop: "3px solid var(--pitch)", color: "var(--ink-muted)" }}
      >
        Lokal-Arena — niže nogometne lige Primorsko-goranske županije
      </footer>
    </div>
  );
}

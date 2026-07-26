import Link from "next/link";
import { LIGE } from "@/lib/lige";
import Grb from "@/components/Grb";

export default function Navigacija() {
  return (
    <header
      className="relative"
      style={{
        background: "var(--pitch)",
        borderBottom: "3px solid var(--oxide)",
      }}
    >
      {/* Znak u samom gornjem lijevom kutu stranice - IZVAN sredinske trake
          u kojoj su naslov i lige. Prikazuje se tek kad ima mjesta u lijevoj
          margini (xl i šire); na užim ekranima ide uz naslov (vidi dolje). */}
      <Link
        href="/"
        aria-label="Lokal-Arena, naslovnica"
        className="absolute left-3 top-3 hidden xl:block"
      >
        {/* raste s ekranom da ispuni lijevu prazninu */}
        <Grb className="h-auto w-16 2xl:w-40 min-[1800px]:w-44" />
      </Link>

      <div className="mx-auto max-w-6xl px-6 py-5">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <Link href="/" className="flex items-center gap-3">
            {/* isti znak, ali samo na užim ekranima gdje margine nema */}
            <span className="xl:hidden">
              <Grb size={42} />
            </span>
            <span className="logo-arena">
              <span
                className="logo-rijec logo-lijevo font-display text-2xl uppercase tracking-wide"
                style={{ color: "var(--card-yellow)" }}
              >
                Lokal
              </span>
              <span className="logo-spona font-display text-2xl" aria-hidden="true">
                –
              </span>
              <span
                className="logo-rijec logo-desno font-display text-2xl uppercase tracking-wide"
                style={{ color: "var(--chalk)" }}
              >
                Arena
              </span>
            </span>
          </Link>

          <p className="max-w-[22rem] text-right font-mono text-[10px] uppercase leading-snug tracking-wide text-[var(--chalk)] opacity-60">
            Niže nogometne lige klubova na prostoru Primorsko-goranske županije
          </p>
        </div>

        <nav className="mt-4 flex flex-wrap gap-x-1 border-t border-white/15 pt-3">
          {LIGE.map((liga) => (
            <Link
              key={liga.slug}
              href={`/liga/${liga.slug}`}
              className="font-sans px-3 py-1.5 text-sm font-medium uppercase tracking-wide text-[var(--chalk)] opacity-75 transition-opacity hover:bg-white/10 hover:opacity-100"
            >
              {liga.naziv}
            </Link>
          ))}
        </nav>
      </div>
    </header>
  );
}

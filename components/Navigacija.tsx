import Link from "next/link";
import { LIGE } from "@/lib/lige";

export default function Navigacija() {
  return (
    <header style={{ background: "var(--pitch)" }}>
      <div className="mx-auto max-w-5xl px-6 py-5">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <Link href="/" className="flex items-baseline gap-0">
            <span
              className="font-display text-2xl font-semibold uppercase tracking-wide"
              style={{ color: "var(--card-yellow)" }}
            >
              Lokal
            </span>
            <span
              className="font-display text-2xl font-semibold"
              style={{ color: "var(--pitch-light)" }}
            >
              -
            </span>
            <span
              className="font-display text-2xl font-semibold uppercase tracking-wide"
              style={{ color: "var(--arena-blue)" }}
            >
              Arena
            </span>
          </Link>
          <p className="font-mono text-[11px] uppercase tracking-widest text-[var(--chalk)] opacity-60">
            Istra &amp; Primorsko-goranska županija
          </p>
        </div>

        <nav className="mt-4 flex flex-wrap gap-x-1 border-t border-white/15 pt-3">
          {LIGE.map((liga) => (
            <Link
              key={liga.slug}
              href={`/liga/${liga.slug}`}
              className="font-display px-3 py-1.5 text-sm font-medium uppercase tracking-wide text-[var(--chalk)] opacity-80 hover:opacity-100 hover:bg-white/10"
            >
              {liga.naziv}
            </Link>
          ))}
        </nav>
      </div>
    </header>
  );
}

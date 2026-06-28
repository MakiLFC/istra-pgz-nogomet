import Link from "next/link";
import { LIGE } from "@/lib/lige";

export default function Navigacija() {
  return (
    <header className="border-b-4 border-black px-6 py-5">
      <div className="mx-auto max-w-5xl">
        <div className="flex flex-wrap items-baseline justify-between gap-3">
          <Link href="/">
            <h1 className="font-sans text-3xl font-extrabold uppercase tracking-tight">
              Žuti<span className="text-[#d4a13d]">Karton</span>
            </h1>
          </Link>
          <p className="font-sans text-xs uppercase tracking-widest text-[#666]">
            Nogomet Istre &amp; Primorsko-goranske županije
          </p>
        </div>

        <nav className="mt-4 flex flex-wrap gap-x-6 gap-y-2 border-t border-[#d8d0c2] pt-3">
          {LIGE.map((liga) => (
            <Link
              key={liga.slug}
              href={`/liga/${liga.slug}`}
              className="font-sans text-sm font-semibold uppercase tracking-wide text-[#1a1a1a] hover:text-[#d4a13d]"
            >
              {liga.naziv}
            </Link>
          ))}
        </nav>
      </div>
    </header>
  );
}

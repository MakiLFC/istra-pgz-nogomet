// KarticaClanka.tsx — jedan članak u popisu (novosti, naslovnica, stranica lige)

import Link from "next/link";
import { type Clanak, datumHr } from "@/lib/clanci";
import { LIGE } from "@/lib/lige";

/**
 * Slika kartice. Kad članak nema svoju fotografiju, uzima se zaglavlje
 * njegove lige, a za članke bez lige zaglavlje novosti.
 *
 * Razlog: kartice bez slike su u mreži izgledale kao rupa pokraj onih
 * sa slikom. Ovako svaka kartica ima sliku, a zamjenska barem kaže o
 * kojoj je ligi riječ.
 */
function slikaKartice(clanak: Clanak): string {
  if (clanak.slika_url) return clanak.slika_url;
  const liga = LIGE.find((l) => l.naziv === clanak.natjecanje);
  return `/slike/zaglavlja/${liga ? liga.slug : "novosti"}.png`;
}

export default function KarticaClanka({
  clanak,
  kompaktno = false,
  className = "",
}: {
  clanak: Clanak;
  kompaktno?: boolean;
  /** Dodatne klase - npr. "h-full" kad kartice stoje u retku jedna do
   *  druge, da im se visine izjednače bez obzira na duljinu sažetka. */
  className?: string;
}) {
  return (
    <Link
      href={`/novosti/${clanak.slug}`}
      className={`block bg-white p-4 transition-opacity hover:opacity-80 ${className}`}
      style={{ border: "1px solid var(--line)" }}
    >
      {!kompaktno && (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={slikaKartice(clanak)}
          alt=""
          className="mb-3 w-full object-cover"
          style={{ maxHeight: 200 }}
        />
      )}

      <p className="flex flex-wrap items-baseline gap-x-2 font-mono text-[10px] uppercase tracking-widest" style={{ color: "var(--ink-muted)" }}>
        <time dateTime={clanak.objavljeno_u}>{datumHr(clanak.objavljeno_u)}</time>
        {clanak.natjecanje && (
          <span style={{ color: "var(--oxide)" }}>{clanak.natjecanje}</span>
        )}
      </p>

      <h3
        className={`font-display mt-1 uppercase leading-tight ${
          kompaktno ? "text-sm" : "text-lg"
        }`}
      >
        {clanak.naslov}
      </h3>

      {clanak.sazetak && (
        <p
          className="mt-1.5 font-sans text-sm leading-snug"
          style={{ color: "var(--ink-muted)" }}
        >
          {clanak.sazetak}
        </p>
      )}
    </Link>
  );
}

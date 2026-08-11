// KarticaClanka.tsx — jedan članak u popisu (novosti, naslovnica, stranica lige)

import Link from "next/link";
import { type Clanak, datumHr } from "@/lib/clanci";

export default function KarticaClanka({
  clanak,
  kompaktno = false,
}: {
  clanak: Clanak;
  kompaktno?: boolean;
}) {
  return (
    <Link
      href={`/novosti/${clanak.slug}`}
      className="block bg-white p-4 transition-opacity hover:opacity-80"
      style={{ border: "1px solid var(--line)" }}
    >
      {clanak.slika_url && !kompaktno && (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={clanak.slika_url}
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

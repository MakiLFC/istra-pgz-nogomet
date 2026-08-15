// app/novosti/[slug]/page.tsx — pojedinačni članak

import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import Navigacija from "@/components/Navigacija";
import { dohvatiClanak, dohvatiClanke, datumHr, odlomci } from "@/lib/clanci";
import { LIGE } from "@/lib/lige";

export const revalidate = 0;

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const clanak = await dohvatiClanak(slug);
  if (!clanak) return { title: "Članak nije pronađen — Lokal-Arena" };
  return {
    title: `${clanak.naslov} — Lokal-Arena`,
    description: clanak.sazetak ?? undefined,
    openGraph: {
      title: clanak.naslov,
      description: clanak.sazetak ?? undefined,
      type: "article",
      images: clanak.slika_url ? [clanak.slika_url] : undefined,
    },
  };
}

export default async function StranicaClanka({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const clanak = await dohvatiClanak(slug);
  if (!clanak) notFound();

  const ligaSlug = LIGE.find((l) => l.naziv === clanak.natjecanje)?.slug;

  return (
    <div className="min-h-screen" style={{ background: "var(--chalk)" }}>
      <Navigacija />

      <main className="mx-auto max-w-2xl px-6 py-14">
        <Link
          href="/novosti"
          className="font-sans text-xs font-medium hover:underline"
          style={{ color: "var(--pitch)" }}
        >
          ← Sve novosti
        </Link>

        <article className="mt-4">
          <p className="flex flex-wrap items-baseline gap-x-2 font-mono text-[10px] uppercase tracking-widest" style={{ color: "var(--ink-muted)" }}>
            <time dateTime={clanak.objavljeno_u}>{datumHr(clanak.objavljeno_u)}</time>
            {clanak.natjecanje &&
              (ligaSlug ? (
                <Link href={`/liga/${ligaSlug}`} className="hover:underline" style={{ color: "var(--oxide)" }}>
                  {clanak.natjecanje}
                </Link>
              ) : (
                <span style={{ color: "var(--oxide)" }}>{clanak.natjecanje}</span>
              ))}
          </p>

          <h1 className="font-display mt-2 text-4xl uppercase">
            {clanak.naslov}
          </h1>

          {clanak.sazetak && (
            <p className="mt-3 font-sans text-lg leading-snug" style={{ color: "var(--ink-muted)" }}>
              {clanak.sazetak}
            </p>
          )}

          {clanak.slika_url && (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={clanak.slika_url}
              alt=""
              className="mt-5 w-full object-cover"
              style={{ maxHeight: 420 }}
            />
          )}

          {/* Tekst je obostrano poravnat, ali riječi se NE rastavljaju
              crticom na kraju retka - svaka riječ mora ostati cjelovita.
              "hyphens-none" stoji izričito: preglednici koji imaju
              hrvatska pravila rastavljanja (Safari, Firefox, noviji
              Chrome) inače sami lome riječi. Cijena je nešto širi
              razmak među riječima na uskim ekranima, što je ovdje
              svjesno prihvaćeno. */}
          <div className="mt-5 space-y-4">
            {odlomci(clanak.tekst).map((o, i) => (
              <p
                key={i}
                className="font-sans text-[15px] leading-relaxed text-justify hyphens-none"
              >
                {o}
              </p>
            ))}
          </div>
        </article>
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

export async function generateStaticParams() {
  const clanci = await dohvatiClanke();
  return clanci.map((c) => ({ slug: c.slug }));
}

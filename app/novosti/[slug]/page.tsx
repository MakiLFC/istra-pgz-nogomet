// app/novosti/[slug]/page.tsx — pojedinačni članak

import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import Navigacija from "@/components/Navigacija";
import Podnozje from "@/components/Podnozje";
import { dohvatiClanak, dohvatiClanke, datumHr, odlomci } from "@/lib/clanci";
import { LIGE } from "@/lib/lige";
import { SLIKA_DIJELJENJE } from "@/lib/metapodaci";

export const revalidate = 0;

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const clanak = await dohvatiClanak(slug);
  if (!clanak) return { title: "Članak nije pronađen" };
  return {
    title: clanak.naslov,
    description: clanak.sazetak ?? undefined,
    alternates: { canonical: `/novosti/${clanak.slug}` },
    openGraph: {
      title: clanak.naslov,
      description: clanak.sazetak ?? undefined,
      url: `/novosti/${clanak.slug}`,
      locale: "hr_HR",
      publishedTime: clanak.objavljeno_u,
      type: "article",
      // Kad članak nema vlastitu sliku, uzima se zajednička. Bez ovoga
      // bi takav članak ostao posve bez slike pri dijeljenju: metadata
      // članka zamjenjuje onu iz layouta, ne nadopunjuje je.
      images: [clanak.slika_url ?? SLIKA_DIJELJENJE.url],
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
          {/* Datum je preseljen u potpis ispod naslova, pa ovdje ostaje
              samo liga. Kad je članak bez lige, redak se ne iscrtava. */}
          {clanak.natjecanje && (
            <p className="font-mono text-[10px] uppercase tracking-widest" style={{ color: "var(--ink-muted)" }}>
              {ligaSlug ? (
                <Link href={`/liga/${ligaSlug}`} className="hover:underline" style={{ color: "var(--oxide)" }}>
                  {clanak.natjecanje}
                </Link>
              ) : (
                <span style={{ color: "var(--oxide)" }}>{clanak.natjecanje}</span>
              )}
            </p>
          )}

          <h1 className="font-display mt-2 text-4xl uppercase">
            {clanak.naslov}
          </h1>

          {/* Potpis: autor i datum u istom retku. Kad autora nema (stariji
              članci), ostaje samo datum, bez znaka razdvajanja. */}
          <p
            className="mt-3 flex flex-wrap items-baseline gap-x-2 font-mono text-[10px] uppercase tracking-widest"
            style={{ color: "var(--ink-muted)" }}
          >
            {clanak.autor && (
              <>
                <span>{clanak.autor}</span>
                <span aria-hidden="true">·</span>
              </>
            )}
            <time dateTime={clanak.objavljeno_u}>{datumHr(clanak.objavljeno_u)}</time>
          </p>

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

      <Podnozje />
    </div>
  );
}

export async function generateStaticParams() {
  const clanci = await dohvatiClanke();
  return clanci.map((c) => ({ slug: c.slug }));
}

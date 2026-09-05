// app/novosti/[slug]/page.tsx — pojedinačni članak

import Link from "next/link";
import Image from "next/image";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import Navigacija from "@/components/Navigacija";
import Podnozje from "@/components/Podnozje";
import Dijeljenje from "@/components/Dijeljenje";
import { dohvatiClanak, dohvatiClanke, datumHr, odlomci } from "@/lib/clanci";
import { kadarSlike } from "@/lib/slike";
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
      images: clanak.slika_url
        ? [{ url: clanak.slika_url, alt: clanak.slika_opis ?? clanak.naslov }]
        : [SLIKA_DIJELJENJE.url],
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

          {/* Fotografija uz članak. Zadržava omjer u kojem je snimljena, pa
              uspravna slika s tribine ne gubi vrh i dno. Zadane mjere 1600
              x 900 služe samo da preglednik unaprijed rezervira prostor;
              stvarni omjer preuzima "h-auto" kad se slika učita.

              "sizes" odgovara stupcu teksta: on je max-w-2xl, dakle 672 px
              na širokom zaslonu, a na uskom zauzima punu širinu. Bez toga
              bi next/image slao veću sliku nego što treba.

              "priority" jer je slika odmah ispod naslova, pa ne smije
              čekati odgodu učitavanja. */}
          {clanak.slika_url && (
            <figure className="mt-5">
              {/* Okvir stalnog omjera 3:2, a slika se u njega uklapa
                  rezanjem viška. Fotografije stižu s mobitela u svakom
                  omjeru, najčešće uspravne, pa bi bez okvira jedna slika
                  zauzela pola ekrana, a druga bila tanka traka.

                  Reže se iz sredine. Kad je važno ono gore ili dolje,
                  okomiti kadar se pomiče stupcem slika_kadar, bez
                  diranja same datoteke (vidi lib/slike.ts). */}
              <div className="relative aspect-[3/2] w-full overflow-hidden">
                <Image
                  src={clanak.slika_url}
                  alt={clanak.slika_opis ?? ""}
                  fill
                  sizes="(max-width: 768px) 100vw, 672px"
                  className="object-cover"
                  style={{ objectPosition: kadarSlike(clanak.slika_kadar) }}
                  priority
                />
              </div>
              {clanak.slika_potpis && (
                <figcaption
                  className="mt-2 font-sans text-xs"
                  style={{ color: "var(--ink-muted)" }}
                >
                  {clanak.slika_potpis}
                </figcaption>
              )}
            </figure>
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

          {/* Gumbi za dijeljenje idu na dno članka, kad je pročitan. */}
          <Dijeljenje putanja={`/novosti/${clanak.slug}`} naslov={clanak.naslov} />
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

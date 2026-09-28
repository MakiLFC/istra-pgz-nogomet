import type { Metadata } from "next";
import StranicaKluba, { metapodaciKluba, parametriKluba } from "@/components/StranicaKluba";

// Starija sezona jednog kluba, npr. /klub/nk-jadran-porec/sezona/2025-26.
// Vidi app/klub/[slug]/page.tsx i adresaKluba u lib/klubovi.ts.
export const revalidate = 300;

// Prazan popis znači: nijedna starija sezona se ne priprema pri gradnji,
// nego pri prvom otvaranju, a onda se drži kao gotova stranica. Bez ove
// funkcije Next.js rutu tretira kao dinamičnu i renderira je pri svakom
// otvaranju. Isto kao kod kola na stranici lige.
export async function generateStaticParams() {
  return [];
}

type P = { slug: string; sezona: string };

export async function generateMetadata({ params }: { params: Promise<P> }): Promise<Metadata> {
  const p = parametriKluba(await params);
  return metapodaciKluba(p.slug, p.sezona);
}

export default async function Page({ params }: { params: Promise<P> }) {
  return <StranicaKluba {...parametriKluba(await params)} />;
}

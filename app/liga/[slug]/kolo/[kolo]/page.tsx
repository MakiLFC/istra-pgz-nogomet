import type { Metadata } from "next";
import StranicaLige, { metapodaciLige, parametriLige } from "@/components/StranicaLige";

// Jedno kolo tekuće sezone, npr. /liga/3-nl-zapad/kolo/6. Vidi
// app/liga/[slug]/page.tsx i adresaLige u lib/lige.ts.
export const revalidate = 300;

// Prazan popis znači: nijedno kolo se ne priprema pri gradnji, nego pri
// prvom otvaranju, a onda se drži kao gotova stranica. Bez ove funkcije
// Next.js rutu tretira kao dinamičnu i renderira je pri svakom otvaranju.
export async function generateStaticParams() {
  return [];
}

type P = { slug: string; kolo: string };

export async function generateMetadata({ params }: { params: Promise<P> }): Promise<Metadata> {
  const p = parametriLige(await params);
  return metapodaciLige(p.slug, { kolo: p.kolo });
}

export default async function Page({ params }: { params: Promise<P> }) {
  return <StranicaLige {...parametriLige(await params)} />;
}

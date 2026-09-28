import type { Metadata } from "next";
import StranicaNovosti, { metapodaciNovosti } from "@/components/StranicaNovosti";
import { LIGE } from "@/lib/lige";

// Novosti jedne lige, npr. /novosti/liga/3-nl-zapad.
// Vidi app/novosti/page.tsx i adresaNovosti u lib/lige.ts.
export const revalidate = 60;

// Liga su četiri, pa se sve pripremaju pri gradnji. Sve ostalo pod ovom
// putanjom nije liga i završava na "nije pronađeno" (vidi komponentu).
export async function generateStaticParams() {
  return LIGE.map((l) => ({ liga: l.slug }));
}

type P = { liga: string };

export async function generateMetadata({ params }: { params: Promise<P> }): Promise<Metadata> {
  const { liga } = await params;
  return metapodaciNovosti(liga);
}

export default async function Page({ params }: { params: Promise<P> }) {
  const { liga } = await params;
  return <StranicaNovosti ligaSlug={liga} />;
}

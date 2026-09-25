import type { Metadata } from "next";
import { LIGE } from "@/lib/lige";
import StranicaLige, { metapodaciLige, parametriLige } from "@/components/StranicaLige";

// Stranica lige: tekuća sezona, zadnje odigrano kolo. Sav sadržaj je u
// components/StranicaLige.tsx, a ista komponenta služi i adresama s
// kolom i sezonom u putanji (vidi adresaLige u lib/lige.ts).
//
// Do 25.09.2026. ova je stranica čitala ?kolo= i ?sezona= iz adrese, pa
// se renderirala pri SVAKOM otvaranju, koliko god revalidate bio. Sada ne
// čita ništa iz upita, pa je gotova stranica koja se osvježava svakih pet
// minuta. Stare adrese s upitom preusmjerava next.config.ts.
export const revalidate = 300;

export async function generateStaticParams() {
  return LIGE.map((liga) => ({ slug: liga.slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  return metapodaciLige(slug);
}

export default async function Page({ params }: { params: Promise<{ slug: string }> }) {
  return <StranicaLige {...parametriLige(await params)} />;
}

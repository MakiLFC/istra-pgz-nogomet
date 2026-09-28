import type { Metadata } from "next";
import StranicaLige, { metapodaciLige, parametriLige } from "@/components/StranicaLige";

// Starija sezona, zadnje odigrano kolo, npr. /liga/3-nl-zapad/sezona/2025-26.
// Vidi app/liga/[slug]/page.tsx i adresaLige u lib/lige.ts.
export const revalidate = 300;

// Vidi objašnjenje u app/liga/[slug]/kolo/[kolo]/page.tsx.
export async function generateStaticParams() {
  return [];
}

type P = { slug: string; sezona: string };

export async function generateMetadata({ params }: { params: Promise<P> }): Promise<Metadata> {
  const p = parametriLige(await params);
  return metapodaciLige(p.slug, { sezona: p.sezona });
}

export default async function Page({ params }: { params: Promise<P> }) {
  return <StranicaLige {...parametriLige(await params)} />;
}

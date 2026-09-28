// app/klub/[slug]/page.tsx — stranica kluba, najnovija sezona.
//
// Sav sadržaj je u components/StranicaKluba.tsx, a ista komponenta služi
// i adresi sa sezonom u putanji (vidi adresaKluba u lib/klubovi.ts).
//
// Do 28.09.2026. je ova stranica čitala ?sezona= iz adrese, pa se
// renderirala pri SVAKOM otvaranju, koliko god revalidate bio. Sada ne
// čita ništa iz upita, pa je gotova stranica koja se osvježava svakih pet
// minuta. Stare adrese s upitom preusmjerava next.config.ts.

import type { Metadata } from "next";
import StranicaKluba, { metapodaciKluba, parametriKluba } from "@/components/StranicaKluba";
import { dohvatiKlubove } from "@/lib/klubovi";

// Isti razlog kao kod stranice utakmice i stranice igrača: klubova je
// pedesetak, svi su u sitemapu, a podaci im se mijenjaju najviše dvaput
// dnevno, koliko puta ide scraper. Pet minuta je bilo prekratko i ova je
// ruta 14.09.2026. bila druga po potrošnji procesora na Vercelu.
//
// 25.09.2026., na Pro planu, spušteno na pet minuta, kao i stranica
// utakmice, da premješteni termin i novi rezultat ne kasne sat vremena.
export const revalidate = 300;

/**
 * Adrese se pripremaju pri gradnji, da ih tražilice zateknu gotove.
 * Ako baza tada nije dostupna, popis je prazan i stranice se grade na
 * zahtjev; nijedna se ne gubi.
 */
export async function generateStaticParams() {
  try {
    const klubovi = await dohvatiKlubove();
    return klubovi.map((k) => ({ slug: k.slug }));
  } catch {
    return [];
  }
}

type P = { slug: string };

export async function generateMetadata({ params }: { params: Promise<P> }): Promise<Metadata> {
  const p = parametriKluba(await params);
  return metapodaciKluba(p.slug);
}

export default async function Page({ params }: { params: Promise<P> }) {
  return <StranicaKluba {...parametriKluba(await params)} />;
}

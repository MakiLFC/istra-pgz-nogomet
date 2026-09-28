// app/novosti/page.tsx — popis svih objavljenih članaka.
//
// Sav sadržaj je u components/StranicaNovosti.tsx, a ista komponenta
// služi i adresi s ligom u putanji (vidi adresaNovosti u lib/lige.ts).
//
// Do 28.09.2026. je filtar lige bio upit (?liga=...), pa se stranica
// renderirala pri SVAKOM otvaranju, koliko god revalidate bio. Sada ne
// čita ništa iz upita, pa je gotova stranica. Stare adrese s upitom
// preusmjerava next.config.ts.

import type { Metadata } from "next";
import StranicaNovosti, { metapodaciNovosti } from "@/components/StranicaNovosti";

// Članak se objavi i treba biti na popisu odmah, pa je interval kratak.
// Popis je jedan upit nad malom tablicom, dakle jeftin.
export const revalidate = 60;

export const metadata: Metadata = metapodaciNovosti();

export default async function Page() {
  return <StranicaNovosti />;
}

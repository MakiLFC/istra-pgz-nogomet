// app/pretraga.json/route.ts — popis za tražilicu na naslovnici.
//
// Jedna datoteka sa svim klubovima i igračima koji imaju svoju stranicu.
// Pretraživanje ide u pregledniku (components/Trazilica.tsx), pa upit
// koji netko upiše ne troši ništa na poslužitelju. Datoteka se priprema
// pri gradnji i osvježava najviše jednom na sat; preglednik je dohvaća
// tek kad se klikne u polje za traženje, ne s naslovnicom.
//
// Popis se slaže iz ISTIH funkcija iz kojih nastaju stranice kluba i
// igrača (dohvatiKlubove, dohvatiIgrace), pa nijedan pogodak ne može
// voditi na "nije pronađeno".
//
// Oblik je namjerno sažet, polja bez imena, jer igrača ima nekoliko
// tisuća:
//   k: [naziv, slug]           klubovi
//   i: [ime, slug, klub]       igrači; klub je onaj iz najnovije sezone

import { dohvatiKlubove } from "@/lib/klubovi";
import { dohvatiIgrace } from "@/lib/igraci";

// Rang-liste se mijenjaju kad prođe scraper, najviše nekoliko puta dnevno.
// Sat vremena je isto kao kod stranice igrača.
export const revalidate = 3600;

export async function GET() {
  const [klubovi, igraci] = await Promise.all([dohvatiKlubove(), dohvatiIgrace()]);

  // Obje funkcije pri grešci baze vraćaju prazan popis. Prazan popis bi
  // se onda sat vremena posluživao kao gotova datoteka i tražilica ne bi
  // nalazila ništa. Kad se baci greška, Next zadrži prethodnu, ispravnu
  // datoteku. Pri gradnji se ne baca, da nedostupna baza ne sruši build.
  if (!klubovi.length && !igraci.length && process.env.NEXT_PHASE !== "phase-production-build") {
    throw new Error("Pretraga: baza nije vratila ni klubove ni igrače.");
  }

  return Response.json({
    k: klubovi.map((k) => [k.naziv, k.slug]),
    i: igraci.map((i) => [i.ime, i.slug, i.klubovi[0] ?? ""]),
  });
}

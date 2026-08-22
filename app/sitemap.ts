// app/sitemap.ts — popis adresa za tražilice (/sitemap.xml).
//
// Statične adrese stoje u kodu, članci se dohvaćaju iz baze. Ako dohvat
// padne, vraćaju se samo statične adrese: nepotpun sitemap je bezazlen,
// a srušen build ili prazna datoteka nisu.

import type { MetadataRoute } from "next";
import { supabase } from "@/lib/supabase";

// Sitemap se osvježava svakih sat vremena, da novi članak ne mora čekati
// sljedeću objavu da bi se u njemu pojavio.
export const revalidate = 3600;

// Adresa stranice. Ista varijabla kao u app/layout.tsx; ovdje se čita
// zasebno da se postojeće datoteke ne diraju. Zamjenska vrijednost je
// domena, nikad Vercelova adresa, da u sitemapu ne osvane vercel.app.
const OSNOVA = (process.env.NEXT_PUBLIC_SITE_URL?.trim() || "https://lokalarena.com")
  .replace(/\/+$/, "");

const adresa = (putanja: string) => `${OSNOVA}${putanja}`;

const STATICNE: MetadataRoute.Sitemap = [
  { url: adresa("/"), priority: 1.0, changeFrequency: "daily" },
  { url: adresa("/novosti"), priority: 0.9, changeFrequency: "daily" },
  { url: adresa("/liga/3-nl-zapad"), priority: 0.9, changeFrequency: "daily" },
  { url: adresa("/liga/4-nl-ns-rijeka"), priority: 0.9, changeFrequency: "daily" },
  { url: adresa("/liga/1-znl-pgz"), priority: 0.8, changeFrequency: "weekly" },
  { url: adresa("/liga/2-znl-pgz"), priority: 0.8, changeFrequency: "weekly" },
  { url: adresa("/impresum"), priority: 0.3, changeFrequency: "yearly" },
  { url: adresa("/kontakt"), priority: 0.3, changeFrequency: "yearly" },
];

/** Objavljeni članci. Kad dohvat ne uspije, vraća prazan popis. */
async function clanci(): Promise<MetadataRoute.Sitemap> {
  try {
    // Samo dva stupca; sitemapu ne treba ni tekst ni slika.
    const { data, error } = await supabase
      .from("clanci")
      .select("slug, objavljeno_u")
      .eq("objavljen", true)
      .order("objavljeno_u", { ascending: false });

    if (error) {
      console.error("Sitemap: greška kod dohvaćanja članaka:", error.message);
      return [];
    }

    return (data ?? [])
      .filter((c): c is { slug: string; objavljeno_u: string } => Boolean(c?.slug))
      .map((c) => {
        const datum = new Date(c.objavljeno_u);
        return {
          url: adresa(`/novosti/${c.slug}`),
          lastModified: isNaN(datum.getTime()) ? undefined : datum,
          priority: 0.7,
          changeFrequency: "monthly" as const,
        };
      });
  } catch (e) {
    console.error("Sitemap: dohvat članaka nije uspio:", e);
    return [];
  }
}

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  return [...STATICNE, ...(await clanci())];
}

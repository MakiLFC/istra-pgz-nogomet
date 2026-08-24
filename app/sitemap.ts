// app/sitemap.ts — popis adresa za tražilice (/sitemap.xml).
//
// Statične adrese stoje u kodu, članci se dohvaćaju iz baze. Ako dohvat
// padne, vraćaju se samo statične adrese: nepotpun sitemap je bezazlen,
// a srušen build ili prazna datoteka nisu.

import type { MetadataRoute } from "next";
import { supabase } from "@/lib/supabase";
import { dohvatiKlubove } from "@/lib/klubovi";
import { dohvatiUtakmiceZaAdrese } from "@/lib/utakmice";
import { dohvatiIgrace } from "@/lib/igraci";
import { slugUtakmice } from "@/lib/slug";

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

/** Stranice klubova. Kad dohvat ne uspije, vraća prazan popis. */
async function klubovi(): Promise<MetadataRoute.Sitemap> {
  try {
    const popis = await dohvatiKlubove();
    return popis.map((k) => ({
      url: adresa(`/klub/${k.slug}`),
      priority: 0.6,
      changeFrequency: "weekly" as const,
    }));
  } catch (e) {
    console.error("Sitemap: dohvat klubova nije uspio:", e);
    return [];
  }
}

/**
 * Utakmice, odigrane i nadolazeće.
 *
 * Nadolazeće su prije bile izostavljene. Ulaze zato što ih ljudi traže
 * prije kola ("tko igra u subotu"), a stranica već ima termin, stadion
 * i oba kluba. Dobivaju manju važnost i dnevno osvježavanje, jer im se
 * sadržaj mijenja čim utakmica bude odigrana; odigrana se poslije toga
 * više ne mijenja.
 */
async function utakmice(): Promise<MetadataRoute.Sitemap> {
  try {
    const popis = await dohvatiUtakmiceZaAdrese();
    return popis.map((u) => ({
      url: adresa(`/utakmica/${slugUtakmice(u)}`),
      priority: u.odigrana ? 0.5 : 0.4,
      changeFrequency: u.odigrana ? ("yearly" as const) : ("daily" as const),
    }));
  } catch (e) {
    console.error("Sitemap: dohvat utakmica nije uspio:", e);
    return [];
  }
}

/** Igrači iz rang-lista strijelaca i kartona. */
async function igraci(): Promise<MetadataRoute.Sitemap> {
  try {
    const popis = await dohvatiIgrace();
    return popis.map((i) => ({
      url: adresa(`/igrac/${i.slug}`),
      priority: 0.5,
      changeFrequency: "weekly" as const,
    }));
  } catch (e) {
    console.error("Sitemap: dohvat igrača nije uspio:", e);
    return [];
  }
}

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const [odClanaka, odKlubova, odUtakmica, odIgraca] = await Promise.all([
    clanci(),
    klubovi(),
    utakmice(),
    igraci(),
  ]);
  return [...STATICNE, ...odKlubova, ...odIgraca, ...odClanaka, ...odUtakmica];
}

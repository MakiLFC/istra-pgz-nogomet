// app/robots.ts — pravila za tražilice (/robots.txt).
//
// Cijela stranica je javna i sve je dopušteno indeksirati. Jedino što
// ovdje stoji je uputa gdje se nalazi popis adresa.

import type { MetadataRoute } from "next";

const OSNOVA = (process.env.NEXT_PUBLIC_SITE_URL?.trim() || "https://lokalarena.com")
  .replace(/\/+$/, "");

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [{ userAgent: "*", allow: "/" }],
    sitemap: `${OSNOVA}/sitemap.xml`,
  };
}

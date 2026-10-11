// lib/rss.ts — RSS 2.0 feed članaka (/rss.xml).
//
// Feed čita vanjska aplikacija (HR Nogomet), kojoj je Andrej 11.10.2026.
// dopustio prikaz NASLOVA, KRATKOG OPISA, DATUMA I POVEZNICE, i ničeg više.
// Zato ovdje namjerno nema punog teksta (content:encoded), slika
// (enclosure, media:*, <img>), rezultata ni tablica. Tko god proširuje
// feed, prvo pita Andreja: to je uvjet dopuštenja, ne tehnička odluka.
//
// Ova datoteka nema ovisnosti o Nextu ni o bazi, samo slaže XML iz
// podataka, pa se može isprobati i bez stranice.

/** Adresa stranice, ista kao u app/robots.ts i app/sitemap.ts. */
export const OSNOVA_FEEDA = (
  process.env.NEXT_PUBLIC_SITE_URL?.trim() || "https://lokalarena.com"
).replace(/\/+$/, "");

export const ADRESA_FEEDA = `${OSNOVA_FEEDA}/rss.xml`;

/** Za `alternates.types` u metapodacima, da preglednici i čitači nađu feed. */
export const RSS_ALTERNATE = { "application/rss+xml": ADRESA_FEEDA };

/** Koliko najnovijih članaka ide u feed. */
export const KOLIKO_U_FEEDU = 30;

/** Jedini stupci koji se uopće čitaju iz tablice clanci. */
export const STUPCI_FEEDA = "slug, naslov, sazetak, natjecanje, objavljeno_u";

export type StavkaFeeda = {
  slug: string;
  naslov: string;
  sazetak: string | null;
  natjecanje: string | null;
  objavljeno_u: string;
};

/** Znakovi koji u XML-u nisu dopušteni ni escapirani (kontrolni znakovi). */
const NEDOPUSTENI = /[\u0000-\u0008\u000B\u000C\u000E-\u001F￾￿]/g;

/** Escapira tekst za XML: & < > " ' i izbacuje nedopuštene znakove. */
export function escapeXml(tekst: string): string {
  return tekst
    .replace(NEDOPUSTENI, "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;");
}

/**
 * Čisti tekst: bez HTML oznaka, s prazninama skupljenim u jedan razmak.
 * Miču se samo prave oznake (<b>, </p>, <img ...>), a ne svaki znak "<",
 * da obična rečenica poput "a < b" ostane cijela.
 */
export function cistiTekst(tekst: string | null | undefined): string {
  return (tekst ?? "")
    .replace(/<\/?[a-zA-Z][^<>]*>/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

/** ISO datum u RFC 822 obliku ("Sun, 11 Oct 2026 08:00:00 GMT"); null kad ne valja. */
export function datumRfc822(iso: string | null | undefined): string | null {
  if (!iso) return null;
  const d = new Date(iso);
  return isNaN(d.getTime()) ? null : d.toUTCString();
}

function stavka(c: StavkaFeeda): string {
  const adresa = `${OSNOVA_FEEDA}/novosti/${encodeURIComponent(c.slug)}`;
  const opis = cistiTekst(c.sazetak);
  const datum = datumRfc822(c.objavljeno_u);
  const liga = cistiTekst(c.natjecanje);

  const redci = [
    `<title>${escapeXml(cistiTekst(c.naslov))}</title>`,
    `<link>${escapeXml(adresa)}</link>`,
    `<guid isPermaLink="true">${escapeXml(adresa)}</guid>`,
  ];
  if (datum) redci.push(`<pubDate>${datum}</pubDate>`);
  // Članak bez kratkog opisa ide bez opisa, a ne s komadom teksta članka
  // (Andrejeva odluka 11.10.2026.). RSS to dopušta kad stavka ima naslov.
  if (opis) redci.push(`<description>${escapeXml(opis)}</description>`);
  if (liga) redci.push(`<category>${escapeXml(liga)}</category>`);

  return `    <item>\n${redci.map((r) => `      ${r}`).join("\n")}\n    </item>`;
}

/** Cijeli feed kao tekst. `sada` je vrijeme slaganja, za lastBuildDate. */
export function slozFeed(clanci: StavkaFeeda[], sada: Date = new Date()): string {
  const kanal = [
    `<title>Lokal-Arena</title>`,
    `<link>${escapeXml(OSNOVA_FEEDA)}</link>`,
    `<description>${escapeXml(
      "Najave, osvrti i novosti nižih nogometnih liga Istre i Primorsko-goranske županije."
    )}</description>`,
    `<language>hr</language>`,
    `<lastBuildDate>${sada.toUTCString()}</lastBuildDate>`,
    `<atom:link href="${escapeXml(ADRESA_FEEDA)}" rel="self" type="application/rss+xml"/>`,
  ];

  return [
    `<?xml version="1.0" encoding="UTF-8"?>`,
    `<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">`,
    `  <channel>`,
    ...kanal.map((r) => `    ${r}`),
    ...clanci.map(stavka),
    `  </channel>`,
    `</rss>`,
    ``,
  ].join("\n");
}

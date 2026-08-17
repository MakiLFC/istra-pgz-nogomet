import type { Metadata } from "next";
import { Archivo, Bebas_Neue, Inter, JetBrains_Mono, Playfair_Display } from "next/font/google";
import "./globals.css";
import { SLIKA_DIJELJENJE } from "@/lib/metapodaci";

// Fontovi se učitavaju preko next/font: Next ih poslužuje s vlastite domene,
// unaprijed ih učita i spriječi treptaj teksta pri otvaranju stranice.
// Prije su dolazili <link>-om na Google, što je blokiralo iscrtavanje.
const archivo = Archivo({
  subsets: ["latin-ext"],
  variable: "--f-display",
  display: "swap",
});

// Zbijeni "plakatni" font - koristi se SAMO za veliki naslov u uvodnoj
// traci naslovnice. Ostali naslovi po stranici i dalje su Archivo.
// Ima samo jednu težinu (400), pa se ne navode ostale.
const heroNaslov = Bebas_Neue({
  subsets: ["latin", "latin-ext"],
  weight: "400",
  variable: "--f-hero",
  display: "swap",
});

const inter = Inter({
  subsets: ["latin-ext"],
  variable: "--f-sans",
  display: "swap",
});

// Serifni kurziv - koristi se SAMO za naglašenu riječ u velikim naslovima
const akcent = Playfair_Display({
  subsets: ["latin-ext"],
  style: ["italic"],
  weight: ["400", "500"],
  variable: "--f-akcent",
  display: "swap",
});

const mono = JetBrains_Mono({
  subsets: ["latin-ext"],
  variable: "--f-mono",
  display: "swap",
});

// Osnovna adresa stranice. Treba je zbog slika u člancima: u bazi se
// upisuju kao "/slike/...", a kad netko podijeli članak na društvenoj
// mreži ta se putanja mora razriješiti u punu adresu.
//
// NAMJERNO SE NE KORISTI "VERCEL_URL". To je adresa POJEDINOG
// deploymenta (npr. ...-f2erh3b6c-...vercel.app): mijenja se pri svakoj
// objavi, pa bi već podijeljene poveznice ostajale bez slike, a ako je
// uključena Vercel Deployment Protection, Facebookov crawler na njoj
// dobije 401 i slika se ne prikaže.
//
// Redoslijed: prvo NEXT_PUBLIC_SITE_URL (ondje upiši svoju domenu, npr.
// lokal-arena.hr), pa stalna produkcijska adresa projekta koju Vercel
// nudi kao VERCEL_PROJECT_PRODUCTION_URL, i na kraju lokalni poslužitelj.
function sShemom(adresa: string): string {
  return /^https?:\/\//i.test(adresa) ? adresa : `https://${adresa}`;
}

const vlastitaAdresa = process.env.NEXT_PUBLIC_SITE_URL?.trim();
const produkcijskaAdresa = process.env.VERCEL_PROJECT_PRODUCTION_URL?.trim();

const osnovnaAdresa = vlastitaAdresa
  ? sShemom(vlastitaAdresa)
  : produkcijskaAdresa
    ? sShemom(produkcijskaAdresa)
    : "http://localhost:3000";

export const metadata: Metadata = {
  metadataBase: new URL(osnovnaAdresa),
  title: "Lokal-Arena — niže nogometne lige Primorsko-goranske županije",
  description:
    "Rezultati, zapisnici, tablice i strijelci nižih nogometnih liga klubova na prostoru Primorsko-goranske županije. Podaci: HNS Semafor.",
  alternates: { canonical: "/" },
  openGraph: {
    title: "Lokal-Arena",
    description:
      "Rezultati, tablice i strijelci nižih nogometnih liga Primorsko-goranske županije.",
    url: "/",
    siteName: "Lokal-Arena",
    type: "website",
    locale: "hr_HR",
    // Zajednička slika za dijeljenje, ista za naslovnicu i sve lige.
    // Namjerno je u omjeru 1200x630 (traži ga Facebook), a ne u omjeru
    // zaglavlja stranica - ona su široka 3,57:1 pa bi ih obrezao.
    // Članci koji imaju vlastitu sliku nadjačavaju ovu.
    images: [SLIKA_DIJELJENJE],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="hr"
      className={`h-full antialiased ${archivo.variable} ${heroNaslov.variable} ${inter.variable} ${mono.variable} ${akcent.variable}`}
    >
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}

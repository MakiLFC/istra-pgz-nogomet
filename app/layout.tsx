import type { Metadata } from "next";
import { Archivo, Inter, JetBrains_Mono, Playfair_Display } from "next/font/google";
import "./globals.css";

// Fontovi se učitavaju preko next/font: Next ih poslužuje s vlastite domene,
// unaprijed ih učita i spriječi treptaj teksta pri otvaranju stranice.
// Prije su dolazili <link>-om na Google, što je blokiralo iscrtavanje.
const archivo = Archivo({
  subsets: ["latin-ext"],
  variable: "--f-display",
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

export const metadata: Metadata = {
  title: "Lokal-Arena — niže nogometne lige Primorsko-goranske županije",
  description:
    "Rezultati, zapisnici, tablice i strijelci nižih nogometnih liga klubova na prostoru Primorsko-goranske županije. Podaci: HNS Semafor.",
  openGraph: {
    title: "Lokal-Arena",
    description:
      "Rezultati, tablice i strijelci nižih nogometnih liga Primorsko-goranske županije.",
    type: "website",
    locale: "hr_HR",
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
      className={`h-full antialiased ${archivo.variable} ${inter.variable} ${mono.variable} ${akcent.variable}`}
    >
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}

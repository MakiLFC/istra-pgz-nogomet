import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Lokal-Arena — niže nogometne lige Primorsko-goranske županije",
  description:
    "Rezultati, zapisnici, tablice i strijelci nižih nogometnih liga klubova na prostoru Primorsko-goranske županije. Podaci: HNS Semafor.",
  // Kad stranica dobije vlastitu domenu, ovdje dodaj:
  // metadataBase: new URL("https://tvoja-domena.hr"),
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
    <html lang="hr" className="h-full antialiased">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          rel="preconnect"
          href="https://fonts.gstatic.com"
          crossOrigin="anonymous"
        />
        {/* Archivo Black (naslovi) + Inter (tekst) + JetBrains Mono (brojke).
            Oswald je izbačen - više se ne koristi nakon promjene dizajna. */}
        <link
          href="https://fonts.googleapis.com/css2?family=Archivo+Black&family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@500;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}

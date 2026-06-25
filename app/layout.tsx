import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Žuti Karton — nogomet Istre i PGŽ-a",
  description:
    "Rezultati, zapisnici i tablice lokalnog nogometa Istre i Primorsko-goranske županije.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="hr" className="h-full antialiased">
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}

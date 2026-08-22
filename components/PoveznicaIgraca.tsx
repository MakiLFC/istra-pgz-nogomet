// PoveznicaIgraca.tsx — ime igrača kao poveznica na njegov profil.
//
// Stranice imaju samo igrači koji se pojavljuju u rang-listama strijelaca
// ili kartona, pa se ova poveznica stavlja samo ondje gdje se čita iz tih
// lista. Vidi lib/igraci.ts.

import Link from "next/link";
import { slugKluba } from "@/lib/slug";

export default function PoveznicaIgraca({
  ime,
  className = "",
}: {
  ime: string;
  className?: string;
}) {
  const slug = slugKluba(ime);
  if (!slug) return <>{ime}</>;

  return (
    <Link href={`/igrac/${slug}`} className={`hover:underline ${className}`}>
      {ime}
    </Link>
  );
}

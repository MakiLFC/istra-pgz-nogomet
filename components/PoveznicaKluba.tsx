// PoveznicaKluba.tsx — ime kluba kao poveznica na njegovu stranicu.
//
// Adresa se izvodi iz imena, jer klubovi u bazi nemaju svoj identifikator.
// Koristi se kljucKluba, a ne slugKluba: u tablici poretka klub s
// kaznenim bodovima piše se kao "NK Crikvenica (-3)", pa adresa mora
// nastati od imena bez tog dodatka, dok se ispisuje puni zapis.

import Link from "next/link";
import { kljucKluba } from "@/lib/slug";

export default function PoveznicaKluba({
  naziv,
  className = "",
  style,
}: {
  naziv: string;
  className?: string;
  style?: React.CSSProperties;
}) {
  const slug = kljucKluba(naziv);
  if (!slug) return <>{naziv}</>;

  return (
    <Link href={`/klub/${slug}`} className={`hover:underline ${className}`} style={style}>
      {naziv}
    </Link>
  );
}

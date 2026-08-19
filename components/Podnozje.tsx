// Podnozje.tsx — zajedničko podnožje svih stranica.
//
// Prije je svaka stranica imala svoje podnožje prepisano u kodu, pa su
// se tekstovi razišli (naslovnica i lige spominjale su izvor podataka,
// novosti nisu). Sad stoji na jednom mjestu.
//
// Impresum i Kontakt NAMJERNO nisu u gornjoj navigaciji: tamo idu samo
// lige i novosti. Ovdje stoje u istom retku i istoj prigušenosti kao
// napomena o izvoru.

import Link from "next/link";

export default function Podnozje() {
  return (
    <footer
      className="px-6 py-5 text-center font-sans text-xs"
      style={{ borderTop: "3px solid var(--pitch)", color: "var(--ink-muted)" }}
    >
      Lokal-Arena — lokalni nogomet Istre i Primorsko-goranske županije ·{" "}
      podaci s HNS Semafora ·{" "}
      <Link href="/impresum" className="hover:underline">
        Impresum
      </Link>{" "}
      ·{" "}
      <Link href="/kontakt" className="hover:underline">
        Kontakt
      </Link>
    </footer>
  );
}

// app/kontakt/page.tsx — kako se javiti redakciji.
//
// NEMA obrasca: nema klijentskog stanja ni slanja iz preglednika, samo
// mailto poveznica. Serverska komponenta, sadržaj fiksan u kodu.

import Link from "next/link";
import type { Metadata } from "next";
import Navigacija from "@/components/Navigacija";
import Podnozje from "@/components/Podnozje";

export const metadata: Metadata = {
  title: "Kontakt",
  description:
    "Javite nam vijest iz kluba, prijavite pogrešku u podacima ili predložite suradnju.",
  alternates: { canonical: "/kontakt" },
};

const POSTA = "lokal.arena26@gmail.com";

const BLOKOVI = [
  {
    naslov: "Klubovi",
    tekst:
      "Dovodite pojačanje, mijenjate trenera, otvarate teren, slavite obljetnicu? Pošaljite dvije-tri rečenice i fotografiju i objavit ćemo. Ne treba vam gotov tekst, dovoljne su informacije.",
  },
  {
    naslov: "Ispravci",
    tekst:
      "Pogrešan rezultat, krivo pripisan gol, pogrešno napisano ime igrača? Javite i ispravljamo. Podaci dolaze s HNS Semafora, pa ćemo pogrešku proslijediti i dalje ako je u izvoru.",
  },
  {
    naslov: "Suradnja",
    tekst:
      "Pišete o lokalnom nogometu, fotografirate utakmice ili vodite klupsku stranicu? Otvoreni smo za suradnju.",
  },
  {
    naslov: "Oglašavanje",
    tekst: "Za oglasni prostor i sponzorstva javite se na istu adresu.",
  },
];

export default function StranicaKontakt() {
  return (
    <div className="min-h-screen" style={{ background: "var(--chalk)" }}>
      <Navigacija />

      {/* Uža ploha nego na stranicama liga, isto kao impresum. */}
      <main className="mx-auto max-w-2xl px-6 py-14">
        <p className="oznaka-sekcije">Pišite nam</p>
        <h1 className="font-display mt-3 text-4xl uppercase tracking-tight">Kontakt</h1>

        <p className="mt-6 font-sans text-[15px] leading-relaxed">
          Lokal-Arena živi od informacija koje dolaze s terena. Ako imate vijest,
          ispravak ili prijedlog, javite se, a odgovaramo u roku od dan-dva.
        </p>

        <p className="mt-8">
          <a
            href={`mailto:${POSTA}`}
            className="font-display text-2xl tracking-tight underline decoration-2 underline-offset-4 sm:text-3xl"
            style={{ color: "var(--oxide)" }}
          >
            {POSTA}
          </a>
        </p>

        <div className="mt-10 space-y-9">
          {BLOKOVI.map((b) => (
            <section key={b.naslov}>
              <h2 className="font-display text-lg uppercase tracking-tight">{b.naslov}</h2>
              <p className="mt-3 font-sans text-[15px] leading-relaxed">{b.tekst}</p>
            </section>
          ))}
        </div>

        <p
          className="mt-12 pt-5 font-sans text-sm"
          style={{ borderTop: "1px solid var(--line)", color: "var(--ink-muted)" }}
        >
          Podaci o izdavaču nalaze se u{" "}
          <Link href="/impresum" className="underline" style={{ color: "var(--pitch)" }}>
            impresumu
          </Link>
          .
        </p>
      </main>

      <Podnozje />
    </div>
  );
}

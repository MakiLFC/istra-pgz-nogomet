// app/impresum/page.tsx — podaci o izdavaču, izvoru podataka i pravima.
//
// Sadržaj je fiksan i stoji u kodu; ne dohvaća se iz baze. Serverska
// komponenta, bez ijednog klijentskog dijela.

import type { Metadata } from "next";
import Navigacija from "@/components/Navigacija";
import Podnozje from "@/components/Podnozje";

export const metadata: Metadata = {
  title: "Impresum",
  description:
    "Podaci o izdavaču portala Lokal-Arena, izvoru podataka i uvjetima korištenja sadržaja.",
  alternates: { canonical: "/impresum" },
};

const POSTA = "lokal.arena26@gmail.com";

/** Naslov odjeljka, u istom slogu kao naslovi sekcija po stranici. */
function Odjeljak({
  naslov,
  children,
}: {
  naslov: string;
  children: React.ReactNode;
}) {
  return (
    <section className="mt-10">
      <h2 className="font-display text-lg uppercase tracking-tight">{naslov}</h2>
      <div
        className="mt-3 space-y-3 font-sans text-[15px] leading-relaxed"
        style={{ color: "var(--ink)" }}
      >
        {children}
      </div>
    </section>
  );
}

function Posta() {
  return (
    <a href={`mailto:${POSTA}`} className="underline" style={{ color: "var(--oxide)" }}>
      {POSTA}
    </a>
  );
}

export default function StranicaImpresum() {
  return (
    <div className="min-h-screen" style={{ background: "var(--chalk)" }}>
      <Navigacija />

      {/* Uža ploha nego na stranicama liga: ovo je tekst za čitanje, a ne
          tablica, pa redak ne smije biti predug. */}
      <main className="mx-auto max-w-2xl px-6 py-14">
        <p className="oznaka-sekcije">O portalu</p>
        <h1 className="font-display mt-3 text-4xl uppercase tracking-tight">Impresum</h1>

        <p className="mt-6 font-sans text-[15px] leading-relaxed">
          Lokal-Arena je portal o nižim nogometnim ligama Istre i
          Primorsko-goranske županije. Prati 3. NL Zapad, 4. NL NS Rijeka te 1. i
          2. ŽNL PGŽ, natjecanja o kojima se rezultati, tablice i statistika
          inače teško pronalaze na jednom mjestu.
        </p>

        <Odjeljak naslov="Izdavač">
          <p>Izdavač i urednik: Andrej Malnar</p>
          <p>
            Kontakt: <Posta />
          </p>
          <p>Sjedište: Rijeka</p>
        </Odjeljak>

        <Odjeljak naslov="Izvor podataka">
          <p>
            Rezultati, tablice, strijelci, kartoni i zapisnici utakmica
            preuzimaju se s HNS Semafora (
            <a
              href="https://semafor.hns.family"
              target="_blank"
              rel="noopener"
              className="underline"
              style={{ color: "var(--oxide)" }}
            >
              semafor.hns.family
            </a>
            ). Za točnost izvornih podataka odgovoran je izvor. Uočite li
            pogrešku, javite nam se i ispravit ćemo je.
          </p>
          <p>
            Lokal-Arena nije službena stranica Hrvatskog nogometnog saveza,
            Nogometnog saveza Primorsko-goranske županije niti bilo kojeg kluba,
            i s njima nije poslovno ni na koji drugi način povezana.
          </p>
        </Odjeljak>

        <Odjeljak naslov="Sadržaj">
          <p>
            Podaci o rezultatima preuzimaju se s HNS Semafora. Svi tekstovi na
            ovoj stranici, vijesti, najave kola, sažeci utakmica i analize,
            nastaju u vlastitoj redakciji i za njih odgovara urednik portala. Ne
            preuzimaju se s drugih portala ni iz priopćenja.
          </p>
        </Odjeljak>

        <Odjeljak naslov="Autorska prava">
          <p>
            Tekstovi, grafički materijali i vizualni identitet na ovoj stranici
            vlasništvo su Lokal-Arene. Prenošenje sadržaja dopušteno je uz
            navođenje izvora i poveznicu na izvorni članak.
          </p>
        </Odjeljak>

        <Odjeljak naslov="Ispravci">
          <p>
            Trudimo se da podaci budu točni, ali pogreške su moguće, i u obradi i
            u izvoru. Svaki ispravak objavljujemo bez odgode. Javite se na{" "}
            <Posta />.
          </p>
        </Odjeljak>

        <Odjeljak naslov="Privatnost">
          <p>
            Stranica ne koristi kolačiće i ne prati posjetitelje. Posjete se
            broje anonimno i skupno.
          </p>
        </Odjeljak>
      </main>

      <Podnozje />
    </div>
  );
}

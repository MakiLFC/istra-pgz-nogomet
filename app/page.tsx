import Link from "next/link";
import { supabase } from "@/lib/supabase";
import { LIGE } from "@/lib/lige";
import Navigacija from "@/components/Navigacija";
import { IkonaTeren } from "@/components/Ikone";
import PregledKola from "@/components/PregledKola";
import Podnozje from "@/components/Podnozje";
import KarticaClanka from "@/components/KarticaClanka";
import { dohvatiClanke } from "@/lib/clanci";
import Otkrivanje from "@/components/Otkrivanje";
import Hero from "@/components/Hero";
import OvajVikend from "@/components/OvajVikend";
import { zadnjeKolo, utakmiceKola, golovi } from "@/lib/kolo";

export const revalidate = 300;

// Naslovnica dohvaća samo stupce koje prikazuje, pa ima i svoj uži tip.
// (Puni tip Utakmica uključuje i postave, koje ovdje namjerno ne vučemo.)
type UtakmicaNaslovnica = {
  id: number;
  natjecanje: string;
  sezona: string | null;
  kolo: number | null;
  domacin: string;
  gost: string;
  rezultat: string | null;
  gledatelja: string | null;
  derbi: boolean | null;
  tekst_clanka: string | null;
};

async function dohvatiUtakmice(): Promise<UtakmicaNaslovnica[]> {
  // Samo stupci koje naslovnica stvarno prikazuje. Prije se dohvaćalo
  // select("*"), što je povlačilo i postave svih utakmica (~4 MB).
  const { data, error } = await supabase
    .from("utakmice")
    .select(
      "id, natjecanje, sezona, kolo, domacin, gost, rezultat, gledatelja, derbi, tekst_clanka"
    )
    .order("created_at", { ascending: false });

  if (error) {
    console.error("Greška kod dohvaćanja utakmica:", error);
    return [];
  }
  return (data ?? []) as UtakmicaNaslovnica[];
}

function grupirajPoNatjecanju(utakmice: UtakmicaNaslovnica[]) {
  const grupe: Record<string, UtakmicaNaslovnica[]> = {};
  for (const u of utakmice) {
    if (!grupe[u.natjecanje]) grupe[u.natjecanje] = [];
    grupe[u.natjecanje].push(u);
  }
  return grupe;
}

export default async function Home() {
  const [utakmice, clanci] = await Promise.all([
    dohvatiUtakmice(),
    dohvatiClanke({ koliko: 4 }),
  ]);
  // Naslovnica uvijek prikazuje NAJNOVIJU sezonu. Stare ostaju u bazi,
  // ali se ne miješaju s tekućom (inače bi se brojke zbrajale kroz godine).
  const sezone = utakmice
    .map((u) => u.sezona)
    .filter((s): s is string => Boolean(s));
  const tekucaSezona = sezone.length ? sezone.sort().reverse()[0] : null;

  const utakmiceSezone = tekucaSezona
    ? utakmice.filter((u) => u.sezona === tekucaSezona)
    : utakmice;

  const grupe = grupirajPoNatjecanju(utakmiceSezone);

  // Brojke za uvodnu traku. Utakmice i golovi broje se SAMO za odigrane
  // susrete, pa brojka raste iz kola u kolo umjesto da od prvog dana
  // stoji na punom rasporedu.
  const odigrane = utakmiceSezone.filter((u) => golovi(u.rezultat));
  const ukupnoGolova = odigrane.reduce((zbroj, u) => {
    const g = golovi(u.rezultat)!;
    return zbroj + g[0] + g[1];
  }, 0);

  // Klubovi se broje iz cijelog rasporeda - poznati su i prije prvog kola.
  const klubovi = new Set<string>();
  for (const u of utakmiceSezone) {
    if (u.domacin) klubovi.add(u.domacin);
    if (u.gost) klubovi.add(u.gost);
  }

  return (
    <div className="min-h-screen" style={{ background: "var(--chalk)" }}>
      <Navigacija />

      <Hero
        brojLiga={LIGE.length}
        brojKlubova={klubovi.size}
        brojUtakmica={odigrane.length}
        brojGolova={ukupnoGolova}
        sezona={tekucaSezona}
      />

      <main className="mx-auto max-w-6xl px-6 py-14">
        {utakmiceSezone.length === 0 && (
          <p className="font-sans text-sm" style={{ color: "var(--ink-muted)" }}>
            Trenutno nema učitanih utakmica. Pokreni scraper da napuniš bazu podataka.
          </p>
        )}

        {/* Traka "Ovaj vikend" stoji iznad novosti. Sama se skriva kad
            nema nadolazećih utakmica, pa ovdje nema uvjeta. */}
        <OvajVikend />

        {/* Novosti idu u puni redak iznad rezultata: do četiri kartice
            jedna do druge, najnovija lijevo (upit ih već vraća posloženo
            po datumu, najnovija prva). Na užim ekranima red se lomi na
            dvije pa na jednu karticu. */}
        {clanci.length > 0 && (
          <section className="mb-14">
            <Otkrivanje>
              <div
                className="mb-5 flex flex-wrap items-end justify-between gap-x-6 gap-y-2 pb-3"
                style={{ borderBottom: "1px solid var(--line)" }}
              >
                <div>
                  <p className="oznaka-sekcije">Novosti</p>
                  <h2 className="font-display mt-1.5 text-2xl uppercase">Najnovije</h2>
                </div>
                <Link
                  href="/novosti"
                  className="font-sans text-sm font-medium hover:opacity-70"
                  style={{ color: "var(--pitch)" }}
                >
                  Sve novosti →
                </Link>
              </div>
            </Otkrivanje>

            <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4">
              {clanci.map((c, idx) => (
                <Otkrivanje key={c.id} kasnjenje={idx * 60} className="h-full">
                  <KarticaClanka clanak={c} className="h-full" />
                </Otkrivanje>
              ))}
            </div>
          </section>
        )}

        {/* Dva stupca: lijevo pregled kola po ligama, desno rezultati.
            Na mobitelu pregled ide ispod rezultata (flex-col-reverse). */}
        <div className="flex flex-col-reverse gap-8 lg:flex-row">
          <aside className="w-full shrink-0 space-y-4 lg:w-72">
            <PregledKola utakmice={utakmiceSezone} />
          </aside>

          <div className="min-w-0 flex-1">
        {LIGE.map((liga) => {
          const utakmiceLige = grupe[liga.naziv];
          if (!utakmiceLige || utakmiceLige.length === 0) return null;

          // Sekcija se zove "Rezultati · N. kolo", pa i pokazuje utakmice
          // TOG kola, i to samo odigrane.
          //
          // Prije se uzimalo šest najnovijih odigranih utakmica lige, uz
          // označeni derbi na prvom mjestu. To je imalo dvije rupe:
          //
          //   1. derbi se uzimao iz SVIH utakmica lige, bez provjere je li
          //      odigran, pa je neodigrana utakmica označena kao derbi
          //      upadala među rezultate, s "?:?" umjesto rezultata, i još
          //      istiskivala jedan pravi rezultat. Tako se 02.09.2026.
          //      Pomorac - Jadran-Poreč iz 2. kola našao među rezultatima
          //      prvog.
          //   2. šest najnovijih zna pomiješati dva kola čim se odigra prva
          //      utakmica novog, a naslov bi i dalje govorio samo o jednom.
          //
          // Sada je popis vezan uz kolo iz naslova, pa oba slučaja otpadaju.
          const kolo = zadnjeKolo(utakmiceSezone, liga.naziv);
          const odigraneKola = utakmiceKola(utakmiceSezone, liga.naziv, kolo)
            .filter((u) => golovi(u.rezultat));
          // Označeni derbi ide na prvo mjesto, ako je iz ovog kola i odigran.
          const derbi = odigraneKola.find((u) => u.derbi) ?? null;
          const najnovije = derbi
            ? [derbi, ...odigraneKola.filter((u) => u.id !== derbi.id)]
            : odigraneKola;
          // Prije početka sezone raspored postoji, ali nijedna utakmica
          // još nije odigrana - ništa za prikazati ovdje.
          if (najnovije.length === 0) return null;

          return (
            <section key={liga.slug} className="mb-16">
              <Otkrivanje>
                <div
                  className="mb-5 flex flex-wrap items-end justify-between gap-x-6 gap-y-2 pb-3"
                  style={{ borderBottom: "1px solid var(--line)" }}
                >
                  <div>
                    <p className="oznaka-sekcije">
                      Rezultati{kolo ? ` · ${kolo}. kolo` : ""}
                    </p>
                    <h2 className="font-display mt-1.5 text-2xl uppercase">
                      {liga.naziv}
                    </h2>
                  </div>
                  <Link
                    href={`/liga/${liga.slug}`}
                    className="font-sans text-sm font-medium hover:opacity-70"
                    style={{ color: "var(--pitch)" }}
                  >
                    Svi rezultati i kola →
                  </Link>
                </div>
              </Otkrivanje>

              <div className="grid grid-cols-1 gap-2.5 sm:grid-cols-2">
                {najnovije.map((u, idx) => {
                  const sadrzaj = (
                    <>
                      <IkonaTeren />
                      <p className="font-sans text-[15px] leading-snug">
                        <span className="font-medium">{u.domacin}</span>{" "}
                        <span className="semafor text-sm">{u.rezultat ?? "?:?"}</span>{" "}
                        <span className="font-medium">{u.gost}</span>
                      </p>
                      {u.derbi && (
                        <span
                          className="ml-auto shrink-0 px-1.5 py-0.5 font-display text-[10px] font-bold uppercase tracking-widest"
                          style={{ background: "var(--card-yellow)", color: "var(--ink)" }}
                        >
                          Derbi
                        </span>
                      )}
                    </>
                  );

                  // Derbi kartica je klikabilna - vodi na kolo te utakmice
                  // na stranici lige, gdje čeka sažetak.
                  return u.derbi ? (
                    <Otkrivanje key={u.id} kasnjenje={idx * 45}>
                    <Link
                      href={`/liga/${liga.slug}${u.kolo ? `?kolo=${u.kolo}` : ""}`}
                      className="flex items-center gap-3 bg-white px-4 py-3 transition-opacity hover:opacity-80"
                      style={{ border: "2px solid var(--card-yellow)" }}
                    >
                      {sadrzaj}
                    </Link>
                    </Otkrivanje>
                  ) : (
                    <Otkrivanje key={u.id} kasnjenje={idx * 45}>
                    <div
                      className="flex items-center gap-3 bg-white px-4 py-3"
                      style={{ border: "1px solid var(--line)" }}
                    >
                      {sadrzaj}
                    </div>
                    </Otkrivanje>
                  );
                })}
              </div>
            </section>
          );
        })}
          </div>
        </div>
      </main>

      <Podnozje />
    </div>
  );
}

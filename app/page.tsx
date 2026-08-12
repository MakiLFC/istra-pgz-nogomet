import Link from "next/link";
import { supabase, Utakmica } from "@/lib/supabase";
import { LIGE } from "@/lib/lige";
import Navigacija from "@/components/Navigacija";
import { IkonaTeren } from "@/components/Ikone";
import PregledKola from "@/components/PregledKola";
import KarticaClanka from "@/components/KarticaClanka";
import { dohvatiClanke } from "@/lib/clanci";
import Otkrivanje from "@/components/Otkrivanje";
import Hero from "@/components/Hero";
import { zadnjeKolo, golovi } from "@/lib/kolo";

export const revalidate = 300;

async function dohvatiUtakmice(): Promise<Utakmica[]> {
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
  return data ?? [];
}

function grupirajPoNatjecanju(utakmice: Utakmica[]) {
  const grupe: Record<string, Utakmica[]> = {};
  for (const u of utakmice) {
    if (!grupe[u.natjecanje]) grupe[u.natjecanje] = [];
    grupe[u.natjecanje].push(u);
  }
  return grupe;
}

export default async function Home() {
  const [utakmice, clanci] = await Promise.all([
    dohvatiUtakmice(),
    dohvatiClanke({ koliko: 3 }),
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

        {/* Dva stupca: lijevo pregled kola po ligama, desno rezultati.
            Na mobitelu pregled ide ispod rezultata (flex-col-reverse). */}
        <div className="flex flex-col-reverse gap-8 lg:flex-row">
          <aside className="w-full shrink-0 space-y-4 lg:w-72">
            {clanci.length > 0 && (
              <section style={{ background: "var(--paper)", border: "1px solid var(--line)" }}>
                <div className="flex items-baseline justify-between gap-2 px-3 py-2" style={{ background: "var(--pitch)", color: "var(--chalk)" }}>
                  <h3 className="font-display text-sm uppercase tracking-wide">Novosti</h3>
                  <Link href="/novosti" className="font-sans text-[11px] hover:underline">sve →</Link>
                </div>
                <div className="space-y-2 p-2">
                  {clanci.map((c) => (
                    <KarticaClanka key={c.id} clanak={c} kompaktno />
                  ))}
                </div>
              </section>
            )}
            <PregledKola utakmice={utakmiceSezone} />
          </aside>

          <div className="min-w-0 flex-1">
        {LIGE.map((liga) => {
          const utakmiceLige = grupe[liga.naziv];
          if (!utakmiceLige || utakmiceLige.length === 0) return null;

          // Derbi lige (ako je označen) uvijek ulazi u prikaz, i to na prvo
          // mjesto - ostatak popunjavamo najnovijim utakmicama do ukupno 6.
          const kolo = zadnjeKolo(utakmiceSezone, liga.naziv);
          const derbi = utakmiceLige.find((u) => u.derbi) ?? null;
          const ostale = derbi
            ? utakmiceLige.filter((u) => u.id !== derbi.id)
            : utakmiceLige;
          const najnovije = derbi
            ? [derbi, ...ostale.slice(0, 5)]
            : ostale.slice(0, 6);

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

      <footer
        className="px-6 py-5 text-center font-sans text-xs"
        style={{ borderTop: "3px solid var(--pitch)", color: "var(--ink-muted)" }}
      >
        Lokal-Arena — lokalni nogomet Istre i Primorsko-goranske županije · podaci s HNS Semafora
      </footer>
    </div>
  );
}

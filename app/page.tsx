import Link from "next/link";
import { supabase, Utakmica } from "@/lib/supabase";
import { LIGE } from "@/lib/lige";
import Navigacija from "@/components/Navigacija";
import { IkonaTeren } from "@/components/Ikone";

export const revalidate = 0;

async function dohvatiUtakmice(): Promise<Utakmica[]> {
  const { data, error } = await supabase
    .from("utakmice")
    .select("*")
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
  const utakmice = await dohvatiUtakmice();
  const grupe = grupirajPoNatjecanju(utakmice);

  return (
    <div className="min-h-screen" style={{ background: "var(--chalk)" }}>
      <Navigacija />

      <main className="mx-auto max-w-5xl px-6 py-10">
        {utakmice.length === 0 && (
          <p className="font-sans text-sm" style={{ color: "var(--ink-muted)" }}>
            Trenutno nema učitanih utakmica. Pokreni scraper da napuniš bazu podataka.
          </p>
        )}

        {LIGE.map((liga) => {
          const utakmiceLige = grupe[liga.naziv];
          if (!utakmiceLige || utakmiceLige.length === 0) return null;

          // Derbi lige (ako je označen) uvijek ulazi u prikaz, i to na prvo
          // mjesto - ostatak popunjavamo najnovijim utakmicama do ukupno 6.
          const derbi = utakmiceLige.find((u) => u.derbi) ?? null;
          const ostale = derbi
            ? utakmiceLige.filter((u) => u.id !== derbi.id)
            : utakmiceLige;
          const najnovije = derbi
            ? [derbi, ...ostale.slice(0, 5)]
            : ostale.slice(0, 6);

          return (
            <section key={liga.slug} className="mb-10">
              <div
                className="mb-3 flex items-baseline justify-between pb-2"
                style={{ borderBottom: "3px solid var(--pitch)" }}
              >
                <h2 className="font-display text-lg font-semibold uppercase tracking-wide">
                  {liga.naziv}
                </h2>
                <Link
                  href={`/liga/${liga.slug}`}
                  className="font-sans text-xs font-medium hover:underline"
                  style={{ color: "var(--pitch)" }}
                >
                  Svi rezultati i kola →
                </Link>
              </div>

              <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
                {najnovije.map((u) => {
                  const sadrzaj = (
                    <>
                      <IkonaTeren />
                      <p className="font-sans text-[15px] leading-snug">
                        <span className="font-medium">{u.domacin}</span>{" "}
                        <span className="font-mono font-bold" style={{ color: "var(--pitch)" }}>
                          {u.rezultat ?? "?:?"}
                        </span>{" "}
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
                    <Link
                      key={u.id}
                      href={`/liga/${liga.slug}${u.kolo ? `?kolo=${u.kolo}` : ""}`}
                      className="flex items-center gap-3 bg-white px-4 py-3 transition-opacity hover:opacity-80"
                      style={{ border: "2px solid var(--card-yellow)" }}
                    >
                      {sadrzaj}
                    </Link>
                  ) : (
                    <div
                      key={u.id}
                      className="flex items-center gap-3 bg-white px-4 py-3"
                      style={{ border: "1px solid var(--line)" }}
                    >
                      {sadrzaj}
                    </div>
                  );
                })}
              </div>
            </section>
          );
        })}
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

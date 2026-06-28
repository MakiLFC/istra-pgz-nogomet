import Link from "next/link";
import { supabase, Utakmica } from "@/lib/supabase";
import { LIGE } from "@/lib/lige";
import Navigacija from "@/components/Navigacija";

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
    <div className="min-h-screen bg-[#faf7f2] text-[#1a1a1a]">
      <Navigacija />

      <main className="mx-auto max-w-5xl px-6 py-10">
        {utakmice.length === 0 && (
          <p className="font-sans text-sm text-[#888]">
            Trenutno nema učitanih utakmica. Pokreni scraper da napuniš bazu podataka.
          </p>
        )}

        {LIGE.map((liga) => {
          const utakmiceLige = grupe[liga.naziv];
          if (!utakmiceLige || utakmiceLige.length === 0) return null;

          // Na početnoj prikazujemo SAMO najnovije rezultate (sažeto), bez
          // strijelaca i drugih detalja - puni detalji su na stranici lige
          const najnovije = utakmiceLige.slice(0, 6);

          return (
            <section key={liga.slug} className="mb-12">
              <div className="mb-4 flex items-baseline justify-between border-b-2 border-black pb-2">
                <h2 className="font-sans text-xs font-bold uppercase tracking-widest">
                  {liga.naziv}
                </h2>
                <Link
                  href={`/liga/${liga.slug}`}
                  className="font-sans text-xs font-semibold text-[#d4a13d] hover:underline"
                >
                  Svi rezultati i kola →
                </Link>
              </div>

              <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
                {najnovije.map((u) => (
                  <div
                    key={u.id}
                    className="border border-[#d8d0c2] bg-white px-4 py-3"
                  >
                    <p className="font-serif text-base leading-snug">
                      <span className="font-semibold">{u.domacin}</span>
                      {" "}
                      <span className="text-[#d4a13d] font-bold">
                        {u.rezultat ?? "?:?"}
                      </span>
                      {" "}
                      <span className="font-semibold">{u.gost}</span>
                    </p>
                  </div>
                ))}
              </div>
            </section>
          );
        })}
      </main>

      <footer className="border-t-4 border-black px-6 py-5 text-center font-sans text-xs text-[#888]">
        Žuti Karton — lokalni nogomet Istre i Primorsko-goranske županije · podaci s HNS Semafora
      </footer>
    </div>
  );
}

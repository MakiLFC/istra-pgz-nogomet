import { supabase, Utakmica } from "@/lib/supabase";

// Next.js posebna postavka: ne keširaj ovu stranicu, uvijek dohvati svježe
// podatke pri svakom posjetu - bitno jer se rezultati mijenjaju iz dana u dan
export const revalidate = 0;

const NATJECANJA_REDOSLIJED = [
  "3. NL Zapad",
  "4. NL NS Rijeka",
  "1. ŽNL PGŽ",
  "2. ŽNL PGŽ",
];

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
      {/* MASTHEAD */}
      <header className="border-b-4 border-black px-6 py-7">
        <div className="mx-auto max-w-5xl flex flex-wrap items-baseline justify-between gap-3">
          <h1 className="font-sans text-3xl font-extrabold uppercase tracking-tight">
            Žuti<span className="text-[#d4a13d]">Karton</span>
          </h1>
          <p className="font-sans text-xs uppercase tracking-widest text-[#666]">
            Nogomet Istre &amp; Primorsko-goranske županije
          </p>
        </div>
      </header>

      <main className="mx-auto max-w-5xl px-6 py-10">
        {utakmice.length === 0 && (
          <p className="font-sans text-sm text-[#888]">
            Trenutno nema učitanih utakmica. Pokreni scraper da napuniš bazu podataka.
          </p>
        )}

        {NATJECANJA_REDOSLIJED.map((naziv) => {
          const utakmiceLige = grupe[naziv];
          if (!utakmiceLige || utakmiceLige.length === 0) return null;

          return (
            <section key={naziv} className="mb-12">
              <h2 className="mb-4 border-b-2 border-black pb-2 font-sans text-xs font-bold uppercase tracking-widest text-[#1a1a1a]">
                {naziv}
                <span className="ml-2 font-normal text-[#999]">
                  ({utakmiceLige.length} utakmica)
                </span>
              </h2>

              <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
                {utakmiceLige.map((u) => (
                  <article
                    key={u.id}
                    className="border border-[#d8d0c2] bg-white p-4"
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

                    {u.strijelci && u.strijelci.length > 0 && (
                      <p className="mt-2 font-sans text-xs text-[#666]">
                        ⚽{" "}
                        {u.strijelci
                          .map((s) => `${s.igrac} ${s.minuta}`)
                          .join(", ")}
                      </p>
                    )}

                    {u.stadion_datum && (
                      <p className="mt-2 font-sans text-[0.7rem] uppercase tracking-wide text-[#aaa]">
                        {u.stadion_datum}
                      </p>
                    )}
                  </article>
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

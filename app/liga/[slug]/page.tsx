import Link from "next/link";
import { notFound } from "next/navigation";
import { supabase, Utakmica } from "@/lib/supabase";
import { ligaPoSlugu, LIGE } from "@/lib/lige";
import Navigacija from "@/components/Navigacija";
import Postava from "@/components/Postava";

export const revalidate = 0;

async function dohvatiUtakmiceLige(nazivLige: string): Promise<Utakmica[]> {
  const { data, error } = await supabase
    .from("utakmice")
    .select("*")
    .eq("natjecanje", nazivLige)
    .order("kolo", { ascending: true });

  if (error) {
    console.error("Greška kod dohvaćanja utakmica:", error);
    return [];
  }
  return data ?? [];
}

export default async function StranicaLige({
  params,
  searchParams,
}: {
  params: Promise<{ slug: string }>;
  searchParams: Promise<{ kolo?: string }>;
}) {
  const { slug } = await params;
  const { kolo: koloIzUrl } = await searchParams;

  const liga = ligaPoSlugu(slug);
  if (!liga) notFound();

  const sveUtakmice = await dohvatiUtakmiceLige(liga.naziv);

  // Popis svih kola koja postoje za ovu ligu, sortirano, bez duplikata
  const svaKola = Array.from(
    new Set(sveUtakmice.map((u) => u.kolo).filter((k): k is number => k !== null))
  ).sort((a, b) => a - b);

  // Ako kolo nije navedeno u URL-u, prikaži NAJNOVIJE kolo koje ima utakmice
  const odabranoKolo = koloIzUrl ? parseInt(koloIzUrl, 10) : svaKola[svaKola.length - 1];

  const utakmiceKola = sveUtakmice.filter((u) => u.kolo === odabranoKolo);

  return (
    <div className="min-h-screen bg-[#faf7f2] text-[#1a1a1a]">
      <Navigacija />

      <main className="mx-auto max-w-5xl px-6 py-10">
        <h1 className="mb-1 font-sans text-2xl font-extrabold uppercase tracking-tight">
          {liga.naziv}
        </h1>
        <p className="mb-6 font-sans text-xs text-[#999]">
          {sveUtakmice.length} utakmica ukupno · sezona 2025/26
        </p>

        {/* IZBORNIK KOLA */}
        <div className="mb-8 flex flex-wrap gap-2 border-b border-[#d8d0c2] pb-6">
          {svaKola.map((k) => (
            <Link
              key={k}
              href={`/liga/${slug}?kolo=${k}`}
              className={`px-3 py-1.5 font-sans text-sm font-semibold ${
                k === odabranoKolo
                  ? "bg-[#1a1a1a] text-white"
                  : "border border-[#d8d0c2] bg-white text-[#1a1a1a] hover:border-[#1a1a1a]"
              }`}
            >
              {k}. kolo
            </Link>
          ))}
        </div>

        {/* UTAKMICE ODABRANOG KOLA */}
        {utakmiceKola.length === 0 ? (
          <p className="font-sans text-sm text-[#888]">
            Nema podataka za odabrano kolo.
          </p>
        ) : (
          <div className="space-y-4">
            <h2 className="font-sans text-xs font-bold uppercase tracking-widest text-[#999]">
              {odabranoKolo}. kolo
            </h2>

            {utakmiceKola.map((u) => {
              // Utakmice predane bez borbe nemaju strijelce/postave u zapisniku
              // - to je normalno (administrativni rezultat), ne greška, pa to
              // jasno naznačimo umjesto da prikažemo prazne sekcije
              const imaDetalje =
                (u.strijelci && u.strijelci.length > 0) ||
                (u.postava_domacin && u.postava_domacin.length > 0) ||
                (u.postava_gost && u.postava_gost.length > 0);

              return (
                <article key={u.id} className="border border-[#d8d0c2] bg-white p-5">
                  <p className="font-serif text-lg leading-snug">
                    <span className="font-semibold">{u.domacin}</span>
                    {" "}
                    <span className="text-[#d4a13d] font-bold">
                      {u.rezultat ?? "?:?"}
                    </span>
                    {" "}
                    <span className="font-semibold">{u.gost}</span>
                  </p>

                  <div className="mt-3 grid grid-cols-1 gap-y-1 font-sans text-sm text-[#555] sm:grid-cols-2">
                    {u.stadion_datum && <p>{u.stadion_datum}</p>}
                    {u.gledatelja && u.gledatelja !== "Nepoznato" && (
                      <p>Gledatelja: {u.gledatelja}</p>
                    )}
                    {u.suci && u.suci !== "Nepoznato" && <p>Suci: {u.suci}</p>}
                  </div>

                  {!imaDetalje && (
                    <p className="mt-3 font-sans text-sm italic text-[#999]">
                      Utakmica predana bez borbe — zapisnik nije dostupan.
                    </p>
                  )}

                  {u.strijelci && u.strijelci.length > 0 && (
                    <p className="mt-3 font-sans text-sm text-[#1a1a1a]">
                      <span className="font-semibold">⚽ Strijelci: </span>
                      {u.strijelci.map((s) => `${s.igrac} ${s.minuta}`).join(", ")}
                    </p>
                  )}

                  {(u.postava_domacin?.length || u.postava_gost?.length) ? (
                    <details className="mt-3 group">
                      <summary className="cursor-pointer font-sans text-sm font-semibold text-[#d4a13d] hover:underline">
                        Postave i izmjene
                      </summary>
                      <div className="mt-3 grid grid-cols-1 gap-6 border-t border-[#d8d0c2] pt-3 sm:grid-cols-2">
                        {u.postava_domacin && u.postava_domacin.length > 0 && (
                          <Postava nazivKluba={u.domacin} igraci={u.postava_domacin} />
                        )}
                        {u.postava_gost && u.postava_gost.length > 0 && (
                          <Postava nazivKluba={u.gost} igraci={u.postava_gost} />
                        )}
                      </div>
                    </details>
                  ) : null}
                </article>
              );
            })}
          </div>
        )}
      </main>

      <footer className="border-t-4 border-black px-6 py-5 text-center font-sans text-xs text-[#888]">
        Žuti Karton — lokalni nogomet Istre i Primorsko-goranske županije · podaci s HNS Semafora
      </footer>
    </div>
  );
}

// Generira statičke putanje za sve lige unaprijed (poboljšava performanse)
export async function generateStaticParams() {
  return LIGE.map((liga) => ({ slug: liga.slug }));
}

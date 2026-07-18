import Link from "next/link";
import { notFound } from "next/navigation";
import { supabase, Utakmica } from "@/lib/supabase";
import { ligaPoSlugu, LIGE } from "@/lib/lige";
import Navigacija from "@/components/Navigacija";
import Postava from "@/components/Postava";
import { IkonaLopta, IkonaTeren } from "@/components/Ikone";

export const revalidate = 0;

// Strijelci u bazi nisu eksplicitno označeni kojem klubu pripadaju, ali
// znamo postave oba kluba - pa svakog strijelca pripisujemo klubu čija
// postava sadrži njegovo ime. Ako postava nije dostupna (rijetko), strijelac
// ostaje u "nepoznato" skupu kao siguran fallback.
function razdvojiStrijelceePoKlubu(u: Utakmica) {
  const domacinImena = new Set((u.postava_domacin ?? []).map((i) => i.igrac));
  const gostImena = new Set((u.postava_gost ?? []).map((i) => i.igrac));

  const domacin: typeof u.strijelci = [];
  const gost: typeof u.strijelci = [];
  const nepoznato: typeof u.strijelci = [];

  for (const s of u.strijelci ?? []) {
    if (domacinImena.has(s.igrac)) domacin!.push(s);
    else if (gostImena.has(s.igrac)) gost!.push(s);
    else nepoznato!.push(s);
  }

  return { domacin, gost, nepoznato };
}

async function dohvatiSezone(nazivLige: string): Promise<string[]> {
  const { data, error } = await supabase
    .from("utakmice")
    .select("sezona")
    .eq("natjecanje", nazivLige);

  if (error || !data) return ["2025/26"];
  const jedinstvene = Array.from(new Set(data.map((d) => d.sezona ?? "2025/26")));
  return jedinstvene.sort().reverse();
}

async function dohvatiUtakmiceLige(nazivLige: string, sezona: string): Promise<Utakmica[]> {
  const { data, error } = await supabase
    .from("utakmice")
    .select("*")
    .eq("natjecanje", nazivLige)
    .eq("sezona", sezona)
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
  searchParams: Promise<{ kolo?: string; sezona?: string }>;
}) {
  const { slug } = await params;
  const { kolo: koloIzUrl, sezona: sezonaIzUrl } = await searchParams;

  const liga = ligaPoSlugu(slug);
  if (!liga) notFound();

  const sveSezone = await dohvatiSezone(liga.naziv);
  const odabranaSezona = sezonaIzUrl ?? sveSezone[0] ?? "2025/26";

  const sveUtakmice = await dohvatiUtakmiceLige(liga.naziv, odabranaSezona);

  const svaKola = Array.from(
    new Set(sveUtakmice.map((u) => u.kolo).filter((k): k is number => k !== null))
  ).sort((a, b) => a - b);

  const odabranoKolo = koloIzUrl ? parseInt(koloIzUrl, 10) : svaKola[svaKola.length - 1];

  const utakmiceKola = sveUtakmice.filter((u) => u.kolo === odabranoKolo);

  return (
    <div className="min-h-screen" style={{ background: "var(--chalk)" }}>
      <Navigacija />

      <main className="mx-auto max-w-5xl px-6 py-10">
        <div className="mb-1 flex flex-wrap items-baseline justify-between gap-3">
          <h1 className="font-display text-2xl font-semibold uppercase tracking-wide">
            {liga.naziv}
          </h1>

          {sveSezone.length > 0 && (
            <div className="flex gap-1">
              {sveSezone.map((s) => {
                const aktivno = s === odabranaSezona;
                return (
                  <Link
                    key={s}
                    href={`/liga/${slug}?sezona=${encodeURIComponent(s)}`}
                    className="font-mono px-2.5 py-1 text-xs font-medium"
                    style={
                      aktivno
                        ? { background: "var(--arena-blue)", color: "var(--chalk)" }
                        : { border: "1px solid var(--line)", background: "white", color: "var(--ink)" }
                    }
                  >
                    {s}
                  </Link>
                );
              })}
            </div>
          )}
        </div>

        <p className="mb-6 font-mono text-xs" style={{ color: "var(--ink-muted)" }}>
          {sveUtakmice.length} utakmica ukupno · sezona {odabranaSezona}
        </p>

        {svaKola.length === 0 ? (
          <p className="font-sans text-sm" style={{ color: "var(--ink-muted)" }}>
            Nema podataka za sezonu {odabranaSezona}. Čim počne nova sezona, scraper će ovdje
            automatski prikazati rasporede i rezultate.
          </p>
        ) : (
          <>
            <div className="mb-8 flex flex-wrap gap-1.5 pb-6" style={{ borderBottom: "1px solid var(--line)" }}>
              {svaKola.map((k) => {
                const aktivno = k === odabranoKolo;
                return (
                  <Link
                    key={k}
                    href={`/liga/${slug}?kolo=${k}&sezona=${encodeURIComponent(odabranaSezona)}`}
                    className="font-mono px-3 py-1.5 text-sm font-medium"
                    style={
                      aktivno
                        ? { background: "var(--pitch)", color: "var(--chalk)" }
                        : { border: "1px solid var(--line)", background: "white", color: "var(--ink)" }
                    }
                  >
                    {k}.
                  </Link>
                );
              })}
            </div>

            {utakmiceKola.length === 0 ? (
              <p className="font-sans text-sm" style={{ color: "var(--ink-muted)" }}>
                Nema podataka za odabrano kolo.
              </p>
            ) : (
              <div className="space-y-4">
                <h2 className="font-display text-xs font-semibold uppercase tracking-widest" style={{ color: "var(--ink-muted)" }}>
                  {odabranoKolo}. kolo
                </h2>

                {utakmiceKola.map((u) => {
                  const imaDetalje =
                    (u.strijelci && u.strijelci.length > 0) ||
                    (u.postava_domacin && u.postava_domacin.length > 0) ||
                    (u.postava_gost && u.postava_gost.length > 0);

                  const { domacin, gost, nepoznato } = razdvojiStrijelceePoKlubu(u);

                  return (
                    <article key={u.id} className="bg-white p-5" style={{ border: "1px solid var(--line)" }}>
                      <div className="flex items-center gap-3">
                        <IkonaTeren />
                        <p className="font-sans text-lg leading-snug">
                          <span className="font-medium">{u.domacin}</span>
                          {" "}
                          <span className="font-mono font-bold" style={{ color: "var(--pitch)" }}>
                            {u.rezultat ?? "?:?"}
                          </span>
                          {" "}
                          <span className="font-medium">{u.gost}</span>
                        </p>
                      </div>

                      <div className="mt-3 grid grid-cols-1 gap-y-1 font-sans text-sm sm:grid-cols-2" style={{ color: "var(--ink-muted)" }}>
                        {u.stadion_datum && <p>{u.stadion_datum}</p>}
                        {u.gledatelja && u.gledatelja !== "Nepoznato" && (
                          <p>Gledatelja: {u.gledatelja}</p>
                        )}
                        {u.suci && u.suci !== "Nepoznato" && <p>Suci: {u.suci}</p>}
                      </div>

                      {!imaDetalje && (
                        <p className="mt-3 font-sans text-sm italic" style={{ color: "var(--ink-muted)" }}>
                          Utakmica predana bez borbe — zapisnik nije dostupan.
                        </p>
                      )}

                      {u.strijelci && u.strijelci.length > 0 && (
                        <div className="mt-3 grid grid-cols-1 gap-1 font-sans text-sm sm:grid-cols-2">
                          {domacin && domacin.length > 0 && (
                            <p className="flex items-baseline gap-1.5">
                              <IkonaLopta />
                              {domacin.map((s) => `${s.igrac} ${s.minuta}`).join(", ")}
                            </p>
                          )}
                          {gost && gost.length > 0 && (
                            <p className="flex items-baseline gap-1.5">
                              <IkonaLopta />
                              {gost.map((s) => `${s.igrac} ${s.minuta}`).join(", ")}
                            </p>
                          )}
                          {nepoznato && nepoznato.length > 0 && (
                            <p className="flex items-baseline gap-1.5 sm:col-span-2" style={{ color: "var(--ink-muted)" }}>
                              <IkonaLopta />
                              {nepoznato.map((s) => `${s.igrac} ${s.minuta}`).join(", ")}
                            </p>
                          )}
                        </div>
                      )}

                      {(u.postava_domacin?.length || u.postava_gost?.length) ? (
                        <details className="mt-3 group">
                          <summary
                            className="cursor-pointer font-sans text-sm font-medium hover:underline"
                            style={{ color: "var(--pitch)" }}
                          >
                            Postave i izmjene
                          </summary>
                          <div
                            className="mt-3 grid grid-cols-1 gap-6 pt-3 sm:grid-cols-2"
                            style={{ borderTop: "1px solid var(--line)" }}
                          >
                            {u.postava_domacin && u.postava_domacin.length > 0 && (
                              <Postava nazivKluba={u.domacin} igraci={u.postava_domacin} strijelci={u.strijelci ?? []} />
                            )}
                            {u.postava_gost && u.postava_gost.length > 0 && (
                              <Postava nazivKluba={u.gost} igraci={u.postava_gost} strijelci={u.strijelci ?? []} />
                            )}
                          </div>
                        </details>
                      ) : null}

                      {/* Prostor za AI-generirani ili rucno napisani clanak o utakmici - */}
                      {/* prikazuje se samo kad postoji tekst, inace ostaje skriveno */}
                      {u.tekst_clanka && (
                        <div className="mt-4 pt-4" style={{ borderTop: "1px solid var(--line)" }}>
                          {u.slika_url && (
                            // eslint-disable-next-line @next/next/no-img-element
                            <img
                              src={u.slika_url}
                              alt={`${u.domacin} - ${u.gost}`}
                              className="mb-3 w-full object-cover"
                              style={{ maxHeight: 320 }}
                            />
                          )}
                          <p className="font-sans text-sm leading-relaxed">{u.tekst_clanka}</p>
                        </div>
                      )}
                    </article>
                  );
                })}
              </div>
            )}
          </>
        )}
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

export async function generateStaticParams() {
  return LIGE.map((liga) => ({ slug: liga.slug }));
}

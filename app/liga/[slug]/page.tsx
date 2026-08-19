import Link from "next/link";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { supabase, Utakmica } from "@/lib/supabase";
import { dohvatiStatistike } from "@/lib/statistike";
import { ligaPoSlugu, LIGE } from "@/lib/lige";
import Navigacija from "@/components/Navigacija";
import Podnozje from "@/components/Podnozje";
import Postava from "@/components/Postava";
import SidebarLiga from "@/components/SidebarLiga";
import KarticaClanka from "@/components/KarticaClanka";
import { dohvatiClanke } from "@/lib/clanci";
import Otkrivanje from "@/components/Otkrivanje";
import Brojka from "@/components/Brojka";
import { IkonaLopta, IkonaTeren } from "@/components/Ikone";
import { golovi } from "@/lib/kolo";
import ZaglavljeStranice from "@/components/ZaglavljeStranice";
import { SLIKA_DIJELJENJE } from "@/lib/metapodaci";

// Podaci se osvježavaju tri puta tjedno, pa je kratko keširanje sigurno
// i čini kretanje po stranici trenutnim.
export const revalidate = 300;

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

/** Jeftin upit: samo brojevi kola i rezultat (bez postava) - za popis kola,
 * ukupan broj i odabir zadnjeg ODIGRANOG kola (raspored sadrži i buduće
 * utakmice bez rezultata, koje ne smiju postati zadano kolo). */
async function dohvatiKola(
  nazivLige: string,
  sezona: string
): Promise<{ kolo: number; rezultat: string | null }[]> {
  const { data, error } = await supabase
    .from("utakmice")
    .select("kolo, rezultat")
    .eq("natjecanje", nazivLige)
    .eq("sezona", sezona);

  if (error || !data) return [];
  return data.filter((d): d is { kolo: number; rezultat: string | null } => d.kolo !== null);
}

/** Pune podatke (uključujući postave) dohvaćamo SAMO za prikazano kolo. */
async function dohvatiUtakmiceKola(
  nazivLige: string,
  sezona: string,
  kolo: number
): Promise<Utakmica[]> {
  const { data, error } = await supabase
    .from("utakmice")
    .select("*")
    .eq("natjecanje", nazivLige)
    .eq("sezona", sezona)
    .eq("kolo", kolo);

  if (error) {
    console.error("Greška kod dohvaćanja utakmica:", error);
    return [];
  }
  return data ?? [];
}

// Bez ovoga je svaka stranica lige nosila generički naslov "Lokal-Arena"
// i opis cijele stranice. Sad svaka ima svoj naslov, opis i adresu
// (og:url), što traži i Facebookov provjeravač.
export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const liga = ligaPoSlugu(slug);
  if (!liga) return { title: "Natjecanje nije pronađeno" };

  const naslov = `${liga.naziv} — rezultati, tablica i strijelci`;
  const opis = `Rezultati, raspored, tablica i strijelci natjecanja ${liga.naziv}. Podaci s HNS Semafora, osvježeni svakog vikenda.`;
  const adresa = `/liga/${liga.slug}`;

  return {
    title: naslov,
    description: opis,
    alternates: { canonical: adresa },
    openGraph: {
      title: naslov,
      description: opis,
      url: adresa,
      type: "website",
      locale: "hr_HR",
      images: [SLIKA_DIJELJENJE],
    },
  };
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

  const svaKolaSve = await dohvatiKola(liga.naziv, odabranaSezona);
  const svaKola = Array.from(new Set(svaKolaSve.map((d) => d.kolo))).sort((a, b) => a - b);
  const ukupnoUtakmica = svaKolaSve.length;

  // Zadano kolo je zadnje ODIGRANO (raspored uključuje i buduće utakmice
  // bez rezultata, koje ne smiju postati zadani prikaz). Ako sezona još
  // nije počela, pokaži prvo kolo (najavu).
  const odigranaKola = svaKolaSve.filter((d) => golovi(d.rezultat)).map((d) => d.kolo);
  const zadnjeOdigranoKolo = odigranaKola.length ? Math.max(...odigranaKola) : null;
  const odabranoKolo = koloIzUrl
    ? parseInt(koloIzUrl, 10)
    : zadnjeOdigranoKolo ?? svaKola[0];

  // Sve što stranica treba dohvaćamo USPOREDNO, a pune podatke samo za
  // prikazano kolo - ne za cijelu sezonu.
  const [utakmiceSirovo, clanciLige, statistike] = await Promise.all([
    odabranoKolo ? dohvatiUtakmiceKola(liga.naziv, odabranaSezona, odabranoKolo) : Promise.resolve([]),
    dohvatiClanke({ liga: liga.naziv, koliko: 4 }),
    dohvatiStatistike(liga.naziv, odabranaSezona),
  ]);

  // Derbi kola ide na vrh popisa
  const utakmiceKola = [...utakmiceSirovo].sort(
    (a, b) => (b.derbi ? 1 : 0) - (a.derbi ? 1 : 0)
  );

  return (
    <div className="min-h-screen" style={{ background: "var(--chalk)" }}>
      <Navigacija />

      <main className="mx-auto max-w-6xl px-6 py-14">
        <ZaglavljeStranice slika={slug} naslov={liga.naziv} />

        {/* Naziv lige stoji u zaglavlju iznad, pa ovdje ostaje samo
            birač sezona (poravnat desno) i brojka ispod. */}
        <div className="mb-1 flex flex-wrap items-end justify-end gap-x-6 gap-y-3">
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

        <p className="mb-8 font-mono text-xs" style={{ color: "var(--ink-muted)" }}>
          <Brojka vrijednost={ukupnoUtakmica} /> utakmica ukupno · sezona{" "}
          {odabranaSezona}
        </p>

        {/* Dva stupca: sadržaj lige lijevo, sidebar (tablica/strijelci/kartoni)
            desno na velikim ekranima, ispod sadržaja na mobitelu. */}
        <div className="flex flex-col gap-8 lg:flex-row">
          <div className="min-w-0 flex-1">
            {svaKola.length === 0 ? (
              <p className="font-sans text-sm" style={{ color: "var(--ink-muted)" }}>
                Nema podataka za sezonu {odabranaSezona}. Čim počne nova sezona, scraper će ovdje
                automatski prikazati rasporede i rezultate.
              </p>
            ) : (
              <>
                <p className="oznaka-sekcije mb-3">Kola</p>
                <div className="mb-10 flex flex-wrap gap-1.5 pb-6" style={{ borderBottom: "1px solid var(--line)" }}>
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
                  <div className="space-y-3">
                    <Otkrivanje>
                      <div className="pb-1">
                        <p className="oznaka-sekcije">Rezultati</p>
                        <h2 className="font-display mt-1.5 text-2xl uppercase">
                          {odabranoKolo}. kolo
                        </h2>
                      </div>
                    </Otkrivanje>

                    {utakmiceKola.map((u, idx) => {
                      const imaDetalje =
                        (u.strijelci && u.strijelci.length > 0) ||
                        (u.postava_domacin && u.postava_domacin.length > 0) ||
                        (u.postava_gost && u.postava_gost.length > 0);

                      const { domacin, gost, nepoznato } = razdvojiStrijelceePoKlubu(u);

                      return (
                        <Otkrivanje key={u.id} kasnjenje={Math.min(idx, 6) * 45}>
                        <article
                          className="bg-white p-5"
                          style={{
                            border: u.derbi
                              ? "2px solid var(--card-yellow)"
                              : "1px solid var(--line)",
                          }}
                        >
                          {u.derbi && (
                            <p
                              className="mb-2 inline-block px-2 py-0.5 font-display text-[10px] font-bold uppercase tracking-widest"
                              style={{ background: "var(--card-yellow)", color: "var(--ink)" }}
                            >
                              Derbi kola
                            </p>
                          )}
                          <div className="flex items-center gap-3">
                            <IkonaTeren />
                            <p className="font-sans text-lg leading-snug">
                              <span className="font-medium">{u.domacin}</span>
                              {" "}
                              <span className="semafor text-base">{u.rezultat ?? "?:?"}</span>
                              {" "}
                              <span className="font-medium">{u.gost}</span>
                            </p>
                          </div>

                          <div className="mt-3 grid grid-cols-1 gap-y-1 font-sans text-sm sm:grid-cols-2" style={{ color: "var(--ink-muted)" }}>
                            {/* "Nepoznato" preskačemo isto kao kod gledatelja i
                                sudaca - inače bi ta riječ osvanula korisniku
                                umjesto termina. Stariji zapisi u bazi je još
                                mogu imati, pa provjera ostaje i nakon popravka
                                u scraperu. */}
                            {u.stadion_datum && u.stadion_datum !== "Nepoznato" ? (
                              <p>{u.stadion_datum}</p>
                            ) : (
                              (u.datum || u.stadion) && (
                                <p>
                                  {u.stadion}
                                  {u.stadion && (u.datum || u.vrijeme) ? ", " : ""}
                                  {u.datum}
                                  {u.vrijeme ? ` u ${u.vrijeme}` : ""}
                                </p>
                              )
                            )}
                            {u.gledatelja && u.gledatelja !== "Nepoznato" && (
                              <p>Gledatelja: {u.gledatelja}</p>
                            )}
                            {u.suci && u.suci !== "Nepoznato" && <p>Suci: {u.suci}</p>}
                          </div>

                          {!imaDetalje && u.rezultat && (
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
                        </Otkrivanje>
                      );
                    })}
                  </div>
                )}
              </>
            )}
          </div>

          <aside className="w-full shrink-0 lg:w-80">
            <div className="space-y-4 lg:sticky lg:top-6">
              <Otkrivanje>
                <SidebarLiga statistike={statistike} />
              </Otkrivanje>
              {clanciLige.length > 0 && (
                <Otkrivanje kasnjenje={80}>
                <section style={{ background: "var(--paper)", border: "1px solid var(--line)" }}>
                  <div className="flex items-baseline justify-between gap-2 px-3 py-2" style={{ background: "var(--pitch)", color: "var(--chalk)" }}>
                    <h3 className="font-display text-sm uppercase tracking-wide">Novosti lige</h3>
                    <Link href={`/novosti?liga=${encodeURIComponent(liga.naziv)}`} className="font-sans text-[11px] hover:underline">sve →</Link>
                  </div>
                  <div className="space-y-2 p-2">
                    {clanciLige.map((c) => (
                      <KarticaClanka key={c.id} clanak={c} kompaktno />
                    ))}
                  </div>
                </section>
                </Otkrivanje>
              )}
            </div>
          </aside>
        </div>
      </main>

      <Podnozje />
    </div>
  );
}

export async function generateStaticParams() {
  return LIGE.map((liga) => ({ slug: liga.slug }));
}

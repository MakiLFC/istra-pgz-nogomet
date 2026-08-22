// app/utakmica/[slug]/page.tsx — zapisnik pojedine utakmice.
//
// Postoji zato da se zapisnik s postavama može podijeliti poveznicom.
// Dosad je stajao samo unutar stranice lige, pa se nije mogao poslati
// nikome izravno.
//
// Adresa nosi imena oba kluba i identifikator retka; vidi lib/slug.ts.

import Link from "next/link";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import Navigacija from "@/components/Navigacija";
import Podnozje from "@/components/Podnozje";
import Otkrivanje from "@/components/Otkrivanje";
import Postava from "@/components/Postava";
import PoveznicaKluba from "@/components/PoveznicaKluba";
import { IkonaLopta } from "@/components/Ikone";
import { dohvatiUtakmicu, strijelciPoKlubu, imaZapisnik } from "@/lib/utakmice";
import { idIzSluga, slugUtakmice, kljucKluba } from "@/lib/slug";
import { golovi } from "@/lib/kolo";
import { LIGE } from "@/lib/lige";
import { SLIKA_DIJELJENJE } from "@/lib/metapodaci";
import type { Utakmica } from "@/lib/supabase";

export const revalidate = 300;

/** "NK A 2:1 NK B" za odigranu, "NK A - NK B" za onu koja se tek igra. */
function naslovUtakmice(u: Utakmica): string {
  return golovi(u.rezultat)
    ? `${u.domacin} ${u.rezultat} ${u.gost}`
    : `${u.domacin} - ${u.gost}`;
}

function opisUtakmice(u: Utakmica): string {
  const kolo = u.kolo ? `${u.kolo}. kolo ` : "";
  const gdje = `${kolo}${u.natjecanje}${u.sezona ? `, sezona ${u.sezona}` : ""}`;
  return golovi(u.rezultat)
    ? `Zapisnik utakmice ${u.domacin} ${u.rezultat} ${u.gost}, ${gdje}. Strijelci, postave i izmjene.`
    : `Utakmica ${u.domacin} i ${u.gost}, ${gdje}. Termin, stadion i podaci o susretu.`;
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const id = idIzSluga(slug);
  const u = id ? await dohvatiUtakmicu(id) : null;
  if (!u) return { title: "Utakmica nije pronađena" };

  const naslov = naslovUtakmice(u);
  const opis = opisUtakmice(u);
  // Kanonska adresa uvijek nosi ispravan zapis imena, i onda kad je
  // netko došao preko stare ili nepotpune poveznice s istim brojem.
  const adresa = `/utakmica/${slugUtakmice(u)}`;

  return {
    title: naslov,
    description: opis,
    alternates: { canonical: adresa },
    openGraph: {
      title: naslov,
      description: opis,
      url: adresa,
      type: "article",
      locale: "hr_HR",
      images: u.slika_url ? [u.slika_url] : [SLIKA_DIJELJENJE],
    },
  };
}

function Podatak({ children }: { children: React.ReactNode }) {
  return <p>{children}</p>;
}

export default async function StranicaUtakmice({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const id = idIzSluga(slug);
  const u = id ? await dohvatiUtakmicu(id) : null;
  if (!u) notFound();

  const rezultat = golovi(u.rezultat);
  const ligaSlug = LIGE.find((l) => l.naziv === u.natjecanje)?.slug;
  const { domacin, gost, nepoznato } = strijelciPoKlubu(u);
  const zapisnik = imaZapisnik(u);

  return (
    <div className="min-h-screen" style={{ background: "var(--chalk)" }}>
      <Navigacija />

      <main className="mx-auto max-w-3xl px-6 py-14">
        {ligaSlug && (
          <Link
            href={`/liga/${ligaSlug}${u.kolo ? `?kolo=${u.kolo}` : ""}`}
            className="font-sans text-xs font-medium hover:underline"
            style={{ color: "var(--pitch)" }}
          >
            ← {u.kolo ? `${u.kolo}. kolo` : u.natjecanje}
          </Link>
        )}

        <Otkrivanje>
          <article className="mt-4">
            <p className="oznaka-sekcije">
              {[u.natjecanje, u.kolo ? `${u.kolo}. kolo` : null, u.sezona]
                .filter(Boolean)
                .join(" · ")}
            </p>

            {u.derbi && (
              <p
                className="mt-3 inline-block px-2 py-0.5 font-display text-[10px] font-bold uppercase tracking-widest"
                style={{ background: "var(--card-yellow)", color: "var(--ink)" }}
              >
                Derbi kola
              </p>
            )}

            <h1 className="font-display mt-3 text-3xl uppercase leading-tight tracking-tight sm:text-4xl">
              <PoveznicaKluba naziv={u.domacin} />{" "}
              {rezultat ? (
                <span className="semafor text-2xl sm:text-3xl">{u.rezultat}</span>
              ) : (
                <span className="text-2xl" style={{ color: "var(--oxide)" }}>
                  vs
                </span>
              )}{" "}
              <PoveznicaKluba naziv={u.gost} />
            </h1>

            <div
              className="mt-5 grid grid-cols-1 gap-y-1 font-sans text-sm sm:grid-cols-2"
              style={{ color: "var(--ink-muted)" }}
            >
              {/* "Nepoznato" se preskače: to je zapis iz baze, ne podatak
                  koji treba vidjeti posjetitelj. */}
              {u.stadion_datum && u.stadion_datum !== "Nepoznato" ? (
                <Podatak>{u.stadion_datum}</Podatak>
              ) : (
                (u.stadion || u.datum) && (
                  <Podatak>
                    {u.stadion}
                    {u.stadion && (u.datum || u.vrijeme) ? ", " : ""}
                    {u.datum}
                    {u.vrijeme ? ` u ${u.vrijeme}` : ""}
                  </Podatak>
                )
              )}
              {u.gledatelja && u.gledatelja !== "Nepoznato" && (
                <Podatak>Gledatelja: {u.gledatelja}</Podatak>
              )}
              {u.suci && u.suci !== "Nepoznato" && <Podatak>Suci: {u.suci}</Podatak>}
            </div>

            {/* Poruka smije stajati samo kad utakmica IMA rezultat, a nema
                zapisnik. Inače bi je dobila svaka buduća utakmica. */}
            {!zapisnik && rezultat && (
              <p className="mt-4 font-sans text-sm italic" style={{ color: "var(--ink-muted)" }}>
                Utakmica predana bez borbe, zapisnik nije dostupan.
              </p>
            )}

            {u.strijelci && u.strijelci.length > 0 && (
              <section className="mt-7">
                <p className="oznaka-sekcije">Strijelci</p>
                <div className="mt-3 grid grid-cols-1 gap-1 font-sans text-sm sm:grid-cols-2">
                  {domacin.length > 0 && (
                    <p className="flex items-baseline gap-1.5">
                      <IkonaLopta />
                      {domacin.map((s) => `${s.igrac} ${s.minuta}`).join(", ")}
                    </p>
                  )}
                  {gost.length > 0 && (
                    <p className="flex items-baseline gap-1.5">
                      <IkonaLopta />
                      {gost.map((s) => `${s.igrac} ${s.minuta}`).join(", ")}
                    </p>
                  )}
                  {nepoznato.length > 0 && (
                    <p
                      className="flex items-baseline gap-1.5 sm:col-span-2"
                      style={{ color: "var(--ink-muted)" }}
                    >
                      <IkonaLopta />
                      {nepoznato.map((s) => `${s.igrac} ${s.minuta}`).join(", ")}
                    </p>
                  )}
                </div>
              </section>
            )}

            {/* Postave stoje otvorene, bez sklapanja: one su razlog zbog
                kojeg ova stranica postoji. */}
            {(u.postava_domacin?.length || u.postava_gost?.length) ? (
              <section className="mt-8">
                <p className="oznaka-sekcije">Postave i izmjene</p>
                <div className="mt-4 grid grid-cols-1 gap-6 sm:grid-cols-2">
                  {u.postava_domacin && u.postava_domacin.length > 0 && (
                    <Postava
                      nazivKluba={u.domacin}
                      igraci={u.postava_domacin}
                      strijelci={u.strijelci ?? []}
                    />
                  )}
                  {u.postava_gost && u.postava_gost.length > 0 && (
                    <Postava
                      nazivKluba={u.gost}
                      igraci={u.postava_gost}
                      strijelci={u.strijelci ?? []}
                    />
                  )}
                </div>
              </section>
            ) : null}

            {u.tekst_clanka && (
              <section className="mt-8 pt-6" style={{ borderTop: "1px solid var(--line)" }}>
                {u.slika_url && (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    src={u.slika_url}
                    alt={`${u.domacin} - ${u.gost}`}
                    className="mb-4 w-full object-cover"
                    style={{ maxHeight: 360 }}
                  />
                )}
                <p className="font-sans text-[15px] leading-relaxed">{u.tekst_clanka}</p>
              </section>
            )}

            <nav
              className="mt-10 flex flex-wrap gap-x-5 gap-y-2 pt-5 font-sans text-sm"
              style={{ borderTop: "1px solid var(--line)" }}
            >
              <Link
                href={`/klub/${kljucKluba(u.domacin)}`}
                className="font-medium hover:underline"
                style={{ color: "var(--pitch)" }}
              >
                {u.domacin} →
              </Link>
              <Link
                href={`/klub/${kljucKluba(u.gost)}`}
                className="font-medium hover:underline"
                style={{ color: "var(--pitch)" }}
              >
                {u.gost} →
              </Link>
              {ligaSlug && (
                <Link
                  href={`/liga/${ligaSlug}${u.kolo ? `?kolo=${u.kolo}` : ""}`}
                  className="font-medium hover:underline"
                  style={{ color: "var(--pitch)" }}
                >
                  Cijelo {u.kolo ? `${u.kolo}. ` : ""}kolo →
                </Link>
              )}
            </nav>
          </article>
        </Otkrivanje>
      </main>

      <Podnozje />
    </div>
  );
}

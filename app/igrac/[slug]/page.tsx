// app/igrac/[slug]/page.tsx — profil igrača.
//
// Sastavljen je od dvaju izvora: rang-lista strijelaca i kartona (ukupni
// učinak po sezoni) te postava pojedinih utakmica (nastupi i događaji).
//
// Nastupi i minute dolaze iz službene rang-liste natjecanja, kad je
// stranica nudi. Kad ih nema, nastupi se broje iz zapisnika, a minute se
// ne prikazuju; ne procjenjuju se iz izmjena.

import Link from "next/link";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import Navigacija from "@/components/Navigacija";
import Podnozje from "@/components/Podnozje";
import Otkrivanje from "@/components/Otkrivanje";
import PoveznicaKluba from "@/components/PoveznicaKluba";
import {
  dohvatiIgraca,
  dohvatiIgrace,
  dohvatiNastupe,
  jeIgrao,
  type NastupIgraca,
} from "@/lib/igraci";
import { slugUtakmice } from "@/lib/slug";
import { golovi } from "@/lib/kolo";
import { sBrojem } from "@/lib/hrvatski";
import { SLIKA_DIJELJENJE } from "@/lib/metapodaci";

export const revalidate = 300;

export async function generateStaticParams() {
  try {
    const igraci = await dohvatiIgrace();
    return igraci.map((i) => ({ slug: i.slug }));
  } catch {
    return [];
  }
}

function opisIgraca(ime: string, klubovi: string[]): string {
  const uKlubu = klubovi.length ? `, ${klubovi.join(", ")}` : "";
  return `Golovi, kartoni i nastupi igrača ${ime}${uKlubu}. Podaci s HNS Semafora, osvježeni svakog vikenda.`;
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const igrac = await dohvatiIgraca(slug);
  if (!igrac) return { title: "Igrač nije pronađen" };

  const opis = opisIgraca(igrac.ime, igrac.klubovi);
  const adresa = `/igrac/${igrac.slug}`;

  return {
    title: igrac.ime,
    description: opis,
    alternates: { canonical: adresa },
    openGraph: {
      title: igrac.ime,
      description: opis,
      url: adresa,
      type: "profile",
      locale: "hr_HR",
      images: [SLIKA_DIJELJENJE],
    },
  };
}

const NAZIV_DOGADAJA: Record<string, string> = {
  gol: "gol",
  karton_zuti: "žuti karton",
  karton_crveni: "crveni karton",
  karton_zutocrveni: "žuto-crveni karton",
  izmjena_ulazak: "ušao",
  izmjena_izlazak: "izašao",
};

function Brojka({ oznaka, vrijednost }: { oznaka: string; vrijednost: number }) {
  return (
    <div>
      <p className="font-mono text-[10px] uppercase tracking-widest" style={{ color: "var(--ink-muted)" }}>
        {oznaka}
      </p>
      <p className="mt-1 font-display text-3xl leading-none">{vrijednost}</p>
    </div>
  );
}

function RedakNastupa({ n }: { n: NastupIgraca }) {
  const u = n.utakmica;
  const rezultat = golovi(u.rezultat);
  const dogadjaji = n.dogadjaji
    .map((d) => {
      const naziv = NAZIV_DOGADAJA[d.tip] ?? d.tip;
      return d.minuta ? `${naziv} ${d.minuta}` : naziv;
    })
    .join(", ");

  return (
    <div
      className="flex flex-wrap items-baseline gap-x-3 gap-y-1 bg-white px-4 py-3"
      style={{ border: "1px solid var(--line)" }}
    >
      <Link
        href={`/utakmica/${slugUtakmice(u)}`}
        className="w-16 shrink-0 font-mono text-[11px] hover:underline"
        style={{ color: "var(--ink-muted)" }}
      >
        {u.kolo ? `${u.kolo}. kolo` : "utakmica"}
      </Link>

      <p className="font-sans text-[15px] leading-snug">
        <span className={u.domacin === n.klub ? "font-bold" : "font-medium"}>
          {u.domacin}
        </span>{" "}
        {rezultat ? (
          <span className="semafor text-sm">{u.rezultat}</span>
        ) : (
          <span className="font-mono text-xs" style={{ color: "var(--oxide)" }}>
            vs
          </span>
        )}{" "}
        <span className={u.gost === n.klub ? "font-bold" : "font-medium"}>{u.gost}</span>
      </p>

      {dogadjaji && (
        <span className="font-sans text-xs" style={{ color: "var(--oxide)" }}>
          {dogadjaji}
        </span>
      )}

      {!jeIgrao(n) && (
        <span className="font-sans text-xs" style={{ color: "var(--ink-muted)" }}>
          na klupi
        </span>
      )}
    </div>
  );
}

export default async function StranicaIgraca({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const igrac = await dohvatiIgraca(slug);
  if (!igrac) notFound();

  const nastupi = await dohvatiNastupe(igrac.ime);
  // Službeni broj nastupa ima prednost; kad ga nema, broje se zapisnici.
  const izZapisnika = nastupi.filter(jeIgrao).length;
  const brojNastupa = igrac.nastupi ?? (izZapisnika || null);

  return (
    <div className="min-h-screen" style={{ background: "var(--chalk)" }}>
      <Navigacija />

      <main className="mx-auto max-w-3xl px-6 py-14">
        <Otkrivanje>
          <p className="oznaka-sekcije">Igrač</p>
          <h1 className="font-display mt-3 text-4xl uppercase tracking-tight sm:text-5xl">
            {igrac.ime}
          </h1>

          <p className="mt-4 flex flex-wrap items-baseline gap-x-2 font-sans text-sm">
            {igrac.klubovi.map((klub) => (
              <PoveznicaKluba key={klub} naziv={klub} className="font-medium" style={{ color: "var(--pitch)" }} />
            ))}
            <span className="font-mono text-xs" style={{ color: "var(--ink-muted)" }}>
              · {igrac.sezone.join(" · ")}
            </span>
          </p>
        </Otkrivanje>

        <Otkrivanje kasnjenje={60}>
          <div
            className="mt-8 flex flex-wrap gap-x-10 gap-y-5 p-5"
            style={{ background: "var(--paper)", border: "1px solid var(--line)" }}
          >
            {brojNastupa != null && (
              <Brojka oznaka="Nastupi" vrijednost={brojNastupa} />
            )}
            {igrac.minute != null && (
              <Brojka oznaka="Minute" vrijednost={igrac.minute} />
            )}
            <Brojka oznaka="Golovi" vrijednost={igrac.golovi} />
            <Brojka oznaka="Žuti" vrijednost={igrac.zuti} />
            <Brojka oznaka="Crveni" vrijednost={igrac.crveni} />
          </div>
        </Otkrivanje>

        {igrac.poSezoni.length > 1 && (
          <section className="mt-10">
            <p className="oznaka-sekcije">Po sezonama</p>
            <div
              className="mt-3 overflow-x-auto"
              style={{ background: "var(--paper)", border: "1px solid var(--line)" }}
            >
              <table className="w-full font-sans text-sm">
                <thead>
                  <tr style={{ borderBottom: "1px solid var(--line)", color: "var(--ink-muted)" }}>
                    <th className="px-3 py-2 text-left font-normal">Sezona</th>
                    <th className="px-3 py-2 text-left font-normal">Klub</th>
                    <th className="px-3 py-2 text-right font-normal">Nast.</th>
                    <th className="px-3 py-2 text-right font-normal">Min.</th>
                    <th className="px-3 py-2 text-right font-normal">Golovi</th>
                    <th className="px-3 py-2 text-right font-normal">Žuti</th>
                    <th className="px-3 py-2 text-right font-normal">Crveni</th>
                  </tr>
                </thead>
                <tbody>
                  {igrac.poSezoni.map((u, i) => (
                    <tr key={i} style={i ? { borderTop: "1px solid var(--line)" } : undefined}>
                      <td className="px-3 py-2 font-mono text-xs">{u.sezona}</td>
                      <td className="px-3 py-2">
                        <PoveznicaKluba naziv={u.klub} />
                      </td>
                      <td className="px-3 py-2 text-right font-mono">
                        {u.nastupi ?? "-"}
                      </td>
                      <td className="px-3 py-2 text-right font-mono">
                        {u.minute ?? "-"}
                      </td>
                      <td className="px-3 py-2 text-right font-mono">{u.golovi}</td>
                      <td className="px-3 py-2 text-right font-mono">{u.zuti}</td>
                      <td className="px-3 py-2 text-right font-mono">{u.crveni}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </section>
        )}

        {nastupi.length > 0 && (
          <section className="mt-10">
            <p className="oznaka-sekcije">Utakmice</p>
            <p className="mt-1.5 font-mono text-xs" style={{ color: "var(--ink-muted)" }}>
              {sBrojem(nastupi.length, [
                "utakmica sa zapisnikom",
                "utakmice sa zapisnikom",
                "utakmica sa zapisnikom",
              ])}
            </p>
            <div className="mt-3 space-y-2">
              {nastupi.map((n, i) => (
                <Otkrivanje key={`${n.utakmica.id}-${i}`} kasnjenje={Math.min(i, 6) * 40}>
                  <RedakNastupa n={n} />
                </Otkrivanje>
              ))}
            </div>
          </section>
        )}

        <p className="mt-10 font-sans text-xs" style={{ color: "var(--ink-muted)" }}>
          Golovi, kartoni, nastupi i minute preuzimaju se iz službenih
          rang-lista natjecanja. Gdje minuta nema, stranica natjecanja ih ne
          objavljuje; ne procjenjujemo ih. Popis utakmica slaže se iz
          zapisnika, pa sadrži samo one kojima je zapisnik objavljen.
        </p>
      </main>

      <Podnozje />
    </div>
  );
}

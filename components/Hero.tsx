// Hero.tsx — uvodna traka naslovnice.
//
// Tamna ploha odmah ispod izbornika: grb, izjava s naglašenom riječi
// i četiri brojke koje se odbroje. Daje stranici uvodni "trenutak"
// prije nego se ide u rezultate.

import Grb from "@/components/Grb";
import Brojka from "@/components/Brojka";
import Otkrivanje from "@/components/Otkrivanje";

export default function Hero({
  brojLiga,
  brojUtakmica,
  brojGolova,
  brojKlubova,
  sezona,
}: {
  brojLiga: number;
  brojUtakmica: number;
  brojGolova: number;
  brojKlubova: number;
  sezona?: string | null;
}) {
  const brojke = [
    { broj: brojLiga, oznaka: "lige" },
    { broj: brojKlubova, oznaka: "klubova" },
    { broj: brojUtakmica, oznaka: "odigranih utakmica" },
    { broj: brojGolova, oznaka: "golova" },
  ];

  return (
    <section
      className="relative overflow-hidden"
      style={{
        background:
          "linear-gradient(160deg, var(--pitch) 0%, var(--pitch-dark) 100%)",
        color: "var(--chalk)",
      }}
    >
      {/* nacrt terena kao tihi vodeni žig u pozadini */}
      <div
        aria-hidden="true"
        className="pointer-events-none absolute inset-0 opacity-[0.07]"
        style={{
          backgroundImage:
            "url(\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='150' height='150' viewBox='0 0 150 150'%3E%3Cg fill='none' stroke='%23ffffff' stroke-width='1.4'%3E%3Crect x='24' y='39' width='102' height='72'/%3E%3Cline x1='75' y1='39' x2='75' y2='111'/%3E%3Ccircle cx='75' cy='75' r='15'/%3E%3C/g%3E%3C/svg%3E\")",
          backgroundSize: "150px 150px",
        }}
      />

      <div className="relative mx-auto max-w-6xl px-6 py-14 sm:py-20">
        <Otkrivanje>
          <div className="flex flex-col gap-7 sm:flex-row sm:items-center sm:gap-10">
            <Grb className="h-auto w-28 shrink-0 sm:w-40" />

            <div className="min-w-0">
              <p
                className="font-mono text-[11px] uppercase tracking-[0.22em]"
                style={{ color: "var(--oxide-light)" }}
              >
                Istra i Primorje
                {sezona ? ` · ${sezona}` : ""}
              </p>

              {/* "gol." nosi tamnu plohu lopte, "Svaki karton." prelazi iz
                  žute u crvenu, a "Svako kolo." ostaje serifni kurziv.
                  Stilovi su u globals.css (naslov-hero, ploha-lopte,
                  prijelaz-kartona) - vidi tamo za oprez oko čitljivosti. */}
              <h1 className="naslov-hero mt-3 text-4xl sm:text-6xl">
                Svaki <span className="ploha-lopte">gol.</span>
                <br />
                <span className="prijelaz-kartona">Svaki karton.</span>{" "}
                <span className="naglasak">Svako kolo.</span>
              </h1>

              <p className="mt-4 max-w-xl font-sans text-sm leading-relaxed opacity-75 sm:text-base">
                Rezultati, zapisnici, tablice i strijelci nižih nogometnih liga,
                sve na jednom mjestu i osvježeno svakog vikenda.
              </p>
            </div>
          </div>
        </Otkrivanje>

        {/* brojke */}
        <Otkrivanje kasnjenje={120}>
          <dl
            className="mt-12 grid grid-cols-2 gap-x-6 gap-y-7 border-t pt-8 sm:grid-cols-4"
            style={{ borderColor: "rgba(233,234,229,0.2)" }}
          >
            {brojke.map((b) => (
              <div key={b.oznaka}>
                <dt className="sr-only">{b.oznaka}</dt>
                <dd>
                  <span className="font-display block text-3xl sm:text-4xl">
                    <Brojka vrijednost={b.broj} />
                  </span>
                  <span className="mt-1.5 block font-mono text-[10px] uppercase tracking-[0.2em] opacity-60">
                    {b.oznaka}
                  </span>
                </dd>
              </div>
            ))}
          </dl>
        </Otkrivanje>
      </div>
    </section>
  );
}

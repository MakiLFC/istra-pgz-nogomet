// StatistikaKluba.tsx — poredak, forma, strijelci i kartoni jednog kluba.
//
// Tablica poretka se NE računa, nego se čita onakva kakva je scrapeana:
// službena tablica već uključuje kaznene bodove, pa bi vlastiti izračun
// bio kriv (vidi CLAUDE.md).
//
// Forma se, suprotno tome, mora izračunati iz utakmica: u bazi stoji
// samo zadnje stanje tablice, pa se niz zadnjih rezultata iz nje ne može
// izvesti.

import { kljucKluba, type Ishod } from "@/lib/klubovi";
import { sBrojem } from "@/lib/hrvatski";
import type { StatistikeLige } from "@/lib/statistike";

const BOJE: Record<Ishod, { pozadina: string; tekst: string; naziv: string }> = {
  P: { pozadina: "var(--pitch)", tekst: "var(--chalk)", naziv: "pobjeda" },
  N: { pozadina: "var(--line)", tekst: "var(--ink)", naziv: "neriješeno" },
  I: { pozadina: "var(--oxide)", tekst: "var(--chalk)", naziv: "poraz" },
};

/** "12" -> 12, sve ostalo -> null. Vrijednosti u bazi su tekst. */
function broj(v: string | null | undefined): number | null {
  if (!v) return null;
  const c = v.replace(/[^\d-]/g, "");
  if (!c) return null;
  const n = parseInt(c, 10);
  return isNaN(n) ? null : n;
}

function Podatak({ oznaka, vrijednost }: { oznaka: string; vrijednost: string }) {
  return (
    <div>
      <p className="font-mono text-[10px] uppercase tracking-widest" style={{ color: "var(--ink-muted)" }}>
        {oznaka}
      </p>
      <p className="mt-1 font-mono text-lg font-bold">{vrijednost}</p>
    </div>
  );
}

function Lista({
  naslov,
  redci,
}: {
  naslov: string;
  redci: { ime: string; vrijednost: string }[];
}) {
  if (!redci.length) return null;
  return (
    <section>
      <p className="oznaka-sekcije">{naslov}</p>
      <ul className="mt-3" style={{ background: "var(--paper)", border: "1px solid var(--line)" }}>
        {redci.map((r, i) => (
          <li
            key={`${r.ime}-${i}`}
            className="flex items-baseline justify-between gap-3 px-3 py-2"
            style={i ? { borderTop: "1px solid var(--line)" } : undefined}
          >
            <span className="min-w-0 font-sans text-sm">{r.ime}</span>
            <span className="shrink-0 font-mono text-sm font-bold">{r.vrijednost}</span>
          </li>
        ))}
      </ul>
    </section>
  );
}

export default function StatistikaKluba({
  naziv,
  statistike,
  forma,
}: {
  naziv: string;
  statistike: StatistikeLige;
  forma: Ishod[];
}) {
  const kljuc = kljucKluba(naziv);
  const red = statistike.tablica.find((r) => kljucKluba(r.klub) === kljuc);

  const strijelci = statistike.strijelci
    .filter((s) => kljucKluba(s.klub) === kljuc)
    .map((s) => ({ ime: s.igrac, golovi: broj(s.golovi) ?? 0 }))
    .filter((s) => s.golovi > 0)
    .sort((a, b) => b.golovi - a.golovi || a.ime.localeCompare(b.ime, "hr"))
    .slice(0, 10);

  const kartoni = statistike.kartoni
    .filter((k) => kljucKluba(k.klub) === kljuc)
    .map((k) => ({ ime: k.igrac, zuti: broj(k.zuti) ?? 0, crveni: broj(k.crveni) ?? 0 }))
    .filter((k) => k.zuti > 0 || k.crveni > 0)
    .sort((a, b) => b.crveni - a.crveni || b.zuti - a.zuti || a.ime.localeCompare(b.ime, "hr"))
    .slice(0, 10);

  if (!red && !forma.length && !strijelci.length && !kartoni.length) return null;

  const pozicija = broj(red?.pozicija);

  return (
    <div className="mt-10 space-y-8">
      {(red || forma.length > 0) && (
        <section>
          <p className="oznaka-sekcije">Poredak i forma</p>

          <div
            className="mt-3 flex flex-wrap items-center gap-x-10 gap-y-5 p-5"
            style={{ background: "var(--paper)", border: "1px solid var(--line)" }}
          >
            {pozicija != null && (
              <div className="flex items-baseline gap-2">
                <span className="font-display text-4xl leading-none" style={{ color: "var(--oxide)" }}>
                  {pozicija}.
                </span>
                <span className="font-sans text-sm" style={{ color: "var(--ink-muted)" }}>
                  mjesto
                </span>
              </div>
            )}

            {red && (
              <>
                <Podatak oznaka="Bodovi" vrijednost={red.bodovi ?? "?"} />
                <Podatak oznaka="Odigrano" vrijednost={red.odigrano ?? "?"} />
                <Podatak
                  oznaka="P / N / I"
                  vrijednost={`${red.pobjede ?? "?"} / ${red.remiji ?? "?"} / ${red.porazi ?? "?"}`}
                />
                <Podatak
                  oznaka="Golovi"
                  vrijednost={`${red.golovi_dani ?? "?"} : ${red.golovi_primljeni ?? "?"}`}
                />
              </>
            )}

            {forma.length > 0 && (
              <div>
                <p className="font-mono text-[10px] uppercase tracking-widest" style={{ color: "var(--ink-muted)" }}>
                  Forma
                </p>
                <div className="mt-1.5 flex gap-1">
                  {forma.map((i, n) => (
                    <span
                      key={n}
                      title={BOJE[i].naziv}
                      className="flex h-6 w-6 items-center justify-center font-mono text-xs font-bold"
                      style={{ background: BOJE[i].pozadina, color: BOJE[i].tekst }}
                    >
                      {i}
                    </span>
                  ))}
                </div>
              </div>
            )}
          </div>

          {forma.length > 0 && (
            <p className="mt-2 font-sans text-xs" style={{ color: "var(--ink-muted)" }}>
              Forma prikazuje zadnje odigrane utakmice, najnovija lijevo.
            </p>
          )}
        </section>
      )}

      <div className="grid grid-cols-1 gap-8 sm:grid-cols-2">
        <Lista
          naslov="Strijelci"
          redci={strijelci.map((s) => ({ ime: s.ime, vrijednost: String(s.golovi) }))}
        />
        <Lista
          naslov="Kartoni"
          redci={kartoni.map((k) => ({
            ime: k.ime,
            vrijednost: [
              k.zuti > 0 ? sBrojem(k.zuti, ["žuti", "žuta", "žutih"]) : null,
              k.crveni > 0 ? sBrojem(k.crveni, ["crveni", "crvena", "crvenih"]) : null,
            ]
              .filter(Boolean)
              .join(", "),
          }))}
        />
      </div>
    </div>
  );
}

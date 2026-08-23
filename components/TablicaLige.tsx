// TablicaLige.tsx — puna tablica poretka lige.
//
// Prije je tablica stajala u bočnom stupcu, širokom 320 piksela, gdje su
// stala samo tri stupca. Ovdje ide preko cijele širine, pa ima mjesta za
// pobjede, neriješene, poraze, golove i formu.
//
// Brojke se čitaju onakve kakve su scrapeane, ne računaju se: službena
// tablica već uključuje kaznene bodove. Forma je iznimka i računa se iz
// utakmica, jer u bazi stoji samo zadnje stanje tablice.

import PoveznicaKluba from "@/components/PoveznicaKluba";
import { kljucKluba } from "@/lib/slug";
import type { RedTablice } from "@/lib/statistike";
import type { Ishod } from "@/lib/tablica";

const BOJE: Record<Ishod, { pozadina: string; tekst: string; naziv: string }> = {
  P: { pozadina: "var(--pitch-light)", tekst: "var(--pitch-dark)", naziv: "pobjeda" },
  N: { pozadina: "var(--line)", tekst: "var(--ink)", naziv: "neriješeno" },
  I: { pozadina: "var(--card-red)", tekst: "var(--chalk)", naziv: "poraz" },
};

function Zaglavlje({
  children,
  naslov,
  desno = true,
}: {
  children: React.ReactNode;
  naslov?: string;
  desno?: boolean;
}) {
  return (
    <th
      title={naslov}
      className={`px-2 py-2 font-normal ${desno ? "text-right" : "text-left"}`}
      style={{ whiteSpace: "nowrap" }}
    >
      {children}
    </th>
  );
}

export default function TablicaLige({
  tablica,
  forma,
  prvak,
  ispadanje,
}: {
  tablica: RedTablice[];
  forma: Map<string, Ishod[]>;
  prvak: number;
  ispadanje: number;
}) {
  if (!tablica.length) return null;

  const ukupno = tablica.length;
  const imaForme = Array.from(forma.values()).some((f) => f.length > 0);

  return (
    <section className="mb-12">
      <p className="oznaka-sekcije mb-3">Tablica</p>

      {/* Na užim ekranima tablica se pomiče vodoravno unutar svog okvira,
          umjesto da razvuče cijelu stranicu. */}
      <div
        className="overflow-x-auto"
        style={{ background: "var(--paper)", border: "1px solid var(--line)" }}
      >
        <table className="w-full font-sans text-sm" style={{ minWidth: 640 }}>
          <thead>
            <tr
              style={{
                background: "var(--pitch)",
                color: "var(--chalk)",
              }}
            >
              <Zaglavlje desno={false}>#</Zaglavlje>
              <Zaglavlje desno={false}>Klub</Zaglavlje>
              <Zaglavlje naslov="Odigrano">O</Zaglavlje>
              <Zaglavlje naslov="Pobjede">P</Zaglavlje>
              <Zaglavlje naslov="Neriješeno">N</Zaglavlje>
              <Zaglavlje naslov="Porazi">I</Zaglavlje>
              <Zaglavlje naslov="Dani golovi">G+</Zaglavlje>
              <Zaglavlje naslov="Primljeni golovi">G-</Zaglavlje>
              <Zaglavlje naslov="Gol razlika">+/−</Zaglavlje>
              <Zaglavlje naslov="Bodovi">B</Zaglavlje>
              {imaForme && (
                <Zaglavlje naslov="Zadnjih pet utakmica, najnovija lijevo" desno={false}>
                  Forma
                </Zaglavlje>
              )}
            </tr>
          </thead>
          <tbody>
            {tablica.map((r, i) => {
              const mjesto = i + 1;
              const jePrvak = mjesto <= prvak;
              const ispada = mjesto > ukupno - ispadanje;
              const ishodi = forma.get(kljucKluba(r.klub)) ?? [];

              return (
                <tr
                  key={r.klub}
                  style={{
                    borderTop: "1px solid var(--line)",
                    background: jePrvak
                      ? "rgba(47,158,143,0.13)"
                      : ispada
                        ? "rgba(187,58,44,0.10)"
                        : undefined,
                  }}
                >
                  <td
                    className="px-2 py-2 font-mono"
                    style={{
                      color: "var(--ink-muted)",
                      whiteSpace: "nowrap",
                      // Boja se ne oslanja samo na pozadinu retka: uz mjesto
                      // stoji i traka, da se razlika vidi i na ispisu i
                      // onima koji slabije razlikuju boje.
                      borderLeft: jePrvak
                        ? "4px solid var(--pitch-light)"
                        : ispada
                          ? "4px solid var(--card-red)"
                          : "4px solid transparent",
                    }}
                  >
                    {r.pozicija}
                  </td>
                  <td className="px-2 py-2 leading-tight">
                    <PoveznicaKluba naziv={r.klub} className="font-medium" />
                  </td>
                  <td className="px-2 py-2 text-right font-mono">{r.odigrano}</td>
                  <td className="px-2 py-2 text-right font-mono">{r.pobjede}</td>
                  <td className="px-2 py-2 text-right font-mono">{r.remiji}</td>
                  <td className="px-2 py-2 text-right font-mono">{r.porazi}</td>
                  <td className="px-2 py-2 text-right font-mono">{r.golovi_dani}</td>
                  <td className="px-2 py-2 text-right font-mono">{r.golovi_primljeni}</td>
                  <td className="px-2 py-2 text-right font-mono">{r.gol_razlika}</td>
                  <td className="px-2 py-2 text-right font-mono font-bold">{r.bodovi}</td>
                  {imaForme && (
                    <td className="px-2 py-2">
                      <span className="flex gap-1">
                        {ishodi.map((o, n) => (
                          <span
                            key={n}
                            title={BOJE[o].naziv}
                            className="flex h-5 w-5 items-center justify-center font-mono text-[10px] font-bold"
                            style={{ background: BOJE[o].pozadina, color: BOJE[o].tekst }}
                          >
                            {o}
                          </span>
                        ))}
                      </span>
                    </td>
                  )}
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      <p
        className="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 font-sans text-xs"
        style={{ color: "var(--ink-muted)" }}
      >
        <span className="flex items-center gap-1.5">
          <span
            aria-hidden="true"
            style={{ width: 10, height: 10, background: "var(--pitch-light)" }}
          />
          viši rang
        </span>
        <span className="flex items-center gap-1.5">
          <span
            aria-hidden="true"
            style={{ width: 10, height: 10, background: "var(--card-red)" }}
          />
          ispadanje
        </span>
        {imaForme && <span>Forma: zadnjih pet utakmica, najnovija lijevo.</span>}
      </p>
    </section>
  );
}

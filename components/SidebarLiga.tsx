"use client";

// SidebarLiga.tsx
//
// Tri odvojena bloka po ligi: Tablica / Strijelci / Kartoni.
// - Tablica: puna imena klubova (ne režu se)
// - Strijelci i kartoni: prvih 10, gumb "Prikaži sve" otvara ostatak
//
// NAPOMENA: bitni stilovi su ugrađeni izravno u komponentu, pa raspored
// ispravno radi i ako globals.css nije osvježen.

import { useState } from "react";
import type {
  RedTablice,
  RedStrijelca,
  RedKartona,
  StatistikeLige,
} from "@/lib/statistike";


const PRIKAZI_ODMAH = 5;

export default function SidebarLiga({ statistike }: { statistike: StatistikeLige }) {
  const { tablica, strijelci, kartoni } = statistike;
  const [sviStrijelci, setSviStrijelci] = useState(false);
  const [sviKartoni, setSviKartoni] = useState(false);

  const vidljiviStrijelci = sviStrijelci ? strijelci : strijelci.slice(0, PRIKAZI_ODMAH);
  const vidljiviKartoni = sviKartoni ? kartoni : kartoni.slice(0, PRIKAZI_ODMAH);

  return (
    <div className="space-y-4">
      {/* ---------------- TABLICA ---------------- */}
      <Blok naslov="Tablica" ukupno={tablica.length}>
        {tablica.length === 0 ? (
          <Prazno poruka="Tablica još nije učitana." />
        ) : (
          <table className="w-full font-sans text-xs">
            <thead>
              <tr style={{ borderBottom: "1px solid var(--line)", color: "var(--ink-muted)" }}>
                <th className="py-1.5 pl-2 pr-1 text-left font-normal">#</th>
                <th className="py-1.5 pr-1 text-left font-normal">Klub</th>
                <th className="py-1.5 pr-1 text-right font-normal">O</th>
                <th className="py-1.5 pr-1 text-right font-normal">+/−</th>
                <th className="py-1.5 pr-2 text-right font-normal">B</th>
              </tr>
            </thead>
            <tbody>
              {tablica.map((r) => (
                <tr key={r.klub} style={{ borderBottom: "1px solid var(--line)" }}>
                  <td
                    className="py-1.5 pl-2 pr-1 font-mono"
                    style={{ color: "var(--ink-muted)", width: "1%" }}
                  >
                    {r.pozicija}
                  </td>
                  {/* ime kluba dobiva svu preostalu širinu i ne reže se */}
                  <td className="py-1.5 pr-2 leading-tight">{r.klub}</td>
                  <td
                    className="py-1.5 pr-1 text-right font-mono"
                    style={{ width: "1%", whiteSpace: "nowrap" }}
                  >
                    {r.odigrano}
                  </td>
                  <td
                    className="py-1.5 pr-1 text-right font-mono"
                    style={{ width: "1%", whiteSpace: "nowrap" }}
                  >
                    {r.gol_razlika}
                  </td>
                  <td
                    className="py-1.5 pr-2 text-right font-mono font-bold"
                    style={{ width: "1%", whiteSpace: "nowrap" }}
                  >
                    {r.bodovi}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Blok>

      {/* ---------------- STRIJELCI ---------------- */}
      <Blok naslov="Strijelci" ukupno={strijelci.length}>
        {strijelci.length === 0 ? (
          <Prazno poruka="Lista strijelaca još nije učitana." />
        ) : (
          <>
            <ul className="font-sans text-xs">
              {vidljiviStrijelci.map((s, i) => (
                <RedIgraca
                  key={i}
                  pozicija={s.pozicija}
                  igrac={s.igrac}
                  klub={s.klub}
                  desno={<span className="font-mono text-sm font-bold">{s.golovi}</span>}
                />
              ))}
            </ul>
            <GumbProsiri
              otvoreno={sviStrijelci}
              ukupno={strijelci.length}
              prikazano={PRIKAZI_ODMAH}
              naKlik={() => setSviStrijelci((v) => !v)}
            />
          </>
        )}
      </Blok>

      {/* ---------------- KARTONI ---------------- */}
      <Blok naslov="Kartoni" ukupno={kartoni.length}>
        {kartoni.length === 0 ? (
          <Prazno poruka="Lista kartona još nije učitana." />
        ) : (
          <>
            <ul className="font-sans text-xs">
              {vidljiviKartoni.map((k, i) => (
                <RedIgraca
                  key={i}
                  pozicija={k.pozicija}
                  igrac={k.igrac}
                  klub={k.klub}
                  desno={
                    <span className="inline-flex items-center gap-1 font-mono">
                      <span className="card-tick" aria-hidden="true" />
                      {k.zuti}
                      {Number(k.crveni) > 0 && (
                        <>
                          <span className="card-tick card-tick-red ml-1" aria-hidden="true" />
                          {k.crveni}
                        </>
                      )}
                    </span>
                  }
                />
              ))}
            </ul>
            <GumbProsiri
              otvoreno={sviKartoni}
              ukupno={kartoni.length}
              prikazano={PRIKAZI_ODMAH}
              naKlik={() => setSviKartoni((v) => !v)}
            />
          </>
        )}
      </Blok>
    </div>
  );
}

/* ---------------- pomoćne komponente ---------------- */

function Blok({
  naslov,
  ukupno,
  children,
}: {
  naslov: string;
  ukupno?: number;
  children: React.ReactNode;
}) {
  return (
    <section style={{ background: "var(--paper)", border: "1px solid var(--line)" }}>
      <div
        className="flex items-baseline justify-between gap-3 px-3 py-2"
        style={{ background: "var(--pitch)", color: "var(--chalk)" }}
      >
        <h3 className="font-display text-sm uppercase tracking-wide">{naslov}</h3>
        {typeof ukupno === "number" && ukupno > 0 && (
          <span className="font-mono text-[10px] tracking-widest opacity-70">
            {ukupno}
          </span>
        )}
      </div>
      {children}
    </section>
  );
}

function RedIgraca({
  pozicija,
  igrac,
  klub,
  desno,
}: {
  pozicija: string;
  igrac: string;
  klub: string | null;
  desno: React.ReactNode;
}) {
  return (
    <li
      className="flex items-center gap-2 px-2 py-1.5"
      style={{ borderBottom: "1px solid var(--line)" }}
    >
      <span
        className="w-5 shrink-0 text-right font-mono"
        style={{ color: "var(--ink-muted)" }}
      >
        {pozicija}
      </span>
      <span className="min-w-0 flex-1 leading-tight">
        <span className="block">{igrac}</span>
        {klub && (
          <span className="block text-[11px]" style={{ color: "var(--ink-muted)" }}>
            {klub}
          </span>
        )}
      </span>
      <span className="shrink-0">{desno}</span>
    </li>
  );
}

function GumbProsiri({
  otvoreno,
  ukupno,
  prikazano,
  naKlik,
}: {
  otvoreno: boolean;
  ukupno: number;
  prikazano: number;
  naKlik: () => void;
}) {
  if (ukupno <= prikazano) return null;
  return (
    <button
      onClick={naKlik}
      className="w-full px-3 py-2 text-center font-sans text-xs font-medium hover:underline"
      style={{ color: "var(--pitch)" }}
    >
      {otvoreno ? "Prikaži manje" : `Prikaži sve (${ukupno})`}
    </button>
  );
}

function Prazno({ poruka }: { poruka: string }) {
  return (
    <p className="px-3 py-6 text-center font-sans text-xs" style={{ color: "var(--ink-muted)" }}>
      {poruka}
    </p>
  );
}

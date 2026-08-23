"use client";

// SidebarLiga.tsx
//
// Tri bloka po ligi: Posjećenost / Strijelci / Kartoni. Kod strijelaca i
// kartona prikazuje se prvih pet, gumb "Prikaži sve" otvara ostatak.
//
// Tablica poretka je preseljena u glavni stupac (components/TablicaLige):
// ovdje je bilo mjesta samo za tri stupca, a treba ih jedanaest. Na
// njezino mjesto došla je posjećenost.
//
// NAPOMENA: bitni stilovi su ugrađeni izravno u komponentu, pa raspored
// ispravno radi i ako globals.css nije osvježen.

import { useState } from "react";
import PoveznicaIgraca from "@/components/PoveznicaIgraca";
import PoveznicaKluba from "@/components/PoveznicaKluba";
import type { StatistikeLige } from "@/lib/statistike";
import { brojHr, type Posjecenost } from "@/lib/posjecenost";


const PRIKAZI_ODMAH = 5;

export default function SidebarLiga({
  statistike,
  posjecenost,
}: {
  statistike: StatistikeLige;
  posjecenost?: Posjecenost;
}) {
  const { strijelci, kartoni } = statistike;
  const [svaPosjecenost, setSvaPosjecenost] = useState(false);

  const redciPosjecenosti = posjecenost?.redci ?? [];
  const vidljivaPosjecenost = svaPosjecenost
    ? redciPosjecenosti
    : redciPosjecenosti.slice(0, PRIKAZI_ODMAH);
  const [sviStrijelci, setSviStrijelci] = useState(false);
  const [sviKartoni, setSviKartoni] = useState(false);

  const vidljiviStrijelci = sviStrijelci ? strijelci : strijelci.slice(0, PRIKAZI_ODMAH);
  const vidljiviKartoni = sviKartoni ? kartoni : kartoni.slice(0, PRIKAZI_ODMAH);

  return (
    <div className="space-y-4">
      {/* ---------------- POSJEĆENOST ---------------- */}
      {/* Broj gledatelja stoji u zapisniku svake odigrane utakmice.
          Broji se samo na domaćem terenu, pa se gostu ne pripisuje. */}
      {redciPosjecenosti.length > 0 && posjecenost && (
        <Blok naslov="Posjećenost" ukupno={redciPosjecenosti.length}>
          <p
            className="px-2 py-1.5 font-sans text-[11px]"
            style={{ borderBottom: "1px solid var(--line)", color: "var(--ink-muted)" }}
          >
            Prosjek lige{" "}
            <span className="font-mono font-bold" style={{ color: "var(--ink)" }}>
              {brojHr(posjecenost.prosjekLige)}
            </span>{" "}
            po utakmici
          </p>

          <ul className="font-sans text-xs">
            {vidljivaPosjecenost.map((r, i) => (
              <li
                key={r.klub}
                className="flex items-center gap-2 px-2 py-1.5"
                style={{ borderBottom: "1px solid var(--line)" }}
              >
                <span
                  className="w-5 shrink-0 text-right font-mono"
                  style={{ color: "var(--ink-muted)" }}
                >
                  {i + 1}
                </span>
                <span className="min-w-0 flex-1 leading-tight">
                  <span className="block">
                    <PoveznicaKluba naziv={r.klub} />
                  </span>
                  <span className="block text-[11px]" style={{ color: "var(--ink-muted)" }}>
                    {r.utakmica} kod kuće · ukupno {brojHr(r.ukupno)}
                  </span>
                </span>
                <span className="shrink-0 font-mono text-sm font-bold">
                  {brojHr(r.prosjek)}
                </span>
              </li>
            ))}
          </ul>

          <GumbProsiri
            otvoreno={svaPosjecenost}
            ukupno={redciPosjecenosti.length}
            prikazano={PRIKAZI_ODMAH}
            naKlik={() => setSvaPosjecenost((v) => !v)}
          />

          {posjecenost.vrhunac && (
            <p
              className="px-2 py-2 font-sans text-[11px] leading-snug"
              style={{ borderTop: "1px solid var(--line)", color: "var(--ink-muted)" }}
            >
              Najposjećenija:{" "}
              <span style={{ color: "var(--ink)" }}>
                {posjecenost.vrhunac.domacin} - {posjecenost.vrhunac.gost}
              </span>
              , <span className="font-mono font-bold">{brojHr(posjecenost.vrhunac.gledatelja)}</span>
              {posjecenost.vrhunac.kolo ? `, ${posjecenost.vrhunac.kolo}. kolo` : ""}
            </p>
          )}
        </Blok>
      )}

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
        <span className="block">
          <PoveznicaIgraca ime={igrac} />
        </span>
        {klub && (
          <span className="block text-[11px]" style={{ color: "var(--ink-muted)" }}>
            <PoveznicaKluba naziv={klub} />
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

// PregledKola.tsx — lijevi stupac naslovnice: tri bloka, svaki razložen
// po ligama. Sve se računa iz utakmica koje naslovnica ionako dohvaća,
// pa nema dodatnih upita ni novog scrapanja.

import Link from "next/link";
import Brojka from "@/components/Brojka";
import Otkrivanje from "@/components/Otkrivanje";
import { LIGE } from "@/lib/lige";
import {
  sazetakKola,
  najposjecenija,
  derbiLige,
  golovi,
  skrati,
  type UtakmicaMin,
} from "@/lib/kolo";

export default function PregledKola({ utakmice }: { utakmice: UtakmicaMin[] }) {
  return (
    <div className="space-y-4">
      <Otkrivanje>
        <BlokKoloUBrojkama utakmice={utakmice} />
      </Otkrivanje>
      <Otkrivanje kasnjenje={80}>
        <BlokNajposjecenije utakmice={utakmice} />
      </Otkrivanje>
      <Otkrivanje kasnjenje={160}>
        <BlokDerbiji utakmice={utakmice} />
      </Otkrivanje>
    </div>
  );
}

/* ---------------- 1. Kolo u brojkama ---------------- */

function BlokKoloUBrojkama({ utakmice }: { utakmice: UtakmicaMin[] }) {
  const redovi = LIGE.map((l) => ({ liga: l, s: sazetakKola(utakmice, l.naziv) })).filter(
    (r) => r.s
  );
  if (!redovi.length) return null;

  return (
    <Blok naslov="Kolo u brojkama">
      {redovi.map(({ liga, s }) => (
        <div key={liga.slug} className="px-3 py-2.5" style={{ borderBottom: "1px solid var(--line)" }}>
          <ZaglavljeLige liga={liga} dodatak={`${s!.kolo}. kolo`} />
          <p className="mt-1 font-mono text-xs" style={{ color: "var(--ink-muted)" }}>
            <Brojka vrijednost={s!.brojUtakmica} /> utakmica ·{" "}
            <Brojka vrijednost={s!.ukupnoGolova} /> golova
          </p>
          {s!.najviseGolova && (
            <p className="mt-1 font-sans text-[11px] leading-snug">
              <span style={{ color: "var(--ink-muted)" }}>Najviše golova: </span>
              {s!.najviseGolova.u.domacin} {s!.najviseGolova.u.rezultat}{" "}
              {s!.najviseGolova.u.gost}
            </p>
          )}
          {s!.najuvjerljivija && (
            <p className="font-sans text-[11px] leading-snug">
              <span style={{ color: "var(--ink-muted)" }}>Najuvjerljivije: </span>
              {s!.najuvjerljivija.u.domacin} {s!.najuvjerljivija.u.rezultat}{" "}
              {s!.najuvjerljivija.u.gost}
            </p>
          )}
        </div>
      ))}
    </Blok>
  );
}

/* ---------------- 2. Najposjećenije ---------------- */

function BlokNajposjecenije({ utakmice }: { utakmice: UtakmicaMin[] }) {
  const redovi = LIGE.map((l) => ({ liga: l, n: najposjecenija(utakmice, l.naziv) })).filter(
    (r) => r.n
  );
  if (!redovi.length) return null;

  return (
    <Blok naslov="Najposjećenije">
      {redovi.map(({ liga, n }) => (
        <div key={liga.slug} className="px-3 py-2.5" style={{ borderBottom: "1px solid var(--line)" }}>
          <ZaglavljeLige liga={liga} />
          <p className="mt-1 font-sans text-[11px] leading-snug">
            {n!.u.domacin} {n!.u.rezultat} {n!.u.gost}
          </p>
          <p className="font-mono text-xs font-bold" style={{ color: "var(--oxide)" }}>
            <Brojka vrijednost={n!.gledatelja} /> gledatelja
          </p>
        </div>
      ))}
    </Blok>
  );
}

/* ---------------- 3. Derbiji vikenda ---------------- */

function BlokDerbiji({ utakmice }: { utakmice: UtakmicaMin[] }) {
  const redovi = LIGE.map((l) => ({ liga: l, d: derbiLige(utakmice, l.naziv) })).filter(
    (r) => r.d
  );
  if (!redovi.length) return null;

  return (
    <Blok naslov="Derbiji vikenda">
      {redovi.map(({ liga, d }) => (
        <Link
          key={liga.slug}
          href={`/liga/${liga.slug}${d!.kolo ? `?kolo=${d!.kolo}` : ""}`}
          className="block px-3 py-2.5 transition-opacity hover:opacity-75"
          style={{ borderBottom: "1px solid var(--line)" }}
        >
          <ZaglavljeLige liga={liga} />
          <p className="mt-1 font-sans text-[11px] font-medium leading-snug">
            {d!.domacin}{" "}
            {golovi(d!.rezultat) && (
              <span className="font-mono font-bold">{d!.rezultat}</span>
            )}{" "}
            {d!.gost}
          </p>
          {d!.tekst_clanka && (
            <p className="mt-1 font-sans text-[11px] leading-snug" style={{ color: "var(--ink-muted)" }}>
              {skrati(d!.tekst_clanka, 110)}
            </p>
          )}
          {/* Derbi se označi PRIJE utakmice, a sažetak stiže poslije nje.
              Dok teksta nema, poveznica ne smije obećavati osvrt. */}
          <span className="mt-1 inline-block font-sans text-[11px] font-medium" style={{ color: "var(--pitch)" }}>
            {d!.tekst_clanka ? "Cijeli osvrt →" : "Vidi kolo →"}
          </span>
        </Link>
      ))}
    </Blok>
  );
}

/* ---------------- zajedničko ---------------- */

function Blok({ naslov, children }: { naslov: string; children: React.ReactNode }) {
  return (
    <section style={{ background: "var(--paper)", border: "1px solid var(--line)" }}>
      <div className="px-3 py-2" style={{ background: "var(--pitch)", color: "var(--chalk)" }}>
        <h3 className="font-display text-sm uppercase tracking-wide">{naslov}</h3>
      </div>
      {children}
    </section>
  );
}

function ZaglavljeLige({
  liga,
  dodatak,
}: {
  liga: { naziv: string; slug: string };
  dodatak?: string;
}) {
  return (
    <p className="flex items-baseline justify-between gap-2">
      <span className="font-display text-[11px] uppercase tracking-wide">{liga.naziv}</span>
      {dodatak && (
        <span className="font-mono text-[10px]" style={{ color: "var(--ink-muted)" }}>
          {dodatak}
        </span>
      )}
    </p>
  );
}

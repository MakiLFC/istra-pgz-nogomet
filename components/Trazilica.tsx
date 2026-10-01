"use client";

// Trazilica.tsx — traženje igrača i klubova, na naslovnici.
//
// Popis dolazi iz /pretraga.json (app/pretraga.json/route.ts), jedne
// datoteke pripremljene na poslužitelju. Dohvaća se TEK kad se klikne u
// polje, ne s naslovnicom, jer je velika stotinjak kilobajta, a većina
// posjetitelja ne traži ništa. Samo traženje ide ovdje, u pregledniku,
// pa upisani upit ne troši ništa na poslužitelju.
//
// Popis rezultata stoji u toku stranice, a ne kao padajući izbornik
// preko nje: Hero ima overflow-hidden, pa bi mu donji dio bio odrezan.

import { useMemo, useRef, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";

type Stavka = {
  vrsta: "klub" | "igrac";
  ime: string;
  slug: string;
  /** Klub igrača; kod klubova prazno. */
  klub: string;
  /** Riječi imena bez dijakritika, za usporedbu. */
  rijeci: string[];
};

type Popis = { k: [string, string][]; i: [string, string, string][] };

const NAJVISE = 10;

/** "Josipović Đurđa" -> "josipovic durda" */
function bezKvacica(tekst: string): string {
  return tekst
    .replace(/[đĐ]/g, "d")
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .toLowerCase();
}

const uRijeci = (tekst: string) => bezKvacica(tekst).split(/[^a-z0-9]+/).filter(Boolean);

function uStavke(p: Popis): Stavka[] {
  return [
    ...p.k.map(([ime, slug]) => ({
      vrsta: "klub" as const, ime, slug, klub: "", rijeci: uRijeci(ime),
    })),
    ...p.i.map(([ime, slug, klub]) => ({
      vrsta: "igrac" as const, ime, slug, klub, rijeci: uRijeci(ime),
    })),
  ];
}

/**
 * Svaka upisana riječ mora biti POČETAK neke riječi imena, bilo kojim
 * redom: "jos kar" nađe Karla Josipovića, "kralj" Kraljevicu. Kvačice se
 * ne gledaju, pa "zminj" nađe Žminj.
 */
function trazi(stavke: Stavka[], upit: string): Stavka[] {
  const trazene = uRijeci(upit);
  if (!trazene.length) return [];
  return stavke
    .filter((s) => trazene.every((t) => s.rijeci.some((r) => r.startsWith(t))))
    // Klubovi prvi, jer ih je malo i lako se izgube među igračima.
    .sort((a, b) => (a.vrsta === b.vrsta ? 0 : a.vrsta === "klub" ? -1 : 1))
    .slice(0, NAJVISE);
}

const adresa = (s: Stavka) => (s.vrsta === "klub" ? `/klub/${s.slug}` : `/igrac/${s.slug}`);

export default function Trazilica() {
  const router = useRouter();
  const [stavke, setStavke] = useState<Stavka[] | null>(null);
  const [greska, setGreska] = useState(false);
  const [upit, setUpit] = useState("");
  const [oznacen, setOznacen] = useState(0);
  const dohvaca = useRef(false);

  function ucitaj() {
    if (stavke || dohvaca.current) return;
    dohvaca.current = true;
    setGreska(false);
    fetch("/pretraga.json")
      .then((r) => {
        if (!r.ok) throw new Error(String(r.status));
        return r.json() as Promise<Popis>;
      })
      .then((p) => setStavke(uStavke(p)))
      // Oznaka se spušta SAMO nakon greške, da se može pokušati ponovno.
      // Nakon uspjeha ostaje podignuta: do iscrtavanja s učitanim popisom
      // sljedeća tipka bi inače vidjela prazan popis i dohvatila ga opet.
      .catch(() => {
        dohvaca.current = false;
        setGreska(true);
      });
  }

  const rezultati = useMemo(
    () => (stavke && upit.trim().length >= 2 ? trazi(stavke, upit) : []),
    [stavke, upit]
  );

  function tipka(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setOznacen((o) => Math.min(o + 1, rezultati.length - 1));
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setOznacen((o) => Math.max(o - 1, 0));
    } else if (e.key === "Enter" && rezultati[oznacen]) {
      e.preventDefault();
      router.push(adresa(rezultati[oznacen]));
    } else if (e.key === "Escape") {
      setUpit("");
    }
  }

  const prikaziPopis = upit.trim().length >= 2;

  return (
    <div className="mt-6 max-w-xl">
      <label htmlFor="trazilica" className="sr-only">
        Traži igrača ili klub
      </label>
      <div className="relative">
        <svg
          aria-hidden="true"
          viewBox="0 0 24 24"
          width="18"
          height="18"
          className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 opacity-70"
        >
          <circle cx="10.5" cy="10.5" r="6.5" fill="none" stroke="currentColor" strokeWidth="2.6" />
          <path d="M15.5 15.5 21 21" stroke="currentColor" strokeWidth="2.8" strokeLinecap="round" />
        </svg>
        <input
          id="trazilica"
          // "text", ne "search": polje za traženje u Chromeu dobiva plavi
          // križić koji na tamnoj podlozi strši. Tipka za traženje na
          // mobitelu ostaje, preko enterKeyHint.
          type="text"
          enterKeyHint="search"
          autoComplete="off"
          spellCheck={false}
          placeholder="Traži igrača ili klub"
          value={upit}
          onFocus={ucitaj}
          onChange={(e) => {
            setUpit(e.target.value);
            setOznacen(0);
            ucitaj();
          }}
          onKeyDown={tipka}
          role="combobox"
          aria-expanded={prikaziPopis && rezultati.length > 0}
          aria-controls="trazilica-rezultati"
          aria-activedescendant={rezultati[oznacen] ? `trazilica-${oznacen}` : undefined}
          className="w-full rounded-md border py-3 pl-11 pr-4 font-sans text-base outline-none transition-colors placeholder:opacity-60 focus:border-[var(--oxide-light)]"
          style={{
            background: "rgba(247,250,246,0.08)",
            borderColor: "rgba(233,234,229,0.28)",
            color: "var(--chalk)",
          }}
        />
      </div>

      {prikaziPopis && (
        <div
          className="mt-2 overflow-hidden rounded-md font-sans text-sm shadow-lg"
          style={{ background: "var(--paper)", color: "var(--ink)" }}
        >
          {greska ? (
            <p className="px-4 py-3" style={{ color: "var(--ink-muted)" }}>
              Popis se nije mogao učitati. Pokušaj ponovno za trenutak.
            </p>
          ) : !stavke ? (
            <p className="px-4 py-3" style={{ color: "var(--ink-muted)" }}>
              Učitavam popis igrača i klubova...
            </p>
          ) : rezultati.length === 0 ? (
            <p className="px-4 py-3" style={{ color: "var(--ink-muted)" }}>
              Nema igrača ni kluba s tim imenom.
            </p>
          ) : (
            <ul id="trazilica-rezultati" role="listbox">
              {rezultati.map((s, idx) => (
                <li
                  key={`${s.vrsta}-${s.slug}`}
                  id={`trazilica-${idx}`}
                  role="option"
                  aria-selected={idx === oznacen}
                >
                  <Link
                    href={adresa(s)}
                    onMouseEnter={() => setOznacen(idx)}
                    className="flex items-baseline justify-between gap-3 border-b px-4 py-2.5 last:border-b-0"
                    style={{
                      borderColor: "var(--line)",
                      background: idx === oznacen ? "var(--chalk)" : undefined,
                      // Kartica i podloga su bliske boje, pa označeni redak
                      // dobiva i hrđastu crtu s lijeve strane.
                      boxShadow: idx === oznacen ? "inset 3px 0 0 var(--oxide)" : undefined,
                    }}
                  >
                    <span className="min-w-0 truncate font-medium">{s.ime}</span>
                    <span
                      className="shrink-0 font-mono text-[10px] uppercase tracking-[0.14em]"
                      style={{ color: s.vrsta === "klub" ? "var(--oxide)" : "var(--ink-muted)" }}
                    >
                      {s.vrsta === "klub" ? "klub" : s.klub || "igrač"}
                    </span>
                  </Link>
                </li>
              ))}
            </ul>
          )}
        </div>
      )}
    </div>
  );
}

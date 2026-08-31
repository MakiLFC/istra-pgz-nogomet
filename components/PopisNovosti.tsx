"use client";

// PopisNovosti.tsx — mreža kartica na stranici novosti, s postupnim
// otkrivanjem.
//
// Zašto klijentska: gumb "Učitaj više" traži klik, a sve članke stranica
// ionako dohvati na poslužitelju u jednom upitu. Ovdje se dakle ništa ne
// dohvaća, samo se dio popisa drži skrivenim dok se ne zatraži.
//
// Popis je malen (desetci članaka), pa nema smisla raditi dohvat po
// stranicama: to bi dodalo čekanje ondje gdje ga sada nema.

import { useState } from "react";
import type { Clanak } from "@/lib/clanci";
import KarticaClanka from "./KarticaClanka";
import Otkrivanje from "./Otkrivanje";

/** Koliko kartica stoji odmah, i koliko ih donese svaki klik. */
const KORAK = 6;

export default function PopisNovosti({ clanci }: { clanci: Clanak[] }) {
  const [vidljivo, setVidljivo] = useState(KORAK);

  const prikazani = clanci.slice(0, vidljivo);
  const preostalo = clanci.length - prikazani.length;

  return (
    <>
      <div className="mt-8 grid grid-cols-1 gap-3 sm:grid-cols-2">
        {prikazani.map((c, idx) => (
          <Otkrivanje key={c.id} kasnjenje={Math.min(idx % KORAK, 6) * 45}>
            <KarticaClanka clanak={c} />
          </Otkrivanje>
        ))}
      </div>

      {preostalo > 0 && (
        <div className="mt-6 text-center">
          <button
            onClick={() => setVidljivo((n) => n + KORAK)}
            className="font-sans px-4 py-2 text-sm font-medium hover:opacity-80"
            style={{
              border: "1px solid var(--line)",
              background: "var(--paper)",
              color: "var(--pitch)",
            }}
          >
            Učitaj više ({preostalo})
          </button>
        </div>
      )}
    </>
  );
}

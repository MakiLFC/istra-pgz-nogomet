"use client";

// SidebarLiga.tsx
//
// Sidebar s tri kartice po ligi: Tablica / Strijelci / Kartoni.
// Podatke čita iz Supabase tablice 'statistike' (puni je scraper).
//
// UGRADNJA na stranicu lige (npr. app/liga/[naziv]/page.tsx):
//
//   import SidebarLiga from "@/components/SidebarLiga";
//   ...
//   <div className="flex flex-col gap-6 lg:flex-row">
//     <main className="min-w-0 flex-1">
//       {/* postojeći sadržaj lige (kola, rezultati...) */}
//     </main>
//     <aside className="w-full shrink-0 lg:w-80">
//       <SidebarLiga natjecanje={nazivLige} sezona="2025/26" />
//     </aside>
//   </div>
//
// Na velikim ekranima sidebar stoji desno, na mobitelu ispod sadržaja.
// NAPOMENA: 'supabase' klijent se uvozi iz "@/lib/supabase" - isti onaj
// koji već koristiš za utakmice. Ako se tvoj export zove drugačije,
// prilagodi liniju uvoza ispod.

import { useEffect, useState } from "react";
import { supabase } from "@/lib/supabase";

type RedTablice = {
  pozicija: string; klub: string; odigrano: string; pobjede: string;
  remiji: string; porazi: string; golovi_dani: string;
  golovi_primljeni: string; gol_razlika: string; bodovi: string;
};
type RedStrijelca = { pozicija: string; igrac: string; klub: string; golovi: string };
type RedKartona = { pozicija: string; igrac: string; klub: string; zuti: string; crveni: string };

type Kartica = "tablica" | "strijelci" | "kartoni";

export default function SidebarLiga({
  natjecanje,
  sezona,
}: {
  natjecanje: string;
  sezona: string;
}) {
  const [kartica, setKartica] = useState<Kartica>("tablica");
  const [tablica, setTablica] = useState<RedTablice[]>([]);
  const [strijelci, setStrijelci] = useState<RedStrijelca[]>([]);
  const [kartoni, setKartoni] = useState<RedKartona[]>([]);
  const [ucitava, setUcitava] = useState(true);

  useEffect(() => {
    let aktivno = true;
    (async () => {
      setUcitava(true);
      const { data, error } = await supabase
        .from("statistike")
        .select("tip, podaci")
        .eq("natjecanje", natjecanje)
        .eq("sezona", sezona);
      if (!aktivno) return;
      if (!error && data) {
        for (const red of data) {
          if (red.tip === "tablica") setTablica(red.podaci as RedTablice[]);
          if (red.tip === "strijelci") setStrijelci(red.podaci as RedStrijelca[]);
          if (red.tip === "kartoni") setKartoni(red.podaci as RedKartona[]);
        }
      }
      setUcitava(false);
    })();
    return () => { aktivno = false; };
  }, [natjecanje, sezona]);

  const gumb = (k: Kartica, naslov: string) => (
    <button
      key={k}
      onClick={() => setKartica(k)}
      className={`flex-1 px-2 py-1.5 font-sans text-xs font-semibold uppercase tracking-wide transition-colors ${
        kartica === k ? "" : "opacity-50 hover:opacity-80"
      }`}
      style={{
        color: kartica === k ? "var(--ink)" : "var(--ink-muted)",
        borderBottom: kartica === k
          ? "2px solid var(--card-yellow)"
          : "2px solid transparent",
      }}
    >
      {naslov}
    </button>
  );

  return (
    <div className="rounded-lg border p-3" style={{ borderColor: "var(--ink-muted)" }}>
      <div className="mb-2 flex" role="tablist">
        {gumb("tablica", "Tablica")}
        {gumb("strijelci", "Strijelci")}
        {gumb("kartoni", "Kartoni")}
      </div>

      {ucitava ? (
        <p className="py-4 text-center font-sans text-xs" style={{ color: "var(--ink-muted)" }}>
          Učitavanje…
        </p>
      ) : kartica === "tablica" ? (
        tablica.length === 0 ? (
          <Prazno />
        ) : (
          <table className="w-full font-sans text-xs">
            <thead>
              <tr style={{ color: "var(--ink-muted)" }}>
                <th className="py-1 pr-1 text-left font-normal">#</th>
                <th className="py-1 pr-1 text-left font-normal">Klub</th>
                <th className="py-1 pr-1 text-right font-normal">U</th>
                <th className="py-1 pr-1 text-right font-normal">+/-</th>
                <th className="py-1 text-right font-normal">Bod</th>
              </tr>
            </thead>
            <tbody>
              {tablica.map((r) => (
                <tr key={r.klub}>
                  <td className="py-0.5 pr-1 font-mono" style={{ color: "var(--ink-muted)" }}>
                    {r.pozicija}
                  </td>
                  <td className="max-w-0 truncate py-0.5 pr-1" title={r.klub}>{r.klub}</td>
                  <td className="py-0.5 pr-1 text-right font-mono">{r.odigrano}</td>
                  <td className="py-0.5 pr-1 text-right font-mono">{r.gol_razlika}</td>
                  <td className="py-0.5 text-right font-mono font-semibold">{r.bodovi}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )
      ) : kartica === "strijelci" ? (
        strijelci.length === 0 ? (
          <Prazno />
        ) : (
          <ul className="font-sans text-xs">
            {strijelci.map((s, i) => (
              <li key={i} className="flex items-baseline gap-2 py-1">
                <span className="w-4 shrink-0 text-right font-mono" style={{ color: "var(--ink-muted)" }}>
                  {s.pozicija}
                </span>
                <span className="min-w-0 flex-1">
                  <span className="block truncate">{s.igrac}</span>
                  <span className="block truncate" style={{ color: "var(--ink-muted)" }}>
                    {s.klub}
                  </span>
                </span>
                <span className="font-mono font-semibold">{s.golovi}</span>
              </li>
            ))}
          </ul>
        )
      ) : kartoni.length === 0 ? (
        <Prazno />
      ) : (
        <ul className="font-sans text-xs">
          {kartoni.map((k, i) => (
            <li key={i} className="flex items-baseline gap-2 py-1">
              <span className="w-4 shrink-0 text-right font-mono" style={{ color: "var(--ink-muted)" }}>
                {k.pozicija}
              </span>
              <span className="min-w-0 flex-1">
                <span className="block truncate">{k.igrac}</span>
                <span className="block truncate" style={{ color: "var(--ink-muted)" }}>
                  {k.klub}
                </span>
              </span>
              <span className="inline-flex items-baseline gap-1 font-mono">
                <span style={{ color: "var(--card-yellow)" }}>▮</span>{k.zuti}
                <span className="ml-1" style={{ color: "var(--card-red)" }}>▮</span>{k.crveni}
              </span>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

function Prazno() {
  return (
    <p className="py-4 text-center font-sans text-xs" style={{ color: "var(--ink-muted)" }}>
      Nema podataka.
    </p>
  );
}

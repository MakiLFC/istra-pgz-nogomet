"use client";

// components/Dijeljenje.tsx — gumbi za dijeljenje pojedine stranice.
//
// Adresa se NE čita iz window.location. Komponenta se prvo iscrtava na
// poslužitelju, gdje window ne postoji, pa bi poveznice na prvom prikazu
// bile prazne i tek bi ih preglednik naknadno popunio. Umjesto toga
// putanja dolazi kao prop, a domena iz NEXT_PUBLIC_SITE_URL, iste
// varijable koju koriste sitemap i oznake za dijeljenje.
//
// Klijentska je samo zbog gumba "Kopiraj": čitanje i pisanje u
// međuspremnik radi jedino u pregledniku. Stranice na koje se ugrađuje
// ostaju poslužiteljske.

import { useEffect, useState } from "react";

// Ista zamjenska vrijednost kao u app/sitemap.ts: domena, nikad Vercelova
// adresa, da podijeljena poveznica ne odvede na pomoćnu adresu.
const OSNOVA = (process.env.NEXT_PUBLIC_SITE_URL?.trim() || "https://lokalarena.com")
  .replace(/\/+$/, "");

export default function Dijeljenje({
  putanja,
  naslov,
}: {
  /** Putanja stranice, npr. "/novosti/najava-1-kola". */
  putanja: string;
  /** Naslov koji ide u poruku na WhatsAppu. */
  naslov: string;
}) {
  const adresa = `${OSNOVA}${putanja.startsWith("/") ? putanja : `/${putanja}`}`;

  const [kopirano, setKopirano] = useState(false);
  // Međuspremnik postoji samo u sigurnom kontekstu (https ili localhost).
  // Provjera ide u useEffect, dakle tek u pregledniku: kad bi se radila
  // pri iscrtavanju, poslužitelj i preglednik dali bi različit ishod i
  // React bi prijavio neslaganje.
  const [mozeKopirati, setMozeKopirati] = useState(false);

  useEffect(() => {
    setMozeKopirati(typeof navigator !== "undefined" && !!navigator.clipboard);
  }, []);

  useEffect(() => {
    if (!kopirano) return;
    const odbrojavanje = setTimeout(() => setKopirano(false), 2000);
    return () => clearTimeout(odbrojavanje);
  }, [kopirano]);

  async function kopiraj() {
    try {
      await navigator.clipboard.writeText(adresa);
      setKopirano(true);
    } catch {
      // Neki preglednici odbiju pisanje bez izravne dozvole. Radije se
      // gumb makne nego da posjetitelj klika nešto što ne radi.
      setMozeKopirati(false);
    }
  }

  const facebook = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(adresa)}`;
  const whatsapp = `https://wa.me/?text=${encodeURIComponent(`${naslov} ${adresa}`)}`;

  return (
    <div className="mt-8 flex flex-wrap items-center gap-2 pt-5" style={{ borderTop: "1px solid var(--line)" }}>
      <span
        className="mr-1 font-mono text-[10px] uppercase tracking-widest"
        style={{ color: "var(--ink-muted)" }}
      >
        Podijeli
      </span>

      <a className="gumb-dijeljenje" href={facebook} target="_blank" rel="noopener noreferrer">
        Facebook
      </a>

      <a className="gumb-dijeljenje" href={whatsapp} target="_blank" rel="noopener noreferrer">
        WhatsApp
      </a>

      {mozeKopirati && (
        <button className="gumb-dijeljenje" onClick={kopiraj} type="button">
          {kopirano ? "Kopirano" : "Kopiraj poveznicu"}
        </button>
      )}

      {/* Potvrda se izgovara i čitačima ekrana, koji promjenu natpisa na
          gumbu ne moraju primijetiti. */}
      <span aria-live="polite" className="sr-only">
        {kopirano ? "Poveznica je kopirana." : ""}
      </span>
    </div>
  );
}

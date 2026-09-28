"use client";

// OcistiStariUpit.tsx — briše ostatke starih adresa iz adresne trake.
//
// Kolo, sezona i filtar novosti nekad su stajali u upitu (?kolo=6,
// ?sezona=2025/26, ?liga=3. NL Zapad). Sada su dio putanje, a stare
// adrese preusmjerava next.config.ts.
//
// Next.js pri preusmjeravanju UVIJEK prenese stari upit na novu adresu i
// to se u konfiguraciji ne može isključiti; isprobana su četiri oblika
// odredišta (obično, s "?", s praznom vrijednošću, s punom adresom), i
// svi su ga zadržali. Posjetitelj koji dođe sa stare poveznice tako
// završi na ispravnoj stranici, ali s repom u adresi:
//
//   /novosti/liga/3-nl-zapad?liga=3.%20NL%20Zapad
//
// Ovdje se taj rep miče nakon učitavanja, preko history.replaceState.
// To NE traži novo učitavanje stranice, ne šalje ništa poslužitelju i ne
// pravi novi zapis u povijesti preglednika, pa gumb "natrag" radi kao i
// prije.
//
// Brišu se SAMO ta tri ključa, nikad cijeli upit: tako se ne dira ništa
// što bi neka buduća stranica mogla čitati.

import { useEffect } from "react";

const STARI_KLJUCEVI = ["kolo", "sezona", "liga"];

export default function OcistiStariUpit() {
  useEffect(() => {
    try {
      const adresa = new URL(window.location.href);
      let dirnuto = false;

      for (const kljuc of STARI_KLJUCEVI) {
        if (adresa.searchParams.has(kljuc)) {
          adresa.searchParams.delete(kljuc);
          dirnuto = true;
        }
      }

      if (dirnuto) {
        window.history.replaceState(
          null,
          "",
          adresa.pathname + adresa.search + adresa.hash
        );
      }
    } catch {
      // Adresna traka je kozmetika; ako nešto ne prođe, stranica radi dalje.
    }
  }, []);

  return null;
}

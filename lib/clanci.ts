// lib/clanci.ts — dohvat i pomoćne funkcije za članke.

import { supabase } from "@/lib/supabase";

export type Clanak = {
  id: number;
  slug: string;
  naslov: string;
  sazetak: string | null;
  tekst: string;
  natjecanje: string | null;
  slika_url: string | null;
  objavljen: boolean;
  objavljeno_u: string;
};

/** Objavljeni članci, najnoviji prvi. `liga` filtrira po natjecanju. */
export async function dohvatiClanke(opcije?: {
  liga?: string;
  koliko?: number;
}): Promise<Clanak[]> {
  let upit = supabase
    .from("clanci")
    .select("*")
    .eq("objavljen", true)
    .order("objavljeno_u", { ascending: false });

  if (opcije?.liga) upit = upit.eq("natjecanje", opcije.liga);
  if (opcije?.koliko) upit = upit.limit(opcije.koliko);

  const { data, error } = await upit;
  if (error) {
    console.error("Greška kod dohvaćanja članaka:", error);
    return [];
  }
  return data ?? [];
}

export async function dohvatiClanak(slug: string): Promise<Clanak | null> {
  const { data, error } = await supabase
    .from("clanci")
    .select("*")
    .eq("slug", slug)
    .eq("objavljen", true)
    .maybeSingle();

  if (error) {
    console.error("Greška kod dohvaćanja članka:", error);
    return null;
  }
  return data ?? null;
}

/** "2026-08-11T18:30:00Z" -> "11. kolovoza 2026." */
export function datumHr(iso: string): string {
  const mjeseci = [
    "siječnja", "veljače", "ožujka", "travnja", "svibnja", "lipnja",
    "srpnja", "kolovoza", "rujna", "listopada", "studenoga", "prosinca",
  ];
  const d = new Date(iso);
  if (isNaN(d.getTime())) return "";
  return `${d.getDate()}. ${mjeseci[d.getMonth()]} ${d.getFullYear()}.`;
}

/** Tekst -> odlomci (prazan red razdvaja odlomke) */
export function odlomci(tekst: string): string[] {
  return tekst
    .split(/\n\s*\n/)
    .map((o) => o.trim())
    .filter(Boolean);
}

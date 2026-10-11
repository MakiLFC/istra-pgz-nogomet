// app/rss.xml/route.ts — RSS 2.0 feed objavljenih članaka (/rss.xml).
//
// Što smije ući u feed i zašto, stoji u lib/rss.ts. Ukratko: samo naslov,
// kratki opis (sazetak), datum, poveznica i liga, nikad tekst ni slike.
//
// Upit čita samo potrebne stupce, javnim (anon) klijentom kao i /novosti.
// RLS na tablici clanci ionako pušta samo objavljene, a uvjet objavljen
// stoji i ovdje, da feed ne ovisi samo o postavci u bazi.

import { supabase } from "@/lib/supabase";
import { KOLIKO_U_FEEDU, STUPCI_FEEDA, slozFeed, type StavkaFeeda } from "@/lib/rss";

// Isto kao bočni stupac: novi članak u feedu je najkasnije za pet minuta.
export const revalidate = 300;

export async function GET() {
  const sada = new Date();
  const { data, error } = await supabase
    .from("clanci")
    .select(STUPCI_FEEDA)
    .eq("objavljen", true)
    // Zakazanog objavljivanja zasad nema, ali članak s datumom u
    // budućnosti ne smije u feed ni ako se jednom uvede.
    .lte("objavljeno_u", sada.toISOString())
    .order("objavljeno_u", { ascending: false })
    .limit(KOLIKO_U_FEEDU);

  // Kad baza vrati grešku, ruta je baci. Next tada zadrži zadnji ispravan
  // feed, umjesto da pet minuta poslužuje prazan i aplikacija koja ga čita
  // pomisli da su članci nestali. Pri gradnji se ne baca, da kratki ispad
  // baze ne sruši objavu cijele stranice.
  if (error && process.env.NEXT_PHASE !== "phase-production-build") {
    throw new Error(`RSS: baza je vratila grešku: ${error.message}`);
  }

  const clanci = (data ?? []) as StavkaFeeda[];
  return new Response(slozFeed(clanci, sada), {
    headers: { "Content-Type": "application/rss+xml; charset=utf-8" },
  });
}

// lib/utakmice.ts — dohvat pojedine utakmice i pomoćni izračuni.

import { supabase, type Utakmica } from "@/lib/supabase";

/**
 * Jedna utakmica po identifikatoru.
 *
 * Ovdje je select("*") u redu, za razliku od naslovnice: dohvaća se
 * jedan redak, a stranica prikazuje gotovo sva njegova polja, uključujući
 * postave, zbog kojih ta stranica i postoji.
 */
export async function dohvatiUtakmicu(id: number): Promise<Utakmica | null> {
  const { data, error } = await supabase
    .from("utakmice")
    .select("*")
    .eq("id", id)
    .maybeSingle();

  if (error) {
    console.error("Utakmica: greška kod dohvaćanja:", error.message);
    return null;
  }
  return (data as Utakmica) ?? null;
}

/**
 * Strijelci razvrstani po klubu.
 *
 * U bazi nije zapisano kojem klubu strijelac pripada, ali znamo postave
 * obiju momčadi, pa se svaki strijelac pripisuje klubu u čijoj se postavi
 * nalazi. Kad postave nema, strijelac ostaje u skupini "nepoznato", da se
 * ne pripiše krivom klubu.
 */
export function strijelciPoKlubu(u: Utakmica) {
  const doma = new Set((u.postava_domacin ?? []).map((i) => i.igrac));
  const vani = new Set((u.postava_gost ?? []).map((i) => i.igrac));

  type Strijelac = { igrac: string; minuta: string };
  const domacin: Strijelac[] = [];
  const gost: Strijelac[] = [];
  const nepoznato: Strijelac[] = [];

  for (const s of u.strijelci ?? []) {
    if (doma.has(s.igrac)) domacin.push(s);
    else if (vani.has(s.igrac)) gost.push(s);
    else nepoznato.push(s);
  }

  return { domacin, gost, nepoznato };
}

/** Ima li utakmica zapisnik, dakle strijelce ili postave. */
export function imaZapisnik(u: Utakmica): boolean {
  return Boolean(
    u.strijelci?.length || u.postava_domacin?.length || u.postava_gost?.length
  );
}

/**
 * Odigrane utakmice, samo polja potrebna za adrese. Za sitemap.
 * Dohvat ide u komadima, jer Supabase po zadanom vraća najviše tisuću
 * redaka, a odigranih utakmica kroz sve sezone ima i više.
 */
export async function dohvatiOdigraneZaAdrese(): Promise<
  { id: number; domacin: string; gost: string }[]
> {
  const KOMAD = 1000;
  const NAJVISE_KOMADA = 50;
  const svi: { id: number; domacin: string; gost: string }[] = [];

  try {
    for (let i = 0; i < NAJVISE_KOMADA; i++) {
      const od = i * KOMAD;
      const { data, error } = await supabase
        .from("utakmice")
        .select("id, domacin, gost, rezultat")
        .order("id", { ascending: true })
        .range(od, od + KOMAD - 1);

      if (error) {
        console.error("Utakmice: greška kod dohvaćanja adresa:", error.message);
        break;
      }
      if (!data?.length) break;

      for (const r of data as { id: number; domacin: string; gost: string; rezultat: string | null }[]) {
        if (/^\s*\d{1,2}\s*:\s*\d{1,2}\s*$/.test(r.rezultat ?? "")) {
          svi.push({ id: r.id, domacin: r.domacin, gost: r.gost });
        }
      }
      if (data.length < KOMAD) break;
    }
  } catch (e) {
    console.error("Utakmice: dohvat adresa nije uspio:", e);
  }

  return svi;
}

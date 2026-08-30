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

/** Ključ igrač + minuta, za usporedbu s popisom autogolova. */
export function kljucPogotka(igrac: string, minuta: string): string {
  return `${igrac.trim().toLowerCase()}|${minuta.trim()}`;
}

/** Skup ključeva autogolova jedne utakmice. */
export function autogoliKljucevi(u: {
  autogolovi?: { igrac: string; minuta: string }[] | null;
}): Set<string> {
  return new Set((u.autogolovi ?? []).map((a) => kljucPogotka(a.igrac, a.minuta)));
}

/**
 * Strijelci razvrstani po klubu.
 *
 * U bazi nije zapisano kojem klubu strijelac pripada, ali znamo postave
 * obiju momčadi, pa se svaki strijelac pripisuje klubu u čijoj se postavi
 * nalazi. Kad postave nema, strijelac ostaje u skupini "nepoznato", da se
 * ne pripiše krivom klubu.
 *
 * Autogol je iznimka: strijelac je u postavi jedne momčadi, a pogodak
 * pripada drugoj. Takvi pogoci navode se u stupcu "autogolovi" i ovdje se
 * prebacuju na suparničku stranu, uz oznaku koju prikaz ispiše kao (ag).
 */
export function strijelciPoKlubu(u: Utakmica) {
  const doma = new Set((u.postava_domacin ?? []).map((i) => i.igrac));
  const vani = new Set((u.postava_gost ?? []).map((i) => i.igrac));
  const autogoli = autogoliKljucevi(u);

  type Strijelac = { igrac: string; minuta: string; autogol?: boolean };
  const domacin: Strijelac[] = [];
  const gost: Strijelac[] = [];
  const nepoznato: Strijelac[] = [];

  for (const s of u.strijelci ?? []) {
    const autogol = autogoli.has(kljucPogotka(s.igrac, s.minuta));
    const zapis: Strijelac = autogol ? { ...s, autogol: true } : s;

    // Kod autogola strane se zamjenjuju: pogodak ide protivniku strijelca.
    if (doma.has(s.igrac)) (autogol ? gost : domacin).push(zapis);
    else if (vani.has(s.igrac)) (autogol ? domacin : gost).push(zapis);
    else nepoznato.push(zapis);
  }

  return { domacin, gost, nepoznato };
}

/** Ispis jednog strijelca: "Ime 16'" ili "Ime 16' (ag)". */
export function zapisStrijelca(s: {
  igrac: string;
  minuta: string;
  autogol?: boolean;
}): string {
  return `${s.igrac} ${s.minuta}${s.autogol ? " (ag)" : ""}`;
}

/** Ima li utakmica zapisnik, dakle strijelce ili postave. */
export function imaZapisnik(u: Utakmica): boolean {
  return Boolean(
    u.strijelci?.length || u.postava_domacin?.length || u.postava_gost?.length
  );
}

/**
 * Utakmice s vlastitom adresom, samo polja potrebna za sitemap.
 *
 * Vraća i ODIGRANE i one koje se tek igraju. Nadolazeće su prije bile
 * izostavljene, uz obrazloženje da na njima nema što indeksirati, ali
 * one imaju termin, stadion i oba kluba, a upravo se to i traži prije
 * kola. Oznaka "odigrana" ide van da im sitemap može dati manju
 * važnost i češće osvježavanje.
 *
 * Dohvat ide u komadima, jer Supabase po zadanom vraća najviše tisuću
 * redaka, a utakmica kroz sve sezone ima i više.
 */
export async function dohvatiUtakmiceZaAdrese(): Promise<
  { id: number; domacin: string; gost: string; odigrana: boolean }[]
> {
  const KOMAD = 1000;
  const NAJVISE_KOMADA = 50;
  const svi: { id: number; domacin: string; gost: string; odigrana: boolean }[] = [];

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
        // Utakmica bez oba kluba nema smislenu adresu, pa se preskače.
        if (!r.domacin || !r.gost) continue;
        svi.push({
          id: r.id,
          domacin: r.domacin,
          gost: r.gost,
          odigrana: /^\s*\d{1,2}\s*:\s*\d{1,2}\s*$/.test(r.rezultat ?? ""),
        });
      }
      if (data.length < KOMAD) break;
    }
  } catch (e) {
    console.error("Utakmice: dohvat adresa nije uspio:", e);
  }

  return svi;
}

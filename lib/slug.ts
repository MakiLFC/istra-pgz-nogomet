// lib/slug.ts — pretvaranje imena kluba u dio adrese.
//
// Odvojeno od lib/klubovi.ts namjerno: ovdje nema veze na bazu, pa se
// smije uvesti i u komponente koje se izvršavaju u pregledniku, bez da
// se u njih povuče cijeli Supabase.

// Slova koja se ne razlažu u osnovno slovo i znak (đ je jedan znak, ne
// d s crticom), pa ih zamjenjujemo ručno.
const POSEBNA: Record<string, string> = { đ: "d", Đ: "d" };

/**
 * "NK Jadran-Poreč" -> "nk-jadran-porec"
 * "OŠK Omišalj"     -> "osk-omisalj"
 * "NK Naprijed (H)" -> "nk-naprijed-h"
 */
export function slugKluba(naziv: string): string {
  return naziv
    .replace(/[đĐ]/g, (z) => POSEBNA[z])
    // NFD razlaže č, ć, ž, š na osnovno slovo i dijakritički znak, koji
    // se onda ukloni.
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

/**
 * Ključ za usporedbu imena kluba između tablica, i za adresu kad ime
 * dolazi iz tablice poretka.
 *
 * Ondje se klub s kaznenim bodovima piše s dodatkom, npr.
 * "NK Crikvenica (-3)", dok u utakmicama stoji bez njega. Dodatak se
 * zato miče. Oznake poput "(H)" ili "(R)", koje su dio imena, ostaju
 * netaknute, jer se miče samo zagrada s predznakom i brojem.
 */
export function kljucKluba(naziv: string): string {
  return slugKluba(naziv.replace(/\s*\([+-]\s*\d+\)\s*$/, ""));
}

/**
 * Adresa utakmice: imena oba kluba i identifikator, npr.
 * "nk-naprijed-h-nk-kraljevica-1234".
 *
 * Identifikator je na kraju namjerno: imena su ondje zbog čitljivosti i
 * tražilica, ali jedini pouzdan ključ je id retka. Isti par klubova
 * igra dvaput po sezoni, a u trokružnim ligama i triput.
 */
export function slugUtakmice(u: {
  id: number;
  domacin: string;
  gost: string;
}): string {
  return `${slugKluba(u.domacin)}-${slugKluba(u.gost)}-${u.id}`;
}

/** Iz "nk-naprijed-h-nk-kraljevica-1234" vadi 1234, inače null. */
export function idIzSluga(slug: string): number | null {
  const m = slug.match(/-(\d+)$/);
  if (!m) return null;
  const n = parseInt(m[1], 10);
  return isNaN(n) ? null : n;
}

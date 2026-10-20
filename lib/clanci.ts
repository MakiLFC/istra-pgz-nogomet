// lib/clanci.ts — dohvat i pomoćne funkcije za članke.

import { supabase } from "@/lib/supabase";

export type Clanak = {
  id: number;
  slug: string;
  naslov: string;
  sazetak: string | null;
  tekst: string;
  natjecanje: string | null;
  /** Potpis autora ispod naslova. Stariji članci ga mogu nemati. */
  autor: string | null;
  slika_url: string | null;
  /** Opis fotografije za čitače ekrana i za slučaj da se ne učita. */
  slika_opis: string | null;
  /** Potpis ispod fotografije, npr. "Foto: Lokal-Arena". */
  slika_potpis: string | null;
  /**
   * Okomiti položaj kadra kad se fotografija reže na omjer okvira:
   * "vrh", "sredina", "dno" ili broj od 0 do 100. Prazno je sredina.
   * Vidi lib/slike.ts i sql/slika_kadar.sql.
   */
  slika_kadar: string | null;
  objavljen: boolean;
  objavljeno_u: string;
};

/**
 * Članak bez teksta, onoliko koliko treba kartici na popisu.
 *
 * Kartica prikazuje naslov, sažetak, datum, ligu i fotografiju; tekst
 * joj ne treba. Vidi `dohvatiClanke` niže.
 */
export type ClanakKartica = Omit<Clanak, "tekst">;

/**
 * Stupci za popise. TEKST NAMJERNO NIJE MEĐU NJIMA.
 *
 * Do 20.10.2026. su popisi išli preko `select("*")`, pa je svaki dohvat
 * povlačio i cijeli tekst svakog članka. Popis novosti nema ograničenje
 * broja, dakle povlačio je sve tekstove sezone da bi ispisao kartice
 * koje tekst ni ne prikazuju. Isto je radio i popis adresa pri gradnji.
 * To je bio glavni sumnjivac kad je Supabase 19.10.2026. javio da je
 * prijeđena kvota odlaznog prometa besplatnog plana (granica 5 GB).
 */
const STUPCI_KARTICE =
  "id, slug, naslov, sazetak, natjecanje, autor, slika_url, slika_opis, " +
  "slika_potpis, slika_kadar, objavljen, objavljeno_u";

/** Objavljeni članci, najnoviji prvi. `liga` filtrira po natjecanju. */
export async function dohvatiClanke(opcije?: {
  liga?: string;
  koliko?: number;
}): Promise<ClanakKartica[]> {
  let upit = supabase
    .from("clanci")
    .select(STUPCI_KARTICE)
    .eq("objavljen", true)
    .order("objavljeno_u", { ascending: false });

  if (opcije?.liga) upit = upit.eq("natjecanje", opcije.liga);
  if (opcije?.koliko) upit = upit.limit(opcije.koliko);

  const { data, error } = await upit;
  if (error) {
    console.error("Greška kod dohvaćanja članaka:", error);
    return [];
  }
  return (data ?? []) as unknown as ClanakKartica[];
}

/**
 * Samo slugovi objavljenih članaka, za popis adresa pri gradnji.
 *
 * Jedan stupac umjesto cijele tablice. Vidi `STUPCI_KARTICE` iznad.
 */
export async function slugoviClanaka(): Promise<string[]> {
  const { data, error } = await supabase
    .from("clanci")
    .select("slug")
    .eq("objavljen", true);

  if (error) {
    console.error("Greška kod dohvaćanja adresa članaka:", error);
    return [];
  }
  return (data ?? []).map((c) => c.slug).filter(Boolean);
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

/**
 * Koje kolo članak najavljuje, iz sluga ili iz naslova.
 *
 * Najave se rade po ustaljenom obrascu, pa broj kola stoji na dva mjesta:
 *   slug:   "najava-2-kola-3-nl-zapad-2627"
 *   naslov: "NAJAVA 2. KOLA: 3. NL ZAPAD"
 *
 * Vraća null kad se broj ne može pročitati, a to je namjerno sigurna
 * strana: bez broja kola poveznica na najavu se ne prikazuje, umjesto da
 * vodi na najavu nekog drugog kola.
 *
 * Pregledi kola ("pregled-1-kola-...") ovdje NE prolaze, jer traže riječ
 * "najava" na početku.
 */
export function koloNajave(clanak: { slug?: string | null; naslov?: string | null }): number | null {
  const izSluga = (clanak.slug ?? "").match(/^najava-(\d+)-kola\b/);
  if (izSluga) return Number(izSluga[1]);

  const izNaslova = (clanak.naslov ?? "").match(/najava\s+(\d+)\.\s*kola/i);
  if (izNaslova) return Number(izNaslova[1]);

  return null;
}

/**
 * Koje kolo članak pregledava, iz sluga ili iz naslova.
 *
 * Isti obrazac kao kod najava, samo s drugom riječju:
 *   slug:   "pregled-3-kola-3-nl-zapad-2627"
 *   naslov: "PREGLED 3. KOLA: 3. NL ZAPAD"
 *
 * Naslovi pregleda u pravilu NEMAJU riječ "pregled" (zovu se npr. "PET
 * GOSTUJUĆIH POBJEDA..."), pa se u praksi prepoznaju po slugu. Provjera
 * po naslovu stoji kao rezerva.
 *
 * Kao i kod najave, null znači "ne zna se", pa se poveznica ne prikazuje.
 */
export function koloPregleda(clanak: { slug?: string | null; naslov?: string | null }): number | null {
  const izSluga = (clanak.slug ?? "").match(/^pregled-(\d+)-kola\b/);
  if (izSluga) return Number(izSluga[1]);

  const izNaslova = (clanak.naslov ?? "").match(/pregled\s+(\d+)\.\s*kola/i);
  if (izNaslova) return Number(izNaslova[1]);

  return null;
}

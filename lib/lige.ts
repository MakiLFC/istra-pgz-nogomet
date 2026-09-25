export type Liga = {
  slug: string;
  naziv: string;
  kratica: string;
  /**
   * Koliko mjesta s vrha vodi u viši rang (zeleno u tablici).
   * Koliko mjesta s dna vodi u niži rang (crveno u tablici).
   *
   * Crveno je NAMJERNO samo jedno mjesto, i to ostaje tako.
   * Tko stvarno ispada rijetko se zna do kraja: ovisi o ispadanjima iz
   * viših rangova, o odustajanjima i o administrativnim odlukama, a ne
   * samo o poretku. Označiti dva ili tri mjesta značilo bi tvrditi
   * nešto što se ne zna, pa se označava samo posljednji, kao naznaka.
   */
  prvak: number;
  ispadanje: number;
};

// Redoslijed ovdje određuje redoslijed prikaza u navigaciji i na početnoj stranici
export const LIGE: Liga[] = [
  { slug: "3-nl-zapad", naziv: "3. NL Zapad", kratica: "3. NL", prvak: 1, ispadanje: 1 },
  { slug: "4-nl-ns-rijeka", naziv: "4. NL NS Rijeka", kratica: "4. NL", prvak: 1, ispadanje: 1 },
  { slug: "1-znl-pgz", naziv: "1. ŽNL PGŽ", kratica: "1. ŽNL", prvak: 1, ispadanje: 1 },
  { slug: "2-znl-pgz", naziv: "2. ŽNL PGŽ", kratica: "2. ŽNL", prvak: 1, ispadanje: 1 },
];

export function ligaPoSlugu(slug: string): Liga | undefined {
  return LIGE.find((l) => l.slug === slug);
}

// ---------------------------------------------------------------------
// ADRESE STRANICE LIGE
// ---------------------------------------------------------------------
// Svako kolo ima svoju adresu, a ne više parametar u upitu (?kolo=6).
// Stranica koja čita parametre iz adrese renderira se pri SVAKOM
// otvaranju, koliko god revalidate bio (vidi CLAUDE.md, Fluid Active
// CPU). S kolom u putanji svaka se stranica pripremi jednom i drži kao
// gotova, a osvježava se po revalidate, kao i ostale stranice.
//
//   /liga/3-nl-zapad                            tekuća sezona, zadnje odigrano kolo
//   /liga/3-nl-zapad/kolo/6                     tekuća sezona, 6. kolo
//   /liga/3-nl-zapad/sezona/2025-26             starija sezona, zadnje odigrano kolo
//   /liga/3-nl-zapad/sezona/2025-26/kolo/6      starija sezona, 6. kolo
//
// Kosa crta iz "2026/27" ne smije u putanju, pa se u adresi piše
// "2026-27". Stare adrese s ?kolo= i ?sezona= preusmjerava next.config.ts.

/** "2026/27" -> "2026-27" */
export function sezonaUAdresu(sezona: string): string {
  return sezona.replace("/", "-");
}

/** "2026-27" -> "2026/27"; sve što ne izgleda kao sezona -> null */
export function sezonaIzAdrese(dio: string): string | null {
  const m = decodeURIComponent(dio).match(/^(\d{4})[-/](\d{2})$/);
  return m ? `${m[1]}/${m[2]}` : null;
}

/** "6" -> 6; sve što nije pozitivan cijeli broj -> null */
export function koloIzAdrese(dio: string): number | null {
  return /^\d{1,3}$/.test(dio) && parseInt(dio, 10) > 0 ? parseInt(dio, 10) : null;
}

/**
 * Adresa stranice lige. Bez sezone vodi na tekuću sezonu; sezonu treba
 * zadati samo kad poveznica može voditi i na stariju (npr. sa stranice
 * utakmice iz prošle sezone).
 */
export function adresaLige(
  slug: string,
  { kolo, sezona }: { kolo?: number | null; sezona?: string | null } = {}
): string {
  const osnova = sezona ? `/liga/${slug}/sezona/${sezonaUAdresu(sezona)}` : `/liga/${slug}`;
  return kolo ? `${osnova}/kolo/${kolo}` : osnova;
}

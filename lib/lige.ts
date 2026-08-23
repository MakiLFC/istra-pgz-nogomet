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

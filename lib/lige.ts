export type Liga = {
  slug: string;
  naziv: string;
  kratica: string;
  /**
   * Koliko mjesta s vrha vodi u viši rang (zeleno u tablici).
   * Koliko mjesta s dna vodi u niži rang (crveno u tablici).
   *
   * PROVJERITI U PROPOZICIJAMA. Ovdje stoji ono što se vidjelo iz
   * prošle sezone: iz 3. NL Zapad ispala je Novalja i ušao je prvak
   * 4. NL. Broj mjesta zna se mijenjati iz sezone u sezonu, ovisno o
   * ispadanjima iz viših rangova, pa ako propozicije kažu drukčije,
   * promijeni brojke ovdje i tablica se sama preboji.
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

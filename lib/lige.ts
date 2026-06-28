export type Liga = {
  slug: string;
  naziv: string;
  kratica: string;
};

// Redoslijed ovdje određuje redoslijed prikaza u navigaciji i na početnoj stranici
export const LIGE: Liga[] = [
  { slug: "3-nl-zapad", naziv: "3. NL Zapad", kratica: "3. NL" },
  { slug: "4-nl-ns-rijeka", naziv: "4. NL NS Rijeka", kratica: "4. NL" },
  { slug: "1-znl-pgz", naziv: "1. ŽNL PGŽ", kratica: "1. ŽNL" },
  { slug: "2-znl-pgz", naziv: "2. ŽNL PGŽ", kratica: "2. ŽNL" },
];

export function ligaPoSlugu(slug: string): Liga | undefined {
  return LIGE.find((l) => l.slug === slug);
}

// lib/tablica.ts — forma za tablicu poretka.
//
// Tablica se NE računa, nego se čita onakva kakva je scrapeana: službena
// već uključuje kaznene bodove (vidi CLAUDE.md). Forma je iznimka, jer u
// bazi stoji samo zadnje stanje tablice, pa se niz zadnjih rezultata iz
// nje ne može izvesti. Zato se računa iz utakmica.

import { golovi } from "@/lib/kolo";
import { kljucKluba } from "@/lib/slug";

/** P = pobjeda, N = neriješeno, I = izgubljeno. */
export type Ishod = "P" | "N" | "I";

export type UtakmicaZaFormu = {
  kolo: number | null;
  domacin: string;
  gost: string;
  rezultat: string | null;
};

/**
 * Zadnjih nekoliko ishoda za svaki klub, najnoviji prvi.
 *
 * Ključ je svedeno ime kluba, jer se u tablici poretka klub s kaznenim
 * bodovima piše kao "NK Crikvenica (-3)", a u utakmicama bez toga.
 */
export function formaPoKlubu(
  utakmice: UtakmicaZaFormu[],
  koliko = 5
): Map<string, Ishod[]> {
  const odigrane = utakmice
    .filter((u) => golovi(u.rezultat))
    .sort((a, b) => (b.kolo ?? 0) - (a.kolo ?? 0));

  const mapa = new Map<string, Ishod[]>();

  const dodaj = (klub: string, ishod: Ishod) => {
    const kljuc = kljucKluba(klub);
    if (!kljuc) return;
    const dosad = mapa.get(kljuc) ?? [];
    if (dosad.length >= koliko) return;
    dosad.push(ishod);
    mapa.set(kljuc, dosad);
  };

  for (const u of odigrane) {
    const [dom, gos] = golovi(u.rezultat)!;
    if (dom > gos) {
      dodaj(u.domacin, "P");
      dodaj(u.gost, "I");
    } else if (dom < gos) {
      dodaj(u.domacin, "I");
      dodaj(u.gost, "P");
    } else {
      dodaj(u.domacin, "N");
      dodaj(u.gost, "N");
    }
  }

  return mapa;
}

// lib/slike.ts — kadriranje fotografija uz članke.
//
// Fotografije stižu s mobitela, u svakom omjeru, najčešće uspravne. Da
// stranica ne ovisi o tome, slika se uvijek prikazuje u okviru stalnog
// omjera (3:2 u članku, 16:9 na kartici), a višak se odreže. Time nijedna
// fotografija ne može zauzeti pola ekrana ni razbiti red kartica.
//
// Rezanje ide iz sredine, što je dobro u većini slučajeva. Kad nije, na
// članku se okomiti položaj kadra pomiče stupcem `slika_kadar`, bez
// diranja same datoteke. Vrijednosti su opisne ("vrh", "sredina", "dno")
// ili broj od 0 do 100, gdje je 0 vrh slike, a 100 dno.

const OPISNE: Record<string, number> = {
  vrh: 0,
  gore: 0,
  sredina: 50,
  centar: 50,
  dno: 100,
  dolje: 100,
};

/**
 * Vrijednost za CSS svojstvo object-position, npr. "50% 60%".
 *
 * Vodoravno je uvijek sredina: fotografije se po širini režu tek
 * neznatno, jer su okviri širi nego viši. Bitan je okomiti položaj.
 */
export function kadarSlike(kadar: string | null | undefined): string {
  return `50% ${postotakKadra(kadar)}%`;
}

/** Okomiti položaj kadra u postotku. Nepoznat ili prazan unos je sredina. */
export function postotakKadra(kadar: string | null | undefined): number {
  if (kadar === null || kadar === undefined) return 50;

  const ocisceno = kadar.trim().toLowerCase();
  if (!ocisceno) return 50;

  if (ocisceno in OPISNE) return OPISNE[ocisceno];

  // Dopušta se i "60" i "60%", jer se lako zaboravi znak.
  const broj = Number.parseFloat(ocisceno.replace("%", "").replace(",", "."));
  if (!Number.isFinite(broj)) return 50;

  return Math.min(100, Math.max(0, broj));
}

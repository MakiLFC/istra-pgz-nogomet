// lib/hrvatski.ts — sitni jezični pomoćnici.

/**
 * Hrvatska množina uz broj. Predaju se tri oblika, onim redom kojim se
 * javljaju uz 1, uz 2 i uz 5:
 *
 *   mnozina(1, ["utakmica", "utakmice", "utakmica"])  -> "utakmica"
 *   mnozina(3, ...)                                    -> "utakmice"
 *   mnozina(8, ...)                                    -> "utakmica"
 *
 * Pravilo ide po zadnjoj znamenki, uz iznimku za 11 do 14 ("11 utakmica",
 * ne "11 utakmica" po zadnjoj jedinici). Radi i za veće brojeve: 21 se
 * ponaša kao 1, 22 kao 2, 25 kao 5.
 */
export function mnozina(
  broj: number,
  [jedan, dva, pet]: [string, string, string]
): string {
  const n = Math.abs(Math.trunc(broj));
  if (n % 100 >= 11 && n % 100 <= 14) return pet;
  const zadnja = n % 10;
  if (zadnja === 1) return jedan;
  if (zadnja >= 2 && zadnja <= 4) return dva;
  return pet;
}

/** Broj i uz njega ispravan oblik riječi: "8 utakmica". */
export function sBrojem(
  broj: number,
  oblici: [string, string, string]
): string {
  return `${broj} ${mnozina(broj, oblici)}`;
}

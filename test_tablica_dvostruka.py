"""
test_tablica_dvostruka.py

Provjerava da se s HNS-ove stranice natjecanja čita samo UKUPNA
ljestvica (parsiraj_tablicu_lige u scraper_supabase.py).

Zašto ovo postoji: od 02.11.2026. HNS u istom bloku ljestvice iza ukupne
daje i ljestvicu domaćih utakmica. Scraper je čitao sve retke, pa je u
bazu upisao 32 kluba za 3. NL Zapad i 12 za 2. ŽNL PGŽ, a stranica lige
prikazivala je tablicu dvaput: nakon 6. mjesta opet je išlo 1.

Pravilo koje se ovdje čuva: čita se prva ljestvica, do prvog kluba koji
se ponovi.

POKRETANJE:  python test_tablica_dvostruka.py
Ništa ne dohvaća s interneta i ništa ne piše u bazu.
"""

import os
import sys
import types

# Scraper pri uvozu otvara vezu prema Supabaseu; za ovu provjeru ne treba.
for ime, sadrzaj in {
    "supabase": {"create_client": lambda *a, **k: None},
    "dotenv": {"load_dotenv": lambda *a, **k: None},
}.items():
    modul = types.ModuleType(ime)
    for kljuc, vrijednost in sadrzaj.items():
        setattr(modul, kljuc, vrijednost)
    sys.modules.setdefault(ime, modul)

os.environ.setdefault("SUPABASE_URL", "test")
os.environ.setdefault("SUPABASE_SERVICE_KEY", "test")

from bs4 import BeautifulSoup  # noqa: E402
import scraper_supabase  # noqa: E402


def redak(mjesto, klub, odigrano, bodovi):
    return (f'<li><div class="position">{mjesto}.</div>'
            f'<a href="/klubovi/{klub}">{klub}</a>'
            f'<div class="played">{odigrano}</div>'
            f'<div class="points">{bodovi}</div></li>')


# Stanje 2. ŽNL PGŽ nakon 8. kola: ukupna ljestvica, pa domaća.
UKUPNA = [("NK Gomirje", 8, 18), ("NK Goranka", 8, 16), ("NK Mrkopalj", 8, 15),
          ("NK Željezničar (M)", 8, 11), ("NK Polet (Sk)", 8, 10),
          ("NK Snježnik", 8, 0)]
DOMACA = [("NK Gomirje", 4, 12), ("NK Goranka", 4, 9), ("NK Mrkopalj", 4, 9),
          ("NK Željezničar (M)", 4, 4), ("NK Polet (Sk)", 4, 4),
          ("NK Snježnik", 4, 0)]


def stranica(*ljestvice):
    retci = "".join(redak(i + 1, k, o, b)
                    for lj in ljestvice for i, (k, o, b) in enumerate(lj))
    return BeautifulSoup(
        f'<div class="competition_table"><ul>{retci}</ul></div>', "html.parser")


def provjeri(uvjet, opis):
    print(("   OK  " if uvjet else "   KRIVO  ") + opis)
    return uvjet


def main():
    sve = True

    print("1. dvije ljestvice u bloku: čita se samo ukupna")
    tablica = scraper_supabase.parsiraj_tablicu_lige(stranica(UKUPNA, DOMACA))
    sve &= provjeri(len(tablica) == 6, f"šest klubova, dobiveno {len(tablica)}")
    sve &= provjeri(all(r["odigrano"] == "8" for r in tablica),
                    "svi retci su iz ukupne ljestvice (8 odigranih)")
    sve &= provjeri(tablica[-1]["klub"] == "NK Snježnik"
                    and tablica[-1]["pozicija"] == "6.",
                    "zadnji je 6. Snježnik")

    print("2. samo jedna ljestvica, kao prije: ništa se ne mijenja")
    tablica = scraper_supabase.parsiraj_tablicu_lige(stranica(UKUPNA))
    sve &= provjeri(len(tablica) == 6, f"šest klubova, dobiveno {len(tablica)}")

    print("3. nema bloka ljestvice: prazan popis")
    tablica = scraper_supabase.parsiraj_tablicu_lige(
        BeautifulSoup("<html></html>", "html.parser"))
    sve &= provjeri(tablica == [], "prazno")

    if not sve:
        print("\nPALO: ljestvica se ne čita kako treba.")
        return 1
    print("\nPROLAZI: čita se samo ukupna ljestvica.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

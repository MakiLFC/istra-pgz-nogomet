"""
test_kraj_rasporeda.py

Provjerava da parsiranje rasporeda STANE na naslovu sekcije koja dolazi
poslije njega ("Ljestvica", "Statistika", "Klubovi u natjecanju").

Zašto ovo postoji: u sekciji "Klubovi u natjecanju" svaka se utakmica
pojavljuje po drugi put, ali ondje nema naslova "X. kolo". Bez prekida
se tim ponovljenim utakmicama pripisivalo zadnje viđeno kolo, ključ za
upsert (kolo, domaćin, gost) bio je drugačiji i one su se upisivale kao
nove utakmice. U kolovozu 2026. tako je 15. kolo 3. NL Zapad imalo 120
redaka umjesto 8, a traka "Sljedeće kolo" na naslovnici pokazivala je
16 utakmica umjesto 8.

POKRETANJE:  python test_kraj_rasporeda.py
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

import requests  # noqa: E402


def _utakmica(domacin, gost, datum, sat):
    return f"""
      <li class="match"><div class="row">
        <a href="/klubovi/1">{domacin}</a>
        <a href="/utakmice/9">- : -</a>
        <a href="/klubovi/2">{gost}</a>
        <span>{datum} {sat}</span>
        <span>Neki stadion</span>
      </div></li>"""


# Pojednostavljena stranica natjecanja: raspored s dva kola, pa ljestvica,
# pa popis klubova u kojem se dvije utakmice ponavljaju.
STRANICA = f"""<html><body>
<h2>Raspored natjecanja</h2>
<div><span>1. kolo</span>
  {_utakmica("NK A", "NK B", "29.08.2026.", "17:30")}
  {_utakmica("NK C", "NK D", "29.08.2026.", "17:30")}
</div>
<div><span>2. kolo</span>
  {_utakmica("NK B", "NK C", "05.09.2026.", "17:30")}
  {_utakmica("NK D", "NK A", "05.09.2026.", "17:30")}
</div>
<h2>Ljestvica</h2>
<div><span>ovdje je tablica poretka</span></div>
<h2>Klubovi u natjecanju</h2>
<div><span>NK A</span>
  {_utakmica("NK A", "NK B", "29.08.2026.", "17:30")}
  {_utakmica("NK D", "NK A", "05.09.2026.", "17:30")}
</div>
</body></html>"""


class _Odgovor:
    text = STRANICA

    def raise_for_status(self):
        pass


def main():
    requests.get = lambda *a, **k: _Odgovor()

    import scraper_supabase

    utakmice = scraper_supabase.dohvati_popis_utakmica("http://test")
    dobiveno = [(u["kolo"], u["domacin"], u["gost"]) for u in utakmice]
    ocekivano = [
        (1, "NK A", "NK B"),
        (1, "NK C", "NK D"),
        (2, "NK B", "NK C"),
        (2, "NK D", "NK A"),
    ]

    for kolo, domacin, gost in dobiveno:
        print(f"  {kolo}. kolo: {domacin} - {gost}")

    if dobiveno != ocekivano:
        print("\nPALO: raspored nije stao gdje treba.")
        print(f"  očekivano {len(ocekivano)} utakmica, dobiveno {len(dobiveno)}")
        return 1

    print("\nPROLAZI: raspored je stao prije sekcija ispod njega.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

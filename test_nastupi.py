"""
test_nastupi.py

Provjerava čitanje NASTUPA i MINUTA iz retka stranice natjecanja.

Zapis tog podatka na HNS stranici nije bio poznat kad je parsiranje
pisano, pa se čitaju svi brojevi iz bloka "apps_minutes", redom: prvi je
broj nastupa, drugi minute. Ovdje se provjeravaju oba viđena oblika, u
jednom i u dva elementa, te ponašanje kad podatka nema.

POKRETANJE:  python test_nastupi.py
Ništa ne dohvaća s interneta i ništa ne piše u bazu.
"""

import os
import sys
import types

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

from scraper_supabase import (  # noqa: E402
    parsiraj_rang_nastupa,
    parsiraj_sve_igrace,
    slozi_listu_nastupa,
)


def _sastav(ime, apps_html):
    return f"""
    <li class="row">
      <div class="shirtNumber">7</div>
      <div class="playerName"><h3>{ime}</h3> Igrač</div>
      {apps_html}
      <div class="goals">3</div>
      <div class="cards">2 / 0</div>
    </li>"""


def stranica(sastavi, rang=""):
    return f"""<html><body>
      <a href="/klubovi/1">NK Naprijed (H)</a>
      {"".join(sastavi)}
      {rang}
    </body></html>"""


def provjeri(naslov, uvjet, dodatno=""):
    print(f"  {'OK  ' if uvjet else 'PALO'}  {naslov}{dodatno}")
    return uvjet


def main():
    uspjeh = True

    # 1. Nastupi i minute u jednom elementu: "26 / 2340"
    soup = BeautifulSoup(
        stranica([_sastav("Marko Marić", '<div class="apps_minutes">26 / 2340</div>')]),
        "html.parser",
    )
    igraci = parsiraj_sve_igrace(soup)
    print("1. zapis u jednom elementu")
    uspjeh &= provjeri("nastupi = 26", igraci[0]["nastupi"] == 26,
                       f"  (dobiveno {igraci[0]['nastupi']})")
    uspjeh &= provjeri("minute = 2340", igraci[0]["minute"] == 2340,
                       f"  (dobiveno {igraci[0]['minute']})")

    # 2. Nastupi i minute u dva elementa
    soup = BeautifulSoup(
        stranica([
            _sastav(
                "Ivan Ivić",
                '<div class="apps_minutes"><div>18</div><div>1450</div></div>',
            )
        ]),
        "html.parser",
    )
    igraci = parsiraj_sve_igrace(soup)
    print("2. zapis u dva elementa")
    uspjeh &= provjeri("nastupi = 18", igraci[0]["nastupi"] == 18,
                       f"  (dobiveno {igraci[0]['nastupi']})")
    uspjeh &= provjeri("minute = 1450", igraci[0]["minute"] == 1450,
                       f"  (dobiveno {igraci[0]['minute']})")

    # 3. Podatka nema: ostaje None, ne nula
    soup = BeautifulSoup(stranica([_sastav("Pero Perić", "")]), "html.parser")
    igraci = parsiraj_sve_igrace(soup)
    print("3. podatka nema")
    uspjeh &= provjeri("nastupi ostaju prazni", igraci[0]["nastupi"] is None)
    uspjeh &= provjeri("minute ostaju prazne", igraci[0]["minute"] is None)
    uspjeh &= provjeri("lista je prazna kad nema ni rezerve",
                       slozi_listu_nastupa(igraci, []) == [])

    # 4. Rezervni izvor: službena rang-lista, redak bez shirtNumber
    rang = """
    <li class="row">
      <div class="position">1</div>
      <div class="playerName"><h3>Luka Lukić</h3> NK Buje</div>
      <div class="apps_minutes">30 / 2700</div>
    </li>"""
    soup = BeautifulSoup(stranica([_sastav("Pero Perić", "")], rang), "html.parser")
    rezerva = parsiraj_rang_nastupa(soup)
    print("4. rezervni izvor")
    uspjeh &= provjeri("pronađen jedan redak", len(rezerva) == 1,
                       f"  (dobiveno {len(rezerva)})")
    lista = slozi_listu_nastupa(parsiraj_sve_igrace(soup), rezerva)
    uspjeh &= provjeri("lista se složila iz rezerve",
                       len(lista) == 1 and lista[0]["minute"] == "2700")

    # 5. Redoslijed: najviše minuta prvo
    soup = BeautifulSoup(
        stranica([
            _sastav("Manje Minuta", '<div class="apps_minutes">5 / 300</div>'),
            _sastav("Više Minuta", '<div class="apps_minutes">30 / 2700</div>'),
        ]),
        "html.parser",
    )
    lista = slozi_listu_nastupa(parsiraj_sve_igrace(soup), [])
    print("5. redoslijed")
    uspjeh &= provjeri("prvi je igrač s najviše minuta",
                       lista[0]["igrac"] == "Više Minuta",
                       f"  (prvi je {lista[0]['igrac']})")

    print("\nPROLAZI" if uspjeh else "\nPALO")
    return 0 if uspjeh else 1


if __name__ == "__main__":
    sys.exit(main())

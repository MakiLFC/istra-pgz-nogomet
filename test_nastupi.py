"""
test_nastupi.py

Provjerava čitanje NASTUPA i MINUTA iz retka stranice natjecanja.

Oblici potvrđeni na stranici 3. NL Zapad 2025/26:
  - u sastavu kluba dva odvojena bloka, "apps" i "minutes"
  - u kratkoj rang-listi jedan blok "apps_minutes" sa zapisom "30 / 2.700"

PAZI NA TOČKU: minute se pišu s razdjelnikom tisućica, "2.700" znači
2700. Bez micanja točke ispalo bi da je igrač odigrao dvije minute.

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
    """Stranica lige, složena kao prava.

    Sastavi stoje unutar bloka svog kluba, u sekciji "Klubovi u
    natjecanju". Klub se od 05.09.2026. čita upravo iz tog bloka, preko
    data-ida, a ne kao najbliža prethodna poveznica (vidi
    test_klub_igraca.py). Bez tog okvira igrači bi ostali bez kluba, a
    lista nastupa uzima samo igrače koji ga imaju.
    """
    return f"""<html><body>
      <div class="block w1280 clubs_in_competition">
        <div class="tabs"><ul>
          <li class="active" data-id="1578">NK Naprijed (H)</li>
        </ul></div>
        <div class="block w1280 club_competition_details" data-id="1578">
          <ul>{"".join(sastavi)}</ul>
        </div>
      </div>
      {rang}
    </body></html>"""


def provjeri(naslov, uvjet, dodatno=""):
    print(f"  {'OK  ' if uvjet else 'PALO'}  {naslov}{dodatno}")
    return uvjet


def main():
    uspjeh = True

    # 1. Sastav kluba: odvojeni blokovi "apps" i "minutes", s točkom
    soup = BeautifulSoup(
        stranica([
            _sastav(
                "Marko Marić",
                '<div class="apps">30</div><div class="minutes">2.700</div>',
            )
        ]),
        "html.parser",
    )
    igraci = parsiraj_sve_igrace(soup)
    print("1. sastav kluba, odvojeni blokovi, minute s točkom")
    uspjeh &= provjeri("nastupi = 30", igraci[0]["nastupi"] == 30,
                       f"  (dobiveno {igraci[0]['nastupi']})")
    uspjeh &= provjeri("minute = 2700, ne 2", igraci[0]["minute"] == 2700,
                       f"  (dobiveno {igraci[0]['minute']})")

    # 2. Jedan blok "apps_minutes", zapis "26 / 2.340"
    soup = BeautifulSoup(
        stranica([_sastav("Ivan Ivić", '<div class="apps_minutes">26 / 2.340</div>')]),
        "html.parser",
    )
    igraci = parsiraj_sve_igrace(soup)
    print("2. jedan blok, zapis \"26 / 2.340\"")
    uspjeh &= provjeri("nastupi = 26", igraci[0]["nastupi"] == 26,
                       f"  (dobiveno {igraci[0]['nastupi']})")
    uspjeh &= provjeri("minute = 2340", igraci[0]["minute"] == 2340,
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
      <div class="apps_minutes">30 / 2.700</div>
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
            _sastav("Manje Minuta",
                    '<div class="apps">5</div><div class="minutes">300</div>'),
            _sastav("Više Minuta",
                    '<div class="apps">30</div><div class="minutes">2.700</div>'),
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

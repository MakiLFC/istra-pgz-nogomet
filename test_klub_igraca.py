"""
test_klub_igraca.py

Provjerava da igrač iz sastava dobije SVOJ klub, a ne protivnika.

Zašto ovo postoji: do 05.09.2026. klub se uzimao kao najbliža prethodna
poveznica kluba u dokumentu. U sekciji "Klubovi u natjecanju" svaki klub
ima svoj blok u kojem prvo stoji popis NJEGOVIH utakmica, pa tek onda
sastav, tako da je najbliža poveznica zapravo protivnik iz posljednje
utakmice. Karlu Josipoviću je zato na listi strijelaca pisalo da igra za
Halubjan, jer je Lokomotivi posljednja utakmica Lokomotiva - Halubjan.
Ližnjanovim igračima je iz istog razloga pisalo Otočac.

HTML je složen po stvarnoj stranici Semafora (provjereno alatom
dijagnostika_klub_igraca.py 05.09.2026.): kartice <li data-id> iznad,
blokovi <div class="club_competition_details" data-id> ispod.

POKRETANJE:  python test_klub_igraca.py
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
    imena_klubova_po_idu,
    parsiraj_sve_igrace,
)


def _redak_utakmice(id_doma, ime_doma, id_gost, ime_gost):
    return f"""
      <li class="row visible" data-match="1" data-round="1">
        <div class="date">29.08.2026. 17:30</div>
        <div class="club1" data-id="{id_doma}"><a href="/klubovi/{id_doma}/">{ime_doma}</a></div>
        <div class="club2" data-id="{id_gost}"><a href="/klubovi/{id_gost}/">{ime_gost}</a></div>
      </li>"""


def _igrac(ime):
    return f"""
      <li class="row">
        <div class="shirtNumber">9</div>
        <div class="playerName"><h3>{ime}</h3> Igrač</div>
        <div class="goals">2</div>
        <div class="cards">1 / 0</div>
      </li>"""


def _blok(id_kluba, utakmice, igraci):
    return f"""
    <div class="block w1280 club_competition_details hidden" data-id="{id_kluba}">
      <div class="matchlist"><ul>{"".join(utakmice)}</ul></div>
      <div class="playerslist"><ul>{"".join(igraci)}</ul></div>
    </div>"""


# Lokomotiva (1570) i njezina posljednja utakmica je protiv Halubjana (1556),
# pa je Halubjan zadnja poveznica kluba prije sastava. Upravo je to rušilo
# staro pravilo.
STRANICA = f"""<html><body>
  <div class="block w1280 competition_table">
    <a href="/klubovi/1570/">NK Lokomotiva (R)</a>
    <a href="/klubovi/1556/">NK Halubjan</a>
  </div>
  <div class="block w1280 clubs_in_competition">
    <h2>Klubovi u natjecanju</h2>
    <div class="tabs"><ul>
      <li class="active" data-id="1570">NK Lokomotiva (R)</li>
      <li data-id="1556">NK Halubjan</li>
    </ul></div>
    {_blok("1570",
           [_redak_utakmice("2334", "NK Buje", "1570", "NK Lokomotiva (R)"),
            _redak_utakmice("1570", "NK Lokomotiva (R)", "1556", "NK Halubjan")],
           [_igrac("Karlo Josipović"), _igrac("Ivor Weitzer")])}
    {_blok("1556",
           [_redak_utakmice("1556", "NK Halubjan", "1507", "NK Banjole")],
           [_igrac("Marko Tadić")])}
  </div>
</body></html>"""


def provjeri(uvjet, opis):
    print(f"  {'OK  ' if uvjet else 'PALO'}  {opis}")
    return uvjet


def main():
    sve = True
    soup = BeautifulSoup(STRANICA, "html.parser")

    print("1. kartice povezuju data-id i ime kluba")
    imena = imena_klubova_po_idu(soup)
    sve &= provjeri(imena == {"1570": "NK Lokomotiva (R)", "1556": "NK Halubjan"},
                    f"pročitana su oba kluba ({imena})")

    print("2. igrač dobiva svoj klub, ne protivnika iz zadnje utakmice")
    igraci = {i["igrac"]: i["klub"] for i in parsiraj_sve_igrace(soup)}
    for ime in ("Karlo Josipović", "Ivor Weitzer"):
        sve &= provjeri(igraci.get(ime) == "NK Lokomotiva (R)",
                        f"{ime}: {igraci.get(ime)!r}")
    sve &= provjeri(igraci.get("Marko Tadić") == "NK Halubjan",
                    f"Marko Tadić: {igraci.get('Marko Tadić')!r}")

    print("3. bez kartica klub se čita iz retka utakmice istog bloka")
    bez_kartica = STRANICA.replace('<li class="active" data-id="1570">NK Lokomotiva (R)</li>', "") \
                          .replace('<li data-id="1556">NK Halubjan</li>', "")
    igraci2 = {i["igrac"]: i["klub"]
               for i in parsiraj_sve_igrace(BeautifulSoup(bez_kartica, "html.parser"))}
    sve &= provjeri(igraci2.get("Karlo Josipović") == "NK Lokomotiva (R)",
                    f"Karlo Josipović: {igraci2.get('Karlo Josipović')!r}")

    print("4. izvan sekcije klubova radije prazno nego krivo")
    samotni = BeautifulSoup(
        f'<html><body><a href="/klubovi/1556/">NK Halubjan</a>{_igrac("Netko Nepoznat")}</body></html>',
        "html.parser",
    )
    igraci3 = parsiraj_sve_igrace(samotni)
    sve &= provjeri(igraci3 and igraci3[0]["klub"] is None,
                    f"klub je prazan ({igraci3[0]['klub'] if igraci3 else 'nema igrača'})")

    print()
    print("PROLAZI" if sve else "NE PROLAZI")
    return 0 if sve else 1


if __name__ == "__main__":
    sys.exit(main())

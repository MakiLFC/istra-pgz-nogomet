#!/usr/bin/env python3
"""
Ispis HTML-a događaja iz jednog zapisnika na HNS Semaforu.

ČEMU SLUŽI
    Kad se pojavi događaj koji scraper ne zna pročitati, najčešće autogol,
    ne pogađa se kako ga HNS označava, nego se pogleda u stvarni HTML.
    Ovaj alat ispiše samo taj dio stranice, dovoljno kratko da se ispis
    može prekopirati u poruku.

    Ništa ne upisuje u bazu i ne treba mu nijedan ključ. Samo čita.

KAKO SE POKREĆE
    python alati/zapisnik_html.py ADRESA_ZAPISNIKA

    Na primjer:
    python alati/zapisnik_html.py https://semafor.hns.family/utakmice/114647309/nk-jadran-porec-nk-nehaj-1-3/

    Ako želiš ispis spremiti u datoteku pa je poslati:
    python alati/zapisnik_html.py ADRESA > zapisnik.txt

ŠTO ISPISUJE
    1. traku strijelaca s vrha stranice (div.events_main), svaki događaj
       s klasama, naslovom ikone, imenom i minutom, pa i sirovi HTML
    2. događaje uz igrače u postavama (div.matchEvents), isto tako
"""

import sys
import re
import requests
from bs4 import BeautifulSoup

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/120.0 Safari/537.36"
}

CRTA = "=" * 70


def skrati(tekst, najvise=400):
    tekst = re.sub(r"\s+", " ", tekst).strip()
    return tekst if len(tekst) <= najvise else tekst[:najvise] + " ..."


def opisi_dogadjaj(li, redni):
    """Jedan događaj: klase, naslov ikone, tekst i sirovi HTML.

    Tip događaja zna stajati i na samom <li> i na nekom elementu unutar
    njega (npr. div.event goal), pa se ispisuju klase SVIH elemenata u
    tom bloku. Upravo se tu očekuje oznaka autogola.
    """
    klase = li.get("class") or []
    unutarnje = []
    for element in li.find_all(attrs={"class": True}):
        unutarnje.append(f'{element.name}.{".".join(element.get("class"))}')

    ikone = []
    for ikona in li.find_all(attrs={"title": True}):
        ikone.append(f'{ikona.name}.{".".join(ikona.get("class") or [])} '
                     f'title="{ikona.get("title")}"')

    ime = li.find("div", class_="playerName")
    tekst = li.get_text(separator=" ", strip=True)
    minuta = re.search(r"\d{1,3}(?:\+\d{1,2})?'", tekst)

    print(f"  [{redni}] klase <li>: {klase}")
    print(f"       klase unutar: {unutarnje if unutarnje else '(nema)'}")
    if ikone:
        for i in ikone:
            print(f"       ikona: {i}")
    else:
        print("       ikona: (nema elementa s naslovom)")
    print(f"       ime: {ime.get_text(strip=True) if ime else '(nema div.playerName)'}")
    print(f"       minuta: {minuta.group(0) if minuta else '(nije pronađena)'}")
    print(f"       tekst: {skrati(tekst, 120)}")
    print(f"       HTML: {skrati(str(li))}")
    print()


def main():
    if len(sys.argv) != 2:
        print(__doc__)
        raise SystemExit("Nedostaje adresa zapisnika.")

    adresa = sys.argv[1]
    print(CRTA)
    print("ZAPISNIK:", adresa)
    print(CRTA)

    odgovor = requests.get(adresa, headers=HEADERS, timeout=30)
    odgovor.raise_for_status()
    # odgovor.content, ne .text: bez toga requests kod stranica bez
    # navedenog kodiranja pretpostavi ISO-8859-1 i č, ć, š postanu smeće.
    soup = BeautifulSoup(odgovor.content, "html.parser")

    naslov = soup.find("h1")
    if naslov:
        print("Naslov stranice:", skrati(naslov.get_text(strip=True), 120))
        print()

    # --- 1. traka strijelaca na vrhu ---
    print(CRTA)
    print("1. TRAKA DOGAĐAJA NA VRHU (div.events_main)")
    print(CRTA)
    events_main = soup.find("div", class_="events_main")
    if not events_main:
        print("  NIJE PRONAĐENA. Znači da se promijenila struktura stranice.")
    else:
        print(f"  klase samog spremnika: {events_main.get('class')}")
        stavke = events_main.find_all("li")
        print(f"  broj stavki: {len(stavke)}")
        print()
        for redni, li in enumerate(stavke, 1):
            opisi_dogadjaj(li, redni)

    # --- 2. događaji uz igrače u postavama ---
    print(CRTA)
    print("2. DOGAĐAJI UZ IGRAČE U POSTAVAMA (div.matchEvents)")
    print(CRTA)
    blokovi = soup.find_all("div", class_="matchEvents")
    print(f"  broj igrača s događajem: {len(blokovi)}")
    print()
    for blok in blokovi:
        roditelj = blok.find_parent("li")
        ime = "(nepoznat igrač)"
        if roditelj:
            h3 = roditelj.find("h3")
            if h3:
                ime = h3.get_text(strip=True)
        print(f"  IGRAČ: {ime}")
        for redni, li in enumerate(blok.find_all("li"), 1):
            opisi_dogadjaj(li, redni)

    print(CRTA)
    print("KRAJ ISPISA")
    print(CRTA)


if __name__ == "__main__":
    main()

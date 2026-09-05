"""
dijagnostika_klub_igraca.py

Provjerava odakle scraperu dolazi KLUB igrača u rang-listama strijelaca i
kartona, i je li taj klub točan.

Zašto postoji: 05.09.2026. Andrej je javio da su ispod pojedinih igrača
ispisani krivi klubovi (Karlo Josipović igra za Lokomotivu, a pisalo je
Halubjan). Klub se u sastavima ne nalazi u samom retku igrača, nego se
uzima kao najbliža PRETHODNA poveznica kluba u dokumentu, pa ovaj ispis
pokazuje što se tim pravilom stvarno pogodi.

POKRETANJE (obično kroz posao "Dijagnostika HNS" na GitHubu, jer radni
prostor u kojem Claude radi nema pristup internetu):

    python dijagnostika_klub_igraca.py --url ADRESA_LIGE [--igrac Prezime]

Ništa ne sprema u bazu, samo ispisuje.
"""

import argparse

import requests
from bs4 import BeautifulSoup

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/120.0 Safari/537.36"
}


def klub_po_sadasnjem_pravilu(li):
    """Isto pravilo koje scraper koristi u parsiraj_sve_igrace."""
    for a in li.find_all_previous("a", href=lambda h: h and "/klubovi/" in h):
        if a.find_parent("div", class_="competition_table"):
            continue
        return a
    return None


def opis_veze(a):
    """Kratki opis poveznice kluba: tekst, adresa i je li u retku utakmice."""
    if a is None:
        return "nema"
    redak_utakmice = a.find_parent(
        lambda t: t.name in ("li", "div")
        and len(t.find_all("a", href=lambda h: h and "/klubovi/" in h)) == 2
    )
    gdje = "u retku utakmice" if redak_utakmice else "samostalna (vjerojatno naslov kluba)"
    return f"{a.get_text(strip=True)!r} [{gdje}]"


def main():
    p = argparse.ArgumentParser(description="Odakle dolazi klub igrača.")
    p.add_argument("--url", required=True, help="adresa stranice lige")
    p.add_argument("--igrac", default="", help="prezime igrača za detaljni ispis")
    p.add_argument("--koliko", type=int, default=25,
                   help="koliko redaka sastava ispisati (zadano 25)")
    args = p.parse_args()

    print(f"Dohvaćam: {args.url}")
    html = requests.get(args.url, headers=HEADERS, timeout=30).text
    soup = BeautifulSoup(html, "html.parser")

    redci = [li for li in soup.find_all("li", class_="row")
             if li.find("div", class_="shirtNumber")
             and li.find("div", class_="playerName")]
    print(f"Redaka sastava: {len(redci)}\n")

    print("=" * 70)
    print(f"1) PRVIH {args.koliko} IGRAČA I KLUB PO SADAŠNJEM PRAVILU")
    print("=" * 70)
    for li in redci[:args.koliko]:
        ime = li.find("div", class_="playerName").find("h3").get_text(strip=True)
        print(f"  {ime:<28} -> {opis_veze(klub_po_sadasnjem_pravilu(li))}")

    if args.igrac:
        print()
        print("=" * 70)
        print(f"2) DETALJNO ZA IGRAČA KOJI SADRŽI {args.igrac!r}")
        print("=" * 70)
        for li in redci:
            ime = li.find("div", class_="playerName").find("h3").get_text(strip=True)
            if args.igrac.casefold() not in ime.casefold():
                continue
            print(f"\nIGRAČ: {ime}")
            print(f"  klub po sadašnjem pravilu: {opis_veze(klub_po_sadasnjem_pravilu(li))}")

            print("  pet prethodnih poveznica kluba, od najbliže:")
            n = 0
            for a in li.find_all_previous("a", href=lambda h: h and "/klubovi/" in h):
                if a.find_parent("div", class_="competition_table"):
                    continue
                print(f"    {n + 1}. {opis_veze(a)}")
                n += 1
                if n == 5:
                    break

            print("  roditelji retka (do korijena), s klasama:")
            for roditelj in li.parents:
                if roditelj.name in (None, "[document]"):
                    break
                klase = " ".join(roditelj.get("class", []))
                naslovi = [h.get_text(strip=True)
                           for h in roditelj.find_all(["h1", "h2", "h3", "h4"], limit=2)]
                print(f"    <{roditelj.name} class={klase!r}> prvi naslovi: {naslovi}")

    print()
    print("=" * 70)
    print("3) SEKCIJA \"KLUBOVI U NATJECANJU\": KARTICE I BLOKOVI SASTAVA")
    print("=" * 70)
    sekcija = soup.find("div", class_="clubs_in_competition")
    if sekcija is None:
        print("  Nema div.clubs_in_competition, struktura se promijenila.")
    else:
        blokovi = sekcija.find_all("div", class_="club_competition_details")
        print(f"  Blokova sastava (div.club_competition_details): {len(blokovi)}")
        for i, blok in enumerate(blokovi[:3], start=1):
            print(f"\n  --- blok {i}, svi atributi: {dict(blok.attrs)}")
            print("      prvih 700 znakova HTML-a:")
            print("      " + str(blok)[:700].replace("\n", " "))

        print("\n  --- elementi koji nose imena klubova, izvan blokova sastava:")
        n = 0
        for element in sekcija.find_all(["a", "li", "span", "h2", "h3", "button"]):
            if element.find_parent("div", class_="club_competition_details"):
                continue
            tekst = " ".join(element.get_text(strip=True).split())
            if not tekst or len(tekst) > 40:
                continue
            print(f"    <{element.name} {dict(element.attrs)}> {tekst}")
            n += 1
            if n == 20:
                break

    print()
    print("=" * 70)
    print("4) NASLOVI SEKCIJA NA STRANICI, REDOM")
    print("=" * 70)
    for h in soup.find_all(["h1", "h2"]):
        tekst = " ".join(h.get_text(strip=True).split())
        if tekst:
            print(f"  <{h.name}> {tekst[:70]}")


if __name__ == "__main__":
    main()

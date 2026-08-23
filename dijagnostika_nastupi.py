"""
dijagnostika_nastupi.py

Gleda kako stranica natjecanja zapisuje NASTUPE i MINUTE, i čita li ih
naš scraper ispravno. NIŠTA ne sprema u bazu, samo ispisuje.

POKRETANJE:

    python dijagnostika_nastupi.py <adresa stranice natjecanja>

Primjer:

    python dijagnostika_nastupi.py https://semafor.hns.family/natjecanja/100585203/treca-nl-zapad-2526/

VAŽNO: uperi ga na PROŠLU sezonu. U sezoni koja tek počinje na stranici
još nema ni sastava klubova ni rang-lista, pa se nema što provjeriti.
Adresu prošle sezone najlakše je uzeti iz preglednika: semafor.hns.family
-> Sezona 2025/26 -> Razina -> Natjecanje -> Traži, pa kopiraj adresu.

Bez adrese uzimaju se natjecanja upisana u scraper_supabase.py.
"""

import sys
from collections import Counter

import requests
from bs4 import BeautifulSoup

from scraper_supabase import (
    HEADERS,
    NATJECANJA,
    _brojevi,
    parsiraj_rang_nastupa,
    parsiraj_sve_igrace,
    slozi_listu_nastupa,
)


def _klase(oznaka):
    return " ".join(oznaka.get("class") or []) or "(bez klase)"


def struktura_retka(soup):
    """
    Ispisuje kako izgleda redak igrača: koje blokove sadrži i što u njima
    piše. Ovo je najvažniji dio kad podatak ne nalazimo pod očekivanim
    imenom, jer pokazuje kako se stvarno zove.
    """
    redci = soup.find_all("li", class_="row")
    print(f"\nRedaka <li class=\"row\"> na stranici: {len(redci)}")

    s_imenom = [li for li in redci if li.find("div", class_="playerName")]
    print(f"Od toga s imenom igrača: {len(s_imenom)}")

    if not s_imenom:
        print("   Nema redaka s igračima. Ako je ovo sezona koja tek")
        print("   počinje, to je normalno: sastavi i rang-liste pojave se")
        print("   tek kad se odigra prvo kolo. Probaj s prošlom sezonom.")
        return

    imena_blokova = Counter()
    for li in s_imenom:
        for div in li.find_all("div", recursive=True):
            imena_blokova[_klase(div)] += 1

    print("\nBlokovi koji se javljaju u retcima s igračima:")
    for naziv, koliko in imena_blokova.most_common(15):
        print(f"   {koliko:>5} x  {naziv}")

    print("\nPrva tri retka s igračem, blok po blok:")
    for li in s_imenom[:3]:
        ime = li.find("div", class_="playerName").get_text(" ", strip=True)
        print(f"\n   --- {ime} ---")
        for div in li.find_all("div", recursive=True):
            tekst = div.get_text(" ", strip=True)
            if not tekst or len(tekst) > 60:
                continue
            print(f"       {_klase(div):<24} \"{tekst}\"")


def pregled(naziv, url):
    print("=" * 70)
    print(naziv)
    print(url)
    print("=" * 70)

    odgovor = requests.get(url, headers=HEADERS, timeout=20)
    odgovor.raise_for_status()
    soup = BeautifulSoup(odgovor.text, "html.parser")

    struktura_retka(soup)

    for naziv in ("apps", "minutes", "apps_minutes"):
        blokovi = soup.find_all("div", class_=naziv)
        print(f"\nBlokova '{naziv}': {len(blokovi)}")
        for b in blokovi[:3]:
            tekst = b.get_text(" ", strip=True)
            # Isto čitanje kao u scraperu: točka je razdjelnik tisućica,
            # pa "2.700" daje 2700, a ne 2 i 700.
            print(f"   \"{tekst}\"   ->  pročitano: {_brojevi(tekst)}")

    igraci = parsiraj_sve_igrace(soup)
    s_podatkom = [i for i in igraci
                  if i.get("nastupi") is not None or i.get("minute") is not None]
    print(f"\nIgrača iz sastava klubova: {len(igraci)}")
    print(f"Od toga s nastupima ili minutama: {len(s_podatkom)}")

    rezerva = parsiraj_rang_nastupa(soup)
    print(f"Redaka u službenoj rang-listi nastupa: {len(rezerva)}")

    lista = slozi_listu_nastupa(igraci, rezerva)
    print(f"\nSpremilo bi se {len(lista)} redaka. Prvih deset:")
    if not lista:
        print("   (prazno)")
    for r in lista[:10]:
        print(f"   {r['pozicija']:>3}. {r['igrac']:<28} {r['klub'] or '?':<22} "
              f"nastupi={r['nastupi'] or '?':>4}  minute={r['minute'] or '?':>6}")
    print()


if __name__ == "__main__":
    if len(sys.argv) > 1:
        pregled("Zadana adresa", sys.argv[1])
    elif NATJECANJA:
        for n in NATJECANJA:
            pregled(n["naziv"], n["url"])
    else:
        print("U scraper_supabase.py nema uključenih natjecanja.")
        sys.exit(1)

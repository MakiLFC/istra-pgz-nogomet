"""
dijagnostika_nastupi.py

Provjerava čita li se s HNS stranice podatak o NASTUPIMA i MINUTAMA.
NIŠTA ne sprema u bazu, samo ispisuje što je pronašao.

Zašto postoji: točan zapis tog podatka na stranici nije bio poznat kad je
parsiranje pisano, pa se prvo gleda očima. Pokreni ovo prije nego pustiš
scraper, i usporedi ispis sa stranicom natjecanja u pregledniku.

POKRETANJE:
    python dijagnostika_nastupi.py
"""

import re
import sys

import requests
from bs4 import BeautifulSoup

from scraper_supabase import (
    HEADERS,
    NATJECANJA,
    parsiraj_rang_nastupa,
    parsiraj_sve_igrace,
    slozi_listu_nastupa,
)


def pregled(natjecanje):
    print("=" * 70)
    print(natjecanje["naziv"])
    print("=" * 70)

    odgovor = requests.get(natjecanje["url"], headers=HEADERS, timeout=15)
    odgovor.raise_for_status()
    soup = BeautifulSoup(odgovor.text, "html.parser")

    # 1. Postoji li uopće blok s nastupima i minutama
    blokovi = soup.find_all("div", class_="apps_minutes")
    print(f"\nBlokova 'apps_minutes' na stranici: {len(blokovi)}")
    if blokovi:
        print("Sirovi zapis prvih pet, ovako stoji na stranici:")
        for b in blokovi[:5]:
            tekst = b.get_text(" ", strip=True)
            print(f"   \"{tekst}\"   ->  brojevi: {re.findall(r'[0-9]+', tekst)}")
    else:
        print("   NEMA IH. Ili stranica taj podatak ne prikazuje, ili se")
        print("   blok zove drukčije. U tom slučaju javi i pogledat ćemo.")

    # 2. Što je izašlo iz sastava klubova
    igraci = parsiraj_sve_igrace(soup)
    s_podatkom = [i for i in igraci
                  if i.get("nastupi") is not None or i.get("minute") is not None]
    print(f"\nIgrača iz sastava klubova: {len(igraci)}")
    print(f"Od toga s nastupima ili minutama: {len(s_podatkom)}")

    # 3. Rezervni izvor
    rezerva = parsiraj_rang_nastupa(soup)
    print(f"Redaka u službenoj rang-listi nastupa: {len(rezerva)}")

    # 4. Konačna lista, onakva kakva bi se spremila
    lista = slozi_listu_nastupa(igraci, rezerva)
    print(f"\nSpremilo bi se {len(lista)} redaka. Prvih deset:")
    if not lista:
        print("   (prazno)")
    for r in lista[:10]:
        print(f"   {r['pozicija']:>3}. {r['igrac']:<28} {r['klub']:<22} "
              f"nastupi={r['nastupi'] or '?':>4}  minute={r['minute'] or '?':>6}")

    print("\nPROVJERI OČIMA: otvori stranicu natjecanja u pregledniku i")
    print("usporedi ova imena i brojke s onim što ondje piše.\n")


if __name__ == "__main__":
    if not NATJECANJA:
        print("U scraper_supabase.py nema uključenih natjecanja.")
        sys.exit(1)
    for natjecanje in NATJECANJA:
        pregled(natjecanje)

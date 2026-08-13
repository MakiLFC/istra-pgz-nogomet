"""
test_raspored.py

PROBNO čitanje rasporeda sa stranice lige - uključujući utakmice koje još
nisu odigrane (one nemaju poveznicu na zapisnik, pa ih dosadašnji scraper
nije vidio). NIŠTA ne sprema u bazu, samo ispisuje što je pročitao.

Pokreni:  python test_raspored.py
Zalijepi ispis u chat.
"""

import re
import requests
from bs4 import BeautifulSoup

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/120.0 Safari/537.36"
}

NATJECANJA = [
    ("3. NL Zapad", "https://semafor.hns.family/natjecanja/114647051/treca-nl-zapad-2627/"),
    ("4. NL NS Rijeka", "https://semafor.hns.family/natjecanja/114651788/4-nl-ns-rijeka-2627/"),
]

RE_KOLO = re.compile(r"^(\d+)\.\s*kolo$")
RE_DATUM = re.compile(r"(\d{2}\.\d{2}\.\d{4}\.)\s*(\d{1,2}:\d{2})?")


def procitaj_raspored(url):
    r = requests.get(url, headers=HEADERS, timeout=20)
    r.raise_for_status()
    soup = BeautifulSoup(r.text, "html.parser")

    pocetna = None
    for el in soup.find_all(["h1", "h2", "h3"]):
        if "Raspored" in el.get_text():
            pocetna = el
            break
    if pocetna is None:
        return None, "NEMA naslova 'Raspored' na stranici"

    utakmice = []
    kolo = None

    for el in pocetna.find_all_next(["li", "div", "span"]):
        tekst = el.get_text(strip=True)

        m = RE_KOLO.match(tekst)
        if m:
            kolo = int(m.group(1))
            continue

        klub_linkovi = el.find_all("a", href=lambda h: h and "/klubovi/" in h)
        if len(klub_linkovi) != 2:
            continue
        # uzmi NAJUŽI element koji sadrži točno dva kluba (izbjegni dvostruko)
        if el.find(lambda t: t.name in ("li", "div")
                   and t is not el
                   and len(t.find_all("a", href=lambda h: h and "/klubovi/" in h)) == 2):
            continue

        domacin = klub_linkovi[0].get_text(strip=True)
        gost = klub_linkovi[1].get_text(strip=True)
        if not domacin or not gost or domacin == gost:
            continue

        link_utakmice = el.find("a", href=lambda h: h and "/utakmice/" in h)
        hns_url = link_utakmice["href"] if link_utakmice else None
        rezultat = None
        if link_utakmice:
            rt = link_utakmice.get_text(strip=True)
            if re.match(r"^\d{1,2}\s*:\s*\d{1,2}$", rt):
                rezultat = rt.replace(" ", "")

        cijeli = el.get_text(" ", strip=True)
        md = RE_DATUM.search(cijeli)
        datum = md.group(1) if md else None
        vrijeme = md.group(2) if md and md.group(2) else None

        # stadion: zadnji tekstualni redak koji nije ime kluba/datum/rezultat
        stadion = None
        for dio in reversed([d.strip() for d in el.get_text("\n").split("\n") if d.strip()]):
            if dio in (domacin, gost):
                continue
            if RE_DATUM.search(dio) or re.match(r"^[\d\s:-]+$", dio):
                continue
            if dio.startswith("http"):
                continue
            stadion = dio
            break

        # izbjegni duplikate (ista utakmica u više blokova na stranici)
        kljuc = (kolo, domacin, gost)
        if any(u["_kljuc"] == kljuc for u in utakmice):
            continue

        utakmice.append({
            "_kljuc": kljuc, "kolo": kolo, "datum": datum, "vrijeme": vrijeme,
            "domacin": domacin, "gost": gost, "rezultat": rezultat,
            "stadion": stadion, "hns_url": hns_url,
        })

    return utakmice, None


for naziv, url in NATJECANJA:
    print("\n" + "=" * 72)
    print(f"LIGA: {naziv}")
    print("=" * 72)
    try:
        utakmice, greska = procitaj_raspored(url)
        if greska:
            print("GREŠKA:", greska)
            continue

        kola = sorted({u["kolo"] for u in utakmice if u["kolo"]})
        odigrane = [u for u in utakmice if u["rezultat"]]
        print(f"Ukupno pročitano: {len(utakmice)} utakmica")
        print(f"Kola: {kola[:5]}{'...' if len(kola) > 5 else ''}  (ukupno {len(kola)})")
        print(f"S rezultatom: {len(odigrane)} | bez rezultata (raspored): {len(utakmice)-len(odigrane)}")
        bez_kola = [u for u in utakmice if not u["kolo"]]
        bez_datuma = [u for u in utakmice if not u["datum"]]
        bez_stadiona = [u for u in utakmice if not u["stadion"]]
        print(f"PROVJERA -> bez kola: {len(bez_kola)} | bez datuma: {len(bez_datuma)} | bez stadiona: {len(bez_stadiona)}")

        print("\n-- PRVIH 10 --")
        for u in utakmice[:10]:
            print(f"  {u['kolo']:>2}. kolo | {u['datum']} {u['vrijeme'] or '--:--'} | "
                  f"{u['domacin']} {u['rezultat'] or '-:-'} {u['gost']} | {u['stadion']}")

        print("\n-- ZADNJE 3 --")
        for u in utakmice[-3:]:
            print(f"  {u['kolo']:>2}. kolo | {u['datum']} {u['vrijeme'] or '--:--'} | "
                  f"{u['domacin']} {u['rezultat'] or '-:-'} {u['gost']} | {u['stadion']}")
    except Exception as e:
        print("GREŠKA:", e)

print("\nGOTOVO. Zalijepi ispis u chat.")

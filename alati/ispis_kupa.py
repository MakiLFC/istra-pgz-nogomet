"""
ispis_kupa.py

Ispisuje utakmice Hrvatskog nogometnog kupa sa Semafora, a za odabrane i
cijeli zapisnik: strijelce, kartone, izmjene i postave s brojevima.
Ne dira bazu i ništa ne upisuje.

ČEMU SLUŽI
Kup nije u scraperu, pa ga nema u bazi. Članci o kupu pisali su se sa
slika ekrana koje je Andrej slao. Ovaj alat iste podatke čita ravno sa
Semafora, preko istih funkcija kojima scraper čita lige, a ispis je u
istom obliku kao "Ispis kola".

KAKO SE POKREĆE
Preko posla "Ispis kupa" na GitHubu (Actions), ili ručno:

    python alati/ispis_kupa.py ADRESA_NATJECANJA "Rječina;Orijent"

Drugi argument su dijelovi imena klubova, odvojeni točka-zarezom. Za
svaku utakmicu u kojoj igra koji od njih, a ima zapisnik, ispiše se
cijeli zapisnik. Bez njega se ispiše samo popis utakmica.

ŠTO SE ISPISUJE
1. naslovi na stranici natjecanja (kolo, faza kupa), da se vidi kako ih
   HNS slaže, jer stranica kupa ne mora izgledati kao stranica lige
2. sve utakmice s domaćinom, gostom, terminom, rezultatom i adresom
   zapisnika, uz zadnji naslov viđen prije njih
3. za odabrane utakmice cijeli zapisnik
"""

import os
import sys

from bs4 import BeautifulSoup

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from scraper_supabase import (  # noqa: E402
    RE_DATUM,
    dohvati_detalje_utakmice,
    dohvati_stranicu,
)
from ispis_kola import ispisi_utakmicu  # noqa: E402

KLJUCNE_RIJECI_NASLOVA = ("finala", "finale", "kolo", "kola", "pretkolo")


def je_naslov(element):
    """Kratki tekst koji zvuči kao faza kupa, npr. "1/8 finala"."""
    tekst = element.get_text(" ", strip=True)
    if not tekst or len(tekst) > 40:
        return None
    if any(r in tekst.lower() for r in KLJUCNE_RIJECI_NASLOVA):
        if element.find(lambda t: t is not element and t.get_text(" ", strip=True) == tekst):
            return None
        return tekst
    return None


def popis_utakmica(soup):
    """Sve utakmice na stranici, redom, uz zadnji naslov faze prije njih."""
    utakmice, vidjene = [], set()
    faza = None
    for element in soup.find_all(True):
        naslov = je_naslov(element)
        if naslov:
            faza = naslov
            continue
        if element.name not in ("li", "div", "span", "tr"):
            continue
        klubovi = element.find_all("a", href=lambda h: h and "/klubovi/" in h)
        if len(klubovi) != 2:
            continue
        if element.find(lambda t: t.name in ("li", "div", "tr") and t is not element
                        and len(t.find_all("a", href=lambda h: h and "/klubovi/" in h)) == 2):
            continue
        domacin = klubovi[0].get_text(strip=True)
        gost = klubovi[1].get_text(strip=True)
        if not domacin or not gost or domacin == gost:
            continue
        veza = element.find("a", href=lambda h: h and "/utakmice/" in h)
        adresa = veza["href"] if veza else None
        rezultat = veza.get_text(strip=True) if veza else None
        tekst = element.get_text(" ", strip=True)
        md = RE_DATUM.search(tekst)
        kljuc = (domacin, gost, adresa)
        if kljuc in vidjene:
            continue
        vidjene.add(kljuc)
        utakmice.append({
            "faza": faza, "domacin": domacin, "gost": gost,
            "datum": md.group(1) if md else None,
            "vrijeme": md.group(2) if md and md.group(2) else None,
            "rezultat": rezultat, "hns_url": adresa,
        })
    return utakmice


def main():
    if len(sys.argv) not in (2, 3):
        raise SystemExit('Uporaba: python alati/ispis_kupa.py ADRESA ["Klub;Klub"]')
    adresa = sys.argv[1].strip()
    trazeni = [k.strip().lower() for k in (sys.argv[2] if len(sys.argv) == 3 else "").split(";")
               if k.strip()]

    soup = BeautifulSoup(dohvati_stranicu(adresa).text, "html.parser")

    print("=" * 60)
    print("NASLOVI NA STRANICI")
    print("=" * 60)
    for el in soup.find_all(["h1", "h2", "h3", "h4"]):
        print(f"  <{el.name}> {el.get_text(' ', strip=True)[:90]}")

    utakmice = popis_utakmica(soup)
    print(f"\n{'=' * 60}\nUTAKMICE ({len(utakmice)})\n{'=' * 60}")
    for u in utakmice:
        print(f"  [{u['faza'] or '?'}] {u['datum'] or ''} {u['vrijeme'] or ''}  "
              f"{u['domacin']} - {u['gost']}  {u['rezultat'] or '-:-'}  {u['hns_url'] or ''}")

    if not trazeni:
        return
    odabrane = [u for u in utakmice
                if any(t in u["domacin"].lower() or t in u["gost"].lower() for t in trazeni)]
    print(f"\n{'=' * 60}\nZAPISNICI ODABRANIH ({len(odabrane)})\n{'=' * 60}")
    for u in odabrane:
        if not u["hns_url"]:
            print(f"\n{u['domacin']} - {u['gost']}: zapisnika još nema")
            continue
        detalji = dohvati_detalje_utakmice(u["hns_url"])
        detalji["domacin"], detalji["gost"] = u["domacin"], u["gost"]
        detalji.setdefault("kolo", u["faza"])
        for k in ("datum", "vrijeme"):
            detalji.setdefault(k, u[k])
        print(f"\nAdresa: {u['hns_url']}")
        ispisi_utakmicu(detalji)


if __name__ == "__main__":
    main()

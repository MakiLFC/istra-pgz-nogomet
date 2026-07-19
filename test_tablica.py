"""
test_tablica.py  (v2 - tablica + strijelci + kartoni + provjera asistenata)

PROBNI parser - NIŠTA ne sprema u bazu, samo ispisuje što je pročitao.

Pokreni:  python test_tablica.py
Zalijepi ispis u chat (prva liga u cijelosti + greške ostalih je dovoljno).
"""

import re
import time
import requests
from bs4 import BeautifulSoup

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/120.0 Safari/537.36"
}

NATJECANJA = [
    ("2. ŽNL PGŽ", "https://semafor.hns.family/natjecanja/101556988/druga-znl-seniori-2526/"),
    ("1. ŽNL PGŽ", "https://semafor.hns.family/natjecanja/101555188/1-znl-seniori-2526/"),
    ("3. NL Zapad", "https://semafor.hns.family/natjecanja/100585203/treca-nl-zapad-2526/"),
    ("4. NL NS Rijeka", "https://semafor.hns.family/natjecanja/100796651/4-nl-ns-rijeka-2526/"),
]


def parsiraj_tablicu(soup):
    blok = soup.find("div", class_="competition_table")
    if not blok:
        return None, "NEMA div.competition_table na stranici!"
    redci, prva_dva = [], []
    for li in blok.find_all("li"):
        klub_link = li.find("a", href=lambda h: h and "/klubovi/" in h)
        if not klub_link:
            continue
        klub = klub_link.get_text(strip=True)
        celije = []
        for div in li.find_all("div"):
            klase = div.get("class") or []
            tekst = div.get_text(" ", strip=True)
            if klase and tekst and not div.find("div"):
                celije.append((" ".join(klase), tekst))
        if len(prva_dva) < 2:
            prva_dva.append((klub, celije))
        redci.append({"klub": klub, "celije": celije})
    return (redci, prva_dva), None


def parsiraj_rang_igraca(soup):
    """
    Sve rang-liste igrača na stranici (strijelci, kartoni, nastupi...).
    Za svaki li.row s igračem ispiši SVE ćelije s klasama - da vidimo
    kako se zove ćelija s brojem golova vs. kartona vs. minuta.
    """
    redovi = []
    for li in soup.find_all("li", class_="row"):
        ime_div = li.find("div", class_="playerName")
        if not ime_div:
            continue
        h3 = ime_div.find("h3")
        ime = h3.get_text(strip=True) if h3 else "?"
        klub = ime_div.get_text(" ", strip=True).replace(ime, "").strip()
        celije = []
        for div in li.find_all("div"):
            klase = div.get("class") or []
            tekst = div.get_text(" ", strip=True)
            if klase and tekst and not div.find("div") and "player" not in " ".join(klase).lower():
                celije.append((" ".join(klase), tekst))
        redovi.append({"igrac": ime, "klub": klub, "celije": celije})
    return redovi


for naziv, url in NATJECANJA:
    print("\n" + "=" * 70)
    print(f"LIGA: {naziv}")
    print("=" * 70)
    try:
        html = requests.get(url, headers=HEADERS, timeout=15).text
        soup = BeautifulSoup(html, "html.parser")

        # 0) Spominju li se ASISTENTI igdje na stranici?
        asist = re.findall(r"[Aa]sist\w*", html)
        print(f"ASISTENTI: {'spominju se! -> ' + str(sorted(set(asist))[:5]) if asist else 'ne spominju se nigdje na stranici'}")

        # 1) Tablica poretka
        rezultat, greska = parsiraj_tablicu(soup)
        if greska:
            print(f"TABLICA: {greska}")
        else:
            redci, prva_dva = rezultat
            print(f"\nTABLICA: pročitano {len(redci)} klubova")
            print("-- STRUKTURA PRVA DVA RETKA (klasa -> vrijednost) --")
            for klub, celije in prva_dva:
                print(f"  {klub}:")
                for klasa, tekst in celije:
                    print(f"      [{klasa}] = {tekst}")
            print("-- CIJELA TABLICA --")
            for r in redci:
                print(f"  {r['klub']:<28} " + " | ".join(t for _, t in r["celije"]))

        # 2) Sve rang-liste igrača (strijelci / kartoni / nastupi)
        redovi = parsiraj_rang_igraca(soup)
        print(f"\nRANG-LISTE IGRAČA: pročitano {len(redovi)} redaka ukupno")
        print("-- SVI REDOVI s klasama ćelija (da razlikujemo strijelce/kartone/nastupe) --")
        for r in redovi:
            celije_str = "  ".join(f"[{k}]={t}" for k, t in r["celije"])
            print(f"  {r['igrac']:<25} {r['klub']:<24} {celije_str}")

    except Exception as e:
        print(f"GREŠKA: {e}")
    time.sleep(1)

print("\nGOTOVO. Zalijepi ispis u chat.")

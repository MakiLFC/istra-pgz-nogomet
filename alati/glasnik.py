"""
glasnik.py

Čita službene glasnike Nogometnog saveza PGŽ (nspgz.hr) i u njima traži
zadana imena, npr. igrača za kojeg treba provjeriti koliko kolo kazne
propušta. Semafor kazne ne prikazuje; izriče ih stegovni sudac saveza i
objavljuje u glasniku. Pokreće ga posao "Glasnik saveza" na GitHubu, jer
se nspgz.hr iz okruženja Claude Code na webu ne može otvoriti.

    python alati/glasnik.py <adresa popisa glasnika> <koliko> "Ime Prezime;Klub"

Ispisuje redove u kojima se ime pojavljuje, s nekoliko redova prije i
poslije, te cijeli odjeljak stegovnog suca kad ga nađe. Ne dira bazu.
"""

import re
import subprocess
import sys
import tempfile
import unicodedata
from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup

HEADERS = {"User-Agent": "Mozilla/5.0 (Lokal-Arena; provjera glasnika)"}
OKO = 4


def bez_kvacica(t):
    return unicodedata.normalize("NFKD", t).encode("ascii", "ignore").decode().lower()


def dohvati(url):
    r = requests.get(url, headers=HEADERS, timeout=40)
    r.raise_for_status()
    return r


def tekst_pdfa(sadrzaj):
    with tempfile.NamedTemporaryFile(suffix=".pdf") as f:
        f.write(sadrzaj)
        f.flush()
        izlaz = subprocess.run(["pdftotext", "-layout", f.name, "-"],
                               capture_output=True, text=True)
    return izlaz.stdout


def pretrazi(naslov, tekst, imena):
    redovi = tekst.splitlines()
    print(f"\n----- {naslov} ({len(redovi)} redova)")
    for i, red in enumerate(redovi):
        if "stegov" in bez_kvacica(red):
            print(f"  [odjeljak stegovnog suca od reda {i}]")
            for r in redovi[i:i + 60]:
                print("   |", r)
            break
    for ime in imena:
        trazi = bez_kvacica(ime)
        for i, red in enumerate(redovi):
            if trazi in bez_kvacica(red):
                print(f"  >>> '{ime}' u redu {i}:")
                for r in redovi[max(0, i - OKO):i + OKO + 1]:
                    print("   |", r)


def main():
    adresa, koliko, imena = sys.argv[1], int(sys.argv[2]), [
        i.strip() for i in sys.argv[3].split(";") if i.strip()]
    popis = BeautifulSoup(dohvati(adresa).text, "html.parser")
    glasnici = []
    for a in popis.find_all("a", href=True):
        url = urljoin(adresa, a["href"])
        if "/glasnik/" in url and url.rstrip("/") != adresa.rstrip("/") and url not in glasnici:
            if a.get_text(strip=True).lower().startswith("glasnik"):
                glasnici.append(url)
    print("Glasnici na popisu:", len(glasnici))
    for url in glasnici[:koliko]:
        print("\n==========", url)
        stranica = BeautifulSoup(dohvati(url).text, "html.parser")
        naslov = stranica.find("h1")
        print("Naslov:", naslov.get_text(strip=True) if naslov else "?")
        pretrazi("tekst stranice", stranica.get_text("\n"), imena)
        for a in stranica.find_all("a", href=True):
            prilog = urljoin(url, a["href"])
            if re.search(r"\.pdf($|\?)", prilog, re.I):
                print("\nPrilog:", prilog)
                try:
                    pretrazi(prilog.rsplit("/", 1)[-1], tekst_pdfa(dohvati(prilog).content), imena)
                except Exception as g:  # prilog se ne da pročitati
                    print("  ne mogu pročitati:", g)


if __name__ == "__main__":
    main()

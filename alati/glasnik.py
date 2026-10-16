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
from urllib.parse import unquote, urljoin

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


def tekst_worda(sadrzaj):
    """Tekst .docx datoteke, bez dodatnih paketa: to je zip s XML-om."""
    import io
    import zipfile
    with zipfile.ZipFile(io.BytesIO(sadrzaj)) as z:
        xml = z.read("word/document.xml").decode("utf-8", "ignore")
    xml = re.sub(r"</w:p>", "\n", xml)
    return re.sub(r"<[^>]+>", "", xml)


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
    # Stranica ima i bočni popis glasnika drugih liga, pa prednost imaju
    # oni čija adresa počinje adresom popisa.
    svoji = [g for g in glasnici if g.startswith(adresa.rstrip("/") + "/")]
    if svoji:
        glasnici = svoji
    print("Glasnici na popisu:", len(glasnici))
    for url in glasnici[:koliko]:
        print("\n==========", url)
        stranica = BeautifulSoup(dohvati(url).text, "html.parser")
        naslov = stranica.find("h1")
        print("Naslov:", naslov.get_text(strip=True) if naslov else "?")
        pretrazi("tekst stranice", stranica.get_text("\n"), imena)
        # Prilozi znaju biti i Word ili ugrađeni preglednik, ne samo PDF,
        # pa se ispisuje sve što izgleda kao datoteka ili ugradnja.
        for oznaka, atribut in (("a", "href"), ("iframe", "src"), ("embed", "src"), ("object", "data")):
            for el in stranica.find_all(oznaka):
                cilj = el.get(atribut)
                if cilj and re.search(r"uploads|\.(pdf|docx?|xlsx?)($|\?)|drive|docs\.google|viewer", cilj, re.I):
                    print(f"  [{oznaka}] {urljoin(url, cilj)}")
                    # Preglednik PDF-a nosi pravu adresu u parametru file=
                    ugradjen = re.search(r"[?&]file=([^&]+\.pdf)", cilj, re.I)
                    if ugradjen:
                        pdf = urljoin(url, unquote(ugradjen.group(1)))
                        print("\nPrilog (ugrađen PDF):", pdf)
                        try:
                            pretrazi(pdf.rsplit("/", 1)[-1], tekst_pdfa(dohvati(pdf).content), imena)
                        except Exception as g:  # prilog se ne da pročitati
                            print("  ne mogu pročitati:", g)
        for a in stranica.find_all("a", href=True):
            prilog = urljoin(url, a["href"])
            if re.search(r"\.docx($|\?)", prilog, re.I):
                print("\nPrilog (Word):", prilog)
                try:
                    pretrazi(prilog.rsplit("/", 1)[-1], tekst_worda(dohvati(prilog).content), imena)
                except Exception as g:  # prilog se ne da pročitati
                    print("  ne mogu pročitati:", g)
            if re.search(r"\.pdf($|\?)", prilog, re.I):
                print("\nPrilog:", prilog)
                try:
                    pretrazi(prilog.rsplit("/", 1)[-1], tekst_pdfa(dohvati(prilog).content), imena)
                except Exception as g:  # prilog se ne da pročitati
                    print("  ne mogu pročitati:", g)


if __name__ == "__main__":
    main()

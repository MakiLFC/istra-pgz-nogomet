"""
scraper_supabase.py

Glavna verzija scrapera - dohvaća utakmice s HNS Semafora i sprema ih
DIREKTNO u Supabase bazu, umjesto u lokalnu JSON datoteku.

Koristi iste provjerene funkcije za parsiranje kao scraper_test.py.

KAKO POKRENUTI:
    python scraper_supabase.py
"""

import requests
from bs4 import BeautifulSoup
import time
import os
import re
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()  # učitava SUPABASE_URL i SUPABASE_SERVICE_KEY iz .env datoteke

supabase = create_client(
    os.environ["SUPABASE_URL"],
    os.environ["SUPABASE_SERVICE_KEY"],
)

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"
}

# Sva četiri natjecanja koja pratimo - naziv koji ćemo spremiti u bazu,
# i ID/URL natjecanja na Semaforu (iz naše datoteke natjecanja.json)
NATJECANJA = [
    {
        "naziv": "2. ŽNL PGŽ",
        "url": "https://semafor.hns.family/natjecanja/101556988/druga-znl-seniori-2526/",
    },
    {
        "naziv": "1. ŽNL PGŽ",
        "url": "https://semafor.hns.family/natjecanja/101555188/1-znl-seniori-2526/",
    },
    {
        "naziv": "3. NL Zapad",
        "url": "https://semafor.hns.family/natjecanja/100585203/treca-nl-zapad-2526/",
    },
    {
        "naziv": "4. NL NS Rijeka",
        "url": "https://semafor.hns.family/natjecanja/100796651/4-nl-ns-rijeka-2526/",
    },
]


def dohvati_popis_utakmica(natjecanje_url):
    """Otvara stranicu natjecanja i vraća listu linkova na utakmice."""
    print(f"Dohvaćam: {natjecanje_url}")
    response = requests.get(natjecanje_url, headers=HEADERS, timeout=15)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "html.parser")

    pocetna_tocka = None
    for element in soup.find_all(["h1", "h2", "h3"]):
        if "Raspored" in element.get_text():
            pocetna_tocka = element
            break

    if pocetna_tocka is None:
        print("UPOZORENJE: nisam pronašao početak rasporeda na stranici.")
        return []

    utakmice = []
    for link in pocetna_tocka.find_all_next("a", href=True):
        href = link["href"]
        if "/utakmice/" in href and href.count("/") >= 4:
            utakmice.append(href)

    jedinstveni_linkovi = list(dict.fromkeys(utakmice))
    print(f"Pronađeno {len(jedinstveni_linkovi)} jedinstvenih utakmica.")
    return jedinstveni_linkovi


def dohvati_detalje_utakmice(utakmica_url):
    """Otvara stranicu jedne utakmice i vraća sve podatke za bazu."""
    response = requests.get(utakmica_url, headers=HEADERS, timeout=15)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "html.parser")

    tekst_stranice = soup.get_text(separator="\n")
    linije = [l.strip() for l in tekst_stranice.split("\n") if l.strip()]

    naslov_tag = soup.find("title")
    naslov_tekst = naslov_tag.text.strip() if naslov_tag else "Nepoznato"

    domacin, gost, rezultat = "Nepoznato", "Nepoznato", "Nepoznato"
    if " - " in naslov_tekst:
        domacin = naslov_tekst.split(" - ")[0].strip()
        desni_dio = naslov_tekst.split(" - ")[1]
        match = re.match(r"^(.*?)\s+(\d+\s*:\s*\d+)", desni_dio)
        if match:
            gost = match.group(1).strip()
            rezultat = match.group(2).replace(" ", "")

    stadion_datum = "Nepoznato"
    for linija in linije:
        if any(g in linija for g in [".2025.", ".2026."]) and "," in linija:
            stadion_datum = linija
            break

    gledatelja = "Nepoznato"
    for linija in linije:
        if linija.startswith("Gledatelja:"):
            gledatelja = linija.replace("Gledatelja:", "").strip()
            break

    suci = "Nepoznato"
    if "Suci:" in tekst_stranice:
        suci = tekst_stranice.split("Suci:")[1].split(".")[0].strip() + "."

    prvi_igrac_link = soup.find("a", href=lambda h: h and "/igraci/" in h)
    strijelci = []
    if prvi_igrac_link:
        for element in prvi_igrac_link.find_all_previous("li"):
            if element.find("a", href=lambda h: h and "/igraci/" in h):
                continue
            dijelovi = [d.strip() for d in element.get_text(separator="\n").split("\n") if d.strip()]
            minuta = next((d for d in dijelovi if d.endswith("'") and d[:-1].isdigit()), None)
            ime = next((d for d in dijelovi if d != minuta and len(d.split()) in (2, 3)), None)
            if minuta and ime:
                strijelci.append({"igrac": ime, "minuta": minuta})
        strijelci.reverse()

    return {
        "hns_url": utakmica_url,
        "domacin": domacin,
        "gost": gost,
        "rezultat": rezultat,
        "stadion_datum": stadion_datum,
        "gledatelja": gledatelja,
        "suci": suci,
        "strijelci": strijelci,
    }


def spremi_u_supabase(redak):
    """
    Sprema jedan redak u tablicu 'utakmice'. Koristi upsert - ako utakmica
    s istim hns_url već postoji, AŽURIRA postojeći redak umjesto da stvori
    duplikat. Ovo je važno jer ćemo scraper pokretati VIŠE PUTA (npr. svaki
    dan) i ne želimo da se ista utakmica spremi 10 puta.
    """
    supabase.table("utakmice").upsert(redak, on_conflict="hns_url").execute()


if __name__ == "__main__":
    ukupno_spremljeno = 0
    ukupno_gresaka = 0

    for natjecanje in NATJECANJA:
        print(f"\n{'=' * 60}")
        print(f"NATJECANJE: {natjecanje['naziv']}")
        print("=" * 60)

        linkovi_utakmica = dohvati_popis_utakmica(natjecanje["url"])
        ukupno = len(linkovi_utakmica)

        for i, link in enumerate(linkovi_utakmica, start=1):
            try:
                detalji = dohvati_detalje_utakmice(link)
                detalji["natjecanje"] = natjecanje["naziv"]
                spremi_u_supabase(detalji)
                ukupno_spremljeno += 1
                print(f"  [{i}/{ukupno}] {detalji['domacin']} - {detalji['gost']} ({detalji['rezultat']}): spremljeno")
            except Exception as greska:
                ukupno_gresaka += 1
                print(f"  [{i}/{ukupno}] GREŠKA na {link}: {greska}")
            time.sleep(1)

    print(f"\n{'=' * 60}")
    print(f"GOTOVO! Spremljeno/ažurirano {ukupno_spremljeno} utakmica. Grešaka: {ukupno_gresaka}.")
    print("=" * 60)

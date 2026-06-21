"""
scraper_test.py

Prvi test scraper - povlači sve utakmice jednog natjecanja s HNS Semafora.
Koristimo "2. ŽNL PGŽ" kao test slučaj jer je to manja liga.

KAKO POKRENUTI (na svom računalu, u mapi istra-pgz-nogomet):
    pip install requests beautifulsoup4
    python scraper_test.py
"""

import requests
from bs4 import BeautifulSoup
import json
import time

# Identificiramo se kao normalni preglednik da nas server ne blokira
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"
}

# URL natjecanja koje testiramo (2. ŽNL PGŽ, sezona 25/26)
NATJECANJE_URL = "https://semafor.hns.family/natjecanja/101556988/druga-znl-seniori-2526/"


def dohvati_popis_utakmica(natjecanje_url):
    """
    Otvara stranicu natjecanja i vraća listu utakmica.
    Svaka utakmica je rječnik s: kolo, datum, domacin, gost, rezultat, url_zapisnika
    """
    print(f"Dohvaćam: {natjecanje_url}")
    response = requests.get(natjecanje_url, headers=HEADERS, timeout=15)
    response.raise_for_status()  # baci grešku ako nešto nije u redu (npr. 404, 403)

    soup = BeautifulSoup(response.text, "html.parser")

    # VAŽNO: HNS Semafor prikazuje na VRHU svake stranice generičku traku s
    # nekoliko najnovijih utakmica iz SuperSport HNL-a (neovisno o ligi koju gledamo).
    # Te linkove MORAMO ignorirati - prepoznajemo ih po tome da sadrže
    # "SuperSport HNL" kao tekst odmah pored linka. Stvaran raspored naše lige
    # dolazi kasnije u HTML-u, nakon naslova "Raspored, rezultati, strijelci".

    # Pronađimo gdje počinje stvaran raspored: tražimo H2/H3 ili tekst koji
    # sadrži "Raspored, rezultati, strijelci" pa parsiramo samo ono ŠTO DOLAZI POSLIJE.
    cijeli_tekst_prije = ""
    pocetna_tocka = None

    for element in soup.find_all(["h1", "h2", "h3"]):
        if "Raspored" in element.get_text():
            pocetna_tocka = element
            break

    if pocetna_tocka is None:
        print("UPOZORENJE: nisam pronašao početak rasporeda na stranici - provjeri URL.")
        return []

    # Uzimamo samo linkove koji se nalaze NAKON te točke u dokumentu
    utakmice = []
    for link in pocetna_tocka.find_all_next("a", href=True):
        href = link["href"]
        if "/utakmice/" in href and href.count("/") >= 4:
            utakmice.append(href)

    # Uklanjamo duplikate, čuvajući redoslijed
    jedinstveni_linkovi = list(dict.fromkeys(utakmice))

    print(f"Pronađeno {len(jedinstveni_linkovi)} jedinstvenih utakmica.")
    return jedinstveni_linkovi


def dohvati_detalje_utakmice(utakmica_url):
    """
    Otvara stranicu jedne utakmice i vraća detalje: rezultat, strijelce, suce.
    """
    response = requests.get(utakmica_url, headers=HEADERS, timeout=15)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "html.parser")

    # Naslov stranice sadrži "Klub A - Klub B X:Y"
    naslov = soup.find("title")
    naslov_tekst = naslov.text.strip() if naslov else "Nepoznato"

    # Tražimo tekst sa sucima - on se nalazi u tekstu stranice s prefiksom "Suci:"
    tekst_stranice = soup.get_text()
    suci = "Nepoznato"
    if "Suci:" in tekst_stranice:
        dio_sa_sucima = tekst_stranice.split("Suci:")[1]
        suci = dio_sa_sucima.split(".")[0].strip() + "."

    return {
        "naslov": naslov_tekst,
        "suci": suci,
        "url": utakmica_url,
    }


if __name__ == "__main__":
    # KORAK 1: dohvati popis svih utakmica u natjecanju
    linkovi_utakmica = dohvati_popis_utakmica(NATJECANJE_URL)

    print("\nPrvih 5 pronađenih utakmica:")
    for link in linkovi_utakmica[:5]:
        print(" -", link)

    # KORAK 2: testno dohvati detalje SAMO za prvu utakmicu (da ne opterećujemo server)
    if linkovi_utakmica:
        print("\nDohvaćam detalje prve utakmice kao test...")
        time.sleep(1)  # malo pauze, fer prema HNS serveru
        detalji = dohvati_detalje_utakmice(linkovi_utakmica[0])
        print(json.dumps(detalji, indent=2, ensure_ascii=False))

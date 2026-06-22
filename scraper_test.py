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
    Otvara stranicu jedne utakmice i vraća sve podatke potrebne za pisanje članka:
    klubovi, rezultat, datum/vrijeme, stadion, gledatelje, suce i strijelce s minutama.

    NAPOMENA O PRISTUPU: prva verzija ove funkcije parsirala je sirovi tekst
    stranice (get_text()) tražeći uzorke "Ime Prezime" + "XX'". To je davalo
    lažne pogotke jer riječi poput "Igrač" ili "Pričuvni igrači" znaju se
    slučajno naći odmah ispred minute izmjene/kartona (ne gola).
    Ova verzija umjesto toga koristi STVARNU HTML STRUKTURU: igrače u postavi
    prepoznajemo po tome što imaju link na "/igraci/", a klubove po linku na
    "/klubovi/". Strijelci na vrhu stranice prikazani su BEZ takvog linka, u
    posebnom kratkom obliku, pa ih tražimo kao "li" elemente koji se nalaze
    PRIJE prvog igrača iz postave.
    """
    response = requests.get(utakmica_url, headers=HEADERS, timeout=15)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "html.parser")

    tekst_stranice = soup.get_text(separator="\n")
    linije = [l.strip() for l in tekst_stranice.split("\n") if l.strip()]

    # --- Naslov ---
    naslov_tag = soup.find("title")
    naslov_tekst = naslov_tag.text.strip() if naslov_tag else "Nepoznato"

    # --- Imena klubova (domaćin i gost) ---
    # NAPOMENA: pokušaj prepoznavanja klubova preko /klubovi/ linkova nije
    # pouzdan - na stranici utakmice klupska imena na vrhu prikazana su samo
    # kao slika+tekst, BEZ klikabilnog linka. Najpouzdaniji izvor je naslov
    # stranice (<title>), koji je dosljedno formatiran kao "Klub A - Klub B X:Y".
    domacin, gost = "Nepoznato", "Nepoznato"
    if " - " in naslov_tekst:
        lijevi_dio = naslov_tekst.split(" - ")[0].strip()
        desni_dio = naslov_tekst.split(" - ")[1]
        domacin = lijevi_dio
        # desni_dio izgleda npr. "NK Risnjak 1:1 - Hrvatski nogometni savez"
        # ime gosta je sve PRIJE prvog broja/rezultata
        import re
        match = re.match(r"^(.*?)\s+\d+\s*:\s*\d+", desni_dio)
        if match:
            gost = match.group(1).strip()

    # --- Stadion, datum, gledatelji ---
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

    # --- Suci ---
    suci = "Nepoznato"
    if "Suci:" in tekst_stranice:
        dio_sa_sucima = tekst_stranice.split("Suci:")[1]
        suci = dio_sa_sucima.split(".")[0].strip() + "."

    # --- Strijelci s minutama ---
    # Pronađemo prvog igrača s linkom na /igraci/ (početak liste postave),
    # pa tražimo "li" elemente PRIJE te točke koji sadrže i ime i minutu.
    prvi_igrac_link = soup.find("a", href=lambda h: h and "/igraci/" in h)

    strijelci = []
    if prvi_igrac_link:
        for element in prvi_igrac_link.find_all_previous("li"):
            # Preskačemo "li" elemente koji su DIO same postave (sadrže link na /igraci/)
            # - njih smo već vidjeli da se mogu pogrešno protumačiti kao strijelce
            if element.find("a", href=lambda h: h and "/igraci/" in h):
                continue
            dijelovi = [d.strip() for d in element.get_text(separator="\n").split("\n") if d.strip()]
            minuta = next((d for d in dijelovi if d.endswith("'") and d[:-1].isdigit()), None)
            ime = next((d for d in dijelovi if d != minuta and len(d.split()) in (2, 3)), None)
            if minuta and ime:
                strijelci.append({"igrac": ime, "minuta": minuta})
        strijelci.reverse()  # find_all_previous ide unatrag, vraćamo izvorni redoslijed

    return {
        "naslov": naslov_tekst,
        "domacin": domacin,
        "gost": gost,
        "stadion_datum": stadion_datum,
        "gledatelja": gledatelja,
        "suci": suci,
        "strijelci": strijelci,
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

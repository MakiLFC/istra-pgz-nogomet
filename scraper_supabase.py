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
    """
    Otvara stranicu natjecanja i vraća listu (link, kolo) parova.
    Kolo se prati tako što HNS stranica prikazuje naslov "X. kolo" kao
    poseban element PRIJE utakmica koje mu pripadaju - mi idemo kroz
    dokument redom i pamtimo "trenutno kolo" sve dok se ne pojavi sljedeći
    "X. kolo" naslov.
    """
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
    trenutno_kolo = None
    vidjeni_linkovi = set()

    # Prolazimo kroz SVE elemente nakon "Raspored..." naslova, redom kako
    # se pojavljuju u dokumentu (find_all_next vraća ih u pravom redoslijedu)
    for element in pocetna_tocka.find_all_next(["li", "div", "span"]):
        tekst = element.get_text(strip=True)

        # Prepoznajemo naslov kola: kratki tekst poput "1. kolo", "12. kolo"
        match_kolo = re.match(r"^(\d+)\.\s*kolo$", tekst)
        if match_kolo:
            trenutno_kolo = int(match_kolo.group(1))
            continue

        # Prepoznajemo link na utakmicu unutar ovog elementa
        link_tag = element.find("a", href=True) if element.name != "a" else element
        if link_tag and "href" in link_tag.attrs:
            href = link_tag["href"]
            if "/utakmice/" in href and href.count("/") >= 4 and href not in vidjeni_linkovi:
                vidjeni_linkovi.add(href)
                utakmice.append({"url": href, "kolo": trenutno_kolo})

    print(f"Pronađeno {len(utakmice)} jedinstvenih utakmica.")
    return utakmice


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

    # --- POSTAVE (oba kluba) ---
    # Svaki igrač u postavi je h3 > a[href*="/igraci/"]. Roditeljski "li" blok
    # sadrži i broj dresa (prvi broj u bloku), poziciju ("Vratar"/"Igrač"),
    # oznaku kapetana "(C)" ako postoji, i minute događaja (kartoni/izmjene -
    # ne razlikujemo tip pouzdano iz teksta, samo bilježimo SVE minute uz igrača).
    # "Pričuvni igrači" tekst prije bloka igrača govori da je taj igrač na klupi,
    # ne u početnoj postavi.
    domacin_postava, gost_postava = [], []
    trenutni_klub_postava = None  # "domacin" ili "gost"
    je_pricuvni = False

    for element in soup.find_all(["li"]):
        tekst_elementa = element.get_text(strip=True)

        # Naslov "NK Mrkopalj" / "NK Risnjak" odmah prije postave - prepoznajemo
        # prijelaz s domaćina na gosta po tome da se klupsko ime PONOVNO pojavi
        if tekst_elementa == domacin and not element.find("a", href=lambda h: h and "/igraci/" in h):
            trenutni_klub_postava = "domacin"
            je_pricuvni = False
            continue
        if tekst_elementa == gost and not element.find("a", href=lambda h: h and "/igraci/" in h):
            trenutni_klub_postava = "gost"
            je_pricuvni = False
            continue
        if tekst_elementa == "Pričuvni igrači":
            je_pricuvni = True
            continue

        h3 = element.find("h3")
        if not h3:
            continue
        link = h3.find("a", href=lambda h: h and "/igraci/" in h)
        if not link or trenutni_klub_postava is None:
            continue

        ime_igraca = link.get_text(strip=True).replace(" (C)", "")
        je_kapetan = "(C)" in h3.get_text()

        dijelovi = [d.strip() for d in element.get_text(separator="\n").split("\n") if d.strip()]
        broj_dresa = next((d for d in dijelovi if d.isdigit() and len(d) <= 2), None)
        pozicija = "Vratar" if "Vratar" in dijelovi else "Igrač"

        # --- Tip događaja preko ikone ---
        # Svaka minuta (npr. "35'") ima PRIJE sebe u HTML-u jednu <div class="icon">
        # s title atributom koji govori tip: "Žuti karton", "Crveni karton",
        # "Izmjena", itd. Pratimo redoslijed: za svaki tekstualni čvor koji
        # završava apostrofom, tražimo najbližu prethodnu icon-div da odredimo tip.
        dogadjaji = []
        ikone = element.find_all("div", class_="icon")
        sirovi_tekst_cvorovi = element.find_all(string=lambda s: s and "'" in s)
        minute_tagovi = []
        for cvor in sirovi_tekst_cvorovi:
            # Izoliramo SAMO dio koji odgovara uzorku minute (npr. "51'"),
            # jer tekstualni čvor može sadržavati i drugu riječ spojenu uz njega
            # (npr. "Igrač\n51'" ako nema razdvajajućeg taga u izvornom HTML-u)
            match = re.search(r"(\d{1,3}'(?:\+\d{1,2}')?)", cvor)
            if match:
                minute_tagovi.append(match.group(1))
        # Uparujemo po redoslijedu - prva ikona ide s prvom minutom, itd.
        # (ovo pretpostavlja da je broj ikona == broj minuta, što očekujemo
        # na temelju strukture stranice; ako se ne poklapa, minuta ostaje
        # bez poznatog tipa kao sigurnosna mjera)
        for idx, minuta_tekst in enumerate(minute_tagovi):
            tip = ikone[idx].get("title", "Nepoznato") if idx < len(ikone) else "Nepoznato"
            dogadjaji.append({"minuta": minuta_tekst, "tip": tip})

        igrac_podaci = {
            "igrac": ime_igraca,
            "broj": broj_dresa,
            "pozicija": pozicija,
            "kapetan": je_kapetan,
            "pricuvni": je_pricuvni,
            "dogadjaji": dogadjaji,
        }

        if trenutni_klub_postava == "domacin":
            domacin_postava.append(igrac_podaci)
        else:
            gost_postava.append(igrac_podaci)

    return {
        "hns_url": utakmica_url,
        "domacin": domacin,
        "gost": gost,
        "rezultat": rezultat,
        "stadion_datum": stadion_datum,
        "gledatelja": gledatelja,
        "suci": suci,
        "strijelci": strijelci,
        "postava_domacin": domacin_postava,
        "postava_gost": gost_postava,
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

        utakmice_s_kolima = dohvati_popis_utakmica(natjecanje["url"])
        ukupno = len(utakmice_s_kolima)

        for i, stavka in enumerate(utakmice_s_kolima, start=1):
            link = stavka["url"]
            kolo = stavka["kolo"]
            try:
                detalji = dohvati_detalje_utakmice(link)
                detalji["natjecanje"] = natjecanje["naziv"]
                detalji["kolo"] = kolo
                spremi_u_supabase(detalji)
                ukupno_spremljeno += 1
                print(f"  [{i}/{ukupno}] (kolo {kolo}) {detalji['domacin']} - {detalji['gost']} ({detalji['rezultat']}): spremljeno")
            except Exception as greska:
                ukupno_gresaka += 1
                print(f"  [{i}/{ukupno}] GREŠKA na {link}: {greska}")
            time.sleep(1)

    print(f"\n{'=' * 60}")
    print(f"GOTOVO! Spremljeno/ažurirano {ukupno_spremljeno} utakmica. Grešaka: {ukupno_gresaka}.")
    print("=" * 60)

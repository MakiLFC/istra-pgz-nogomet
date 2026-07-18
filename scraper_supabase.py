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


# ---------------------------------------------------------------------------
# TIP DOGAĐAJA U POSTAVI (gol / karton / izmjena) — ČITA SE DIREKTNO IZ HTML-a
# ---------------------------------------------------------------------------
# Svaki događaj uz igrača je <li> unutar <div class="matchEvents"><ul class="events">.
# Tip je zapisan i u KLASI tog <li> i u TITLE atributu ikone unutar njega, npr.:
#   <li class="yellow">         <div class="icon" title="Žuti karton"></div> 2'
#   <li class="red">            <div class="icon" title="Crveni karton"></div> 71'
#   <li class="substitutionOut"><div class="icon" title="Izmjena"></div>      62'
#   <li class="substitutionIn"> <div class="icon" title="Izmjena"></div>      62'
#   <li class="goal">           <div class="icon" title="Gol"></div>          12'
# Znači tip NE moramo pogađati — čitamo ga izravno. 100% točno, uklj. crveni karton.

def _norm_min(m):
    """ "45+1'" -> "45+1", "12'" -> "12" (za usporedbu minuta sa strijelcima)."""
    return m.strip().rstrip("'").strip()


def _tokeni_imena(ime):
    ime = ime.replace("(C)", "")
    return {t for t in re.split(r"\s+", ime.strip().lower()) if t}


def _ista_osoba(ime_a, ime_b):
    """Tolerantno poklapanje imena: "Antić" ~ "Sebastijan Antić" (podskup tokena)."""
    ta, tb = _tokeni_imena(ime_a), _tokeni_imena(ime_b)
    if not ta or not tb:
        return False
    return ta <= tb or tb <= ta


def odredi_tip_dogadjaja(klase, title):
    """
    Vraća tip događaja iz klase <li> i title-a ikone.
    Mogući tipovi:
      "gol" | "karton_zuti" | "karton_crveni" | "karton_zutocrveni"
      | "izmjena_izlazak" | "izmjena_ulazak" | "nepoznato"
    """
    k = " ".join(klase).lower()
    t = (title or "").lower()

    if "goal" in k or "gol" in t:
        return "gol"
    if "substitutionout" in k:
        return "izmjena_izlazak"
    if "substitutionin" in k:
        return "izmjena_ulazak"
    # kartoni (redoslijed bitan: prvo žuto-crveni pa tek onda pojedinačni)
    if "yellowred" in k or "secondyellow" in k or ("žut" in t and "crven" in t):
        return "karton_zutocrveni"
    if "red" in k or "crven" in t:
        return "karton_crveni"
    if "yellow" in k or "žut" in t or "zut" in t:
        return "karton_zuti"
    # rezerva: ako je samo "Izmjena" bez smjera u klasi
    if "izmjen" in t:
        return "izmjena_izlazak"
    return "nepoznato"

# Sva četiri natjecanja koja pratimo - naziv koji ćemo spremiti u bazu,
# i ID/URL natjecanja na Semaforu (iz naše datoteke natjecanja.json)
# VAŽNO: kad počne nova sezona (npr. srpanj/kolovoz 2026. za 2026/27),
# promijeni ovu vrijednost PRIJE pokretanja scrapera. Stari podaci ostaju
# u bazi pod starom sezonom - ništa se ne briše, samo dodaje novi sloj
# podataka koji se na stranici odabire preko selektora sezone.
SEZONA = "2025/26"

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

    # --- STRIJELCI ---
    # Stvarna HTML struktura (potvrđena iz DevTools inspektora):
    # Strijelci su u <div class="events events_main"> na vrhu stranice.
    # Svaki gol je <li> koji sadrži:
    #   - <div class="event goal"> (oznaka tipa - gol)
    #   - <div class="playerName"> (ime strijelca)
    #   - minutu kao tekstualni čvor (npr. "45+1'")
    # Ovo je POTPUNO ODVOJENA struktura od postave (<div class="block matchLineup">)
    # pa nema opasnosti od miješanja.
    strijelci = []
    events_main = soup.find("div", class_="events_main")
    if events_main:
        for li in events_main.find_all("li"):
            # Provjeri da je ovo gol (ne izmjena, karton i sl.)
            event_div = li.find("div", class_="event")
            if not event_div or "goal" not in (event_div.get("class") or []):
                continue

            # Izvuci ime strijelca iz div.playerName
            player_name_div = li.find("div", class_="playerName")
            if not player_name_div:
                continue
            ime = player_name_div.get_text(strip=True)
            if not ime:
                continue

            # Izvuci minutu iz teksta li elementa (bez teksta iz divova)
            li_tekst = li.get_text(separator=" ", strip=True)
            match = re.search(r"(\d{1,3}(?:\+\d{1,2})?')", li_tekst)
            if not match:
                continue
            minuta = match.group(1)

            strijelci.append({"igrac": ime, "minuta": minuta})

    # --- POSTAVE (oba kluba) ---
    # Svaki igrač u postavi je h3 > a[href*="/igraci/"]. Roditeljski "li" blok
    # sadrži i broj dresa (prvi broj u bloku), poziciju ("Vratar"/"Igrač"),
    # oznaku kapetana "(C)" ako postoji, te događaje (gol/karton/izmjena) koje
    # čitamo direktno iz <div class="matchEvents"> — tip je u klasi i title-u.
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

        # --- Događaji uz igrača u postavi (gol/karton/izmjena) ---
        # Čitamo ih DIREKTNO iz <div class="matchEvents"><ul class="events">.
        # Svaki <li> nosi tip u svojoj klasi i u title-u ikone (vidi
        # odredi_tip_dogadjaja). 100% točno, uključujući crveni karton.
        dogadjaji = []
        match_events = element.find("div", class_="matchEvents")
        if match_events:
            for ev_li in match_events.find_all("li"):
                klase = ev_li.get("class") or []
                ikona = ev_li.find("div", class_="icon")
                title = ikona.get("title", "") if ikona else ""

                ev_tekst = ev_li.get_text(separator=" ", strip=True)
                m = re.search(r"(\d{1,3}(?:\+\d{1,2})?')", ev_tekst)
                if not m:
                    continue
                minuta = m.group(1)

                tip = odredi_tip_dogadjaja(klase, title)
                # sigurnosna mreža: ako tip nije prepoznat, a igrač+minuta su
                # u listi strijelaca -> to je gol
                if tip == "nepoznato":
                    mk = _norm_min(minuta)
                    if any(_ista_osoba(ime_igraca, s["igrac"])
                           for s in strijelci if _norm_min(s["minuta"]) == mk):
                        tip = "gol"

                dogadjaji.append({"minuta": minuta, "tip": tip})

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

    # --- NADOPUNA STRIJELACA GOLOVIMA IZ POSTAVE ---
    # events_main (izvor za naslov) ponekad preskoči poneki gol, dok ga
    # matchEvents u postavi ima. Postava je potpun i pouzdan izvor, pa svaki
    # gol iz postave koji NIJE već u listi strijelaca dodajemo - tako se
    # rezultat/strijelci u naslovu i oznake u postavi nikad ne raziđu.
    for postava in (domacin_postava, gost_postava):
        for igrac in postava:
            for d in igrac["dogadjaji"]:
                if d["tip"] != "gol":
                    continue
                vec_postoji = any(
                    _norm_min(s["minuta"]) == _norm_min(d["minuta"])
                    and _ista_osoba(s["igrac"], igrac["igrac"])
                    for s in strijelci
                )
                if not vec_postoji:
                    strijelci.append({"igrac": igrac["igrac"], "minuta": d["minuta"]})

    # posloži strijelce po minuti (za uredan prikaz u naslovu)
    strijelci.sort(key=lambda s: int(re.match(r"\d+", _norm_min(s["minuta"])).group()) if re.match(r"\d+", _norm_min(s["minuta"])) else 0)

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
                detalji["sezona"] = SEZONA
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

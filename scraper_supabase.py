"""
scraper_supabase.py

Glavna verzija scrapera - dohvaća utakmice s HNS Semafora i sprema ih
DIREKTNO u Supabase bazu, umjesto u lokalnu JSON datoteku.

Koristi iste provjerene funkcije za parsiranje kao scraper_test.py.

KAKO POKRENUTI:
    python scraper_supabase.py
"""

import argparse
import json
import sys
import requests
from bs4 import BeautifulSoup
import time
import os
import re
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()  # učitava SUPABASE_URL i SUPABASE_SERVICE_KEY iz .env datoteke

# ---------------------------------------------------------------------------
# POSTAVKE POKRETANJA
# ---------------------------------------------------------------------------
# Zadano ponašanje je nepromijenjeno: bez ijedne zastavice scraper radi
# točno ono što je radio i prije, pa GitHub Actions ne treba dirati.
#
#   --dry-run              ništa se ne upisuje u bazu, samo se ispisuje
#                          što BI se upisalo (ili DRY_RUN=1 u okolini)
#   --json datoteka.json   uz dry-run spremi pune retke u datoteku, radi
#                          usporedbe s onim što je već u bazi
#   --natjecanje "3. NL"   obradi samo natjecanja čiji naziv sadrži taj tekst
#   --url ADRESA           obradi JEDNU zadanu adresu natjecanja (za probu
#                          nad prošlom sezonom); ide uz --natjecanje i --sezona
#   --sezona "2025/26"     upiši drugu sezonu od zadane u SEZONA
#   --kolo 15              obradi samo to kolo (brže i blaže prema HNS-u)
#
# PRIMJER regresijske provjere nad završenim kolom prošle sezone:
#   python scraper_supabase.py --dry-run --kolo 15 \
#       --sezona "2025/26" --natjecanje "3. NL Zapad" \
#       --url "https://semafor.hns.family/natjecanja/.../treca-nl-zapad-2526/"
POSTAVKE = {
    "dry_run": os.environ.get("DRY_RUN") == "1",
    "json": None,
}

# Klijent se stvara TEK kad zatreba. Tako dry-run radi i na računalu bez
# ključeva u .env datoteci, a i sam propust ključa se vidi kao jasna
# poruka umjesto kao rušenje pri učitavanju datoteke.
_supabase = None


def klijent():
    global _supabase
    if _supabase is None:
        nedostaje = [k for k in ("SUPABASE_URL", "SUPABASE_SERVICE_KEY")
                     if not os.environ.get(k)]
        if nedostaje:
            raise RuntimeError(
                "Nedostaju postavke: " + ", ".join(nedostaje) +
                ". Upiši ih u .env datoteku ili pokreni s --dry-run."
            )
        _supabase = create_client(
            os.environ["SUPABASE_URL"],
            os.environ["SUPABASE_SERVICE_KEY"],
        )
    return _supabase

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
SEZONA = "2026/27"

NATJECANJA = [
    {
        "naziv": "3. NL Zapad",
        "url": "https://semafor.hns.family/natjecanja/114647051/treca-nl-zapad-2627/",
    },
    {
        "naziv": "4. NL NS Rijeka",
        "url": "https://semafor.hns.family/natjecanja/114651788/4-nl-ns-rijeka-2627/",
    },

    # ------------------------------------------------------------------
    # ŽUPANIJSKE LIGE ZA 2026/27 - JOŠ NISU OBJAVLJENE (stanje: kolovoz 2026)
    #
    # NS PGŽ ih obično unese kasnije od regionalnih liga. Kad se pojave:
    #   1. semafor.hns.family -> Sezona: 2026/27 -> Razina: ŽNS primorsko-goranski
    #   2. odaberi ligu, klikni Traži, kopiraj adresu (mora sadržavati -2627)
    #   3. odkomentiraj blokove ispod i zalijepi adrese
    #
    # OPREZ: nazivi "1. ŽNL" i "2. ŽNL" koriste se u SVIM županijama.
    # Prije upisa provjeri da su na stranici NAŠI klubovi (Risnjak, Goranka,
    # Mrkopalj, Rječina, Stari grad Rijeka...). Jednom je po nazivu greškom
    # upisana bjelovarsko-bilogorska liga.
    # ------------------------------------------------------------------
    # {
    #     "naziv": "1. ŽNL PGŽ",
    #     "url": "OVDJE ZALIJEPI ADRESU ZA 26/27",
    # },
    # {
    #     "naziv": "2. ŽNL PGŽ",
    #     "url": "OVDJE ZALIJEPI ADRESU ZA 26/27",
    # },
]


RE_KOLO = re.compile(r"^(\d+)\.\s*kolo$")
RE_DATUM = re.compile(r"(\d{2}\.\d{2}\.\d{4}\.)\s*(\d{1,2}:\d{2})?")

# Naslovi sekcija koje na stranici natjecanja DOLAZE POSLIJE rasporeda.
# Na njima parsiranje rasporeda mora stati. Vidi CLAUDE.md: u sekciji
# "Klubovi u natjecanju" svaka se utakmica pojavljuje po drugi put, ali
# ondje nema naslova "X. kolo", pa bi joj se pripisalo zadnje viđeno kolo
# i upisala bi se kao nova utakmica s krivim kolom.
KRAJ_RASPOREDA = ("ljestvica", "statistika", "klubovi u natjecanju")


def _je_kraj_rasporeda(tekst):
    """Je li tekst elementa točno naslov sekcije koja slijedi nakon rasporeda."""
    return " ".join(tekst.split()).casefold() in KRAJ_RASPOREDA


def dohvati_popis_utakmica(natjecanje_url):
    """
    Otvara stranicu natjecanja i vraća listu utakmica CIJELOG rasporeda -
    odigranih i neodigranih. Kolo se prati tako što HNS stranica prikazuje
    naslov "X. kolo" kao poseban element PRIJE utakmica koje mu pripadaju -
    mi idemo kroz dokument redom i pamtimo "trenutno kolo" sve dok se ne
    pojavi sljedeći "X. kolo" naslov.

    Neodigrane utakmice NEMAJU poveznicu na zapisnik (na mjestu rezultata
    stoji "- : -"), pa se za njih čitaju samo domaćin/gost/datum/vrijeme/
    stadion s retka rasporeda - vidi CLAUDE.md.

    Vraća listu rječnika: kolo, domacin, gost, datum, vrijeme, stadion,
    hns_url (None ako zapisnik još ne postoji), rezultat (None ako se
    utakmica još nije odigrala).
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
    vidjeni_kljucevi = set()

    # Prolazimo kroz SVE elemente nakon "Raspored..." naslova, redom kako
    # se pojavljuju u dokumentu (find_all_next vraća ih u pravom redoslijedu).
    #
    # Namjerno BEZ filtra po imenu oznake: naslov na kojem raspored
    # završava zna biti <h2>, a utakmice su u <li>/<div>/<span>. Da smo
    # tražili samo te tri oznake, naslov bismo preskočili i nastavili
    # čitati sekcije ispod rasporeda.
    for element in pocetna_tocka.find_all_next(True):
        tekst = element.get_text(strip=True)

        # Kraj rasporeda: dalje slijede ljestvica, statistika i popis
        # klubova, u kojima se iste utakmice pojavljuju po drugi put.
        # Uvjet gađa SAM naslov: omotač cijele sekcije ima puno više
        # teksta od jedne riječi, pa se na njemu ne okida.
        if _je_kraj_rasporeda(tekst):
            break

        if element.name not in ("li", "div", "span"):
            continue

        # Prepoznajemo naslov kola: kratki tekst poput "1. kolo", "12. kolo"
        match_kolo = RE_KOLO.match(tekst)
        if match_kolo:
            trenutno_kolo = int(match_kolo.group(1))
            continue

        klub_linkovi = element.find_all("a", href=lambda h: h and "/klubovi/" in h)
        if len(klub_linkovi) != 2:
            continue
        # uzmi NAJUŽI element koji sadrži točno dva kluba (izbjegni dvostruko
        # brojanje istog para kroz ugniježđene div/li omotače)
        if element.find(lambda t: t.name in ("li", "div")
                         and t is not element
                         and len(t.find_all("a", href=lambda h: h and "/klubovi/" in h)) == 2):
            continue

        domacin = klub_linkovi[0].get_text(strip=True)
        gost = klub_linkovi[1].get_text(strip=True)
        if not domacin or not gost or domacin == gost:
            continue

        link_utakmice = element.find("a", href=lambda h: h and "/utakmice/" in h)
        hns_url = link_utakmice["href"] if link_utakmice else None
        rezultat = None
        if link_utakmice:
            rt = link_utakmice.get_text(strip=True)
            if re.match(r"^\d{1,2}\s*:\s*\d{1,2}$", rt):
                rezultat = rt.replace(" ", "")

        cijeli_tekst = element.get_text(" ", strip=True)
        md = RE_DATUM.search(cijeli_tekst)
        datum = md.group(1) if md else None
        vrijeme = md.group(2) if md and md.group(2) else None

        # stadion: zadnji tekstualni redak koji nije ime kluba/datum/rezultat
        stadion = None
        for dio in reversed([d.strip() for d in element.get_text("\n").split("\n") if d.strip()]):
            if dio in (domacin, gost):
                continue
            if RE_DATUM.search(dio) or re.match(r"^[\d\s:-]+$", dio):
                continue
            if dio.startswith("http"):
                continue
            stadion = dio
            break

        # izbjegni duplikate (ista utakmica se zna pojaviti u više blokova
        # na stranici, npr. i u "Klubovi u natjecanju")
        kljuc = (trenutno_kolo, domacin, gost)
        if kljuc in vidjeni_kljucevi:
            continue
        vidjeni_kljucevi.add(kljuc)

        utakmice.append({
            "kolo": trenutno_kolo, "domacin": domacin, "gost": gost,
            "datum": datum, "vrijeme": vrijeme, "stadion": stadion,
            "hns_url": hns_url, "rezultat": rezultat,
        })

    print(f"Pronađeno {len(utakmice)} jedinstvenih utakmica "
          f"({sum(1 for u in utakmice if u['hns_url'])} s zapisnikom).")
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

    # Redak zapisnika izgleda npr. "Gradski stadion, Crikvenica, 29.08.2026. 17:30".
    # Ranije se tražila DOSLOVNA godina (".2025." ili ".2026."), pa bi prva
    # utakmica odigrana 2027. ostala bez stadiona i datuma - sad se prepoznaje
    # bilo koja godina i ništa se ne mora dirati na prijelazu sezone.
    # Kad retka nema, upisuje se None (prazno), NE "Nepoznato" - stranica tad
    # sama pokaže termin s rasporeda umjesto te riječi.
    stadion_datum = None
    for linija in linije:
        if RE_DATUM.search(linija) and "," in linija:
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
    s istim ključem već postoji, AŽURIRA postojeći redak umjesto da stvori
    duplikat. Ovo je važno jer ćemo scraper pokretati VIŠE PUTA (npr. svaki
    dan) i ne želimo da se ista utakmica spremi 10 puta.

    Ključ je (natjecanje, sezona, kolo, domaćin, gost), NE hns_url - jer
    neodigrane utakmice nemaju hns_url (nema zapisnika dok se ne odigraju).
    Kad utakmica dobije zapisnik, isti redak (prepoznat po istom ključu)
    se samo nadopuni rezultatom, postavama i strijelcima - ne dupla se.
    Zato se domaćin/gost UVIJEK uzimaju s retka rasporeda (vidi
    dohvati_popis_utakmica), ne s naslova stranice zapisnika - da ključ
    ostane isti prije i poslije odigravanja utakmice.
    """
    if POSTAVKE["dry_run"]:
        _zabiljezi_probni_redak(redak)
        return

    klijent().table("utakmice").upsert(
        redak, on_conflict="natjecanje,sezona,kolo,domacin,gost"
    ).execute()


# Redci skupljeni tijekom dry-run pokretanja, za ispis u datoteku na kraju.
PROBNI_REDCI = []
PROBNE_STATISTIKE = []


def _zabiljezi_probni_redak(redak):
    """U dry-run načinu redak se ne šalje u bazu nego se sažme na zaslon,
    a puni sadržaj ostaje sa strane za usporedbu s bazom.

    Sažetak se ispisuje samo za utakmice sa zapisnikom. Kod neodigranih
    nema se što provjeriti, a ispis od dvjesto praznih redaka samo bi
    zatrpao ono što treba pogledati."""
    PROBNI_REDCI.append(redak)
    if redak.get("rezultat") or redak.get("strijelci") or redak.get("postava_domacin"):
        print("        " + _sazetak_retka(redak))


def _sazetak_retka(redak):
    """Jedan redak ispisa: ono po čemu se vidi je li parsiranje ispravno."""
    strijelci = redak.get("strijelci") or []
    postave = (redak.get("postava_domacin") or []) + (redak.get("postava_gost") or [])
    broj = {"gol": 0, "karton_zuti": 0, "karton_crveni": 0,
            "karton_zutocrveni": 0, "izmjena_ulazak": 0, "izmjena_izlazak": 0,
            "nepoznato": 0}
    for igrac in postave:
        for dogadjaj in igrac.get("dogadjaji") or []:
            tip = dogadjaj.get("tip", "nepoznato")
            broj[tip] = broj.get(tip, 0) + 1
    dijelovi = [
        f"rezultat={redak.get('rezultat')}",
        f"strijelaca={len(strijelci)}",
        f"golova_u_postavi={broj['gol']}",
        f"žuti={broj['karton_zuti']}",
        f"crveni={broj['karton_crveni']}",
        f"žuto-crveni={broj['karton_zutocrveni']}",
        f"izmjene={broj['izmjena_ulazak']}/{broj['izmjena_izlazak']}",
        f"postave={len(redak.get('postava_domacin') or [])}"
        f"/{len(redak.get('postava_gost') or [])}",
        f"gledatelja={redak.get('gledatelja')}",
        f"suci={redak.get('suci')}",
    ]
    if broj["nepoznato"]:
        dijelovi.append(f"NEPREPOZNATIH DOGAĐAJA={broj['nepoznato']}")
    return "  ".join(dijelovi)


# ---------------------------------------------------------------------------
# TABLICA LIGE + RANG-LISTE (strijelci, kartoni) — sa stranice natjecanja
# ---------------------------------------------------------------------------
# Struktura potvrđena na stvarnom HTML-u (srpanj 2026.):
#  - Tablica: <div class="competition_table"> -> li po klubu, ćelije s klasama
#    position/played/wins/draws/losses/gplus/gminus/gdiff/points.
#    Kazneni bodovi su VEĆ uračunati (klub npr. "NK Gomirje (-4)").
#  - Rang-liste: li.row s playerName (h3 = ime, ostatak = klub) + goals ILI
#    cards ("7 / 2" = žuti/crveni). Na istoj stranici su i SASTAVI klubova
#    (klub = "Vratar"/"Igrač", imaju shirtNumber) i mini-rang po klubu
#    (prazan klub) — te preskačemo. Rang nastupa (apps_minutes) preskačemo.

def parsiraj_tablicu_lige(soup):
    blok = soup.find("div", class_="competition_table")
    if not blok:
        return []
    tablica = []
    for li in blok.find_all("li"):
        klub_link = li.find("a", href=lambda h: h and "/klubovi/" in h)
        if not klub_link:
            continue

        def cell(k):
            d = li.find("div", class_=k)
            return d.get_text(strip=True) if d else None

        tablica.append({
            "pozicija": cell("position"),
            "klub": klub_link.get_text(strip=True),
            "odigrano": cell("played"),
            "pobjede": cell("wins"),
            "remiji": cell("draws"),
            "porazi": cell("losses"),
            "golovi_dani": cell("gplus"),
            "golovi_primljeni": cell("gminus"),
            "gol_razlika": cell("gdiff"),
            "bodovi": cell("points"),
        })
    return tablica


def parsiraj_rang_nastupa(soup):
    """
    Službena rang-lista nastupa i minuta, ona koju parsiraj_rang_liste
    preskače. Koristi se samo ako u sastavima klubova tog podatka nema.
    Vraća listu rječnika: igrac, klub, nastupi, minute.
    """
    lista = []
    for li in soup.find_all("li", class_="row"):
        if not li.find("div", class_="apps_minutes"):
            continue
        if li.find("div", class_="shirtNumber"):
            continue  # to je sastav kluba, njega čita parsiraj_sve_igrace
        ime_div = li.find("div", class_="playerName")
        if not ime_div:
            continue
        h3 = ime_div.find("h3")
        if not h3:
            continue
        ime = h3.get_text(strip=True)
        klub = ime_div.get_text(" ", strip=True).replace(ime, "").strip()
        if not klub or klub in ("Vratar", "Igrač"):
            continue

        nastupi, minute = _nastupi_i_minute(li)
        if nastupi is None and minute is None:
            continue
        lista.append({"igrac": ime, "klub": klub,
                      "nastupi": nastupi, "minute": minute})
    return lista


def parsiraj_rang_liste(soup):
    strijelci, kartoni = [], []
    for li in soup.find_all("li", class_="row"):
        ime_div = li.find("div", class_="playerName")
        if not ime_div:
            continue
        h3 = ime_div.find("h3")
        if not h3:
            continue
        ime = h3.get_text(strip=True)
        klub = ime_div.get_text(" ", strip=True).replace(ime, "").strip()
        if not klub or klub in ("Vratar", "Igrač"):
            continue  # sastav kluba ili mini-rang unutar kluba
        if li.find("div", class_="shirtNumber"):
            continue  # sastav kluba
        if li.find("div", class_="apps_minutes"):
            continue  # rang nastupa - ne treba nam

        pos = li.find("div", class_="position")
        pozicija = pos.get_text(strip=True) if pos else ""
        goals = li.find("div", class_="goals")
        cards = li.find("div", class_="cards")
        if goals:
            strijelci.append({"pozicija": pozicija, "igrac": ime, "klub": klub,
                              "golovi": goals.get_text(strip=True)})
        elif cards:
            m = re.match(r"(\d+)\s*/\s*(\d+)", cards.get_text(strip=True))
            zuti, crveni = (m.group(1), m.group(2)) if m else ("0", "0")
            kartoni.append({"pozicija": pozicija, "igrac": ime, "klub": klub,
                            "zuti": zuti, "crveni": crveni})
    return strijelci, kartoni


def _broj(tekst):
    try:
        return int(re.sub(r"[^\d]", "", tekst or "") or 0)
    except ValueError:
        return 0


def _brojevi(tekst):
    """
    Cijeli brojevi iz teksta, uz razdjelnik tisućica.

    HNS piše minute s točkom: "2.700" znači 2700, a ne 2 i 700. Bez
    micanja točke ispalo bi da je igrač odigrao dvije minute (provjereno
    na stranici 3. NL Zapad 2025/26).
    """
    return [int(b) for b in re.findall(r"\d+", (tekst or "").replace(".", ""))]


def _nastupi_i_minute(li):
    """
    Nastupi i odigrane minute iz retka, ako ih stranica nudi.

    Dva su oblika, oba viđena na stranici natjecanja:
      - u sastavu kluba, dva odvojena bloka: <div class="apps">30</div>
        i <div class="minutes">2.700</div>
      - u kratkoj rang-listi nastupa, jedan blok:
        <div class="apps_minutes">30 / 2.700</div>

    Vraća (nastupi, minute); svaki može biti None. Kad podatka nema,
    vraća se None, a ne nula, da se prazno ne bi prikazalo kao "0 minuta".
    """
    apps = li.find("div", class_="apps")
    minutes = li.find("div", class_="minutes")
    if apps or minutes:
        n = _brojevi(apps.get_text(strip=True)) if apps else []
        m = _brojevi(minutes.get_text(strip=True)) if minutes else []
        return (n[0] if n else None), (m[0] if m else None)

    blok = li.find("div", class_="apps_minutes")
    if not blok:
        return None, None
    brojevi = _brojevi(blok.get_text(" ", strip=True))
    nastupi = brojevi[0] if len(brojevi) >= 1 else None
    minute = brojevi[1] if len(brojevi) >= 2 else None
    return nastupi, minute


def parsiraj_sve_igrace(soup):
    """
    Svi igrači iz SASTAVA klubova na stranici lige (ne samo top 5).
    Redak sastava prepoznajemo po div.shirtNumber.

    VAŽNO: kod VRATARA stupac 'goals' NIJE broj zabijenih nego PRIMLJENIH
    golova (provjereno: vratar Turbine ima 50, a Turbina je po tablici
    primila točno 50). Zato vratare izbacujemo iz liste strijelaca,
    ali ih zadržavamo u kartonima.
    """
    igraci = []
    for li in soup.find_all("li", class_="row"):
        if not li.find("div", class_="shirtNumber"):
            continue
        ime_div = li.find("div", class_="playerName")
        if not ime_div:
            continue
        h3 = ime_div.find("h3")
        if not h3:
            continue
        ime = h3.get_text(strip=True)
        uloga = ime_div.get_text(" ", strip=True).replace(ime, "").strip()

        # Klub = najbliži PRETHODNI link kluba koji nije u tablici poretka
        klub = None
        for a in li.find_all_previous("a", href=lambda h: h and "/klubovi/" in h):
            if a.find_parent("div", class_="competition_table"):
                continue
            klub = a.get_text(strip=True)
            break

        golovi_div = li.find("div", class_="goals")
        cards_div = li.find("div", class_="cards")
        zuti = crveni = 0
        if cards_div:
            m = re.match(r"(\d+)\s*/\s*(\d+)", cards_div.get_text(strip=True))
            if m:
                zuti, crveni = int(m.group(1)), int(m.group(2))

        nastupi, minute = _nastupi_i_minute(li)

        igraci.append({
            "igrac": ime,
            "klub": klub,
            "vratar": uloga == "Vratar",
            "golovi": _broj(golovi_div.get_text(strip=True)) if golovi_div else 0,
            "zuti": zuti,
            "crveni": crveni,
            "nastupi": nastupi,
            "minute": minute,
        })
    return igraci


def slozi_pune_rang_liste(igraci, koliko=40):
    """Iz sastava složi punu listu strijelaca i kartona (do 'koliko' igrača)."""
    s = [i for i in igraci if not i["vratar"] and i["golovi"] > 0]
    s.sort(key=lambda i: (-i["golovi"], i["igrac"]))
    strijelci = [{"pozicija": str(n + 1), "igrac": i["igrac"], "klub": i["klub"],
                  "golovi": str(i["golovi"])} for n, i in enumerate(s[:koliko])]

    k = [i for i in igraci if i["zuti"] or i["crveni"]]
    k.sort(key=lambda i: (-i["crveni"], -i["zuti"], i["igrac"]))
    kartoni = [{"pozicija": str(n + 1), "igrac": i["igrac"], "klub": i["klub"],
                "zuti": str(i["zuti"]), "crveni": str(i["crveni"])}
               for n, i in enumerate(k[:koliko])]
    return strijelci, kartoni


def slozi_listu_nastupa(igraci, rezerva, koliko=2000):
    """
    Lista nastupa i minuta, poredana po minutama.

    Prvi izvor su sastavi klubova, jer pokrivaju SVE igrače lige (u
    3. NL Zapad njih oko 500). Ako ondje podatka nema, uzima se službena
    rang-lista, koja donosi samo prvih nekoliko.

    Za razliku od strijelaca i kartona, ova se lista ne skraćuje: ne
    prikazuje se u bočnom stupcu, nego služi kao popis igrača za njihove
    stranice, pa svako skraćivanje znači igrača bez stranice.
    """
    iz_sastava = [i for i in igraci
                  if i.get("nastupi") is not None or i.get("minute") is not None]
    izvor = iz_sastava if iz_sastava else rezerva

    n = [i for i in izvor if i.get("klub")]
    n.sort(key=lambda i: (-(i.get("minute") or 0), -(i.get("nastupi") or 0),
                          i["igrac"]))
    return [{"pozicija": str(r + 1), "igrac": i["igrac"], "klub": i["klub"],
             "nastupi": "" if i.get("nastupi") is None else str(i["nastupi"]),
             "minute": "" if i.get("minute") is None else str(i["minute"])}
            for r, i in enumerate(n[:koliko])]


def dohvati_i_spremi_statistike(natjecanje_naziv, natjecanje_url):
    """Dohvaća tablicu + PUNE rang-liste sa stranice natjecanja i sprema u
    Supabase tablicu 'statistike' (jedan redak po ligi i tipu, upsert)."""
    response = requests.get(natjecanje_url, headers=HEADERS, timeout=15)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "html.parser")

    tablica = parsiraj_tablicu_lige(soup)

    # Pune liste iz sastava klubova (desetci igrača, ne samo top 5)
    svi_igraci = parsiraj_sve_igrace(soup)
    strijelci, kartoni = slozi_pune_rang_liste(svi_igraci)

    # SAMOPROVJERA: usporedi naš izračun sa službenom HNS top 5 listom.
    # Ako se vrh poklapa, agregacija iz sastava je pouzdana.
    sluzbeni, _ = parsiraj_rang_liste(soup)
    if sluzbeni and strijelci:
        nas = [(s["igrac"], s["golovi"]) for s in strijelci[:3]]
        njihov = [(s["igrac"], s["golovi"]) for s in sluzbeni[:3]]
        provjera = ("poklapa se sa službenom listom ✓" if nas == njihov
                    else f"NE POKLAPA SE! naše={nas} službeno={njihov}")
    else:
        provjera = "nije bilo s čim usporediti"

    nastupi = slozi_listu_nastupa(svi_igraci, parsiraj_rang_nastupa(soup))

    for tip, podaci in (("tablica", tablica),
                        ("strijelci", strijelci),
                        ("kartoni", kartoni),
                        ("nastupi", nastupi)):
        redak = {"sezona": SEZONA, "natjecanje": natjecanje_naziv,
                 "tip": tip, "podaci": podaci}
        if POSTAVKE["dry_run"]:
            PROBNE_STATISTIKE.append(redak)
            continue
        klijent().table("statistike").upsert(
            redak, on_conflict="sezona,natjecanje,tip",
        ).execute()
    s_minuta = sum(1 for i in nastupi if i["minute"])
    print(f"  STATISTIKE: tablica={len(tablica)} klubova, "
          f"strijelci={len(strijelci)}, kartoni={len(kartoni)}, "
          f"nastupi={len(nastupi)} (s minutama: {s_minuta})"
          f" - {'BEZ UPISA' if POSTAVKE['dry_run'] else 'spremljeno'}")
    print(f"  PROVJERA strijelaca: {provjera}")


def _postavke_iz_naredbe():
    """Čita zastavice s naredbenog retka. Bez ijedne, ponašanje je isto
    kao prije: pune dvije lige, sezona iz konstante, upis u bazu."""
    p = argparse.ArgumentParser(
        description="Scraper HNS Semafora za Lokal-Arenu."
    )
    p.add_argument("--dry-run", action="store_true",
                   help="ništa ne upisuj, samo ispiši što bi se upisalo")
    p.add_argument("--json", metavar="DATOTEKA",
                   help="uz --dry-run spremi pune retke u JSON datoteku")
    p.add_argument("--natjecanje", metavar="TEKST",
                   help="obradi samo natjecanja čiji naziv sadrži taj tekst")
    p.add_argument("--url", metavar="ADRESA",
                   help="adresa natjecanja umjesto one iz popisa "
                        "(za probu nad prošlom sezonom)")
    p.add_argument("--sezona", metavar="SEZONA",
                   help=f"sezona koja se upisuje (zadano: {SEZONA})")
    p.add_argument("--kolo", type=int, metavar="BROJ",
                   help="obradi samo to kolo")
    return p.parse_args()


def _odabrana_natjecanja(args):
    """Popis natjecanja za ovo pokretanje, nakon --natjecanje i --url."""
    odabrana = NATJECANJA
    if args.natjecanje:
        trazeno = args.natjecanje.casefold()
        odabrana = [n for n in NATJECANJA if trazeno in n["naziv"].casefold()]
        if not odabrana:
            raise SystemExit(
                f"Nijedno natjecanje ne odgovara nazivu {args.natjecanje!r}. "
                f"Dostupna: {', '.join(n['naziv'] for n in NATJECANJA)}"
            )

    if args.url:
        # Vlastita adresa ima smisla samo za jedno natjecanje, inače se ne
        # bi znalo kojem pripada.
        if len(odabrana) != 1:
            raise SystemExit(
                "--url ide samo uz --natjecanje koji pogađa točno jedno "
                "natjecanje (sada ih je " + str(len(odabrana)) + ")."
            )
        odabrana = [{"naziv": odabrana[0]["naziv"], "url": args.url}]

    return odabrana


if __name__ == "__main__":
    args = _postavke_iz_naredbe()
    POSTAVKE["dry_run"] = POSTAVKE["dry_run"] or args.dry_run
    POSTAVKE["json"] = args.json
    if args.sezona:
        SEZONA = args.sezona
    if args.json and not POSTAVKE["dry_run"]:
        raise SystemExit("--json ima smisla samo uz --dry-run.")

    natjecanja_za_obradu = _odabrana_natjecanja(args)

    if POSTAVKE["dry_run"]:
        print("=" * 60)
        print("SUHI TEST: ništa se ne upisuje u bazu.")
        print(f"  sezona: {SEZONA}")
        print(f"  natjecanja: {', '.join(n['naziv'] for n in natjecanja_za_obradu)}")
        print(f"  kolo: {args.kolo if args.kolo else 'sva'}")
        print("=" * 60)

    ukupno_spremljeno = 0
    ukupno_gresaka = 0
    greske = []

    for natjecanje in natjecanja_za_obradu:
        print(f"\n{'=' * 60}")
        print(f"NATJECANJE: {natjecanje['naziv']}")
        print("=" * 60)

        utakmice_s_kolima = dohvati_popis_utakmica(natjecanje["url"])
        if args.kolo is not None:
            utakmice_s_kolima = [u for u in utakmice_s_kolima if u["kolo"] == args.kolo]
            print(f"Nakon odabira {args.kolo}. kola ostalo: {len(utakmice_s_kolima)} utakmica.")
        ukupno = len(utakmice_s_kolima)

        # Tablica lige + strijelci + kartoni (za sidebar na stranici)
        #
        # Greška se OVDJE hvata da jedna liga ne sruši ostale, ali se
        # broji i na kraju ruši cijelo pokretanje. Prije se samo
        # ispisala, pa je GitHub pokretanje ostajalo zeleno: tako je
        # tjednima prolazilo neopaženo da baza odbija tip "nastupi" i
        # da minute uopće ne ulaze.
        try:
            dohvati_i_spremi_statistike(natjecanje["naziv"], natjecanje["url"])
        except Exception as greska:
            ukupno_gresaka += 1
            greske.append(f"statistike, {natjecanje['naziv']}: {greska}")
            print(f"  GREŠKA kod statistika: {greska}")

        for i, stavka in enumerate(utakmice_s_kolima, start=1):
            try:
                if stavka["hns_url"]:
                    detalji = dohvati_detalje_utakmice(stavka["hns_url"])
                    # domaćin/gost sa stranice zapisnika mogu se sitno
                    # razlikovati od rasporeda - raspored je izvor istine
                    # za ključ (vidi napomenu u spremi_u_supabase)
                    detalji["domacin"] = stavka["domacin"]
                    detalji["gost"] = stavka["gost"]
                    poruka = f"{detalji['rezultat']}"
                else:
                    # Neodigrana utakmica: nema zapisnika, spremamo samo ono
                    # što piše na retku rasporeda.
                    #
                    # "rezultat" i "hns_url" se NAMJERNO ne šalju. Kad se
                    # stupac ne pošalje, upsert ga ne dira, pa već upisan
                    # rezultat preživi i onda ako HNS jednom ne prikaže
                    # poveznicu na zapisnik. Da su slani kao prazni, takav
                    # bi prolaz obrisao rezultat odigrane utakmice, a
                    # postave bi ostale, pa bi utakmica izgledala kao da
                    # se tek treba odigrati.
                    detalji = {
                        "domacin": stavka["domacin"],
                        "gost": stavka["gost"],
                    }
                    poruka = f"{stavka['datum']} {stavka['vrijeme'] or ''}".strip()

                detalji["natjecanje"] = natjecanje["naziv"]
                detalji["kolo"] = stavka["kolo"]
                detalji["sezona"] = SEZONA
                detalji["datum"] = stavka["datum"]
                detalji["vrijeme"] = stavka["vrijeme"]
                detalji["stadion"] = stavka["stadion"]
                ishod = "BEZ UPISA (suhi test)" if POSTAVKE["dry_run"] else "spremljeno"
                print(f"  [{i}/{ukupno}] (kolo {stavka['kolo']}) {stavka['domacin']} - {stavka['gost']} ({poruka}): {ishod}")
                spremi_u_supabase(detalji)
                ukupno_spremljeno += 1
            except Exception as greska:
                ukupno_gresaka += 1
                greske.append(
                    f"utakmica, {natjecanje['naziv']}, "
                    f"{stavka['domacin']} - {stavka['gost']}: {greska}"
                )
                print(f"  [{i}/{ukupno}] GREŠKA na {stavka.get('hns_url') or stavka['domacin']}: {greska}")
            if stavka["hns_url"]:
                time.sleep(1)

    print(f"\n{'=' * 60}")
    if POSTAVKE["dry_run"]:
        print(f"SUHI TEST GOTOV. Bilo bi upisano {ukupno_spremljeno} utakmica "
              f"i {len(PROBNE_STATISTIKE)} redaka statistike. Grešaka: {ukupno_gresaka}.")
        print("U bazu nije upisano ništa.")
        if POSTAVKE["json"]:
            with open(POSTAVKE["json"], "w", encoding="utf-8") as f:
                json.dump({"sezona": SEZONA,
                           "utakmice": PROBNI_REDCI,
                           "statistike": PROBNE_STATISTIKE},
                          f, ensure_ascii=False, indent=2)
            print(f"Puni sadržaj spremljen u datoteku: {POSTAVKE['json']}")
    else:
        print(f"GOTOVO! Spremljeno/ažurirano {ukupno_spremljeno} utakmica. Grešaka: {ukupno_gresaka}.")
    print("=" * 60)

    # Kad je išta palo, pokretanje završava neuspjehom. GitHub ga tada
    # označi crveno i pošalje poruku, umjesto da greška ostane samo u
    # zapisniku koji nitko ne otvara.
    if greske:
        print("\nŠTO JE PALO:")
        for opis in greske:
            print(f"  - {opis}")
        print("\nPokretanje je označeno kao neuspjelo zbog gornjih grešaka.")
        sys.exit(1)

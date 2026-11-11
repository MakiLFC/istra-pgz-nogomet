"""Zašto Semafor vraća 403, dijagnostika. Pokreće je posao "Zašto 403".

ČEMU SLUŽI

Od 10.11.2026. svi dohvati sa Semafora s GitHuba vraćaju
"403 Client Error: Forbidden", i to na sve četiri lige odjednom. Ista
stranica se u pregledniku na mobitelu otvara normalno, dakle HNS radi,
nego odbija automatski dohvat.

Scraper o tom odbijanju vidi samo rečenicu iz iznimke. Ono što bi nam
reklo TKO odbija i PO ČEMU stoji u zaglavljima i tijelu odgovora, a to
nitko ne ispisuje. Ovaj alat ispisuje upravo to.

ŠTO RADI

Jednu te istu stranicu dohvati s nekoliko različitih skupova zaglavlja,
jedan zahtjev po skupu, s pauzom između. Za svaki ispiše status,
zaglavlja odgovora koja nešto govore (poslužitelj, oznaka Cloudflarea,
razlog) i prvih nekoliko redaka teksta. Usput ispiše i s koje se adrese
izlazi, jer zaštite redovito blokiraju cijele raspone GitHubovih
poslužitelja, a ne pojedini zahtjev.

Iz ispisa se vidi koje je od dvoga posrijedi:

- odbija se OBLIK zahtjeva: onda neki od skupova prolazi, a naš ne
- odbija se ADRESA s koje dolazimo: onda padaju svi skupovi jednako, i
  dotjerivanje zaglavlja nema smisla

NE DIRA BAZU i ne mijenja ništa. Samo čita i ispisuje.

Namjerno NE pokušava zaobići zaštitu: pokušaja je svega nekoliko, idu
s pauzom, i među njima je i pošteno predstavljanje imenom stranice. Ako
ispadne da je HNS automatski pristup zatvorio namjerno, to se rješava
pitanjem njima, ne lukavstvom.
"""

import os
import sys
import time

import requests

ADRESA_ZADANA = "https://semafor.hns.family/natjecanja/114647051/treca-nl-zapad-2627/"

PAUZA = 5

# Zaglavlja koja u odgovoru nešto govore. Cloudflare se predstavlja kroz
# "server" i "cf-ray", a razlog blokade zna stajati u "cf-mitigated".
ZANIMLJIVA_ZAGLAVLJA = (
    "server",
    "cf-ray",
    "cf-mitigated",
    "cf-cache-status",
    "retry-after",
    "content-type",
    "x-sucuri-id",
    "x-powered-by",
)

# Oznaka kojom se scraper predstavlja danas: Chrome, i ništa osim toga.
# Pravi Chrome uz nju uvijek šalje i jezik i prihvaćeni format, pa je
# ovakav zahtjev zaštitama tipičan potpis robota.
UA_CHROME = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/120.0 Safari/537.36"
)

UA_POSTEN = "Lokal-Arena/1.0 (+https://lokalarena.com)"

POKUSAJI = (
    (
        "kao scraper danas (samo Chrome oznaka)",
        {"User-Agent": UA_CHROME},
    ),
    (
        "bez ijedne naše oznake (ono što requests šalje sam)",
        {},
    ),
    (
        "pošteno predstavljanje imenom stranice",
        {"User-Agent": UA_POSTEN},
    ),
    (
        "Chrome oznaka sa svim zaglavljima koja preglednik šalje",
        {
            "User-Agent": UA_CHROME,
            "Accept": (
                "text/html,application/xhtml+xml,application/xml;q=0.9,"
                "image/avif,image/webp,*/*;q=0.8"
            ),
            "Accept-Language": "hr-HR,hr;q=0.9,en;q=0.8",
            "Accept-Encoding": "gzip, deflate",
            "Upgrade-Insecure-Requests": "1",
            "Sec-Fetch-Dest": "document",
            "Sec-Fetch-Mode": "navigate",
            "Sec-Fetch-Site": "none",
        },
    ),
)


def ispisi_adresu():
    """S koje adrese izlazimo prema van.

    Ako zaštita blokira raspon GitHubovih poslužitelja, ovo je jedini
    podatak koji to može potvrditi, i ujedno ono što bi HNS tražio kad
    bi ih se pitalo da nas propuste.
    """
    try:
        odgovor = requests.get("https://api.ipify.org", timeout=15)
        print(f"Izlazna adresa: {odgovor.text.strip()}")
    except requests.RequestException as greska:
        # Nije bitno za samu dijagnozu, pa se ne ruši zbog toga.
        print(f"Izlazna adresa: ne može se utvrditi ({greska.__class__.__name__})")
    print()


def pocetak_teksta(odgovor, koliko=12):
    """Prvih nekoliko redaka odgovora, bez praznih."""
    try:
        tekst = odgovor.text
    except Exception:
        return ["(odgovor se ne da pročitati kao tekst)"]

    redci = [r.strip() for r in tekst.splitlines() if r.strip()]
    return redci[:koliko] or ["(prazan odgovor)"]


def probaj(opis, zaglavlja, url):
    print("=" * 60)
    print(opis)
    print("=" * 60)

    try:
        odgovor = requests.get(url, headers=zaglavlja, timeout=30)
    except requests.RequestException as greska:
        print(f"  Nije bilo odgovora: {greska.__class__.__name__}: {greska}")
        print()
        return None

    print(f"  Status: {odgovor.status_code}")
    print(f"  Veličina odgovora: {len(odgovor.content)} B")

    for ime in ZANIMLJIVA_ZAGLAVLJA:
        if ime in odgovor.headers:
            print(f"  {ime}: {odgovor.headers[ime]}")

    print("  Početak odgovora:")
    for redak in pocetak_teksta(odgovor):
        print(f"    {redak[:160]}")

    # Kad stranica prođe, ovo potvrđuje da je doista stigla ona prava, a
    # ne stranica zaštite s kodom 200.
    if odgovor.status_code == 200:
        ima_raspored = "Ljestvica" in odgovor.text or "Kolo" in odgovor.text
        print(f"  Izgleda kao prava stranica natjecanja: {'da' if ima_raspored else 'NE'}")

    print()
    return odgovor.status_code


def main():
    url = os.environ.get("ADRESA", "").strip() or ADRESA_ZADANA

    print("DIJAGNOSTIKA 403 NA SEMAFORU")
    print(f"Stranica: {url}")
    print(f"Pokušaja: {len(POKUSAJI)}, pauza između njih {PAUZA} s")
    print()

    ispisi_adresu()

    ishodi = []
    for redni, (opis, zaglavlja) in enumerate(POKUSAJI):
        if redni:
            time.sleep(PAUZA)
        ishodi.append((opis, probaj(opis, zaglavlja, url)))

    print("=" * 60)
    print("SAŽETAK")
    print("=" * 60)
    for opis, status in ishodi:
        print(f"  {status if status is not None else 'bez odgovora'}: {opis}")
    print()

    prosli = [opis for opis, status in ishodi if status == 200]
    if prosli:
        print("Barem jedan oblik zahtjeva prolazi, dakle blokira se OBLIK,")
        print("ne adresa s koje dolazimo. Prolaze:")
        for opis in prosli:
            print(f"  - {opis}")
    else:
        print("Nijedan oblik ne prolazi. To govori u prilog tome da je")
        print("blokirana ADRESA s koje dohvaćamo (GitHubovi poslužitelji),")
        print("pa dotjerivanje zaglavlja nema smisla.")

    # Ovo je dijagnostika, ne provjera ispravnosti, pa se ne završava
    # crveno ni kad sve padne: crveno bi značilo da je nešto u NAŠEM kodu
    # puklo, a ovdje je ispis cijeli rezultat.
    return 0


if __name__ == "__main__":
    sys.exit(main())

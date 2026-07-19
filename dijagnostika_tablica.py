"""
dijagnostika_tablica.py

Jednokratna provjera: kako u SIROVOM HTML-u stranice natjecanja izgledaju
(1) tablica poretka (Poredak) i (2) lista najboljih strijelaca.
Na temelju ispisa pišemo parser za tablicu i strijelce.

Pokreni:  python dijagnostika_tablica.py
Zatim zalijepi CIJELI ispis natrag u chat.
"""

import re
import requests
from bs4 import BeautifulSoup

# 3. NL Zapad - ista liga koju smo koristili za sve dosadašnje provjere
URL = "https://semafor.hns.family/natjecanja/100585203/treca-nl-zapad-2526/"
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/120.0 Safari/537.36"
}

html = requests.get(URL, headers=HEADERS, timeout=15).text
soup = BeautifulSoup(html, "html.parser")

print("=" * 70)
print("1) POSTOJI LI <table> ELEMENT (klasična HTML tablica poretka)?")
print("=" * 70)
tablice = soup.find_all("table")
print(f"Pronađeno <table> elemenata: {len(tablice)}")
for i, t in enumerate(tablice[:2]):
    print(f"\n--- TABLICA {i + 1} (prvih 2500 znakova) ---")
    print(t.prettify()[:2500])

print()
print("=" * 70)
print("2) KLASE KOJE ZVUČE KAO POREDAK / TABLICA / RANG")
print("=" * 70)
for kw in ["standing", "poredak", "table", "rank", "position",
           "points", "bodovi"]:
    hits = sorted(set(re.findall(r'class="[^"]*' + kw + r'[^"]*"', html, re.IGNORECASE)))
    if hits:
        print(f"  '{kw}'  ->  {hits[:8]}")

print()
print("=" * 70)
print("3) GDJE SE U TEKSTU SPOMINJE 'Poredak' (kontekst oko naslova)")
print("=" * 70)
for el in soup.find_all(string=re.compile(r"Poredak", re.IGNORECASE))[:3]:
    roditelj = el.find_parent(["div", "section", "li", "h2", "h3"])
    if roditelj:
        print(roditelj.prettify()[:1200])
        print("---")

print()
print("=" * 70)
print("4) STRUKTURA JEDNOG RETKA STRIJELACA (za sidebar strijelaca)")
print("=" * 70)
# Iz ranijeg uvida znamo da su strijelci h3 > a[href*=/igraci/] s brojem golova.
# Ispiši roditeljski blok prvog takvog igrača IZVAN postava (na stranici lige).
prvi = soup.find("a", href=lambda h: h and "/igraci/" in h)
if prvi:
    blok = prvi.find_parent("li") or prvi.parent
    print(blok.prettify()[:1500])
else:
    print("Nema linkova na igrače na ovoj stranici.")

print("\nGOTOVO. Zalijepi cijeli ovaj ispis u chat.")

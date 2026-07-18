"""
dijagnostika_karton.py

Jednokratna provjera: postoji li u SIROVOM HTML-u informacija o tipu/boji
kartona (klasa ili title atribut) uz minute u postavi.

Pokreni:  python dijagnostika_karton.py
Zatim zalijepi CIJELI ispis natrag u chat.
"""

import re
import requests
from bs4 import BeautifulSoup

URL = "https://semafor.hns.family/utakmice/100585734/nk-jadran-porec-nk-lokomotiva-r-3-4/"
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/120.0 Safari/537.36"
}

html = requests.get(URL, headers=HEADERS, timeout=15).text
soup = BeautifulSoup(html, "html.parser")

print("=" * 70)
print("1) SIROVI HTML BLOK IGRAČA S KARTONOM (Loren Pichler — ima 2' i 62')")
print("=" * 70)
nasao = False
for a in soup.find_all("a", href=lambda h: h and "/igraci/" in h):
    if "Pichler" in a.get_text():
        blok = a.find_parent("li") or a.parent
        print(blok.prettify()[:4000])
        nasao = True
        break
if not nasao:
    print("Nisam našao Pichlera — struktura se možda promijenila.")

print()
print("=" * 70)
print("2) IMA LI IGDJE U HTML-u KLASA/TITLE VEZAN UZ KARTON / TIP DOGAĐAJA")
print("=" * 70)
for kw in ["karton", "crveni", "žuti", "zuti", "yellow", "red",
           "card", "icon", "event", "sub", "izmjen"]:
    hits = re.findall(r'class="[^"]*' + kw + r'[^"]*"', html, re.IGNORECASE)
    hits += re.findall(r'title="[^"]*' + kw + r'[^"]*"', html, re.IGNORECASE)
    if hits:
        uniq = sorted(set(hits))[:10]
        print(f"  '{kw}'  ->  {uniq}")
print("\nGOTOVO. Zalijepi cijeli ovaj ispis u chat.")

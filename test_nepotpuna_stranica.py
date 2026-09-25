"""
test_nepotpuna_stranica.py

Provjerava što scraper radi kad HNS odgovori uredno, ali sa stranicom
natjecanja na kojoj nema rasporeda ni ljestvice
(dohvati_potpunu_stranicu u scraper_supabase.py).

Zašto ovo postoji: 23. i 24.09.2026. HNS je nekoliko minuta vraćao takve
stranice, bez ikakve greške. Scraper je prvi put samo ispisao "nisam
pronašao početak rasporeda" i završio zeleno. Drugi put je u bazu upisao
PRAZNU ljestvicu i prazne nastupe za sve četiri lige, i opet završio
zeleno, s porukom "Grešaka: 0".

Pravilo koje se ovdje čuva: nepotpuna stranica se ponavlja kao neodgovor,
a ako ni treći put nije cijela, diže se greška i NIŠTA se ne upisuje.

POKRETANJE:  python test_nepotpuna_stranica.py
Ništa ne dohvaća s interneta i ništa ne piše u bazu.
"""

import os
import sys
import types

# Scraper pri uvozu otvara vezu prema Supabaseu; za ovu provjeru ne treba.
for ime, sadrzaj in {
    "supabase": {"create_client": lambda *a, **k: None},
    "dotenv": {"load_dotenv": lambda *a, **k: None},
}.items():
    modul = types.ModuleType(ime)
    for kljuc, vrijednost in sadrzaj.items():
        setattr(modul, kljuc, vrijednost)
    sys.modules.setdefault(ime, modul)

os.environ.setdefault("SUPABASE_URL", "test")
os.environ.setdefault("SUPABASE_SERVICE_KEY", "test")

import requests  # noqa: E402
import scraper_supabase  # noqa: E402


# Ono što je HNS vraćao tih nekoliko minuta: stranica postoji, ali bez
# sadržaja natjecanja.
NEPOTPUNA = "<html><body><h1>HNS Semafor</h1></body></html>"

CIJELA = """<html><body>
<h2>Raspored natjecanja</h2>
<div><span>1. kolo</span>
  <li class="match"><div class="row">
    <a href="/klubovi/1">NK A</a>
    <a href="/utakmice/9">- : -</a>
    <a href="/klubovi/2">NK B</a>
    <span>29.08.2026. 17:30</span>
    <span>Neki stadion</span>
  </div></li>
</div>
<h2>Ljestvica</h2>
<div class="competition_table"><ul>
  <li><div class="position">1.</div><a href="/klubovi/1">NK A</a>
      <div class="played">0</div><div class="points">0</div></li>
  <li><div class="position">2.</div><a href="/klubovi/2">NK B</a>
      <div class="played">0</div><div class="points">0</div></li>
</ul></div>
</body></html>"""


class _Odgovor:
    def __init__(self, text):
        self.text = text

    def raise_for_status(self):
        pass


def provjeri(uvjet, opis):
    print(f"  {'OK  ' if uvjet else 'PALO'}  {opis}")
    return uvjet


def posluzi(*stranice):
    """requests.get koji redom vraća zadane stranice, pa zadnju zauvijek."""
    dohvati = []

    def get(*a, **k):
        dohvati.append(1)
        return _Odgovor(stranice[min(len(dohvati), len(stranice)) - 1])

    requests.get = get
    return dohvati


def main():
    sve = True
    pauze = []
    # Pauze se ne odrađuju stvarno, da test traje kratko.
    scraper_supabase.time.sleep = lambda sekundi: pauze.append(sekundi)

    print("1. raspored: dvaput nepotpuna, treći put cijela")
    pauze.clear()
    dohvati = posluzi(NEPOTPUNA, NEPOTPUNA, CIJELA)
    utakmice = scraper_supabase.dohvati_popis_utakmica("http://test")
    sve &= provjeri(len(utakmice) == 1, "utakmica je ipak pročitana")
    sve &= provjeri(len(dohvati) == 3, "stranica je dohvaćena tri puta")
    sve &= provjeri(pauze == [15, 45], "pauze su kao kod neodgovora")

    print("2. raspored: nepotpuna sva tri puta")
    pauze.clear()
    posluzi(NEPOTPUNA)
    try:
        scraper_supabase.dohvati_popis_utakmica("http://test")
        sve &= provjeri(False, "diže se greška, a ne vraća prazan popis")
    except scraper_supabase.NepotpunaStranica:
        sve &= provjeri(True, "diže se greška, a ne vraća prazan popis")

    print("3. rang-liste: nepotpuna sva tri puta, u bazu ne ide ništa")
    pauze.clear()
    posluzi(NEPOTPUNA)
    scraper_supabase.POSTAVKE["dry_run"] = True
    scraper_supabase.PROBNE_STATISTIKE.clear()
    try:
        scraper_supabase.dohvati_i_spremi_statistike("Test liga", "http://test")
        sve &= provjeri(False, "diže se greška")
    except scraper_supabase.NepotpunaStranica:
        sve &= provjeri(True, "diže se greška")
    sve &= provjeri(scraper_supabase.PROBNE_STATISTIKE == [],
                    "nijedna rang-lista nije upisana, ni prazna ljestvica")

    print("4. rang-liste: cijela stranica iz prve")
    pauze.clear()
    dohvati = posluzi(CIJELA)
    scraper_supabase.PROBNE_STATISTIKE.clear()
    scraper_supabase.dohvati_i_spremi_statistike("Test liga", "http://test")
    tablica = [r for r in scraper_supabase.PROBNE_STATISTIKE
               if r["tip"] == "tablica"]
    sve &= provjeri(len(dohvati) == 1 and pauze == [],
                    "dohvaćeno jednom, bez čekanja")
    sve &= provjeri(len(tablica) == 1 and len(tablica[0]["podaci"]) == 2,
                    "ljestvica s dva kluba je upisana")

    print("5. zapisnik bez rezultata ne briše postave ni strijelce")
    # Ovako su 24.09.2026. stigla tri zapisnika 3. kola 4. NL NS Rijeka.
    podaci = scraper_supabase.bez_praznog_kad_nema_rezultata({
        "hns_url": "http://test/utakmica", "domacin": "NK A", "gost": "NK B",
        "rezultat": None, "stadion_datum": None, "gledatelja": None,
        "suci": [], "strijelci": [], "postava_domacin": [], "postava_gost": [],
    })
    sve &= provjeri(not any(s in podaci for s in
                            scraper_supabase.STUPCI_ZAPISNIKA),
                    "nijedan prazan stupac zapisnika se ne šalje")
    sve &= provjeri(podaci.get("hns_url") == "http://test/utakmica",
                    "adresa zapisnika ostaje")

    print("6. postava upisana prije rezultata i dalje ide u bazu")
    postava = [{"igrac": "Ivo Ivić", "dogadjaji": []}]
    podaci = scraper_supabase.bez_praznog_kad_nema_rezultata({
        "rezultat": None, "strijelci": [],
        "postava_domacin": postava, "postava_gost": postava,
    })
    sve &= provjeri(podaci.get("postava_domacin") == postava,
                    "pročitana postava se šalje")
    sve &= provjeri("strijelci" not in podaci and "rezultat" not in podaci,
                    "prazni strijelci i rezultat se ne šalju")

    print("7. zapisnik S rezultatom šalje se cijeli, i prazan popis strijelaca")
    # Utakmica 0:0 stvarno nema strijelaca, i to se mora moći upisati.
    podaci = scraper_supabase.bez_praznog_kad_nema_rezultata({
        "rezultat": "0:0", "strijelci": [], "postava_domacin": postava,
    })
    sve &= provjeri(podaci.get("strijelci") == [] and podaci["rezultat"] == "0:0",
                    "0:0 bez strijelaca se upisuje")

    if not sve:
        print("\nPALO: nepotpuna stranica HNS-a nije ispravno obrađena.")
        return 1
    print("\nPROLAZI: nepotpuna stranica se ponavlja, a na kraju ne upisuje.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

"""
test_ponavljanje.py

Provjerava dohvat stranice s HNS-a kad Semafor ne odgovori iz prve
(funkcija dohvati_stranicu u scraper_supabase.py).

Zašto ovo postoji: 03.09.2026. pala je dnevna "Provjera termina" s
porukom "Read timed out (read timeout=15)". Prvi dohvat stranice lige
istekao je i srušio cijelo pokretanje, iako u našem kodu nije bilo ničega
neispravnog. Jedan neuspjeli pokušaj od tada ne znači ništa, tri znače.

POKRETANJE:  python test_ponavljanje.py
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


class _Odgovor:
    text = "<html>stranica</html>"

    def raise_for_status(self):
        pass


def provjeri(uvjet, opis):
    print(f"  {'OK  ' if uvjet else 'PALO'}  {opis}")
    return uvjet


def main():
    sve = True
    # Pauze između pokušaja se ne odrađuju stvarno, da test traje kratko.
    scraper_supabase.time.sleep = lambda sekundi: pauze.append(sekundi)

    print("1. iz prve, bez ponavljanja")
    pauze = []
    pokusaji = []
    requests.get = lambda *a, **k: (pokusaji.append(1), _Odgovor())[1]
    odgovor = scraper_supabase.dohvati_stranicu("http://test")
    sve &= provjeri(odgovor.text == "<html>stranica</html>", "stranica je vraćena")
    sve &= provjeri(len(pokusaji) == 1, "dohvat je pokušan samo jednom")
    sve &= provjeri(pauze == [], "nije se čekalo")

    print("2. prva dva pokušaja padnu, treći uspije")
    pauze = []
    pokusaji = []

    def dva_puta_padne(*a, **k):
        pokusaji.append(1)
        if len(pokusaji) < 3:
            raise requests.exceptions.ReadTimeout("Read timed out")
        return _Odgovor()

    requests.get = dva_puta_padne
    odgovor = scraper_supabase.dohvati_stranicu("http://test")
    sve &= provjeri(odgovor.text == "<html>stranica</html>", "stranica je ipak dohvaćena")
    sve &= provjeri(len(pokusaji) == 3, "pokušano je tri puta")
    sve &= provjeri(pauze == [15, 45], "pauza između pokušaja raste")

    print("3. HNS vrati 500, pa tek onda proradi")
    # 13.09.2026. je vecernje pokretanje palo s "500 Server Error" na
    # stranicama 3. NL i 4. NL. Greska na HNS-ovu posluzitelju mora se
    # ponavljati jednako kao istek vremena, jer raise_for_status() dize
    # HTTPError, koji je i sam RequestException.
    pauze = []
    pokusaji = []

    class _OdgovorPetsto:
        text = ""

        def raise_for_status(self):
            raise requests.exceptions.HTTPError("500 Server Error")

    def petsto_pa_uspjeh(*a, **k):
        pokusaji.append(1)
        return _Odgovor() if len(pokusaji) >= 2 else _OdgovorPetsto()

    requests.get = petsto_pa_uspjeh
    odgovor = scraper_supabase.dohvati_stranicu("http://test")
    sve &= provjeri(odgovor.text == "<html>stranica</html>", "stranica je dohvaćena nakon 500")
    sve &= provjeri(len(pokusaji) == 2, "pokušano je dvaput")
    sve &= provjeri(pauze == [15], "čekalo se prije drugog pokušaja")

    print("4. HNS ne odgovara nijednom: greška ide dalje")
    pauze = []
    pokusaji = []

    def uvijek_padne(*a, **k):
        pokusaji.append(1)
        raise requests.exceptions.ReadTimeout("Read timed out")

    requests.get = uvijek_padne
    try:
        scraper_supabase.dohvati_stranicu("http://test")
        sve &= provjeri(False, "greška je proslijeđena dalje")
    except requests.exceptions.ReadTimeout:
        sve &= provjeri(True, "greška je proslijeđena dalje")
    sve &= provjeri(len(pokusaji) == 3, "pokušano je točno tri puta, pa se odustalo")

    print()
    print("PROLAZI" if sve else "NE PROLAZI")
    return 0 if sve else 1


if __name__ == "__main__":
    sys.exit(main())

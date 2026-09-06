"""
test_rezultat_bez_brojki.py

Provjerava sto se dogodi kad zapisnik na HNS-u postoji, ali u njegovom
naslovu nema rezultata.

Povod: 06.09.2026., HNK Goranin - NK Stari grad Rijeka, 1. kolo 1. ZNL PGZ.
Utakmica je imala poveznicu na zapisnik, ali bez brojki u naslovu, pa je
scraper u bazu upisao rijec "Nepoznato" kao rezultat. Stranica je to onda
prikazala kao da je to rezultat utakmice.

Pravilo od tada: kad se rezultat ne procita, kljuc "rezultat" se UOPCE ne
salje u upsert. Stupac koji se ne posalje upsert ne dira, pa se rezultat
koji je vec u bazi ne moze prebrisati jednim losije procitanim zapisnikom.

POKRETANJE:  python test_rezultat_bez_brojki.py
Nista ne dohvaca s interneta i nista ne pise u bazu.
"""

import os
import sys
import types

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

import scraper_supabase  # noqa: E402


class LaznaStranica:
    def __init__(self, tekst):
        self.text = tekst


def _stranica(naslov):
    """Najmanji zapisnik koji funkcija zna procitati: samo naslov."""
    return LaznaStranica(f"<html><head><title>{naslov}</title></head>"
                         "<body></body></html>")


def _detalji(naslov):
    izvorna = scraper_supabase.dohvati_stranicu
    scraper_supabase.dohvati_stranicu = lambda url: _stranica(naslov)
    try:
        return scraper_supabase.dohvati_detalje_utakmice("http://primjer/1")
    finally:
        scraper_supabase.dohvati_stranicu = izvorna


def test_rezultat_se_procita():
    d = _detalji("HNK Goranin - NK Stari grad Rijeka 2:1")
    assert d["rezultat"] == "2:1", d.get("rezultat")
    assert d["domacin"] == "HNK Goranin", d["domacin"]
    assert d["gost"] == "NK Stari grad Rijeka", d["gost"]
    print("OK: rezultat iz naslova se procita")


def test_bez_rezultata_nema_kljuca():
    d = _detalji("HNK Goranin - NK Stari grad Rijeka")
    assert "rezultat" not in d, (
        "kad rezultata nema, kljuc se NE smije slati u upsert, "
        f"a poslano je: {d.get('rezultat')!r}"
    )
    print("OK: bez rezultata se kljuc uopce ne salje")


def test_nikad_rijec_nepoznato():
    for naslov in ("HNK Goranin - NK Stari grad Rijeka",
                   "HNK Goranin vs NK Stari grad Rijeka",
                   "Zapisnik utakmice"):
        d = _detalji(naslov)
        assert d.get("rezultat") != "Nepoznato", naslov
    print("OK: rijec Nepoznato nikad ne zavrsi kao rezultat")


if __name__ == "__main__":
    test_rezultat_se_procita()
    test_bez_rezultata_nema_kljuca()
    test_nikad_rijec_nepoznato()
    print("\nSVE PROLAZI")

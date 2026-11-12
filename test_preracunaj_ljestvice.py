"""Testovi za alati/preracunaj_ljestvice.py, bez interneta i bez baze.

Od 12.11.2026. se tablica poretka RAČUNA iz rezultata, a ne skida gotova
s HNS-a. Dok se skidala, njezinu je točnost jamčio HNS. Sada je jamči
ovaj izračun, pa mora biti pokriven testovima: bodovi, gol razlika,
poredak, kazneni bodovi i klub koji još nije odigrao nijednu utakmicu.
"""

import sys
import types
from pathlib import Path

# scraper_supabase uvozi supabase na vrhu, a taj paket ovdje ne treba,
# jer se ne dira baza. Lažni modul je dovoljan da uvoz prođe.
sys.modules.setdefault("supabase", types.SimpleNamespace(
    create_client=lambda *a, **k: None, Client=object))

sys.path.insert(0, str(Path(__file__).parent / "alati"))
sys.path.insert(0, str(Path(__file__).parent))

import preracunaj_ljestvice as p  # noqa: E402


def utakmica(domacin, gost, rezultat=None):
    return {"domacin": domacin, "gost": gost, "rezultat": rezultat,
            "postava_domacin": [], "postava_gost": []}


def test_rezultat_u_brojke():
    assert p.rezultat_u_brojke("2:1") == (2, 1)
    assert p.rezultat_u_brojke("2 : 1") == (2, 1)
    assert p.rezultat_u_brojke("- : -") is None
    assert p.rezultat_u_brojke("") is None
    assert p.rezultat_u_brojke(None) is None
    print("OK: rezultat se čita samo kad su obje brojke")


def test_bodovi_i_poredak():
    tablica = p.izracunaj_tablicu([
        utakmica("A", "B", "2:1"),
        utakmica("B", "C", "0:0"),
        utakmica("C", "A", "1:3"),
    ], {})

    po_klubu = {r["klub"]: r for r in tablica}
    assert po_klubu["A"]["bodovi"] == "6", po_klubu["A"]
    assert po_klubu["B"]["bodovi"] == "1"
    assert po_klubu["C"]["bodovi"] == "1"
    assert po_klubu["A"]["gol_razlika"] == "3"
    assert po_klubu["A"]["pozicija"] == "1"
    # B i C su na bodu, ali B ima bolju gol razliku (1:2 prema 1:3).
    assert po_klubu["B"]["pozicija"] == "2", tablica
    print("OK: bodovi, gol razlika i poredak")


def test_neodigrana_ne_ulazi():
    tablica = p.izracunaj_tablicu([
        utakmica("A", "B", "1:0"),
        utakmica("A", "B", None),
        utakmica("A", "B", "- : -"),
    ], {})
    po_klubu = {r["klub"]: r for r in tablica}
    assert po_klubu["A"]["odigrano"] == "1", po_klubu["A"]
    print("OK: utakmica bez rezultata se ne broji")


def test_klub_bez_utakmice_je_u_tablici():
    """Klub koji još nije igrao mora stajati u tablici, s nulama."""
    tablica = p.izracunaj_tablicu([utakmica("A", "B", None)], {})
    assert {r["klub"] for r in tablica} == {"A", "B"}
    assert all(r["odigrano"] == "0" for r in tablica)
    print("OK: klub bez odigrane utakmice je u tablici")


def test_kazneni_bodovi():
    bez = p.izracunaj_tablicu([utakmica("A", "B", "1:0")], {})
    s_kaznom = p.izracunaj_tablicu([utakmica("A", "B", "1:0")], {"A": -3})

    assert {r["klub"]: r["bodovi"] for r in bez}["A"] == "3"
    assert {r["klub"]: r["bodovi"] for r in s_kaznom}["A"] == "0"

    # Uz kaznu su oba kluba na nuli, pa odlučuje gol razlika, a ona je i
    # dalje na strani pobjednika. Dakle A ostaje prvi.
    assert s_kaznom[0]["klub"] == "A", s_kaznom

    # Da kazna doista pomiče poredak, provjerava se na jačoj kazni.
    # A ima tri boda za pobjedu, pa ga tek kazna veca od toga spusta
    # ispod B, koji je na nuli.
    jaca = p.izracunaj_tablicu([utakmica("A", "B", "1:0")], {"A": -4})
    assert {r["klub"]: r["bodovi"] for r in jaca}["A"] == "-1", jaca
    assert jaca[0]["klub"] == "B", jaca
    print("OK: kazneni bodovi se oduzimaju i mijenjaju poredak")


def test_prazno_ime_kluba_se_preskace():
    tablica = p.izracunaj_tablicu([
        utakmica("", "B", "1:0"),
        utakmica("A", "B", "1:0"),
    ], {})
    assert {r["klub"] for r in tablica} == {"A", "B"}
    print("OK: redak bez imena kluba ne ulazi u tablicu")


def test_sve_vrijednosti_su_tekst():
    """Stranica očekuje tekst u svim poljima (tip RedTablice)."""
    tablica = p.izracunaj_tablicu([utakmica("A", "B", "1:0")], {})
    for redak in tablica:
        for kljuc, vrijednost in redak.items():
            assert isinstance(vrijednost, str), (kljuc, vrijednost)
    print("OK: sve vrijednosti su tekst, kao i kod scrapera")


if __name__ == "__main__":
    test_rezultat_u_brojke()
    test_bodovi_i_poredak()
    test_neodigrana_ne_ulazi()
    test_klub_bez_utakmice_je_u_tablici()
    test_kazneni_bodovi()
    test_prazno_ime_kluba_se_preskace()
    test_sve_vrijednosti_su_tekst()
    print("\nSVE PROLAZI")

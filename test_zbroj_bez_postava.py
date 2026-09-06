"""
test_zbroj_bez_postava.py

Provjera zbroja golova kad zapisnik NEMA postave.

Povod: 06.09.2026. trazio sam zasto provjera nije javila neslaganje na
utakmici NK Rab - NK Vihor (B) 4:2. Ispalo je da je sve bilo u redu, jer
je scraper autogol Mihaela Radica sam prepoznao, pa je zbroj bio tocan.
Usput se pokazalo da utakmica bez postava nije prolazila NIKAKVU provjeru.

Od tada provjera ima dvije razine:
  - s obje postave gleda se podjela po momcadima (4:2 prema 3:3)
  - bez postava gleda se samo ukupan broj pogodaka

Druga razina ne moze uhvatiti krivo pripisan gol, jer se bez postava ne
zna cija je koja strana. Uhvati gol koji fali ili je upisan dvaput.

Prazan popis strijelaca namjerno NE okida uzbunu: utakmica predana bez
borbe ima rezultat, a nema strijelaca, i to je uredno.

POKRETANJE:  python test_zbroj_bez_postava.py
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

from scraper_supabase import provjeri_zbroj_golova  # noqa: E402


def _igrac(ime):
    return {"igrac": ime, "dogadjaji": []}


def _strijelci(*imena):
    return [{"igrac": ime, "minuta": f"{i + 1}'"}
            for i, ime in enumerate(imena)]


def test_bez_postava_zbroj_se_slaze():
    redak = {
        "rezultat": "4:2",
        "strijelci": _strijelci("A", "B", "C", "D", "E", "F"),
        "postava_domacin": [],
        "postava_gost": [],
    }
    assert provjeri_zbroj_golova(redak) is None
    print("OK: sest strijelaca za 4:2 ne okida uzbunu")


def test_bez_postava_gol_fali():
    redak = {
        "rezultat": "4:2",
        "strijelci": _strijelci("A", "B", "C", "D", "E"),
        "postava_domacin": [],
        "postava_gost": [],
    }
    poruka = provjeri_zbroj_golova(redak)
    assert poruka and "traži 6 pogodaka" in poruka, poruka
    assert "strijelaca je 5" in poruka, poruka
    print("OK: gol koji fali se prijavi")


def test_bez_postava_gol_viska():
    redak = {
        "rezultat": "1:0",
        "strijelci": _strijelci("A", "A"),
        "postava_domacin": [],
        "postava_gost": [],
    }
    poruka = provjeri_zbroj_golova(redak)
    assert poruka and "strijelaca je 2" in poruka, poruka
    print("OK: gol upisan dvaput se prijavi")


def test_samo_jedna_postava_ide_na_zbroj():
    redak = {
        "rezultat": "2:1",
        "strijelci": _strijelci("A", "B", "C"),
        "postava_domacin": [_igrac("A"), _igrac("B")],
        "postava_gost": [],
    }
    assert provjeri_zbroj_golova(redak) is None
    print("OK: s jednom postavom se gleda samo ukupan broj")


def test_predana_bez_borbe_ne_okida():
    redak = {
        "rezultat": "3:0",
        "strijelci": [],
        "postava_domacin": [],
        "postava_gost": [],
    }
    assert provjeri_zbroj_golova(redak) is None
    print("OK: utakmica bez strijelaca ne okida uzbunu")


def test_s_postavama_i_dalje_gleda_podjelu():
    """Stara razina mora ostati netaknuta."""
    redak = {
        "rezultat": "4:2",
        "strijelci": _strijelci("A", "B", "C", "D", "E", "F"),
        "postava_domacin": [_igrac("A"), _igrac("B"), _igrac("C")],
        "postava_gost": [_igrac("D"), _igrac("E"), _igrac("F")],
    }
    poruka = provjeri_zbroj_golova(redak)
    assert poruka and "strijelci daju 3:3" in poruka, poruka
    print("OK: s postavama se i dalje hvata kriva podjela")


def test_autogol_iz_zapisnika_ispravlja_podjelu():
    """Kao Rab - Vihor: autogol gosta je pogodak domaćina."""
    strijelci = _strijelci("A", "B", "C", "D", "E", "F")
    for s in strijelci:
        if s["igrac"] == "E":
            s["autogol"] = True
    redak = {
        "rezultat": "4:2",
        "strijelci": strijelci,
        "postava_domacin": [_igrac("A"), _igrac("B"), _igrac("C")],
        "postava_gost": [_igrac("D"), _igrac("E"), _igrac("F")],
    }
    assert provjeri_zbroj_golova(redak) is None
    print("OK: automatski prepoznat autogol daje točan zbroj")


if __name__ == "__main__":
    test_bez_postava_zbroj_se_slaze()
    test_bez_postava_gol_fali()
    test_bez_postava_gol_viska()
    test_samo_jedna_postava_ide_na_zbroj()
    test_predana_bez_borbe_ne_okida()
    test_s_postavama_i_dalje_gleda_podjelu()
    test_autogol_iz_zapisnika_ispravlja_podjelu()
    print("\nSVE PROLAZI")

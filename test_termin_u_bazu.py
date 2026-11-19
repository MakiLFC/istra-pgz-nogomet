"""Testovi za alati/termin_u_bazu.py, bez interneta i bez baze.

Termin je od 12.11.2026. jedini podatak koji se mijenja BEZ ikakve
kočnice: zapisnik barem provjerava zbroj golova, a ovdje kriv upis samo
tiho premjesti utakmicu. Zato se čitanje datuma, vremena i pogađanje
prave utakmice provjeravaju testovima.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent / "alati"))

import termin_u_bazu as t  # noqa: E402


def red(kolo, domacin, gost, datum=None, vrijeme=None, stadion=None, rezultat=None):
    return {"id": kolo, "kolo": kolo, "domacin": domacin, "gost": gost,
            "datum": datum, "vrijeme": vrijeme, "stadion": stadion,
            "rezultat": rezultat}


def test_datum():
    assert t.normaliziraj_datum("14.11.2026.") == "14.11.2026."
    # Bez točke na kraju i s jednoznamenkastim danom, kako se tipka na mobitelu.
    assert t.normaliziraj_datum("4.11.2026") == "04.11.2026."
    # Prazno znači "ne diraj", a crtica znači "obriši termin".
    assert t.normaliziraj_datum("") == ""
    assert t.normaliziraj_datum("-") is None
    print("OK: datum se čita i u skraćenom obliku")


def test_krivi_datum_pada():
    for krivi in ("14.11.26", "2026-11-14", "subota", "32.11.2026"):
        try:
            t.normaliziraj_datum(krivi)
        except SystemExit:
            continue
        raise AssertionError(f"'{krivi}' je prošao, a ne smije")
    print("OK: datum koji se ne da pročitati se odbija")


def test_vrijeme():
    assert t.normaliziraj_vrijeme("14:30") == "14:30"
    assert t.normaliziraj_vrijeme("9:00") == "9:00"
    assert t.normaliziraj_vrijeme("") == ""
    assert t.normaliziraj_vrijeme("-") is None
    for krivo in ("1430", "25:00", "14:60", "14.30"):
        try:
            t.normaliziraj_vrijeme(krivo)
        except SystemExit:
            continue
        raise AssertionError(f"'{krivo}' je prošao, a ne smije")
    print("OK: vrijeme se čita, a nemoguće se odbija")


def test_nepotpuno_ime_nalazi_klub():
    redovi = [red(13, "NK Vinodol", "NK Naprijed (H)")]
    nadjen = t.odaberi_utakmicu(redovi, "vinodol", "naprijed")
    assert nadjen["kolo"] == 13
    print("OK: utakmica se nalazi i bez punog naziva kluba")


def test_isti_par_dvaput_trazi_kolo():
    """Dvokružna liga ima isti par dvaput, trokružna i triput."""
    redovi = [red(3, "NK Rab", "NK Draga"), red(17, "NK Rab", "NK Draga")]

    try:
        t.odaberi_utakmicu(redovi, "Rab", "Draga")
    except SystemExit as greska:
        assert "dvjema utakmicama" in str(greska), greska
    else:
        raise AssertionError("dvoznačnost je prošla, a ne smije")

    assert t.odaberi_utakmicu(redovi, "Rab", "Draga", kolo=17)["kolo"] == 17
    print("OK: dvoznačan par traži kolo, a s kolom se razriješi")


def test_krivo_kolo_ne_promasuje():
    """Kolo razrješava dvoznačnost, ali samo po sebi ne isključuje.

    Kolo se ne prepoznaje po datumu (vidi CLAUDE.md), pa je zabuna u
    kolu česta. Kad par postoji samo jednom, nađe se i uz krivo kolo.
    """
    redovi = [red(12, "NK Vinodol", "NK Nehaj")]
    assert t.odaberi_utakmicu(redovi, "Vinodol", "Nehaj", kolo=11)["kolo"] == 12
    print("OK: jedinstven par se nađe i kad je kolo krivo zadano")


def test_obrnut_par_nije_ista_utakmica():
    redovi = [red(5, "NK Rab", "NK Draga")]
    try:
        t.odaberi_utakmicu(redovi, "Draga", "Rab")
    except SystemExit as greska:
        assert "Ne nalazim" in str(greska)
        print("OK: zamijenjen domaćin i gost se ne pogađa nego prijavi")
        return
    raise AssertionError("obrnut par je prošao, a ne smije")


def test_mijenja_se_samo_zadano():
    r = red(13, "NK Krk", "NK OŠK Omišalj", datum="14.11.2026.", vrijeme="14:30",
            stadion="Igralište Krk")
    # Prazno polje znači "ne diraj", pa promjena samo datuma ne briše vrijeme.
    assert t.promjene(r, "15.11.2026.", "", "") == {"datum": "15.11.2026."}
    # Isti termin nije promjena.
    assert t.promjene(r, "14.11.2026.", "14:30", "") == {}
    print("OK: upisuje se samo ono što se stvarno mijenja")


def test_brisanje_termina():
    r = red(13, "NK Krk", "NK Omišalj", datum="14.11.2026.", vrijeme="14:30")
    assert t.promjene(r, None, None, "") == {"datum": None, "vrijeme": None}
    # Već obrisan termin se ne briše ponovno.
    prazan = red(13, "NK Krk", "NK Omišalj")
    assert t.promjene(prazan, None, None, "") == {}
    print("OK: odgoda briše termin, i to samo kad ima što obrisati")


def test_oznaka_odgode():
    # Prazno i "ne diraj" ne diraju oznaku.
    assert t.oznaka_odgode("", "22.11.2026.") is None
    assert t.oznaka_odgode("ne diraj", "") is None
    # Novi termin uz odgodu "da": Željezničar - Mrkopalj, 14.11.2026.
    assert t.oznaka_odgode("da", "22.11.2026.") is True
    assert t.oznaka_odgode("ne", "") is False
    # Brisanje termina je uvijek odgoda, i bez izričite oznake.
    assert t.oznaka_odgode("", None) is True
    print("OK: oznaka odgode")


def test_zamjena_okrece_par():
    r = red(12, "NK Medulin 1921", "NK Ližnjan", "21.11.2026.", "13:30")
    novo = t.zamjena_parova(r, [r])
    assert novo == {"domacin": "NK Ližnjan", "gost": "NK Medulin 1921"}
    print("OK: zamjena okreće domaćina i gosta")


def test_zamjena_odbija_odigranu():
    r = red(8, "NK Medulin 1921", "NK Mladost Fažana", "18.11.2026.",
            "14:30", rezultat="1:1")
    try:
        t.zamjena_parova(r, [r])
    except SystemExit:
        print("OK: odigrana utakmica se ne okreće")
        return
    raise AssertionError("odigrana utakmica je okrenuta, a ne smije")


def test_zamjena_odbija_dvojnika():
    r = red(12, "NK Otočac", "NK Funtana")
    blizanac = red(12, "NK Funtana", "NK Otočac")
    try:
        t.zamjena_parova(r, [r, blizanac])
    except SystemExit:
        print("OK: zamjena se odbija kad obrnut par već postoji")
        return
    raise AssertionError("nastala bi dva ista para, a to je prošlo")


if __name__ == "__main__":
    test_datum()
    test_krivi_datum_pada()
    test_vrijeme()
    test_nepotpuno_ime_nalazi_klub()
    test_isti_par_dvaput_trazi_kolo()
    test_krivo_kolo_ne_promasuje()
    test_obrnut_par_nije_ista_utakmica()
    test_mijenja_se_samo_zadano()
    test_brisanje_termina()
    test_oznaka_odgode()
    test_zamjena_okrece_par()
    test_zamjena_odbija_odigranu()
    test_zamjena_odbija_dvojnika()
    print("\nSVE PROLAZI")

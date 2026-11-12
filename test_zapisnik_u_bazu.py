"""Testovi za alati/zapisnik_u_bazu.py, bez interneta i bez baze.

Od 12.11.2026. zapisnike upisuje Andrej ručno, iz snimke zaslona, jer
HNS je automatsko preuzimanje zabranio. Zato je prijepis jedino mjesto
na kojem podatak može nastati krivo, a kriva postava u bazi ostaje
zauvijek i nitko je ne primijeti.

Testovi pokrivaju upravo to: čitanje datoteke, prepoznavanje događaja,
slaganje liste strijelaca i kočnicu koja ne da upisati zapisnik čiji se
zbroj golova ne slaže s rezultatom.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent / "alati"))

import zapisnik_u_bazu as z  # noqa: E402


OSNOVA = """natjecanje: 3. NL Zapad
sezona: 2026/27
kolo: 11
domacin: NK Vinodol
gost: NK Nehaj
rezultat: {rezultat}
---
[domacin]
{domacin}
[gost]
{gost}
"""


def napisi(tmp, rezultat, domacin, gost):
    putanja = tmp / "proba.txt"
    putanja.write_text(
        OSNOVA.format(rezultat=rezultat, domacin=domacin, gost=gost),
        encoding="utf-8",
    )
    return putanja


def test_cita_igraca_s_oznakama(tmp_path=Path("/tmp")):
    igrac = z.procitaj_igraca("11 | Luka Filipović (C) | 84' zuti", False, "proba")
    assert igrac["igrac"] == "Luka Filipović", igrac["igrac"]
    assert igrac["broj"] == "11"
    assert igrac["kapetan"] is True
    assert igrac["pozicija"] == "Igrač"
    assert igrac["dogadjaji"] == [{"minuta": "84'", "tip": "karton_zuti"}]
    print("OK: broj, kapetan i žuti karton se čitaju iz retka")


def test_vratar_i_vise_dogadjaja():
    igrac = z.procitaj_igraca("17 | Matej Prizmić | 22' zuti, 68' izlazak", False, "p")
    assert [d["tip"] for d in igrac["dogadjaji"]] == ["karton_zuti", "izmjena_izlazak"]
    vratar = z.procitaj_igraca("1 | Lovro Pichler | vratar", True, "p")
    assert vratar["pozicija"] == "Vratar"
    assert vratar["pricuvni"] is True
    print("OK: vratar, pričuva i dva događaja u istom retku")


def test_drugi_zuti_ide_prije_zutog():
    """'drugi zuti' sadrži 'zuti', pa redoslijed traženja mora biti točan.

    Ista zamka kao kod autogola i 'goal' u scraperu (vidi CLAUDE.md).
    """
    igrac = z.procitaj_igraca("9 | Netko | 70' drugi zuti", False, "p")
    assert igrac["dogadjaji"][0]["tip"] == "karton_zutocrveni", igrac["dogadjaji"]
    print("OK: drugi žuti se ne čita kao obični žuti")


def test_dogadjaj_bez_minute():
    """HNS zna upisati karton bez minute, i to nije razlog da nestane."""
    igrac = z.procitaj_igraca("5 | Netko | zuti", False, "p")
    assert igrac["dogadjaji"] == [{"minuta": "", "tip": "karton_zuti"}]
    print("OK: događaj bez minute se upisuje s praznom minutom")


def test_minuta_s_nadoknadom():
    igrac = z.procitaj_igraca("7 | Netko | 90+3 gol", False, "p")
    assert igrac["dogadjaji"][0]["minuta"] == "90+3'"
    print("OK: minuta iz nadoknade ostaje cijela")


def test_strijelci_se_slazu_po_minuti():
    postava_d = [z.procitaj_igraca("18 | Prvi | 35' gol", False, "p")]
    postava_g = [z.procitaj_igraca("9 | Drugi | 16' gol", False, "p")]
    strijelci = z.strijelci_iz_postava(postava_d, postava_g)
    assert [s["igrac"] for s in strijelci] == ["Drugi", "Prvi"], strijelci
    assert all("autogol" not in s for s in strijelci)
    print("OK: lista strijelaca se slaže iz postava i poreda po minuti")


def test_autogol_ide_protivniku():
    """Autogol se broji momčadi protiv koje je dan, kao i kod scrapera."""
    postava_d = [z.procitaj_igraca("4 | Nesretnik | 20' autogol", False, "p")]
    postava_g = [z.procitaj_igraca("9 | Nitko", False, "p")]
    assert z.prebroji_golove(postava_d, postava_g) == 0
    assert z.prebroji_golove(postava_g, postava_d) == 1
    strijelci = z.strijelci_iz_postava(postava_d, postava_g)
    assert strijelci[0]["autogol"] is True
    z.provjeri_zbroj("0:1", postava_d, postava_g, False)
    print("OK: autogol ide protivniku i u zbroju i u listi strijelaca")


def test_nesklad_ne_prolazi():
    postava_d = [z.procitaj_igraca("18 | Prvi | 35' gol", False, "p")]
    postava_g = [z.procitaj_igraca("9 | Drugi", False, "p")]
    try:
        z.provjeri_zbroj("2:0", postava_d, postava_g, False)
    except SystemExit as greska:
        assert "NE SLAŽE" in str(greska)
        print("OK: zapisnik koji se ne slaže s rezultatom ne prolazi")
        return
    raise AssertionError("nesklad je prošao, a ne smije")


def test_nesklad_prolazi_uz_zastavicu():
    postava_d = [z.procitaj_igraca("18 | Prvi | 35' gol", False, "p")]
    postava_g = [z.procitaj_igraca("9 | Drugi", False, "p")]
    z.provjeri_zbroj("2:0", postava_d, postava_g, True)
    print("OK: uz --dopusti-nesklad se svejedno upisuje")


def test_cijela_datoteka(tmp_path=Path("/tmp")):
    putanja = napisi(
        tmp_path, "1:1",
        "99 | Vratar Jedan | vratar\n18 | Strijelac | 16' gol",
        "1 | Vratar Dva | vratar\n18 | Drugi Strijelac | 35' gol",
    )
    podaci = z.procitaj_datoteku(putanja)
    assert podaci["zaglavlje"]["domacin"] == "NK Vinodol"
    assert len(podaci["postava_domacin"]) == 2
    z.provjeri_zbroj("1:1", podaci["postava_domacin"], podaci["postava_gost"], False)
    putanja.unlink()
    print("OK: cijela datoteka se pročita i zbroj se slaže")


def test_nepoznata_oznaka_pada():
    try:
        z.procitaj_igraca("9 | Netko | 70' crvenkasti", False, "p")
    except SystemExit as greska:
        assert "ne razumijem oznaku" in str(greska)
        print("OK: nepoznata oznaka se prijavi, a ne progutaju")
        return
    raise AssertionError("nepoznata oznaka je prošla, a ne smije")


def test_krivi_rezultat_pada(tmp_path=Path("/tmp")):
    putanja = napisi(tmp_path, "pobjeda", "9 | A", "9 | B")
    try:
        z.procitaj_datoteku(putanja)
    except SystemExit as greska:
        assert "rezultat mora biti" in str(greska)
        print("OK: rezultat koji nije oblika 1:1 se odbija")
        return
    finally:
        putanja.unlink()
    raise AssertionError("krivi rezultat je prošao, a ne smije")


if __name__ == "__main__":
    test_cita_igraca_s_oznakama()
    test_vratar_i_vise_dogadjaja()
    test_drugi_zuti_ide_prije_zutog()
    test_dogadjaj_bez_minute()
    test_minuta_s_nadoknadom()
    test_strijelci_se_slazu_po_minuti()
    test_autogol_ide_protivniku()
    test_nesklad_ne_prolazi()
    test_nesklad_prolazi_uz_zastavicu()
    test_cijela_datoteka()
    test_nepoznata_oznaka_pada()
    test_krivi_rezultat_pada()
    print("\nSVE PROLAZI")

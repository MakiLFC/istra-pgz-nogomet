"""Testovi za alati/preimenuj_igraca.py, bez interneta i bez baze.

Preimenovanje dira postave svih utakmica jednog igrača i rang-liste, pa
greška ovdje tiho mijenja tuđe podatke. Najopasnije je traženje dijela
imena: "Hodak" bi pogodio i Marka i Luku.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent / "alati"))

import preimenuj_igraca as p  # noqa: E402


def test_zamjena_trazi_tocno_ime():
    popis = [
        {"igrac": "Marko Hodak", "dogadjaji": []},
        {"igrac": "Luka Hodak", "dogadjaji": []},
        {"igrac": "Hodak", "dogadjaji": []},
    ]
    novi, koliko = p.zamijeni_u_popisu(popis, "Marko Hodak", "Marko Hodaković")
    assert koliko == 1, koliko
    assert [i["igrac"] for i in novi] == ["Marko Hodaković", "Luka Hodak", "Hodak"]
    print("OK: mijenja se samo točno ime, ne dio imena")


def test_ostala_polja_ostaju():
    popis = [{"igrac": "A", "broj": "9", "pricuvni": True,
              "dogadjaji": [{"minuta": "12'", "tip": "karton_zuti"}]}]
    novi, _ = p.zamijeni_u_popisu(popis, "A", "B")
    assert novi[0]["broj"] == "9"
    assert novi[0]["pricuvni"] is True
    assert novi[0]["dogadjaji"][0]["tip"] == "karton_zuti"
    print("OK: mijenja se ime, sve ostalo ostaje")


def test_izvornik_se_ne_dira():
    """Redak iz baze se ne smije mijenjati na mjestu, jer se uspoređuje."""
    popis = [{"igrac": "A"}]
    novi, _ = p.zamijeni_u_popisu(popis, "A", "B")
    assert popis[0]["igrac"] == "A"
    assert novi[0]["igrac"] == "B"
    print("OK: izvorni popis ostaje netaknut")


def test_prazno_i_neocekivano():
    assert p.zamijeni_u_popisu(None, "A", "B") == (None, 0)
    assert p.zamijeni_u_popisu([], "A", "B") == ([], 0)
    # Postava zna imati i zapis bez imena; ne smije srušiti alat.
    novi, koliko = p.zamijeni_u_popisu([{"broj": "9"}, "nesto"], "A", "B")
    assert koliko == 0 and len(novi) == 2
    print("OK: prazno i neočekivano ne ruši alat")


def test_salju_se_samo_dirnuti_stupci():
    redak = {
        "id": 1,
        "postava_domacin": [{"igrac": "A"}],
        "postava_gost": [{"igrac": "C"}],
        "strijelci": [{"igrac": "A", "minuta": "5'"}],
    }
    promjene, ukupno = p.promjene_u_utakmici(redak, "A", "B")
    assert ukupno == 2, ukupno
    # Postava gosta se ne šalje, jer se u njoj ništa nije promijenilo.
    assert set(promjene) == {"postava_domacin", "strijelci"}, promjene
    assert promjene["postava_domacin"][0]["igrac"] == "B"
    print("OK: šalju se samo stupci u kojima je ime doista nađeno")


def test_utakmica_bez_imena_ne_daje_posao():
    redak = {"id": 2, "postava_domacin": [{"igrac": "C"}],
             "postava_gost": [], "strijelci": None}
    promjene, ukupno = p.promjene_u_utakmici(redak, "A", "B")
    assert promjene == {} and ukupno == 0
    print("OK: utakmica bez tog igrača se ne dira")


def test_slug_spojnica_i_razmak_daju_isto():
    """Zato se ne smije tvrditi da preimenovanje mijenja adresu."""
    assert p.slug_imena("Jakob Šprem-Veljavečki") == "jakob-sprem-veljavecki"
    assert p.slug_imena("Jakob Šprem Veljavečki") == "jakob-sprem-veljavecki"
    # Kvačice i đ idu u osnovno slovo, kao u lib/slug.ts.
    assert p.slug_imena("Đuro Čačić") == "duro-cacic"
    print("OK: slug je isti za spojnicu i razmak")


if __name__ == "__main__":
    test_zamjena_trazi_tocno_ime()
    test_ostala_polja_ostaju()
    test_izvornik_se_ne_dira()
    test_prazno_i_neocekivano()
    test_salju_se_samo_dirnuti_stupci()
    test_utakmica_bez_imena_ne_daje_posao()
    test_slug_spojnica_i_razmak_daju_isto()
    print("\nSVE PROLAZI")

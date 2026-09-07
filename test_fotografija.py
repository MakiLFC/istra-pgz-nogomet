"""
test_fotografija.py

Provjerava pripremu fotografije za članak: uspravljanje, smanjivanje,
sažimanje i ime pod kojim slika ide u Storage.

Nista se ne dohvaca s interneta i nista ne pise u bazu: slike se ovdje
stvaraju u memoriji.

POKRETANJE:  python test_fotografija.py
"""

import io
import sys

from PIL import Image

sys.path.insert(0, "alati")

from fotografija import (  # noqa: E402
    NAJVISE_BAJTOVA,
    SIRINA,
    ime_datoteke,
    pripremi,
    procisti_adresu,
)


def _slika(sirina, visina, exif=None):
    """Šarena slika, da je sažimanje ne svede na nekoliko bajtova."""
    slika = Image.new("RGB", (sirina, visina))
    piksela = slika.load()
    for x in range(sirina):
        for y in range(0, visina, 3):
            piksela[x, y] = ((x * 7) % 256, (y * 13) % 256, (x + y) % 256)
    spremnik = io.BytesIO()
    if exif is None:
        slika.save(spremnik, format="JPEG", quality=95)
    else:
        slika.save(spremnik, format="JPEG", quality=95, exif=exif)
    return spremnik.getvalue()


def test_siroka_se_smanji_na_1600():
    izlaz = pripremi(_slika(3000, 2000))
    nova = Image.open(io.BytesIO(izlaz))
    assert nova.width == SIRINA, nova.size
    assert nova.height == round(2000 * SIRINA / 3000), nova.size
    print("OK: široka fotografija se smanji na 1600")


def test_mala_se_ne_povecava():
    izlaz = pripremi(_slika(800, 600))
    nova = Image.open(io.BytesIO(izlaz))
    assert nova.size == (800, 600), nova.size
    print("OK: mala fotografija se ne razvlači")


def test_stane_u_300_kb():
    izlaz = pripremi(_slika(4000, 3000))
    assert len(izlaz) <= NAJVISE_BAJTOVA, len(izlaz)
    print(f"OK: sažeta na {len(izlaz) // 1024} KB, ograničenje je "
          f"{NAJVISE_BAJTOVA // 1024} KB")


def test_bocna_fotografija_se_uspravi():
    """Mobitel bočnu sliku sprema uspravno uz EXIF oznaku 6 (zakreni 90)."""
    exif = Image.Exif()
    exif[274] = 6
    izlaz = pripremi(_slika(1200, 900, exif=exif.tobytes()))
    nova = Image.open(io.BytesIO(izlaz))
    assert nova.size == (900, 1200), (
        f"EXIF orijentacija nije poštovana, dobiveno {nova.size}")
    print("OK: bočno snimljena fotografija se uspravi")


def test_ime_iz_sluga():
    putanja = ime_datoteke("osvrt-pomorac-jadran-porec-2-kolo-2627")
    assert putanja.endswith("/osvrt-pomorac-jadran-porec-2-kolo-2627.jpg"), putanja
    assert putanja.count("/") == 2, putanja
    print(f"OK: ime iz sluga, {putanja}")


def test_ime_bez_sluga():
    putanja = ime_datoteke("")
    assert putanja.endswith(".jpg"), putanja
    assert "slika-" in putanja, putanja
    print(f"OK: bez sluga se koristi datum, {putanja}")


def test_ime_bez_neuobicajenih_znakova():
    putanja = ime_datoteke("", "Žminj - Ližnjan!! 04.09.jpg")
    ime = putanja.rsplit("/", 1)[-1]
    assert ime == "minj-li-njan-04-09.jpg", ime
    print(f"OK: ime se očisti, {ime}")


ADRESA = "https://github.com/user-attachments/assets/58b85ab9-cd7f-49b3-b23d-b3ad539dea7d"


def test_adresa_iz_markdown_retka():
    """Ono što GitHub ubaci u polje za tekst kad se učita fotografija."""
    assert procisti_adresu(f"![slika]({ADRESA})") == ADRESA
    print("OK: adresa iz cijelog markdown retka")


def test_adresa_iz_html_oznake():
    assert procisti_adresu(f'<img src="{ADRESA}" width="400" />') == ADRESA
    print("OK: adresa iz HTML oznake")


def test_gola_adresa_prolazi():
    assert procisti_adresu(ADRESA) == ADRESA
    assert procisti_adresu(f"  {ADRESA}  \n") == ADRESA
    print("OK: gola adresa i razmaci oko nje")


def test_bez_poveznice_jasna_poruka():
    """Prazan unos ili tekst bez adrese mora reći što nedostaje."""
    for unos in ("", "   ", "slika s utakmice"):
        try:
            procisti_adresu(unos)
        except SystemExit as greska:
            assert "poveznica" in str(greska), str(greska)
        else:
            raise AssertionError(f"trebalo je stati na unosu {unos!r}")
    print("OK: bez poveznice ide jasna poruka")


if __name__ == "__main__":
    test_siroka_se_smanji_na_1600()
    test_mala_se_ne_povecava()
    test_stane_u_300_kb()
    test_bocna_fotografija_se_uspravi()
    test_ime_iz_sluga()
    test_ime_bez_sluga()
    test_ime_bez_neuobicajenih_znakova()
    test_adresa_iz_markdown_retka()
    test_adresa_iz_html_oznake()
    test_gola_adresa_prolazi()
    test_bez_poveznice_jasna_poruka()
    print("\nSVE PROLAZI")

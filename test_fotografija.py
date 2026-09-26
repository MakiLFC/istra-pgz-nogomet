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
    uokviri_cijelu,
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


def test_uspravna_se_smanji_po_visini():
    """Uspravna fotografija s mobitela, 1500x2000: širina je ispod granice,
    pa se stara provjera nije okidala i slika je ostajala prevelika."""
    izlaz = pripremi(_slika(1500, 2000))
    nova = Image.open(io.BytesIO(izlaz))
    assert max(nova.size) == SIRINA, nova.size
    assert nova.size == (1200, 1600), nova.size
    assert len(izlaz) <= NAJVISE_BAJTOVA, len(izlaz)
    print(f"OK: uspravna 1500x2000 postane {nova.size}, "
          f"{len(izlaz) // 1024} KB")


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
    print("OK: adresa iz HTML oznake s navodnicima")


def test_adresa_iz_html_oznake_bez_navodnika():
    """Točno ono što je GitHub ubacio 07.09.2026., bez navodnika oko vrijednosti."""
    uneseno = (f"<img width=1500 height=2000 alt=Image src={ADRESA} />")
    assert procisti_adresu(uneseno) == ADRESA
    print("OK: adresa iz HTML oznake bez navodnika")


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


def _vidi_se_cijela(platno, sirina, visina):
    """Stane li slika sirina x visina, stavljena u sredinu platna, cijela
    u okvir 3:2 (članak) i 16:9 (kartica) kad stranica reže višak."""
    for okvir in (3 / 2, 16 / 9):
        if platno.width / platno.height > okvir:
            vidljivo = (platno.height * okvir, platno.height)
        else:
            vidljivo = (platno.width, platno.width / okvir)
        if sirina > vidljivo[0] + 1 or visina > vidljivo[1] + 1:
            return False
    return True


def test_cijela_stane_u_oba_okvira():
    """Uspravna, položena, široka i već 16:9: cijela u članku i na kartici."""
    for sirina, visina in ((1200, 1600), (1600, 1200), (1600, 800),
                           (1600, 900), (900, 900)):
        slika = Image.new("RGB", (sirina, visina), (200, 30, 30))
        platno = uokviri_cijelu(slika)
        assert _vidi_se_cijela(platno, sirina, visina), (sirina, visina, platno.size)
        omjer = platno.width / platno.height
        assert 1.5 - 0.01 <= omjer <= 16 / 9 + 0.01, (sirina, visina, platno.size)
    print("OK: cijela slika stane i u 3:2 i u 16:9")


def test_cijela_fotografija_ostaje_netaknuta():
    """Fotografija je zalijepljena u sredinu u punoj veličini; podloga je
    samo sa strane."""
    slika = Image.new("RGB", (1200, 1600), (200, 30, 30))
    platno = uokviri_cijelu(slika)
    lijevo = (platno.width - 1200) // 2
    assert platno.getpixel((lijevo + 600, 800)) == (200, 30, 30)
    assert platno.getpixel((lijevo, 0)) == (200, 30, 30)
    assert platno.getpixel((lijevo + 1199, 1599)) == (200, 30, 30)
    # podloga je zatamnjena, dakle nije ista boja kao fotografija
    assert platno.getpixel((5, 800)) != (200, 30, 30)
    print(f"OK: 1200x1600 netaknuta na podlozi {platno.size}")


def test_cijela_uspravna_kroz_pripremu():
    izlaz = pripremi(_slika(1500, 2000), cijela=True)
    nova = Image.open(io.BytesIO(izlaz))
    assert nova.size == (1600, 900), nova.size
    assert len(izlaz) <= NAJVISE_BAJTOVA, len(izlaz)
    print(f"OK: uspravna 1500x2000 kao cijela postane {nova.size}, "
          f"{len(izlaz) // 1024} KB")


def test_bez_cijele_nista_se_ne_mijenja():
    izlaz = pripremi(_slika(1500, 2000))
    assert Image.open(io.BytesIO(izlaz)).size == (1200, 1600)
    print("OK: bez kvačice slika ostaje u svom omjeru")


if __name__ == "__main__":
    test_siroka_se_smanji_na_1600()
    test_uspravna_se_smanji_po_visini()
    test_mala_se_ne_povecava()
    test_stane_u_300_kb()
    test_bocna_fotografija_se_uspravi()
    test_ime_iz_sluga()
    test_ime_bez_sluga()
    test_ime_bez_neuobicajenih_znakova()
    test_adresa_iz_markdown_retka()
    test_adresa_iz_html_oznake()
    test_adresa_iz_html_oznake_bez_navodnika()
    test_gola_adresa_prolazi()
    test_bez_poveznice_jasna_poruka()
    test_cijela_stane_u_oba_okvira()
    test_cijela_fotografija_ostaje_netaknuta()
    test_cijela_uspravna_kroz_pripremu()
    test_bez_cijele_nista_se_ne_mijenja()
    print("\nSVE PROLAZI")

"""
alati/izrezi_sliku.py

Skida fotografiju s interneta, reže je na zadani omjer i sprema kao JPEG
pripremljen za stranicu (širina 1600, do 300 KB).

Zašto postoji: fotografije uz članke stižu s mobitela, uspravne i velike.
U članku se slika prikazuje cijela, u svom omjeru, pa uspravna zauzme
gotovo cijeli ekran, a na kartici u popisu novosti bude odrezana na 16:9
iz sredine, često baš preko onoga što je važno. Bolje je izrezati je
unaprijed i sam odabrati kadar.

POKRETANJE (obično kroz posao "Izreži sliku" na GitHubu):
    python alati/izrezi_sliku.py \
        --adresa "https://.../slika.jpeg" \
        --izlaz public/slike/clanci/lokomotiva-crikvenica-2026-09-04.jpg \
        --omjer 3:2 --pomak 60

POMAK govori gdje unutar visoke slike leži izrezani pojas: 0 je vrh,
50 sredina, 100 dno. Kod uspravne fotografije s neba gore i terenom dolje
obično se uzima 55 do 70, da otpadnu nebo i prvi plan, a ostane ono glavno.
"""

import argparse
import io
import sys
import time

import requests
from PIL import Image

ZAGLAVLJA = {"User-Agent": "Lokal-Arena alat za slike"}


def dohvati(adresa, najvise_pokusaja=3):
    """Skida sliku, uz ponavljanje kad poslužitelj ne odgovori iz prve."""
    zadnja = None
    for pokusaj in range(1, najvise_pokusaja + 1):
        try:
            odgovor = requests.get(adresa, headers=ZAGLAVLJA, timeout=30)
            odgovor.raise_for_status()
            return odgovor.content
        except requests.RequestException as greska:
            zadnja = greska
            if pokusaj < najvise_pokusaja:
                print(f"  nije uspjelo ({greska.__class__.__name__}), "
                      f"pokušaj {pokusaj} od {najvise_pokusaja}")
                time.sleep(5 * pokusaj)
    raise zadnja


def okvir(sirina, visina, omjer, pomak):
    """Koji pravokutnik izrezati, uz zadani omjer i okomiti pomak.

    Uzima se najveći pravokutnik traženog omjera koji stane u sliku.
    Kod previsoke slike bira se pojas po visini (pomak), kod preširoke
    se reže simetrično s obje strane.
    """
    if sirina / visina > omjer:
        nova_sirina = round(visina * omjer)
        lijevo = (sirina - nova_sirina) // 2
        return (lijevo, 0, lijevo + nova_sirina, visina)

    nova_visina = round(sirina / omjer)
    gore = round((visina - nova_visina) * pomak / 100)
    return (0, gore, sirina, gore + nova_visina)


def spremi_do_velicine(slika, izlaz, najvise_kb):
    """Sprema JPEG i spušta kakvoću dok datoteka ne stane u granicu."""
    for kakvoca in (88, 82, 76, 70, 64):
        spremnik = io.BytesIO()
        slika.save(spremnik, format="JPEG", quality=kakvoca, optimize=True,
                   progressive=True)
        if spremnik.tell() <= najvise_kb * 1024 or kakvoca == 64:
            with open(izlaz, "wb") as f:
                f.write(spremnik.getvalue())
            return spremnik.tell(), kakvoca
    raise RuntimeError("nedostižno")


def main():
    p = argparse.ArgumentParser(description="Izreži fotografiju za članak.")
    p.add_argument("--adresa", required=True, help="adresa slike na internetu")
    p.add_argument("--izlaz", required=True, help="putanja izlazne datoteke")
    p.add_argument("--omjer", default="3:2", help="npr. 3:2, 16:9, 4:3")
    p.add_argument("--pomak", type=float, default=50,
                   help="0 vrh, 50 sredina, 100 dno (zadano 50)")
    p.add_argument("--sirina", type=int, default=1600,
                   help="najveća širina u pikselima (zadano 1600)")
    p.add_argument("--najvise-kb", type=int, default=300,
                   help="gornja granica veličine datoteke (zadano 300)")
    args = p.parse_args()

    sirina_o, visina_o = (int(d) for d in args.omjer.split(":"))
    omjer = sirina_o / visina_o
    if not 0 <= args.pomak <= 100:
        raise SystemExit("--pomak mora biti između 0 i 100.")

    print(f"Skidam: {args.adresa}")
    slika = Image.open(io.BytesIO(dohvati(args.adresa)))
    slika = slika.convert("RGB")
    print(f"Izvorna slika: {slika.width}x{slika.height}")

    slika = slika.crop(okvir(slika.width, slika.height, omjer, args.pomak))
    print(f"Nakon rezanja na {args.omjer} (pomak {args.pomak}): "
          f"{slika.width}x{slika.height}")

    if slika.width > args.sirina:
        nova_visina = round(slika.height * args.sirina / slika.width)
        slika = slika.resize((args.sirina, nova_visina), Image.LANCZOS)
        print(f"Smanjeno na: {slika.width}x{slika.height}")

    velicina, kakvoca = spremi_do_velicine(slika, args.izlaz, args.najvise_kb)
    print(f"Spremljeno: {args.izlaz}, {round(velicina / 1024)} KB, "
          f"kakvoća {kakvoca}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

"""
alati/fotografija.py

Jedan potez od fotografije s mobitela do slike na članku.

ŠTO RADI
  1. skine fotografiju s njezine adrese
  2. uspravi je ako je snimljena bočno (EXIF orijentacija)
  3. smanji na širinu 1600 i sažme na najviše 300 KB
  4. učita je u Supabase Storage, spremnik "clanci"
  5. ako je zadan slug članka, odmah upiše adresu, opis, potpis i kadar

ZAŠTO POSTOJI
  Prije ovoga je uz svaku fotografiju išlo: otvori Supabase na računalu,
  Storage, spremnik clanci, učitaj, kopiraj adresu, zalijepi u SQL,
  pokreni SQL. Petkom navečer, kad se žuri s objavom, to je bilo predugo.
  Ovdje je sve to jedan posao na GitHubu, koji radi i s mobitela.

  Rezanje nije potrebno: stranica sama uklopi sliku u 3:2 u članku i 16:9
  na kartici. Koji se dio po visini zadrži govori stupac slika_kadar.

POKRETANJE (obično kroz posao "Fotografija za članak" na GitHubu):
    python alati/fotografija.py \
        --adresa "https://github.com/user-attachments/assets/..." \
        --slug osvrt-pomorac-jadran-porec-2-kolo-2627 \
        --kadar 15 \
        --opis "Pomoćno igralište na Žuknici"

Bez --slug samo učita sliku i ispiše adresu, pa se upiše ručno.

TRAŽI dvije varijable okoline, iste kao scraper:
    SUPABASE_URL, SUPABASE_SERVICE_KEY
"""

import argparse
import functools
import io
import os
import re
import sys
import time
from datetime import date

import requests
from PIL import Image, ImageOps

print = functools.partial(print, flush=True)  # zapisnik ide redom

ZAGLAVLJA = {"User-Agent": "Lokal-Arena alat za slike"}

SIRINA = 1600          # širina na koju se slika smanjuje
NAJVISE_BAJTOVA = 300 * 1024
SPREMNIK = "clanci"    # spremnik u Supabase Storageu


def procisti_adresu(uneseno):
    """Iz onoga što je zalijepljeno izvlači adresu slike.

    GitHub pri učitavanju fotografije u polje za tekst ubaci cijeli redak,
    npr.  ![ime](https://github.com/user-attachments/assets/...)
    ili, kod nekih formata,  <img src="https://..." width="400" />

    Tražiti od korisnika da mišem označi točno ono unutar zagrade je
    poziv na grešku: 07.09.2026. je prvo pokretanje palo jer su dva znaka
    s kraja adrese završila na njezinu početku. Zato se ovdje prihvaća
    ŠTO GOD da je zalijepljeno i iz toga izvuče prva adresa.
    """
    tekst = (uneseno or "").strip()
    nadjeno = re.search(r"https?://[^\s\)\]\"'>]+", tekst)
    if not nadjeno:
        raise SystemExit(
            "U polje 'adresa' nije stigla nijedna poveznica.\n"
            f"Zalijepljeno je: {tekst[:200]}\n"
            "Očekuje se nešto što počinje s http, npr. cijeli redak koji "
            "GitHub ubaci nakon što se fotografija učita:\n"
            "  ![slika](https://github.com/user-attachments/assets/...)"
        )
    return nadjeno.group(0)


def dohvati(adresa, najvise_pokusaja=3):
    """Skida sliku, uz ponavljanje kad poslužitelj ne odgovori iz prve.

    Isto pravilo kao kod HNS-a: mrežni prekid nije naša greška, ali se
    prijavljuje ako ni treći put ne uspije.
    """
    zadnja = None
    for pokusaj in range(1, najvise_pokusaja + 1):
        try:
            odgovor = requests.get(adresa, headers=ZAGLAVLJA, timeout=30)
            odgovor.raise_for_status()
            return odgovor.content
        except requests.RequestException as greska:
            zadnja = greska
            if pokusaj < najvise_pokusaja:
                pauza = 5 * pokusaj
                print(f"  dohvat nije uspio ({greska}), pokušavam za {pauza} s")
                time.sleep(pauza)
    raise SystemExit(f"Slika se ne može skinuti: {zadnja}")


def pripremi(sadrzaj):
    """Uspravi, smanji i sažmi fotografiju. Vraća bajtove JPEG-a.

    EXIF ORIJENTACIJA je ovdje bitna: mobitel bočno snimljenu fotografiju
    sprema uspravno uz oznaku "zakreni pri prikazu". Alat koji tu oznaku
    ne poštuje dobije sliku položenu na stranu. Zato exif_transpose.
    """
    slika = Image.open(io.BytesIO(sadrzaj))
    slika = ImageOps.exif_transpose(slika)
    if slika.mode != "RGB":
        slika = slika.convert("RGB")

    if slika.width > SIRINA:
        visina = round(slika.height * SIRINA / slika.width)
        slika = slika.resize((SIRINA, visina), Image.LANCZOS)

    # Kvaliteta se spušta dok datoteka ne stane u ograničenje. Ispod 40 se
    # ne ide, jer tada slika vidljivo propada; radije ostane malo veća.
    for kvaliteta in (88, 82, 76, 70, 64, 58, 52, 46, 40):
        spremnik = io.BytesIO()
        slika.save(spremnik, format="JPEG", quality=kvaliteta, optimize=True)
        if spremnik.tell() <= NAJVISE_BAJTOVA or kvaliteta == 40:
            print(f"  {slika.width}x{slika.height}, kvaliteta {kvaliteta}, "
                  f"{spremnik.tell() // 1024} KB")
            return spremnik.getvalue()


def ime_datoteke(slug, zadano_ime=None):
    """Ime pod kojim slika ide u Storage: godina/mjesec/ime.jpg.

    Razvrstavanje po mjesecima postoji da spremnik za koju godinu ostane
    pregledan. Ime se izvodi iz sluga članka, jer je tada odmah jasno
    kojem članku slika pripada.
    """
    if zadano_ime:
        osnova = zadano_ime
    elif slug:
        osnova = slug
    else:
        osnova = f"slika-{date.today().isoformat()}"
    # Nastavak se skida PRIJE čišćenja, inače točka iz ".jpg" postane
    # spojnica pa ime završi kao "...-jpg.jpg".
    osnova = re.sub(r"\.(jpe?g|png|heic|webp)$", "", osnova, flags=re.I)
    osnova = re.sub(r"[^a-z0-9-]+", "-", osnova.lower()).strip("-")
    osnova = re.sub(r"-{2,}", "-", osnova) or "slika"
    osnova += ".jpg"
    danas = date.today()
    return f"{danas.year}/{danas.month:02d}/{osnova}"


def ucitaj_u_storage(adresa_baze, kljuc, putanja, bajtovi):
    """Šalje sliku u Storage i vraća njezinu javnu adresu.

    Ide izravno na REST, a ne kroz supabase paket, jer se sučelje za
    Storage u tom paketu mijenjalo između izdanja, a ovo je stabilno.
    Zaglavlje x-upsert dopušta da se ista slika pošalje ponovno, npr. kad
    se zamijeni krivo odabrana fotografija.
    """
    cilj = f"{adresa_baze}/storage/v1/object/{SPREMNIK}/{putanja}"
    odgovor = requests.post(
        cilj,
        headers={
            "Authorization": f"Bearer {kljuc}",
            "Content-Type": "image/jpeg",
            "x-upsert": "true",
        },
        data=bajtovi,
        timeout=60,
    )
    if odgovor.status_code >= 400:
        raise SystemExit(f"Storage je odbio sliku ({odgovor.status_code}): "
                         f"{odgovor.text}")
    return f"{adresa_baze}/storage/v1/object/public/{SPREMNIK}/{putanja}"


def upisi_u_clanak(adresa_baze, kljuc, slug, adresa_slike, opis, potpis, kadar):
    """Upisuje sliku u redak članka. Vraća je li redak pronađen."""
    cilj = f"{adresa_baze}/rest/v1/clanci?slug=eq.{slug}"
    podaci = {
        "slika_url": adresa_slike,
        "slika_potpis": potpis,
        "slika_kadar": kadar,
    }
    if opis:
        podaci["slika_opis"] = opis
    odgovor = requests.patch(
        cilj,
        headers={
            "apikey": kljuc,
            "Authorization": f"Bearer {kljuc}",
            "Content-Type": "application/json",
            "Prefer": "return=representation",
        },
        json=podaci,
        timeout=30,
    )
    if odgovor.status_code >= 400:
        raise SystemExit(f"Upis u članak nije uspio ({odgovor.status_code}): "
                         f"{odgovor.text}")
    return bool(odgovor.json())


def main():
    p = argparse.ArgumentParser(description="Fotografija za članak")
    p.add_argument("--adresa", required=True, help="javna adresa fotografije")
    p.add_argument("--slug", default="", help="slug članka; bez njega se samo učitava")
    p.add_argument("--ime", default="", help="ime datoteke, zadano je slug članka")
    p.add_argument("--kadar", default="sredina",
                   help="okomiti kadar: vrh, sredina, dno ili broj 0 do 100")
    p.add_argument("--opis", default="", help="opis slike za čitače ekrana")
    p.add_argument("--potpis", default="Foto: Lokal-Arena")
    args = p.parse_args()

    adresa_baze = (os.environ.get("SUPABASE_URL") or "").rstrip("/")
    kljuc = os.environ.get("SUPABASE_SERVICE_KEY")
    if not adresa_baze or not kljuc:
        raise SystemExit("Nedostaju SUPABASE_URL i SUPABASE_SERVICE_KEY.")

    adresa = procisti_adresu(args.adresa)
    if adresa != (args.adresa or "").strip():
        print(f"Iz unosa je izvučena adresa: {adresa}")
    print(f"Skidam: {adresa}")
    bajtovi = pripremi(dohvati(adresa))

    putanja = ime_datoteke(args.slug, args.ime)
    adresa_slike = ucitaj_u_storage(adresa_baze, kljuc, putanja, bajtovi)
    print(f"\nSlika je u Storageu:\n{adresa_slike}")

    if not args.slug:
        print("\nSlug nije zadan, pa članak nije diran. Upiši je ovako:")
        print(f"""
update public.clanci
set slika_url   = '{adresa_slike}',
    slika_opis  = 'OPIS SLIKE',
    slika_potpis = '{args.potpis}',
    slika_kadar = '{args.kadar}'
where slug = 'SLUG-CLANKA';""")
        return

    nasao = upisi_u_clanak(adresa_baze, kljuc, args.slug, adresa_slike,
                           args.opis, args.potpis, args.kadar)
    if not nasao:
        raise SystemExit(f"Članak sa slugom '{args.slug}' ne postoji. "
                         "Slika je učitana, samo je nije bilo gdje upisati.")
    print(f"\nUpisano u članak '{args.slug}'. Kadar: {args.kadar}.")
    if not args.opis:
        print("Opis slike nije zadan. Dodaj ga kasnije, služi čitačima "
              "ekrana i dijeljenju na društvenim mrežama.")


if __name__ == "__main__":
    sys.exit(main())

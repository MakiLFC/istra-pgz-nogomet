"""
preuzmi_grbove.py

Skida grbove klubova sa stranica natjecanja na Semaforu, za slike najava
i pregleda kola. Spremaju se u alati/najave/grbovi/, uz popis.json koji
kaže koja datoteka pripada kojem klubu (ime kluba točno kako ga piše HNS).

ZAŠTO SE GRBOVI UOPĆE KORISTE
Pravi grbovi nisu dio dopuštenja koje je HNS dao za podatke. Andrej je
28.09.2026. odlučio da ih se ipak koristi, na svoju odgovornost, uz
vlastitu obradu (okvir, izbočenje, sjena). Vidi PROCITAJ.md.

KAKO SE POKREĆE
Preko posla "Grbovi klubova" na GitHubu, jer se Semafor iz okruženja
Claude Code na webu ne može otvoriti. Na računalu:

    python alati/najave/preuzmi_grbove.py

KAKO SE GRB PREPOZNAJE
U retku rasporeda domaćin ima grb lijevo od imena, a gost desno. Grb se
zato traži UNUTAR poveznice kluba ili odmah uz nju, u istom retku. Kad se
za klub ne nađe, ništa se ne pogađa: klub ostaje bez grba i to se ispiše
na kraju, a za dijagnozu se ispiše i HTML prvog retka rasporeda.
"""

import hashlib
import json
import os
import re
import sys
import unicodedata
from urllib.parse import urljoin

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

from bs4 import BeautifulSoup  # noqa: E402
import requests  # noqa: E402

from scraper_supabase import NATJECANJA, HEADERS, dohvati_stranicu  # noqa: E402

MAPA = os.path.join(os.path.dirname(__file__), "grbovi")
NASTAVCI = {
    "image/png": ".png", "image/jpeg": ".jpg", "image/webp": ".webp",
    "image/svg+xml": ".svg", "image/gif": ".gif",
}


def slug(ime):
    t = unicodedata.normalize("NFKD", ime).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "-", t.lower()).strip("-")


def adresa_slike(img):
    """Prava adresa slike; lijeno učitavanje zna je staviti u data-src."""
    for atribut in ("data-src", "data-lazy-src", "src"):
        v = img.get(atribut)
        if v and not v.startswith("data:"):
            return v
    srcset = img.get("srcset") or img.get("data-srcset")
    if srcset:
        return srcset.split(",")[-1].strip().split(" ")[0]
    return None


def grb_uz_poveznicu(poveznica, redak, je_domacin):
    """Slika grba za jedan klub u retku rasporeda, ili None."""
    img = poveznica.find("img")
    if img:
        return img
    # Slika uz poveznicu: domaćinova je prije imena, gostova poslije.
    slike = redak.find_all("img")
    if len(slike) == 2:
        return slike[0] if je_domacin else slike[1]
    return None


def grbovi_natjecanja(url):
    soup = BeautifulSoup(dohvati_stranicu(url).text, "html.parser")
    nadeno = {}
    prvi_redak = None
    for redak in soup.find_all(["li", "div"]):
        poveznice = redak.find_all("a", href=lambda h: h and "/klubovi/" in h)
        if len(poveznice) != 2:
            continue
        # najuži element s točno dva kluba, kao u scraperu
        if redak.find(lambda t: t.name in ("li", "div") and t is not redak
                      and len(t.find_all("a", href=lambda h: h and "/klubovi/" in h)) == 2):
            continue
        if prvi_redak is None:
            prvi_redak = redak
        for i, a in enumerate(poveznice):
            ime = a.get_text(strip=True)
            if not ime or ime in nadeno:
                continue
            img = grb_uz_poveznicu(a, redak, i == 0)
            src = adresa_slike(img) if img else None
            if src:
                nadeno[ime] = urljoin(url, src)
    # Rezerva: kartice klubova u sekciji "Klubovi u natjecanju".
    for a in soup.find_all("a", href=lambda h: h and "/klubovi/" in h):
        ime = a.get_text(strip=True)
        img = a.find("img")
        if ime and img and ime not in nadeno and adresa_slike(img):
            nadeno[ime] = urljoin(url, adresa_slike(img))
    return nadeno, prvi_redak


def main():
    os.makedirs(MAPA, exist_ok=True)
    popis_put = os.path.join(MAPA, "popis.json")
    popis = {}
    if os.path.exists(popis_put):
        popis = json.load(open(popis_put, encoding="utf-8")).get("klubovi", {})

    bez_grba = []
    for n in NATJECANJA:
        print(f"\n== {n['naziv']}")
        nadeno, prvi_redak = grbovi_natjecanja(n["url"])
        print(f"   grbova nađeno: {len(nadeno)}")
        if not nadeno and prvi_redak is not None:
            print("   HTML prvog retka rasporeda, za dijagnozu:")
            print(str(prvi_redak)[:3000])
        for ime, src in sorted(nadeno.items()):
            try:
                r = requests.get(src, headers=HEADERS, timeout=30)
                r.raise_for_status()
            except requests.RequestException as g:
                print(f"   {ime}: slika se ne može skinuti ({g})")
                bez_grba.append(ime)
                continue
            vrsta = r.headers.get("Content-Type", "").split(";")[0].strip()
            nastavak = NASTAVCI.get(vrsta) or os.path.splitext(src.split("?")[0])[1] or ".png"
            datoteka = slug(ime) + nastavak
            with open(os.path.join(MAPA, datoteka), "wb") as f:
                f.write(r.content)
            popis[ime] = {
                "datoteka": datoteka,
                "izvor": src,
                "sha1": hashlib.sha1(r.content).hexdigest()[:12],
                "natjecanje": n["naziv"],
            }
            print(f"   {ime}: {datoteka} ({len(r.content)} B, {vrsta or '?'})")

    with open(popis_put, "w", encoding="utf-8") as f:
        json.dump({"_napomena": "Tko je koji grb. Puni ga preuzmi_grbove.py, ne ručno.",
                   "klubovi": dict(sorted(popis.items()))}, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"\nUkupno klubova s grbom: {len(popis)}")
    if bez_grba:
        print("BEZ GRBA:", ", ".join(bez_grba))


if __name__ == "__main__":
    main()

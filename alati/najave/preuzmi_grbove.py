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
import io
import json
import os
import re
import sys
import unicodedata
from urllib.parse import urljoin

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

from bs4 import BeautifulSoup  # noqa: E402
from PIL import Image  # noqa: E402
import requests  # noqa: E402

from scraper_supabase import (  # noqa: E402
    NATJECANJA, HEADERS, dohvati_stranicu, dohvati_popis_utakmica,
)

MAPA = os.path.join(os.path.dirname(__file__), "grbovi")


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


def bez_pozadine(sadrzaj):
    """PNG s prozirnom pozadinom. Bijela pozadina JPG i GIF grbova
    uklanja se poplavom od ruba slike: prozirno postaje samo svijetlo što
    je povezano s rubom, pa bijelo UNUTAR grba ostaje. Rub se omekša, da
    obrub ne bude nazubljen."""
    slika = Image.open(io.BytesIO(sadrzaj)).convert("RGBA")
    s, v = slika.size
    px = slika.load()

    # Bijela pozadina: dovoljan je jedan bijeli kut, jer grb zna dirati
    # ostale. Crna mora biti u sva četiri, jer crnog zna biti i u grbu.
    # Druge boje se ne diraju: tada je kvadrat najčešće dio samog grba.
    kutovi = [px[0, 0], px[s - 1, 0], px[0, v - 1], px[s - 1, v - 1]]
    if all(k[3] == 0 for k in kutovi):
        return slika  # već ima prozirnu pozadinu
    bijela = any(k[3] > 0 and min(k[:3]) >= 225 for k in kutovi)
    crna = all(k[3] > 0 and max(k[:3]) <= 40 for k in kutovi)
    if not (bijela or crna):
        return slika

    def pozadina(x, y):
        r, g, b, a = px[x, y]
        if a == 0:
            return True
        if bijela:
            return min(r, g, b) >= 225 and max(r, g, b) - min(r, g, b) <= 24
        return max(r, g, b) <= 40

    vidjeno = set()
    red = [(x, y) for x in range(s) for y in (0, v - 1)] + [(x, y) for y in range(v) for x in (0, s - 1)]
    while red:
        x, y = red.pop()
        if (x, y) in vidjeno or not (0 <= x < s and 0 <= y < v):
            continue
        if not pozadina(x, y):
            continue
        vidjeno.add((x, y))
        red.extend([(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)])
    for x, y in vidjeno:
        px[x, y] = (0, 0, 0, 0)
    # meki rub: svijetli pikseli uz uklonjenu pozadinu djelomično prozirni
    for x, y in list(vidjeno):
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < s and 0 <= ny < v and (nx, ny) not in vidjeno:
                r, g, b, a = px[nx, ny]
                if a != 255:
                    continue
                if bijela and min(r, g, b) > 170:
                    px[nx, ny] = (r, g, b, int(255 * (255 - min(r, g, b)) / 85))
                elif crna and max(r, g, b) < 85:
                    px[nx, ny] = (r, g, b, int(255 * max(r, g, b) / 85))
    return slika


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
    # Samo klubovi iz rasporeda. Stranica ima i izbornik s klubovima iz
    # drugih liga (Dinamo, Hajduk...) i ljestvicu s imenima poput
    # "NK Crikvenica (-3)"; ništa od toga ovamo ne pripada.
    return nadeno, prvi_redak


def main():
    os.makedirs(MAPA, exist_ok=True)
    popis_put = os.path.join(MAPA, "popis.json")
    # Popis se slaže ispočetka, da klub koji je otišao iz naših liga ne
    # ostane u njemu zauvijek.
    popis = {}

    bez_grba = []
    for n in NATJECANJA:
        print(f"\n== {n['naziv']}")
        nadeno, prvi_redak = grbovi_natjecanja(n["url"])
        # Samo klubovi s rasporeda te lige, kako ga čita scraper. Stranica
        # ima i klubove iz drugih natjecanja (izbornik, kup), a ljestvica
        # imena s kaznenim bodovima ("NK Crikvenica (-3)").
        klubovi = set()
        for u in dohvati_popis_utakmica(n["url"]):
            klubovi.update((u["domacin"], u["gost"]))
        visak = sorted(set(nadeno) - klubovi)
        if visak:
            print("   izvan rasporeda, preskačem:", ", ".join(visak))
        nadeno = {k: v for k, v in nadeno.items() if k in klubovi}
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
            datoteka = slug(ime) + ".png"
            try:
                bez_pozadine(r.content).save(os.path.join(MAPA, datoteka), optimize=True)
            except Exception as g:  # nije slika
                print(f"   {ime}: slika se ne može pročitati ({g})")
                bez_grba.append(ime)
                continue
            popis[ime] = {
                "datoteka": datoteka,
                "izvor": src,
                "sha1": hashlib.sha1(r.content).hexdigest()[:12],
                "natjecanje": n["naziv"],
            }
            print(f"   {ime}: {datoteka} ({len(r.content)} B, {vrsta or '?'})")

    for stara in os.listdir(MAPA):
        if stara != "popis.json" and stara not in {v["datoteka"] for v in popis.values()}:
            os.remove(os.path.join(MAPA, stara))

    with open(popis_put, "w", encoding="utf-8") as f:
        json.dump({"_napomena": "Tko je koji grb. Puni ga preuzmi_grbove.py, ne ručno.",
                   "klubovi": dict(sorted(popis.items()))}, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"\nUkupno klubova s grbom: {len(popis)}")
    if bez_grba:
        print("BEZ GRBA:", ", ".join(bez_grba))


if __name__ == "__main__":
    main()

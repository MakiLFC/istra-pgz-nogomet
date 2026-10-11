"""
provjera_rss.py

Provjerava RSS feed Lokal-Arene (/rss.xml) i ispisuje prve dvije stavke.
Pokreće ga posao "Provjera RSS-a" na GitHubu, koji feed prvo skine s
prave stranice i pošalje ga W3C validatoru.

    python alati/provjera_rss.py rss.xml [odgovor_w3c.xml]

ŠTO SE PROVJERAVA
Osim da je XML ispravan, provjerava se i UVJET DOPUŠTENJA: aplikacija koja
čita feed smije prikazati samo naslov, kratki opis, datum i poveznicu
(vidi lib/rss.ts). Zato posao pada i kad se u feedu pojavi slika, puni
tekst članka ili bilo koji element izvan dogovorenog popisa.

Drugi argument je odgovor W3C validatora u obliku SOAP (output=soap12).
Kad ga nema, provjerava se samo sam feed.
"""

import re
import sys
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from email.utils import parsedate_to_datetime

ATOM = "{http://www.w3.org/2005/Atom}"
DOPUSTENO_U_KANALU = {"title", "link", "description", "language",
                      "lastBuildDate", f"{ATOM}link", "item"}
DOPUSTENO_U_STAVCI = {"title", "link", "guid", "pubDate", "description",
                      "category"}
NAJVISE_STAVKI = 30


def provjeri_feed(xml_tekst, osnova="https://lokalarena.com"):
    """Vraća (greske, stavke). Stavke su rječnici za ispis."""
    greske = []
    try:
        korijen = ET.fromstring(xml_tekst.encode("utf-8"))
    except ET.ParseError as e:
        return [f"XML nije ispravan: {e}"], []

    if korijen.tag != "rss" or korijen.get("version") != "2.0":
        greske.append("korijen nije <rss version=\"2.0\">")
    kanal = korijen.find("channel")
    if kanal is None:
        return greske + ["nema <channel>"], []

    for dijete in kanal:
        if dijete.tag not in DOPUSTENO_U_KANALU:
            greske.append(f"kanal ima nedopušten element <{dijete.tag}>")
    for polje in ("title", "link", "description", "language", "lastBuildDate"):
        if not (kanal.findtext(polje) or "").strip():
            greske.append(f"kanal nema <{polje}>")
    sam = kanal.find(f"{ATOM}link")
    if sam is None or sam.get("rel") != "self" or not (sam.get("href") or "").endswith("/rss.xml"):
        greske.append("kanal nema atom:link rel=\"self\" na /rss.xml")

    stavke = kanal.findall("item")
    if len(stavke) > NAJVISE_STAVKI:
        greske.append(f"feed ima {len(stavke)} stavki, najviše smije {NAJVISE_STAVKI}")

    sada = datetime.now(timezone.utc)
    prethodni = None
    ispis = []
    for n, s in enumerate(stavke, 1):
        oznaka = f"stavka {n}"
        for dijete in s:
            if dijete.tag not in DOPUSTENO_U_STAVCI:
                greske.append(f"{oznaka}: nedopušten element <{dijete.tag}>")
        naslov = (s.findtext("title") or "").strip()
        link = (s.findtext("link") or "").strip()
        guid = s.find("guid")
        opis = s.findtext("description")
        datum_tekst = (s.findtext("pubDate") or "").strip()

        if not naslov:
            greske.append(f"{oznaka}: nema naslova")
        if not link.startswith(f"{osnova}/novosti/"):
            greske.append(f"{oznaka}: poveznica nije {osnova}/novosti/...: {link}")
        if guid is None or guid.get("isPermaLink") != "true" or (guid.text or "").strip() != link:
            greske.append(f"{oznaka}: guid nije isti kao poveznica uz isPermaLink=\"true\"")
        if opis is not None and re.search(r"<[a-zA-Z/]", opis):
            greske.append(f"{oznaka}: opis sadrži HTML")
        try:
            datum = parsedate_to_datetime(datum_tekst)
            if datum > sada:
                greske.append(f"{oznaka}: datum objave je u budućnosti")
            if prethodni and datum > prethodni:
                greske.append(f"{oznaka}: stavke nisu poredane od najnovije")
            prethodni = datum
        except (TypeError, ValueError):
            greske.append(f"{oznaka}: pubDate nije RFC 822: {datum_tekst!r}")

        ispis.append({"title": naslov, "link": link, "pubDate": datum_tekst,
                      "description": opis, "category": s.findtext("category")})
    return greske, ispis


def procitaj_w3c(soap):
    """Iz SOAP odgovora W3C validatora: (valjan, broj_gresaka, upozorenja)."""
    valjan = re.search(r"<m:validity>\s*(\w+)\s*</m:validity>", soap)
    greske = re.search(r"<m:errorcount>\s*(\d+)\s*</m:errorcount>", soap)
    upozorenja = re.findall(r"<text>(.*?)</text>", soap, re.S)
    return ((valjan.group(1) == "true") if valjan else None,
            int(greske.group(1)) if greske else None,
            [u.strip() for u in upozorenja])


def main():
    if len(sys.argv) not in (2, 3):
        raise SystemExit("Uporaba: python alati/provjera_rss.py rss.xml [odgovor_w3c.xml]")
    with open(sys.argv[1], encoding="utf-8") as f:
        tekst = f.read()

    greske, stavke = provjeri_feed(tekst)
    print(f"Stavki u feedu: {len(stavke)}")
    for n, s in enumerate(stavke[:2], 1):
        print(f"\n--- stavka {n} ---")
        for k in ("title", "link", "pubDate", "category", "description"):
            if s[k] is not None:
                print(f"  {k}: {s[k]}")

    if len(sys.argv) == 3:
        with open(sys.argv[2], encoding="utf-8") as f:
            valjan, br_gresaka, poruke = procitaj_w3c(f.read())
        print(f"\nW3C validator: valjan={valjan}, greške={br_gresaka}")
        for p in poruke:
            print(f"  napomena: {p}")
        if valjan is not True:
            greske.append("W3C validator feed ne smatra valjanim")

    if greske:
        print("\nGREŠKE:")
        for g in greske:
            print(f"  - {g}")
        sys.exit(1)
    print("\nFeed je u redu.")


if __name__ == "__main__":
    main()

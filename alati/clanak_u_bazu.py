"""
clanak_u_bazu.py

Upisuje članak iz datoteke u tablicu clanci u Supabaseu, objavljuje ga,
skida sa stranice ili briše. Pokreće ga posao "Članak u bazu" na GitHubu.

ČEMU SLUŽI
Članci su se do 03.10.2026. upisivali isključivo kroz SQL Editor u
Supabaseu, a za to je trebalo računalo: tekst je dugačak i na mobitelu se
teško točno kopira. Sada Claude napiše članak u datoteku u mapi
"clanci", spremi je na main i pokrene ovaj posao, a Andrej u razgovoru
samo kaže "objavi". Ni Supabase ni laptop nisu potrebni.

OBLIK DATOTEKE  clanci/<slug>.txt
Zaglavlje redak po redak, "ključ: vrijednost", pa crta od tri spojnice,
pa tekst članka točno onako kako ide na stranicu:

    slug: najava-5-kola-1-znl-pgz-2627
    naslov: NAJAVA 5. KOLA: ...
    sazetak: Vodeći Lovran ...
    natjecanje: 1. ŽNL PGŽ
    slika_url: /slike/najave/najava-redovi-1-znl-pgz-kolo-5-cijela.png
    slika_opis: Raspored 5. kola ...
    ---
    Peto kolo 1. ŽNL PGŽ igra se ...

Obavezni su slug, naslov, sazetak i natjecanje (prazno ili "nema" znači
da članak ne ide pod ligu). Slika, opis, potpis i kadar nisu obavezni.
Slug mora biti jednak imenu datoteke, da se ne upiše tuđi članak.

RADNJE
  upis           upiše novi članak kao NEOBJAVLJEN, a postojećem prepiše
                 naslov, sažetak, tekst, ligu i sliku. Objavljenost i datum
                 objave ne dira, pa se ispravak objavljenog članka vidi
                 odmah, a neobjavljeni ostaje skriven.
  upis-i-objava  isto, pa odmah objavi
  objavi         samo objavi članak koji je već u bazi
  skini          vrati članak u neobjavljene (ostaje u bazi)
  provjeri       ispiše stanje u bazi i usporedi ga s datotekom
  obrisi         obriše članak iz baze, ali SAMO neobjavljen; objavljeni
                 se prvo mora skinuti, da se slučajno ne obriše živ članak

SAŽETAK UZ ZAPISNIK  clanci/sazetak-<nešto>.txt
Kratak osvrt koji stoji ispod zapisnika na stranici utakmice ide u
stupac utakmice.tekst_clanka, ne u clanke (vidi CLAUDE.md). Takva
datoteka umjesto sluga ima ključ utakmice, imena klubova točno kako
stoje u bazi, i po tome je alat prepoznaje:

    natjecanje: 1. ŽNL PGŽ
    sezona: 2026/27
    kolo: 5
    domacin: NK Mune
    gost: HNK Lovran
    derbi: da            (neobavezno; da ili ne)
    ---
    tekst sažetka

Sažetak nema oznaku objave, pa se vidi čim je upisan: upis, upis-i-objava
i objavi ga upišu, skini i obrisi ga maknu, provjeri ispiše stanje.

PRAVILO 6 IZ CLAUDE.md
Datoteka s dugom ili srednjom crtom se ne upisuje: alat javi redak i
stane. Tako crtica ne može na stranicu ni kad promakne pri pisanju.
"""

import argparse
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

import requests

MAPA = Path(__file__).resolve().parent.parent / "clanci"

OBAVEZNI = ("slug", "naslov", "sazetak", "natjecanje")
NEOBAVEZNI = ("slika_url", "slika_opis", "slika_potpis", "slika_kadar")
SAZETAK_OBAVEZNI = ("natjecanje", "sezona", "kolo", "domacin", "gost")
CRTICE = {"—": "duga crta", "–": "srednja crta"}


class GreskaDatoteke(Exception):
    """Datoteka članka nije ispravna; poruka kaže što i gdje."""


def putanja_clanka(zadano: str) -> Path:
    """Prima slug, ime datoteke ili putanju i vraća putanju datoteke."""
    ime = Path(zadano.strip()).name
    if ime.endswith(".txt"):
        ime = ime[:-4]
    return MAPA / f"{ime}.txt"


def razdvoji(sadrzaj: str, dopustena: tuple) -> tuple:
    """Dijeli datoteku na polja zaglavlja i tekst, uz provjeru crtica."""
    for broj, redak in enumerate(sadrzaj.splitlines(), start=1):
        for znak, naziv in CRTICE.items():
            if znak in redak:
                raise GreskaDatoteke(
                    f"{broj}. redak ima {naziv}, a crtice se ne koriste "
                    f"(pravilo 6): {redak.strip()[:80]}")

    if "\n---" not in "\n" + sadrzaj:
        raise GreskaDatoteke("nema crte '---' koja dijeli zaglavlje od teksta")
    zaglavlje, tekst = ("\n" + sadrzaj).split("\n---", 1)
    tekst = tekst.split("\n", 1)[1] if "\n" in tekst else ""

    polja = {}
    for redak in zaglavlje.strip().splitlines():
        if not redak.strip():
            continue
        if ":" not in redak:
            raise GreskaDatoteke(f"redak zaglavlja bez dvotočke: {redak}")
        kljuc, vrijednost = redak.split(":", 1)
        kljuc = kljuc.strip()
        if kljuc not in dopustena:
            raise GreskaDatoteke(f"nepoznato polje u zaglavlju: {kljuc}")
        polja[kljuc] = vrijednost.strip()
    return polja, tekst.strip()


def je_sazetak(sadrzaj: str) -> bool:
    """Sažetak uz utakmicu prepoznaje se po polju 'domacin' u zaglavlju."""
    zaglavlje = ("\n" + sadrzaj).split("\n---", 1)[0]
    return any(r.split(":", 1)[0].strip() == "domacin"
               for r in zaglavlje.splitlines() if ":" in r)


def procitaj_sazetak(sadrzaj: str) -> tuple:
    """Sažetak uz zapisnik: vraća (ključ utakmice, stupci za upis).

    Ključ je isti kao ključ za upsert u scraperu: natjecanje, sezona,
    kolo, domaćin i gost, s imenima klubova točno kako stoje u bazi
    (npr. "NK Mune", "HNK Lovran").
    """
    polja, tekst = razdvoji(sadrzaj, SAZETAK_OBAVEZNI + ("derbi",))
    for kljuc in SAZETAK_OBAVEZNI:
        if not polja.get(kljuc):
            raise GreskaDatoteke(f"u zaglavlju fali polje: {kljuc}")
    if not polja["kolo"].isdigit():
        raise GreskaDatoteke(f"kolo mora biti broj: {polja['kolo']}")
    if not tekst:
        raise GreskaDatoteke("sažetak nema teksta ispod crte '---'")

    kljuc = {k: polja[k] for k in SAZETAK_OBAVEZNI}
    kljuc["kolo"] = int(polja["kolo"])
    stupci = {"tekst_clanka": tekst}
    if "derbi" in polja:
        derbi = polja["derbi"].lower()
        if derbi not in ("da", "ne"):
            raise GreskaDatoteke("derbi može biti samo 'da' ili 'ne'")
        stupci["derbi"] = derbi == "da"
    return kljuc, stupci


def procitaj(sadrzaj: str, ocekivani_slug: str) -> dict:
    """Pretvara sadržaj datoteke u stupce tablice clanci."""
    polja, tekst = razdvoji(sadrzaj, OBAVEZNI + NEOBAVEZNI)

    for kljuc in OBAVEZNI:
        if kljuc not in polja:
            raise GreskaDatoteke(f"u zaglavlju fali polje: {kljuc}")
    for kljuc in ("slug", "naslov", "sazetak"):
        if not polja[kljuc]:
            raise GreskaDatoteke(f"polje je prazno: {kljuc}")
    if polja["slug"] != ocekivani_slug:
        raise GreskaDatoteke(
            f"slug u datoteci ({polja['slug']}) nije isti kao ime datoteke "
            f"({ocekivani_slug})")

    if not tekst:
        raise GreskaDatoteke("članak nema teksta ispod crte '---'")

    natjecanje = polja["natjecanje"]
    redak = {
        "slug": polja["slug"],
        "naslov": polja["naslov"],
        "sazetak": polja["sazetak"],
        "tekst": tekst,
        "natjecanje": None if natjecanje.lower() in ("", "nema") else natjecanje,
    }
    for kljuc in NEOBAVEZNI:
        if polja.get(kljuc):
            redak[kljuc] = polja[kljuc]
    return redak


# ---------------------------------------------------------------------
# Baza
# ---------------------------------------------------------------------

class Baza:
    """Tablica clanci preko Supabaseova REST sučelja.

    Service ključ zaobilazi RLS, pa vidi i neobjavljene članke. Storage i
    REST traže OBA zaglavlja s ključem (vidi CLAUDE.md, fotografija).
    """

    def __init__(self, adresa: str, kljuc: str):
        self.cilj = f"{adresa.rstrip('/')}/rest/v1/clanci"
        self.zaglavlja = {
            "apikey": kljuc,
            "Authorization": f"Bearer {kljuc}",
            "Content-Type": "application/json",
            "Prefer": "return=representation",
        }

    def _provjeri(self, odgovor, sto):
        if odgovor.status_code >= 400:
            raise SystemExit(f"{sto} nije uspio ({odgovor.status_code}): {odgovor.text}")
        return odgovor.json() if odgovor.text else []

    def dohvati(self, slug):
        o = requests.get(self.cilj, headers=self.zaglavlja,
                         params={"slug": f"eq.{slug}", "select": "*"}, timeout=30)
        redci = self._provjeri(o, "Dohvat članka")
        return redci[0] if redci else None

    def dodaj(self, podaci):
        o = requests.post(self.cilj, headers=self.zaglavlja, json=podaci, timeout=30)
        return self._provjeri(o, "Upis novog članka")[0]

    def promijeni(self, slug, podaci):
        o = requests.patch(self.cilj, headers=self.zaglavlja,
                           params={"slug": f"eq.{slug}"}, json=podaci, timeout=30)
        redci = self._provjeri(o, "Izmjena članka")
        return redci[0] if redci else None

    def obrisi(self, slug):
        o = requests.delete(self.cilj, headers=self.zaglavlja,
                            params={"slug": f"eq.{slug}"}, timeout=30)
        return self._provjeri(o, "Brisanje članka")


class Utakmice:
    """Redak utakmice, za sažetak uz zapisnik (stupac tekst_clanka).

    Scraper taj stupac ne dira, pa upis ovdje preživi svako osvježavanje.
    Utakmica se traži po istom ključu kao u scraperu, nikad po id-ju, da
    se ne može pogoditi tuđi redak.
    """

    def __init__(self, adresa: str, kljuc: str):
        self.cilj = f"{adresa.rstrip('/')}/rest/v1/utakmice"
        self.zaglavlja = Baza(adresa, kljuc).zaglavlja

    @staticmethod
    def _uvjet(kljuc_utakmice):
        return {k: f"eq.{v}" for k, v in kljuc_utakmice.items()}

    def dohvati(self, kljuc_utakmice):
        o = requests.get(self.cilj, headers=self.zaglavlja, timeout=30,
                         params={**self._uvjet(kljuc_utakmice),
                                 "select": "domacin,gost,rezultat,derbi,tekst_clanka"})
        if o.status_code >= 400:
            raise SystemExit(f"Dohvat utakmice nije uspio ({o.status_code}): {o.text}")
        return o.json()

    def promijeni(self, kljuc_utakmice, podaci):
        o = requests.patch(self.cilj, headers=self.zaglavlja, timeout=30,
                           params=self._uvjet(kljuc_utakmice), json=podaci)
        if o.status_code >= 400:
            raise SystemExit(f"Upis u utakmicu nije uspio ({o.status_code}): {o.text}")
        return o.json()


def opis_utakmice(kljuc_utakmice) -> str:
    k = kljuc_utakmice
    return f"{k['domacin']} - {k['gost']} ({k['natjecanje']}, {k['sezona']}, {k['kolo']}. kolo)"


def sazetak_u_bazu(tablica, radnja: str, kljuc_utakmice: dict, stupci: dict) -> None:
    """Upis, brisanje ili provjera sažetka uz jednu utakmicu.

    Sažetak nema oznaku objave: čim je upisan, vidi se ispod zapisnika.
    Zato se upisuje tek kad ga je Andrej odobrio.
    """
    if radnja in ("upis", "upis-i-objava", "objavi"):
        redci = tablica.promijeni(kljuc_utakmice, stupci)
        poruka = "Sažetak upisan, vidi se ispod zapisnika"
    elif radnja in ("skini", "obrisi"):
        redci = tablica.promijeni(kljuc_utakmice, {"tekst_clanka": None})
        poruka = "Sažetak maknut"
    else:
        redci = tablica.dohvati(kljuc_utakmice)
        poruka = "Stanje u bazi"

    if len(redci) != 1:
        raise SystemExit(
            f"Utakmica {opis_utakmice(kljuc_utakmice)} nije pronađena jednoznačno "
            f"(pronađeno redaka: {len(redci)}). Provjeri imena klubova, sezonu i kolo "
            "točno kako stoje u bazi.")
    r = redci[0]
    print(f"{poruka}: {r.get('domacin')} - {r.get('gost')} {r.get('rezultat') or ''}")
    print(f"  derbi:    {'DA' if r.get('derbi') else 'ne'}")
    print(f"  sažetak:  {(r.get('tekst_clanka') or '(nema)')[:80]}")
    if radnja == "provjeri":
        isti = r.get("tekst_clanka") == stupci.get("tekst_clanka")
        print("  datoteka: " + ("ista kao u bazi" if isti else "RAZLIKUJE SE"))


def upisi(baza: Baza, redak: dict) -> dict:
    """Novi članak ulazi neobjavljen; postojećem se mijenja samo sadržaj."""
    postojeci = baza.dohvati(redak["slug"])
    if postojeci is None:
        novi = dict(redak, objavljen=False,
                    objavljeno_u=datetime.now(timezone.utc).isoformat())
        print(f"Novi članak: {redak['slug']} (neobjavljen)")
        return baza.dodaj(novi)
    sadrzaj = {k: v for k, v in redak.items() if k != "slug"}
    print(f"Članak već postoji, prepisujem sadržaj: {redak['slug']} "
          f"({'objavljen' if postojeci.get('objavljen') else 'neobjavljen'})")
    return baza.promijeni(redak["slug"], sadrzaj)


def postavi_objavu(baza: Baza, slug: str, objavljen: bool) -> dict:
    rezultat = baza.promijeni(slug, {"objavljen": objavljen})
    if rezultat is None:
        raise SystemExit(f"Članka {slug} nema u bazi. Prvo ga treba upisati.")
    return rezultat


def obrisi_neobjavljen(baza: Baza, slug: str) -> None:
    postojeci = baza.dohvati(slug)
    if postojeci is None:
        print(f"Članka {slug} nema u bazi, nema se što brisati.")
        return
    if postojeci.get("objavljen"):
        raise SystemExit(f"Članak {slug} je objavljen i NE briše se. "
                         "Ako ga stvarno treba maknuti, prvo radnja 'skini'.")
    baza.obrisi(slug)
    print(f"Obrisan neobjavljen članak: {slug}")


def ispisi_stanje(redak_baze, redak_datoteke=None):
    if redak_baze is None:
        print("U bazi: NEMA ga.")
        return
    print(f"U bazi:     {redak_baze.get('slug')}")
    print(f"  naslov:   {redak_baze.get('naslov')}")
    print(f"  liga:     {redak_baze.get('natjecanje') or '(nijedna)'}")
    print(f"  slika:    {redak_baze.get('slika_url') or '(nema)'}")
    print(f"  objavljen: {'DA' if redak_baze.get('objavljen') else 'ne'}")
    print(f"  početak:  {(redak_baze.get('tekst') or '')[:80]}")
    if redak_datoteke:
        razlike = [k for k, v in redak_datoteke.items() if redak_baze.get(k) != v]
        print("  datoteka:  " + ("ista kao u bazi" if not razlike
                                 else "RAZLIKUJE SE u: " + ", ".join(razlike)))


def main():
    p = argparse.ArgumentParser(description="Članak u bazu")
    p.add_argument("clanak", help="slug članka ili putanja datoteke u mapi clanci")
    p.add_argument("--radnja", default="upis",
                   choices=["upis", "upis-i-objava", "objavi", "skini", "provjeri", "obrisi"])
    args = p.parse_args()

    putanja = putanja_clanka(args.clanak)
    slug = putanja.stem

    # Sažetak uz utakmicu ide u svoj redak tablice utakmice; za njega
    # datoteka treba uz svaku radnju, jer u njoj stoji koja je utakmica.
    if putanja.exists() and je_sazetak(putanja.read_text(encoding="utf-8")):
        try:
            kljuc_utakmice, stupci = procitaj_sazetak(putanja.read_text(encoding="utf-8"))
        except GreskaDatoteke as e:
            raise SystemExit(f"Datoteka {putanja.name} nije ispravna: {e}")
        adresa = os.environ.get("SUPABASE_URL") or ""
        kljuc = os.environ.get("SUPABASE_SERVICE_KEY") or ""
        if not adresa or not kljuc:
            raise SystemExit("Nedostaju SUPABASE_URL i SUPABASE_SERVICE_KEY.")
        sazetak_u_bazu(Utakmice(adresa, kljuc), args.radnja, kljuc_utakmice, stupci)
        return

    redak = None
    if args.radnja in ("upis", "upis-i-objava", "provjeri"):
        if not putanja.exists():
            raise SystemExit(f"Nema datoteke {putanja.relative_to(MAPA.parent)}. "
                             "Je li spremljena na granu s koje se pokreće posao?")
        try:
            redak = procitaj(putanja.read_text(encoding="utf-8"), slug)
        except GreskaDatoteke as e:
            raise SystemExit(f"Datoteka {putanja.name} nije ispravna: {e}")

    adresa = os.environ.get("SUPABASE_URL") or ""
    kljuc = os.environ.get("SUPABASE_SERVICE_KEY") or ""
    if not adresa or not kljuc:
        raise SystemExit("Nedostaju SUPABASE_URL i SUPABASE_SERVICE_KEY.")
    baza = Baza(adresa, kljuc)

    if args.radnja in ("upis", "upis-i-objava"):
        upisi(baza, redak)
        if args.radnja == "upis-i-objava":
            postavi_objavu(baza, slug, True)
            print("Objavljeno.")
    elif args.radnja == "objavi":
        postavi_objavu(baza, slug, True)
        print("Objavljeno.")
    elif args.radnja == "skini":
        postavi_objavu(baza, slug, False)
        print("Skinuto sa stranice, članak ostaje u bazi.")
    elif args.radnja == "obrisi":
        obrisi_neobjavljen(baza, slug)
        return

    ispisi_stanje(baza.dohvati(slug), redak)


if __name__ == "__main__":
    sys.exit(main())

"""Ljestvica, strijelci i kartoni, izračunati iz naše baze. Pokreće ga
posao "Preračunaj ljestvice".

ČEMU SLUŽI

Do 12.11.2026. je sve tri liste punio scraper sa Semafora. HNS je tada
automatsko preuzimanje zabranio (pravilo 7 u CLAUDE.md), pa one od tada
stoje zamrznute na zadnjem prolazu. Bez ovoga bi stranica lige nakon
prvog upisanog kola pokazivala svježe rezultate, a ljestvicu i ljestvice
strijelaca i kartona od tjedan dana prije, i to tiho.

Ovaj alat NE DOHVAĆA NIŠTA IZVANA. Čita utakmice iz naše baze i iz njih
računa:

  tablica    poredak iz odigranih rezultata, uz ručne kaznene bodove
  strijelci  golovi po igraču, iz postava
  kartoni    žuti i crveni po igraču, iz postava

Golove i kartone zbraja ista funkcija koju je koristio i scraper
(`ucinci_iz_zapisnika` u scraper_supabase.py). Ona nikad nije ovisila o
Semaforu, nego o zapisnicima koji su već u bazi, pa se preuzima
nepromijenjena. Time ostaju i sva pravila: autogol se ne pripisuje
strijelcu, drugi žuti se broji kao crveni, a žuti prije njega se ne
broji (članak 24 Disciplinskog pravilnika).

LISTA NASTUPA SE NE DIRA. Nju je scraper uzimao sa sastava na stranici
natjecanja i mi je ne možemo izračunati bez pogađanja, pa ostaje onakva
kakva je zadnji put spremljena.

KAZNENI BODOVI

Službena tablica ih je uključivala (npr. "NK Crikvenica (-3)"), a
izračun ih ne može znati. Zato stoje u datoteci kazneni_bodovi.json:

    {"2026/27": {"3. NL Zapad": {"NK Crikvenica": -3}}}

RADNJA "provjeri" USPOREĐUJE SE SA SLUŽBENOM TABLICOM

Dok u bazi još stoji zadnja tablica koju je scraper skinuo s HNS-a,
postoji jedinstvena prilika: izračun se može usporediti s njom. Razlika
u bodovima kod nekog kluba znači ili kazneni bod koji nam fali, ili
grešku u izračunu. Ta se prilika gubi čim se tablica prepiše, pa
"provjeri" treba pokrenuti PRIJE prvog upisa.

RADNJE

    provjeri  (zadano) izračuna i usporedi sa onim što je u bazi,
              ne upisuje ništa
    upis      izračuna i upiše tablicu, strijelce i kartone
"""

import argparse
import json
import os
import sys
from pathlib import Path

import requests

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from scraper_supabase import (  # noqa: E402
    ucinci_iz_zapisnika,
    slozi_pune_rang_liste,
)

KAZNENI = Path("kazneni_bodovi.json")

STUPCI = ("kolo,domacin,gost,rezultat,postava_domacin,postava_gost,autogolovi")


def zaglavlja(kljuc):
    # Supabase traži OBA zaglavlja s ključem (vidi CLAUDE.md).
    return {
        "apikey": kljuc,
        "Authorization": f"Bearer {kljuc}",
        "Content-Type": "application/json",
        "Prefer": "resolution=merge-duplicates,return=minimal",
    }


def dohvati_utakmice(adresa, kljuc, natjecanje, sezona):
    o = requests.get(
        f"{adresa}/rest/v1/utakmice",
        headers=zaglavlja(kljuc), timeout=60,
        params={"natjecanje": f"eq.{natjecanje}", "sezona": f"eq.{sezona}",
                "select": STUPCI, "order": "kolo"},
    )
    if o.status_code >= 400:
        raise SystemExit(f"Dohvat utakmica nije uspio ({o.status_code}): {o.text}")
    return o.json()


def dohvati_statistiku(adresa, kljuc, natjecanje, sezona, tip):
    o = requests.get(
        f"{adresa}/rest/v1/statistike",
        headers=zaglavlja(kljuc), timeout=30,
        params={"natjecanje": f"eq.{natjecanje}", "sezona": f"eq.{sezona}",
                "tip": f"eq.{tip}", "select": "podaci"},
    )
    if o.status_code >= 400 or not o.json():
        return []
    return o.json()[0].get("podaci") or []


def spremi(adresa, kljuc, natjecanje, sezona, tip, podaci):
    o = requests.post(
        f"{adresa}/rest/v1/statistike",
        headers=zaglavlja(kljuc), timeout=60,
        params={"on_conflict": "sezona,natjecanje,tip"},
        json={"sezona": sezona, "natjecanje": natjecanje,
              "tip": tip, "podaci": podaci},
    )
    if o.status_code >= 400:
        raise SystemExit(f"Upis liste '{tip}' nije uspio ({o.status_code}): {o.text}")


def rezultat_u_brojke(rezultat):
    """ "2:1" -> (2, 1). Sve ostalo (prazno, "- : -") daje None."""
    if not rezultat:
        return None
    dijelovi = str(rezultat).replace(" ", "").split(":")
    if len(dijelovi) != 2:
        return None
    try:
        return int(dijelovi[0]), int(dijelovi[1])
    except ValueError:
        return None


def izracunaj_tablicu(utakmice, kazneni):
    """Poredak iz odigranih rezultata.

    Scraper je tablicu SCRAPAO, a ne računao, upravo zbog kaznenih
    bodova. Sada se mora računati, pa kazneni bodovi dolaze iz datoteke.

    Poredak unutar istog broja bodova ide po gol razlici pa po danim
    golovima. HNS kod potpuno izjednačenih zna primijeniti i međusobni
    omjer, što se ovdje ne radi i namjerno se ne pogađa.
    """
    klubovi = {}

    def red(ime):
        return klubovi.setdefault(ime, {
            "klub": ime, "odigrano": 0, "pobjede": 0, "remiji": 0,
            "porazi": 0, "golovi_dani": 0, "golovi_primljeni": 0,
        })

    for u in utakmice:
        domacin = (u.get("domacin") or "").strip()
        gost = (u.get("gost") or "").strip()
        if not domacin or not gost:
            continue

        # Klub bez ijedne odigrane utakmice svejedno mora biti u tablici.
        red(domacin)
        red(gost)

        brojke = rezultat_u_brojke(u.get("rezultat"))
        if brojke is None:
            continue
        d, g = brojke

        for ime, dani, primljeni in ((domacin, d, g), (gost, g, d)):
            r = red(ime)
            r["odigrano"] += 1
            r["golovi_dani"] += dani
            r["golovi_primljeni"] += primljeni
            if dani > primljeni:
                r["pobjede"] += 1
            elif dani == primljeni:
                r["remiji"] += 1
            else:
                r["porazi"] += 1

    redci = []
    for r in klubovi.values():
        kazna = kazneni.get(r["klub"], 0)
        bodovi = r["pobjede"] * 3 + r["remiji"] + kazna
        redci.append({**r, "bodovi": bodovi,
                      "gol_razlika": r["golovi_dani"] - r["golovi_primljeni"]})

    redci.sort(key=lambda r: (-r["bodovi"], -r["gol_razlika"],
                              -r["golovi_dani"], r["klub"]))

    return [{
        "pozicija": str(n + 1),
        "klub": r["klub"],
        "odigrano": str(r["odigrano"]),
        "pobjede": str(r["pobjede"]),
        "remiji": str(r["remiji"]),
        "porazi": str(r["porazi"]),
        "golovi_dani": str(r["golovi_dani"]),
        "golovi_primljeni": str(r["golovi_primljeni"]),
        "gol_razlika": str(r["gol_razlika"]),
        "bodovi": str(r["bodovi"]),
    } for n, r in enumerate(redci)]


def usporedi_tablice(nasa, sluzbena):
    """Razlika u bodovima po klubu, dok službena tablica još stoji u bazi.

    Službena je uključivala kaznene bodove, pa je razlika najčešće
    upravo kazna koja nam fali u kazneni_bodovi.json. Svaka druga
    razlika znači da nam neki rezultat fali ili je krivo upisan.
    """
    if not sluzbena:
        print("  U bazi nema tablice za usporedbu.")
        return

    # Zagrada se čisti na OBJE strane, jer se pojavljuje u obje, ali
    # različito. U službenoj tablici nosi kazneni bod ("NK Crikvenica
    # (-3)"), a u utakmicama oznaku mjesta ("NK Lokomotiva (R)",
    # "NK Naprijed (H)", "NK Rudar (L)"), koje u službenoj tablici nema.
    # Prva verzija je čistila samo službenu stranu, pa su ta tri kluba
    # 12.11.2026. ispala kao da ih nema u drugoj tablici.
    #
    # Ovo vrijedi samo za usporedbu. Spremaju se imena iz utakmica, jer
    # su to ista imena koja stranica koristi za poveznice na klubove.
    def ocisti(ime):
        return (ime or "").split("(")[0].strip()

    njihovi = {ocisti(r.get("klub")): r for r in sluzbena}
    razlika = False

    for r in nasa:
        njihov = njihovi.get(ocisti(r["klub"]))
        if njihov is None:
            print(f"  SAMO KOD NAS: {r['klub']}")
            razlika = True
            continue
        if str(njihov.get("bodovi")) != r["bodovi"]:
            print(f"  {r['klub']}: izračun {r['bodovi']}, "
                  f"službena {njihov.get('bodovi')} "
                  f"(odigrano {r['odigrano']} prema {njihov.get('odigrano')})")
            razlika = True

    nasi = {ocisti(r["klub"]) for r in nasa}
    for ime in njihovi:
        if ime not in nasi:
            print(f"  SAMO U SLUŽBENOJ: {ime}")
            razlika = True

    if not razlika:
        print("  Tablica se poklapa sa službenom u svemu.")
    else:
        print("  Razlike gore su ili kazneni bodovi (upiši ih u "
              "kazneni_bodovi.json) ili rezultat koji fali.")


def usporedi_liste(naziv, nasa, njihova, kljuc_broja):
    nasi = {(r["igrac"], r["klub"]): r[kljuc_broja] for r in nasa}
    njihovi = {(r.get("igrac"), r.get("klub")): str(r.get(kljuc_broja))
               for r in njihova}

    razlike = [(i, nasi.get(i, "0"), njihovi.get(i, "0"))
               for i in set(nasi) | set(njihovi)
               if nasi.get(i, "0") != njihovi.get(i, "0")]

    print(f"  {naziv}: izračun {len(nasa)}, u bazi {len(njihova)}, "
          f"razlika kod {len(razlike)} igrača")
    for (igrac, klub), nas, njihov in sorted(razlike)[:15]:
        print(f"    {igrac} ({klub}): izračun {nas}, u bazi {njihov}")
    if len(razlike) > 15:
        print(f"    ... i još {len(razlike) - 15}")


def main():
    parser = argparse.ArgumentParser(description="Ljestvice iz naše baze.")
    parser.add_argument("--natjecanje", required=True)
    parser.add_argument("--sezona", required=True)
    parser.add_argument("--radnja", default="provjeri", choices=("provjeri", "upis"))
    args = parser.parse_args()

    adresa = (os.environ.get("SUPABASE_URL") or "").rstrip("/")
    kljuc = os.environ.get("SUPABASE_SERVICE_KEY") or ""
    if not adresa or not kljuc:
        raise SystemExit("Nedostaje SUPABASE_URL ili SUPABASE_SERVICE_KEY.")

    kazneni_svi = {}
    if KAZNENI.exists():
        kazneni_svi = json.loads(KAZNENI.read_text(encoding="utf-8"))
    kazneni = (kazneni_svi.get(args.sezona) or {}).get(args.natjecanje) or {}

    print("=" * 60)
    print(f"{args.natjecanje}, sezona {args.sezona}, radnja {args.radnja}")
    print("=" * 60)

    utakmice = dohvati_utakmice(adresa, kljuc, args.natjecanje, args.sezona)
    odigrane = [u for u in utakmice if rezultat_u_brojke(u.get("rezultat"))]
    print(f"Utakmica u bazi: {len(utakmice)}, s rezultatom: {len(odigrane)}")
    if kazneni:
        print(f"Kazneni bodovi: {kazneni}")
    else:
        print("Kazneni bodovi: nijedan nije upisan")
    print()

    tablica = izracunaj_tablicu(utakmice, kazneni)

    ucinci, bez_postava = ucinci_iz_zapisnika(odigrane)
    strijelci, kartoni = slozi_pune_rang_liste(ucinci, koliko=10000)

    print(f"Izračunato: tablica {len(tablica)} klubova, "
          f"strijelci {len(strijelci)}, kartoni {len(kartoni)}")
    if bez_postava:
        print(f"UPOZORENJE: {len(bez_postava)} odigranih utakmica nema obje "
              f"postave, pa njihovi golovi i kartoni NISU u zbroju:")
        for opis in bez_postava[:10]:
            print(f"  {opis}")
    print()

    if args.radnja == "provjeri":
        print("USPOREDBA S ONIM ŠTO JE U BAZI (ništa nije upisano)")
        print("-" * 60)
        usporedi_tablice(tablica, dohvati_statistiku(
            adresa, kljuc, args.natjecanje, args.sezona, "tablica"))
        usporedi_liste("strijelci", strijelci, dohvati_statistiku(
            adresa, kljuc, args.natjecanje, args.sezona, "strijelci"), "golovi")
        usporedi_liste("kartoni", kartoni, dohvati_statistiku(
            adresa, kljuc, args.natjecanje, args.sezona, "kartoni"), "zuti")
        return

    for tip, podaci in (("tablica", tablica), ("strijelci", strijelci),
                        ("kartoni", kartoni)):
        spremi(adresa, kljuc, args.natjecanje, args.sezona, tip, podaci)
        print(f"  spremljeno: {tip} ({len(podaci)})")

    print()
    print("Lista nastupa nije dirana, nju se iz zapisnika ne može izračunati.")
    print("Stranica lige osvježi se u nekoliko minuta.")


if __name__ == "__main__":
    sys.exit(main())

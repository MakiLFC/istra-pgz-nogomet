"""Promjena termina utakmice, bez SQL Editora.

ČEMU SLUŽI
HNS premještanje utakmice ne objavljuje nigdje, nego tiho prepiše redak
rasporeda. Do 12.11.2026. to je hvatao posao "Provjera termina", koji je
svaki dan čitao raspored sa Semafora. Scraper više ne radi (pravilo 7 u
CLAUDE.md), pa termin od sada mijenja Andrej, kad premještaj vidi.

ZAŠTO NE datum_rucno
Stupce datum_rucno i vrijeme_rucno čitao je ISKLJUČIVO scraper: on je
njihovu vrijednost prepisivao u datum i vrijeme, a stranica čita datum i
vrijeme. Bez scrapera upis u datum_rucno ne mijenja ništa na stranici.
Zato ovaj alat piše izravno u datum, vrijeme i stadion.

KAKO SE POKREĆE
Actions -> "Termin u bazu" -> Run workflow. Imena klubova smiju biti
nepotpuna ("Vinodol" umjesto "NK Vinodol"), jer se utakmica traži po
sadržaju imena. Kad opis odgovara dvjema utakmicama, alat ih ispiše i
ne dira ništa.

PRVO "provjeri", koji samo ispiše staro i novo stanje. Upis ide tek uz
radnju "upis".

ODGODA: datum "-" briše termin. Stranica tada piše da je utakmica
odgođena i da novi termin još nije poznat.
"""

import argparse
import os
import re
import sys

import requests


STUPCI = "id,kolo,domacin,gost,datum,vrijeme,stadion,rezultat"

RE_DATUM = re.compile(r"^(\d{1,2})\.(\d{1,2})\.(\d{4})\.?$")
RE_VRIJEME = re.compile(r"^(\d{1,2}):(\d{2})$")

BRISANJE = ("-", "--", "odgoda", "odgodjeno", "odgođeno")


# ---------------------------------------------------------------------
# Čitanje zadanog termina
# ---------------------------------------------------------------------

def normaliziraj_datum(tekst):
    """ "14.11.2026" i "4.11.2026." daju "14.11.2026." odnosno "04.11.2026.".

    Vraća None kad je zadano brisanje termina, a diže grešku kad se
    datum ne da pročitati. Oblik u bazi je uvijek DD.MM.GGGG. s točkom
    na kraju, jer ga stranica tako čita (datumIzTeksta u lib/kolo.ts).
    """
    t = (tekst or "").strip()
    if not t:
        return ""
    if t.lower() in BRISANJE:
        return None

    m = RE_DATUM.match(t)
    if not m:
        raise SystemExit(
            f"Datum '{tekst}' ne razumijem. Očekujem oblik 14.11.2026., "
            "a '-' briše termin."
        )

    dan, mjesec, godina = int(m.group(1)), int(m.group(2)), int(m.group(3))
    if not (1 <= dan <= 31 and 1 <= mjesec <= 12):
        raise SystemExit(f"Datum '{tekst}' ne postoji.")
    return f"{dan:02d}.{mjesec:02d}.{godina}."


def normaliziraj_vrijeme(tekst):
    """ "14:30" ostaje, "9:00" daje "9:00". Prazno znači "ne diraj"."""
    t = (tekst or "").strip()
    if not t:
        return ""
    if t.lower() in BRISANJE:
        return None

    m = RE_VRIJEME.match(t)
    if not m:
        raise SystemExit(
            f"Vrijeme '{tekst}' ne razumijem. Očekujem oblik 14:30, "
            "a '-' briše vrijeme."
        )
    sat, minuta = int(m.group(1)), int(m.group(2))
    if sat > 23 or minuta > 59:
        raise SystemExit(f"Vrijeme '{tekst}' ne postoji.")
    return f"{sat}:{minuta:02d}"


# ---------------------------------------------------------------------
# Pronalaženje utakmice
# ---------------------------------------------------------------------

def odgovara(ime_u_bazi, trazeno):
    """Traži se SADRŽAJ imena, da se ne mora tipkati puni naziv.

    "vinodol" nalazi "NK Vinodol", a "naprijed" nalazi "NK Naprijed (H)".
    """
    return (trazeno or "").strip().lower() in (ime_u_bazi or "").lower()


def odaberi_utakmicu(redovi, domacin, gost, kolo=None):
    """Vraća jedan redak ili diže grešku s popisom mogućnosti.

    Kolo se NE koristi kao uvjet nego kao razrješenje: par se u istoj
    sezoni ponavlja (dvokružno, a u županijskima i trokružno), pa se kolo
    traži tek kad opis odgovara dvjema utakmicama. Tako premještaj prolazi
    i kad se zabuni u kolu, što je ovdje česta greška (vidi CLAUDE.md:
    kolo se ne prepoznaje po datumu).
    """
    pogodci = [r for r in redovi
               if odgovara(r.get("domacin"), domacin)
               and odgovara(r.get("gost"), gost)]

    if not pogodci:
        raise SystemExit(
            f"Ne nalazim utakmicu '{domacin}' - '{gost}'.\n"
            "Provjeri jesu li klubovi u tom redoslijedu, domaćin pa gost."
        )

    if len(pogodci) > 1 and kolo:
        po_kolu = [r for r in pogodci if str(r.get("kolo")) == str(kolo)]
        if po_kolu:
            pogodci = po_kolu

    if len(pogodci) > 1:
        popis = "\n".join(
            f"  {r.get('kolo')}. kolo, {r.get('domacin')} - {r.get('gost')}, "
            f"{r.get('datum') or 'bez termina'} {r.get('vrijeme') or ''}".rstrip()
            for r in sorted(pogodci, key=lambda r: r.get("kolo") or 0)
        )
        raise SystemExit(
            f"Opis odgovara dvjema utakmicama ili više njih:\n{popis}\n"
            "Zadaj kolo, pa ću znati koja je."
        )

    return pogodci[0]


def promjene(red, datum, vrijeme, stadion):
    """Samo polja koja se stvarno mijenjaju; prazno znači "ne diraj"."""
    novo = {}
    for stupac, zadano in (("datum", datum), ("vrijeme", vrijeme),
                           ("stadion", stadion)):
        if zadano == "":
            continue
        if (red.get(stupac) or None) != (zadano or None):
            novo[stupac] = zadano
    return novo


def opis_termina(red):
    datum = red.get("datum") or "bez datuma"
    vrijeme = red.get("vrijeme") or "bez vremena"
    stadion = red.get("stadion")
    return f"{datum} {vrijeme}" + (f", {stadion}" if stadion else "")


# ---------------------------------------------------------------------
# Baza
# ---------------------------------------------------------------------

class Utakmice:
    def __init__(self, adresa, kljuc):
        self.cilj = f"{adresa.rstrip('/')}/rest/v1/utakmice"
        # Supabase traži OBA zaglavlja s ključem (vidi CLAUDE.md).
        self.zaglavlja = {
            "apikey": kljuc,
            "Authorization": f"Bearer {kljuc}",
            "Content-Type": "application/json",
            "Prefer": "return=representation",
        }

    def kolo_lige(self, natjecanje, sezona):
        o = requests.get(self.cilj, headers=self.zaglavlja, timeout=30,
                         params={"natjecanje": f"eq.{natjecanje}",
                                 "sezona": f"eq.{sezona}",
                                 "select": STUPCI})
        if o.status_code >= 400:
            raise SystemExit(f"Dohvat nije uspio ({o.status_code}): {o.text}")
        return o.json()

    def promijeni(self, id_utakmice, podaci):
        o = requests.patch(self.cilj, headers=self.zaglavlja, timeout=30,
                           params={"id": f"eq.{id_utakmice}"}, json=podaci)
        if o.status_code >= 400:
            raise SystemExit(f"Upis nije uspio ({o.status_code}): {o.text}")
        return o.json()


def main():
    p = argparse.ArgumentParser(description="Promjena termina utakmice")
    p.add_argument("--natjecanje", required=True)
    p.add_argument("--sezona", required=True)
    p.add_argument("--domacin", required=True)
    p.add_argument("--gost", required=True)
    p.add_argument("--kolo", default="")
    p.add_argument("--datum", default="")
    p.add_argument("--vrijeme", default="")
    p.add_argument("--stadion", default="")
    p.add_argument("--radnja", choices=("provjeri", "upis"), default="provjeri")
    a = p.parse_args()

    datum = normaliziraj_datum(a.datum)
    vrijeme = normaliziraj_vrijeme(a.vrijeme)
    stadion = a.stadion.strip()
    if stadion.lower() in BRISANJE:
        stadion = None

    if datum == "" and vrijeme == "" and stadion == "":
        raise SystemExit("Nije zadano ništa novo: upiši datum, vrijeme ili stadion.")

    adresa = os.environ.get("SUPABASE_URL")
    kljuc = os.environ.get("SUPABASE_SERVICE_KEY")
    if not adresa or not kljuc:
        raise SystemExit("Nedostaju SUPABASE_URL i SUPABASE_SERVICE_KEY.")

    baza = Utakmice(adresa, kljuc)
    red = odaberi_utakmicu(baza.kolo_lige(a.natjecanje, a.sezona),
                           a.domacin, a.gost, a.kolo)

    print(f"{red['kolo']}. kolo, {red['domacin']} - {red['gost']}")
    print(f"  sada:  {opis_termina(red)}")

    novo = promjene(red, datum, vrijeme, stadion)
    if not novo:
        print("  novo:  ništa se ne mijenja, termin je već takav.")
        return

    buduci = {**red, **novo}
    print(f"  novo:  {opis_termina(buduci)}")

    if red.get("rezultat"):
        print(f"NAPOMENA: utakmica već ima rezultat ({red['rezultat']}). "
              "Provjeri je li ovo doista premještaj.")

    if a.radnja != "upis":
        print("\nSuhi prolaz, ništa nije upisano. Za upis odaberi radnju 'upis'.")
        return

    baza.promijeni(red["id"], novo)
    print("\nUpisano.")


if __name__ == "__main__":
    sys.exit(main())

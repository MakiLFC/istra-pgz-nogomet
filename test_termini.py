"""
test_termini.py

Provjerava odlučivanje o terminu utakmice (funkcija odredi_termin u
scraper_supabase.py): kad se termin smatra promijenjenim, kad ručni unos
ima prednost i kad se termin iz baze NE smije prebrisati praznim.

Zašto ovo postoji: termin dolazi s retka rasporeda na HNS Semaforu i
scraper ga prepisuje pri svakom pokretanju. NK Žminj - NK Ližnjan u
1. kolu 4. NL NS Rijeka premješten je s 05.09. na 04.09.2026., a takva
promjena nigdje se ne najavljuje - HNS samo tiho prepiše redak. Odatle
tri pravila koja se ovdje čuvaju.

POKRETANJE:  python test_termini.py
Ništa ne dohvaća s interneta i ništa ne piše u bazu.
"""

import os
import sys
import types

# Scraper pri uvozu otvara vezu prema Supabaseu; za ovu provjeru ne treba.
for ime, sadrzaj in {
    "supabase": {"create_client": lambda *a, **k: None},
    "dotenv": {"load_dotenv": lambda *a, **k: None},
}.items():
    modul = types.ModuleType(ime)
    for kljuc, vrijednost in sadrzaj.items():
        setattr(modul, kljuc, vrijednost)
    sys.modules.setdefault(ime, modul)

os.environ.setdefault("SUPABASE_URL", "test")
os.environ.setdefault("SUPABASE_SERVICE_KEY", "test")

import scraper_supabase  # noqa: E402


def _stavka(datum, vrijeme="17:30"):
    return {"kolo": 2, "domacin": "NK Žminj", "gost": "NK Ližnjan",
            "datum": datum, "vrijeme": vrijeme}


# (opis, stavka s HNS-a, redak u bazi, očekivani datum, očekivano vrijeme,
#  očekuje li se prijava promjene, očekuje li se napomena, briše li se
#  ručni termin)
SLUCAJEVI = [
    (
        "premještena utakmica: novi termin ulazi i prijavljuje se",
        _stavka("04.09.2026."),
        {"datum": "05.09.2026.", "vrijeme": "17:30"},
        "04.09.2026.", "17:30", True, False, False,
    ),
    (
        "isti termin: nema ni promjene ni napomene",
        _stavka("05.09.2026."),
        {"datum": "05.09.2026.", "vrijeme": "17:30"},
        "05.09.2026.", "17:30", False, False, False,
    ),
    (
        "pomaknuto samo vrijeme: i to je promjena",
        _stavka("05.09.2026.", "19:00"),
        {"datum": "05.09.2026.", "vrijeme": "17:30"},
        "05.09.2026.", "19:00", True, False, False,
    ),
    (
        "prva utakmica u bazi: prvo punjenje nije promjena",
        _stavka("05.09.2026."),
        {},
        "05.09.2026.", "17:30", False, False, False,
    ),
    (
        "HNS nije pokazao termin: zadnji poznati ostaje, uz napomenu",
        _stavka(None, None),
        {"datum": "05.09.2026.", "vrijeme": "17:30"},
        "05.09.2026.", "17:30", False, True, False,
    ),
    (
        "ručni termin ima prednost pred HNS-om",
        _stavka("05.09.2026."),
        {"datum": "05.09.2026.", "vrijeme": "17:30",
         "datum_rucno": "04.09.2026.", "vrijeme_rucno": None},
        "04.09.2026.", "17:30", False, True, False,
    ),
    (
        "ručno samo vrijeme: datum i dalje dolazi s HNS-a",
        _stavka("05.09.2026."),
        {"datum": "05.09.2026.", "vrijeme": "17:30",
         "datum_rucno": None, "vrijeme_rucno": "19:00"},
        "05.09.2026.", "19:00", False, True, False,
    ),
    (
        "HNS je sustigao ručni termin: ručni unos se briše sam",
        _stavka("04.09.2026."),
        {"datum": "04.09.2026.", "vrijeme": "17:30",
         "datum_rucno": "04.09.2026.", "vrijeme_rucno": None},
        "04.09.2026.", "17:30", False, True, True,
    ),
]


def main():
    palo = 0

    for (opis, stavka, postojeci, d_ocek, v_ocek,
         promjena_ocek, napomena_ocek, ciscenje_ocek) in SLUCAJEVI:
        datum, vrijeme, promjena, napomena, ocisti = scraper_supabase.odredi_termin(
            stavka, postojeci
        )
        dobiveno = (datum, vrijeme, bool(promjena), bool(napomena), ocisti)
        ocekivano = (d_ocek, v_ocek, promjena_ocek, napomena_ocek, ciscenje_ocek)

        if dobiveno == ocekivano:
            print(f"  OK   {opis}")
            if promjena:
                print(f"         promjena: {promjena}")
            if napomena:
                print(f"         napomena: {napomena}")
        else:
            palo += 1
            print(f"  PALO {opis}")
            print(f"         očekivano: {ocekivano}")
            print(f"         dobiveno:  {dobiveno}")

    if palo:
        print(f"\nPALO: {palo} od {len(SLUCAJEVI)} slučajeva.")
        return 1

    print(f"\nPROLAZI: svih {len(SLUCAJEVI)} slučajeva.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

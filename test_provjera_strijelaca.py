"""
test_provjera_strijelaca.py

Provjerava samoprovjeru koja uspoređuje našu listu strijelaca sa
službenom HNS rang-listom (funkcija usporedi_sa_sluzbenom).

Zašto ovo postoji: prva verzija gledala je prva tri mjesta u nizu, pa je
05.09.2026. javljala "NE POKLAPA SE!" za 3. NL Zapad iako su imena i
brojke bili isti, samo drugim redom: Durmo, Josipović, Mijić prema Durmo,
Mijić, Josipović, sva trojica s po dva gola. Kad više igrača ima isti broj
golova, poredak je proizvoljan.

Lažna uzbuna je skupa jednako kao propuštena, jer se poruka koju se nauči
preskakati preskoči i onda kad nešto stvarno ne valja.

POKRETANJE:  python test_provjera_strijelaca.py
Ništa ne dohvaća s interneta i ništa ne piše u bazu.
"""

import os
import sys
import types

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

from scraper_supabase import usporedi_sa_sluzbenom  # noqa: E402


def _s(*parovi):
    return [{"igrac": ime, "golovi": golovi} for ime, golovi in parovi]


def provjeri(uvjet, opis):
    print(f"  {'OK  ' if uvjet else 'PALO'}  {opis}")
    return uvjet


def main():
    sve = True

    print("1. isti igrači i brojke, drugi redoslijed")
    poruka = usporedi_sa_sluzbenom(
        _s(("Ahmed Durmo", "2"), ("Karlo Josipović", "2"), ("Luka Mijić", "2")),
        _s(("Ahmed Durmo", "2"), ("Luka Mijić", "2"), ("Karlo Josipović", "2")),
    )
    sve &= provjeri("poklapa se" in poruka, f"{poruka!r}")

    print("2. naša lista je duža od službene, to nije neslaganje")
    poruka = usporedi_sa_sluzbenom(
        _s(("Ahmed Durmo", "2"), ("Luka Mijić", "2"), ("Petar Perić", "1")),
        _s(("Ahmed Durmo", "2"), ("Luka Mijić", "2")),
    )
    sve &= provjeri("poklapa se" in poruka, f"{poruka!r}")

    print("3. krivo zbrojen gol se prijavljuje")
    poruka = usporedi_sa_sluzbenom(
        _s(("Ahmed Durmo", "1"), ("Luka Mijić", "2")),
        _s(("Ahmed Durmo", "2"), ("Luka Mijić", "2")),
    )
    sve &= provjeri("NE POKLAPA SE" in poruka and "Ahmed Durmo" in poruka, f"{poruka!r}")

    print("4. igrač kojeg kod nas uopće nema se prijavljuje")
    poruka = usporedi_sa_sluzbenom(
        _s(("Luka Mijić", "2")),
        _s(("Ahmed Durmo", "2"), ("Luka Mijić", "2")),
    )
    sve &= provjeri("NE POKLAPA SE" in poruka and "nema" in poruka, f"{poruka!r}")

    print("5. prazne liste")
    sve &= provjeri(usporedi_sa_sluzbenom([], _s(("Ahmed Durmo", "2")))
                    == "nije bilo s čim usporediti", "naša lista prazna")
    sve &= provjeri(usporedi_sa_sluzbenom(_s(("Ahmed Durmo", "2")), [])
                    == "nije bilo s čim usporediti", "službena lista prazna")

    print()
    print("PROLAZI" if sve else "NE PROLAZI")
    return 0 if sve else 1


if __name__ == "__main__":
    sys.exit(main())

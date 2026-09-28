"""
test_samo_novi_zapisnici.py

Provjerava koje zapisnike --samo-novi-zapisnici smije preskočiti
(potpuni_zapisnici u scraper_supabase.py).

Zašto ovo postoji: puni prolaz otvara svaki zapisnik sezone, i one
pročitane prije mjesec dana. U studenome je to tristotinjak zahtjeva prema
HNS-u po prolazu, za podatke koje već imamo. Rani večernji prolaz zato
otvara samo zapisnike kojih u bazi još nema do kraja. Opasnost je u
suprotnom smjeru: preskočiti zapisnik koji NIJE potpun značilo bi da mu
postave ili rezultat nikad ne stignu. Ovaj test čuva tu granicu.

POKRETANJE:  python test_samo_novi_zapisnici.py
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

from scraper_supabase import potpuni_zapisnici  # noqa: E402

POSTAVA = [{"igrac": "Ivo Ivić", "dogadjaji": []}]


def utakmica(kolo, domacin, gost, rezultat, d=POSTAVA, g=POSTAVA):
    return {"kolo": kolo, "domacin": domacin, "gost": gost,
            "rezultat": rezultat, "postava_domacin": d, "postava_gost": g}


def provjeri(uvjet, opis):
    print(f"  {'OK  ' if uvjet else 'PALO'}  {opis}")
    return uvjet


def main():
    sve = True
    potpuni = potpuni_zapisnici([
        utakmica(1, "NK A", "NK B", "2:1"),
        utakmica(1, "NK C", "NK D", None, [], []),
        utakmica(2, "NK A", "NK C", "3:0", [], []),
        utakmica(2, "NK B", "NK D", "1:1", POSTAVA, []),
        utakmica(2, "NK D", "NK A", "?:?"),
        utakmica(3, "NK A", "NK B", "0:0"),
    ])

    sve &= provjeri((1, "NK A", "NK B") in potpuni,
                    "rezultat i obje postave: smije se preskočiti")
    sve &= provjeri((3, "NK A", "NK B") in potpuni,
                    "isti par u drugom kolu je zasebna utakmica")
    sve &= provjeri((1, "NK C", "NK D") not in potpuni,
                    "neodigrana utakmica se ne preskače")
    sve &= provjeri((2, "NK A", "NK C") not in potpuni,
                    "rezultat bez postava (npr. predana) se otvara i dalje")
    sve &= provjeri((2, "NK B", "NK D") not in potpuni,
                    "samo jedna postava: otvara se i dalje")
    sve &= provjeri((2, "NK D", "NK A") not in potpuni,
                    "rezultat koji nije broj:broj se ne računa")
    sve &= provjeri(potpuni_zapisnici([]) == set(),
                    "bez podataka iz baze ne preskače se ništa")

    if not sve:
        print("\nPALO: --samo-novi-zapisnici bi preskočio krive zapisnike.")
        return 1
    print("\nPROLAZI: preskaču se samo zapisnici koji su u bazi do kraja.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

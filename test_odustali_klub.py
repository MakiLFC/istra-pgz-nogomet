"""
test_odustali_klub.py

Provjerava što se događa kad klub napusti natjecanje usred sezone:
preskakanje njegovih utakmica s rasporeda i prepoznavanje utakmica kojih
na rasporedu više nema, a u bazi su.

Zašto ovo postoji: NK Novalja je 02.09.2026. napustila 4. NL NS Rijeka,
dan prije prvog kola, a HNS je na Semaforu i dalje pokazivao cijeli
raspored s njom, uključujući NK Otočac - NK Novalja u 1. kolu. Scraper
inače samo dodaje i mijenja, nikad ne briše, pa bi te utakmice ostale na
stranici i nakon što ih HNS makne.

POKRETANJE:  python test_odustali_klub.py
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


def _u(kolo, domacin, gost):
    return {"kolo": kolo, "domacin": domacin, "gost": gost}


# Isječak rasporeda 4. NL NS Rijeka kakav je HNS pokazivao 02.09.2026.
RASPORED = [
    _u(1, "NK Žminj", "NK Ližnjan"),
    _u(1, "NK Otočac", "NK Novalja"),
    _u(1, "NK Cres", "NK Rječina"),
    _u(2, "NK Novalja", "NK Žminj"),
    _u(2, "NK Cres", "NK Umag-CC Umago"),
]


def provjeri(uvjet, opis):
    print(f"  {'OK  ' if uvjet else 'PALO'}  {opis}")
    return uvjet


def main():
    sve = True

    print("1. popis klubova izvan natjecanja")
    izvan = scraper_supabase.klubovi_izvan_natjecanja("4. NL NS Rijeka", "2026/27")
    sve &= provjeri(izvan == {"NK Novalja"}, "NK Novalja je izvan 4. NL NS Rijeka")
    sve &= provjeri(
        scraper_supabase.klubovi_izvan_natjecanja("3. NL Zapad", "2026/27") == set(),
        "druga liga time nije dirnuta",
    )
    sve &= provjeri(
        scraper_supabase.klubovi_izvan_natjecanja("4. NL NS Rijeka", "2025/26") == set(),
        "prošla sezona time nije dirnuta",
    )

    print("2. utakmice odustalog kluba ispadaju s rasporeda")
    ostalo = scraper_supabase.bez_klubova_izvan(RASPORED, izvan)
    sve &= provjeri(len(ostalo) == 3, "od pet utakmica ostale su tri")
    sve &= provjeri(
        all("NK Novalja" not in (u["domacin"], u["gost"]) for u in ostalo),
        "Novalje nema ni kao domaćina ni kao gosta",
    )
    sve &= provjeri(
        scraper_supabase.bez_klubova_izvan(RASPORED, set()) is RASPORED,
        "bez odustalih klubova raspored se ne dira",
    )

    print("3. utakmice kojih na rasporedu više nema")
    u_bazi = {
        (1, "NK Žminj", "NK Ližnjan"): {"rezultat": None},
        (1, "NK Cres", "NK Rječina"): {"rezultat": None},
        # HNS je presložio parove: ove dvije više nisu na rasporedu
        (1, "NK Klana", "NK Funtana"): {"rezultat": None},
        (2, "NK Štinjan", "NK Medulin 1921"): {"rezultat": "2:1"},
        # 9. kolo u ovom prolazu uopće nije čitano
        (9, "NK Cres", "NK Klana"): {"rezultat": None},
    }
    nestale = scraper_supabase.nestale_s_rasporeda(ostalo, u_bazi)
    sve &= provjeri(len(nestale) == 2, "prijavljene su dvije utakmice")
    sve &= provjeri(
        any("NK Klana - NK Funtana" in o for o in nestale),
        "par kojeg nema na rasporedu je prijavljen",
    )
    sve &= provjeri(
        any("ima rezultat" in o for o in nestale),
        "odigrana utakmica je posebno označena",
    )
    sve &= provjeri(
        not any("9. kolo" in o for o in nestale),
        "kolo koje nije čitano ne ispada kao nestalo",
    )
    for opis in nestale:
        print(f"         {opis}")

    print()
    print("PROLAZI" if sve else "NE PROLAZI")
    return 0 if sve else 1


if __name__ == "__main__":
    sys.exit(main())

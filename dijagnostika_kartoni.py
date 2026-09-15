"""
dijagnostika_kartoni.py

Zašto postoji: 15.09.2026. je lista kartona iz zapisnika u tri lige
zaostala za onom sa stranice natjecanja, i to svaki put za po jedan žuti
karton (Doni Tanković i Ivan Rojnić u 3. NL, Admir Haznadar u 4. NL,
Bakir Delić u 1. ŽNL). Kočnica je odradila svoje i takva se lista nije
objavila, ali se mora vidjeti ZAŠTO nedostaje.

Alat za zadana imena prolazi kroz zapisnike njihovih klubova i ispisuje
svaki događaj uz tog igrača, pa se vidi je li karton uopće u zapisniku,
stoji li uz nekoga tko u postavi nije naveden, ili se ime piše drukčije.

POKRETANJE:
    python dijagnostika_kartoni.py "Doni Tanković" "Ivan Rojnić"

ili preko okoline (tako ga pokreće posao na GitHubu):
    IGRACI="Doni Tanković;Ivan Rojnić" python dijagnostika_kartoni.py

Zadano prolazi kroz sva natjecanja iz scrapera. Može se suziti:
    NATJECANJE="3. NL" python dijagnostika_kartoni.py "Doni Tanković"

Ništa ne piše u bazu; samo čita stranice Semafora i ispisuje.
"""

import os
import sys
import time

from bs4 import BeautifulSoup

from scraper_supabase import (
    NATJECANJA,
    SEZONA,
    _ista_osoba,
    dohvati_detalje_utakmice,
    dohvati_popis_utakmica,
    dohvati_stranicu,
    parsiraj_sve_igrace,
)


def trazena_imena():
    """Imena s naredbenog retka, a ako ih ondje nema, iz okoline."""
    if len(sys.argv) > 1:
        return [i.strip() for i in sys.argv[1:] if i.strip()]
    iz_okoline = os.environ.get("IGRACI", "")
    return [i.strip() for i in iz_okoline.split(";") if i.strip()]


def odabrana_natjecanja():
    trazeno = (os.environ.get("NATJECANJE") or "").strip().casefold()
    if not trazeno:
        return NATJECANJA
    return [n for n in NATJECANJA if trazeno in n["naziv"].casefold()]


def dogadjaji_igraca(postava, ime):
    """Događaji igrača iz jedne postave, uz tolerantno poklapanje imena."""
    nadjeni = []
    for igrac in postava:
        if _ista_osoba(ime, igrac.get("igrac") or ""):
            nadjeni.append(igrac)
    return nadjeni


def ispisi_igraca(natjecanje, igrac_sastav, utakmice):
    ime = igrac_sastav["igrac"]
    klub = igrac_sastav["klub"]
    print()
    print("-" * 70)
    print(f"{ime}  ({klub}, {natjecanje['naziv']}, {SEZONA})")
    print(f"  Sastav na stranici natjecanja: žuti={igrac_sastav['zuti']}, "
          f"crveni={igrac_sastav['crveni']}")

    njegove = [u for u in utakmice
               if u["hns_url"] and klub in (u["domacin"], u["gost"])]
    if not njegove:
        print("  Nijedna odigrana utakmica tog kluba nema zapisnik.")
        return

    zuti = crveni = 0
    for u in njegove:
        detalji = dohvati_detalje_utakmice(u["hns_url"])
        time.sleep(1)

        strana = "domacin" if klub == u["domacin"] else "gost"
        postava_kluba = detalji.get(f"postava_{strana}") or []
        druga_postava = detalji.get(
            "postava_gost" if strana == "domacin" else "postava_domacin"
        ) or []

        opis = (f"  {u['kolo']}. kolo  {u['domacin']} - {u['gost']} "
                f"({detalji.get('rezultat') or 'bez rezultata'})")

        nadjen = dogadjaji_igraca(postava_kluba, ime)
        if not nadjen:
            # Ako je u postavi PROTIVNIKA, klub bi mu na stranici bio kriv.
            kod_protivnika = dogadjaji_igraca(druga_postava, ime)
            if kod_protivnika:
                print(opis + "  -> NIJE u postavi svog kluba, nego u "
                              "postavi protivnika!")
                nadjen = kod_protivnika
            else:
                praznih = "postave nisu upisane" if not postava_kluba \
                    else f"nije u postavi ({len(postava_kluba)} igrača)"
                print(opis + f"  -> {praznih}")
                continue

        for igrac in nadjen:
            dogadjaji = igrac.get("dogadjaji") or []
            opis_dogadjaja = ", ".join(
                f"{d['tip']} {d['minuta']}" for d in dogadjaji
            ) or "bez ijednog događaja"
            oznaka = " (pričuvni)" if igrac.get("pricuvni") else ""
            print(f"{opis}  -> {igrac['igrac']}{oznaka}: {opis_dogadjaja}")
            for d in dogadjaji:
                if d["tip"] == "karton_zuti":
                    zuti += 1
                if d["tip"] in ("karton_crveni", "karton_zutocrveni"):
                    crveni += 1

    print(f"  ZBROJ IZ ZAPISNIKA: žuti={zuti}, crveni={crveni}")
    razlika_zuti = igrac_sastav["zuti"] - zuti
    razlika_crveni = igrac_sastav["crveni"] - crveni
    if razlika_zuti or razlika_crveni:
        print(f"  RAZLIKA prema stranici natjecanja: žuti {razlika_zuti:+d}, "
              f"crveni {razlika_crveni:+d}")
    else:
        print("  Poklapa se sa stranicom natjecanja.")


def main():
    imena = trazena_imena()
    if not imena:
        raise SystemExit(
            "Zadaj barem jedno ime, npr.:\n"
            '  python dijagnostika_kartoni.py "Doni Tanković"'
        )

    natjecanja = odabrana_natjecanja()
    if not natjecanja:
        raise SystemExit(
            f"Nijedno natjecanje ne odgovara nazivu {os.environ.get('NATJECANJE')!r}."
        )

    print(f"Tražim: {', '.join(imena)}")
    print(f"Sezona: {SEZONA}")
    print(f"Natjecanja: {', '.join(n['naziv'] for n in natjecanja)}")

    nadjeno = 0
    for natjecanje in natjecanja:
        print()
        print("=" * 70)
        print(f"NATJECANJE: {natjecanje['naziv']}")
        print("=" * 70)

        soup = BeautifulSoup(dohvati_stranicu(natjecanje["url"]).text,
                             "html.parser")
        svi_igraci = parsiraj_sve_igrace(soup)
        print(f"U sastavima klubova: {len(svi_igraci)} igrača.")

        pogodci = [i for i in svi_igraci
                   if any(_ista_osoba(ime, i["igrac"]) for ime in imena)]
        if not pogodci:
            print("Nijedno od traženih imena nije u ovoj ligi.")
            continue

        utakmice = dohvati_popis_utakmica(natjecanje["url"])
        for igrac in pogodci:
            nadjeno += 1
            ispisi_igraca(natjecanje, igrac, utakmice)

    if not nadjeno:
        print("\nNijedno ime nije nađeno ni u jednoj ligi. Provjeri kako je "
              "točno zapisano na stranici natjecanja.")


if __name__ == "__main__":
    main()

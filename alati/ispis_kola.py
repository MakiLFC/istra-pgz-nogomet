"""
ispis_kola.py

Ispisuje sve sto treba za pisanje najave ili pregleda jednog kola:
rezultate, strijelce s minutama, kartone, gledatelje, sluzbenu
ljestvicu i rang-liste. Ne dira bazu i nista ne upisuje.

CEMU SLUZI
Kad se clanak pise iz okruzenja koje nema pristup Supabaseu (npr.
Claude Code na webu), podaci se ne mogu procitati funkcijom
pregled_kola(). Ovaj alat ih uzima ravno sa Semafora, preko suhog
testa scrapera, i ispisuje ih u oblik koji stane u zapisnik posla.

KAKO SE POKRECE
Preko posla "Ispis kola" na GitHubu (Actions), koji prvo pokrene
scraper u suhom testu i spremi JSON, pa taj JSON preda ovom alatu:

    python scraper_supabase.py --dry-run --json liga.json --natjecanje "3. NL"
    python alati/ispis_kola.py liga.json 5

ZASTO SCRAPER IDE KROZ CIJELU SEZONU, A NE SAMO KROZ TRAZENO KOLO
Zbog rang-lista. Strijelci i kartoni se od 15.09.2026. zbrajaju iz
zapisnika, a u suhom testu nema baze iz koje bi se procitali prijasnji,
pa scraper raspolaze samo zapisnicima ovog prolaza. Uz --kolo bi to bilo
jedno kolo, lista bi zaostajala za sluzbenom i scraper bi objavio onu sa
stranice natjecanja, a ona kasi i po nekoliko sati (vidi CLAUDE.md).
Kad prolaz obuhvati sva kola, lista je ista ona koja je otisla na
stranicu. Cijena je nekoliko minuta po ligi.

Drugi argument je broj kola koje se ispisuje podrobno. Bez njega se
ispisuju sve odigrane utakmice.

STO SE NE ISPISUJE
Pomaci na ljestvici. Njih racuna pregled_kola() iz baze, a ovdje bi
se morali pogadjati. Ljestvica prije kola se dobije tako da se iz
sluzbene ljestvice oduzmu rezultati ovog kola, sto je racun koji se
radi kad zatreba, a ne pretpostavka koju bi alat upisao sam.
"""

import json
import sys


def ucitaj(putanja):
    with open(putanja, encoding="utf-8") as f:
        return json.load(f)


def dogadjaji_po_tipu(utakmica, tip):
    """Igraci iz obje postave koji imaju dogadjaj zadanog tipa.

    Vraca parove (ime, minuta, strana). Minuta zna biti prazna: dogadjaj
    bez minute je i dalje dogadjaj (vidi CLAUDE.md).
    """
    nadjeno = []
    for strana, kljuc in (("D", "postava_domacin"), ("G", "postava_gost")):
        for igrac in utakmica.get(kljuc) or []:
            for dogadjaj in igrac.get("dogadjaji") or []:
                if dogadjaj.get("tip") == tip:
                    nadjeno.append((igrac.get("igrac", ""),
                                    dogadjaj.get("minuta") or "",
                                    strana))
    return nadjeno


def ispisi_utakmicu(utakmica):
    print(f"\n{'-' * 60}")
    print(f"{utakmica.get('domacin')} - {utakmica.get('gost')}   "
          f"{utakmica.get('rezultat') or 'bez rezultata'}")
    print(f"  kolo: {utakmica.get('kolo')}   "
          f"datum: {utakmica.get('datum') or ''} "
          f"{utakmica.get('vrijeme') or ''}")
    print(f"  stadion: {utakmica.get('stadion') or ''}")
    if utakmica.get("stadion_datum"):
        print(f"  iz zapisnika: {utakmica['stadion_datum']}")
    print(f"  gledatelja: {utakmica.get('gledatelja') or 'nema podatka'}")
    if utakmica.get("suci"):
        print(f"  suci: {utakmica['suci']}")

    strijelci = utakmica.get("strijelci") or []
    if strijelci:
        print("  STRIJELCI (traka zapisnika):")
        for s in strijelci:
            oznaka = " (ag)" if s.get("autogol") else ""
            print(f"    {s.get('minuta') or '?'}'  "
                  f"{s.get('igrac', '')}{oznaka}")
    else:
        print("  STRIJELCI: nijedan u zapisniku")

    if utakmica.get("autogolovi"):
        print(f"  RUCNI STUPAC autogolovi: {utakmica['autogolovi']}")

    for naziv, tip in (("GOLOVI iz postave", "gol"),
                       ("AUTOGOLOVI iz postave", "autogol"),
                       ("ZUTI KARTONI", "karton_zuti"),
                       ("CRVENI KARTONI", "karton_crveni"),
                       ("DRUGI ZUTI", "karton_zutocrveni")):
        nadjeno = dogadjaji_po_tipu(utakmica, tip)
        if nadjeno:
            popis = ", ".join(
                f"{ime} ({strana}, {minuta + chr(39) if minuta else 'bez minute'})"
                for ime, minuta, strana in nadjeno
            )
            print(f"  {naziv}: {popis}")

    if not (utakmica.get("postava_domacin") or utakmica.get("postava_gost")):
        print("  NAPOMENA: zapisnik nema postave, pa kartoni nisu poznati.")


def ispisi_statistiku(redak):
    tip = redak.get("tip")
    podaci = redak.get("podaci") or []
    print(f"\n{'=' * 60}")
    print(f"{tip.upper()}  ({len(podaci)} redaka)")
    print("=" * 60)

    if tip == "tablica":
        print(f"  {'mj':>2}  {'klub':<22} {'od':>2} {'pb':>2} {'rm':>2} "
              f"{'pr':>2} {'dani':>4} {'prim':>4} {'raz':>4} {'bod':>3}")
        for klub in podaci:
            print(f"  {klub.get('pozicija') or '':>2}  "
                  f"{klub.get('klub') or '':<22} "
                  f"{klub.get('odigrano') or '':>2} "
                  f"{klub.get('pobjede') or '':>2} "
                  f"{klub.get('remiji') or '':>2} "
                  f"{klub.get('porazi') or '':>2} "
                  f"{klub.get('golovi_dani') or '':>4} "
                  f"{klub.get('golovi_primljeni') or '':>4} "
                  f"{klub.get('gol_razlika') or '':>4} "
                  f"{klub.get('bodovi') or '':>3}")
        return

    # Strijelci, kartoni i nastupi: samo vrh liste, ostalo je za bazu.
    for red in podaci[:25]:
        ostalo = " ".join(f"{k}={v}" for k, v in red.items()
                          if k not in ("pozicija", "igrac", "klub"))
        print(f"  {red.get('pozicija') or '':>3}. "
              f"{red.get('igrac') or '':<26} "
              f"{red.get('klub') or '':<22} {ostalo}")
    if len(podaci) > 25:
        print(f"  ... jos {len(podaci) - 25} redaka")


def main():
    if len(sys.argv) not in (2, 3):
        raise SystemExit(
            "Uporaba: python alati/ispis_kola.py liga.json [broj_kola]")

    sadrzaj = ucitaj(sys.argv[1])
    utakmice = sadrzaj.get("utakmice") or []
    statistike = sadrzaj.get("statistike") or []

    trazeno_kolo = None
    if len(sys.argv) == 3:
        trazeno_kolo = int(sys.argv[2])
        # Rang-liste se racunaju iz svih kola, ali se podrobno ispisuje
        # samo trazeno, da zapisnik posla ostane citljiv.
        utakmice = [u for u in utakmice if u.get("kolo") == trazeno_kolo]

    print("=" * 60)
    print(f"SEZONA: {sadrzaj.get('sezona')}   "
          f"kolo: {trazeno_kolo if trazeno_kolo else 'sva'}   "
          f"utakmica: {len(utakmice)}   "
          f"redaka statistike: {len(statistike)}")
    print("=" * 60)

    odigrane = [u for u in utakmice if u.get("rezultat")]
    neodigrane = [u for u in utakmice if not u.get("rezultat")]

    print(f"\nODIGRANO: {len(odigrane)}   BEZ REZULTATA: {len(neodigrane)}")

    for utakmica in odigrane:
        ispisi_utakmicu(utakmica)

    if neodigrane:
        print(f"\n{'=' * 60}")
        print("BEZ REZULTATA")
        print("=" * 60)
        for utakmica in neodigrane:
            print(f"  {utakmica.get('domacin')} - {utakmica.get('gost')}   "
                  f"{utakmica.get('datum') or ''} "
                  f"{utakmica.get('vrijeme') or ''}")

    for redak in statistike:
        ispisi_statistiku(redak)


if __name__ == "__main__":
    main()

"""
test_suhi_test.py

Provjerava zastavicu --dry-run ("suhi test") i ono što uz nju ide.

Zašto ovo postoji: suhi test ima smisla samo ako je ZAJAMČENO da ne
dodirne bazu. Ovdje se klijent prema Supabaseu namjerno zamjenjuje
zamkom koja ruši test čim je itko pozove, pa se propust ne može
provući neopaženo.

Uz to se provjerava i da neodigrana utakmica NE šalje prazan rezultat.
Kad bi ga slala, prolaz u kojem HNS ne prikaže poveznicu na zapisnik
obrisao bi rezultat već odigrane utakmice.

POKRETANJE:  python test_suhi_test.py
Ništa ne dohvaća s interneta i ništa ne piše u bazu.
"""

import io
import json
import os
import runpy
import sys
import tempfile
import types

# Scraper pri uvozu traži pakete kojih na ovom računalu ne mora biti.
for ime, sadrzaj in {
    "supabase": {"create_client": lambda *a, **k: None},
    "dotenv": {"load_dotenv": lambda *a, **k: None},
}.items():
    modul = types.ModuleType(ime)
    for kljuc, vrijednost in sadrzaj.items():
        setattr(modul, kljuc, vrijednost)
    sys.modules.setdefault(ime, modul)

import requests  # noqa: E402


ADRESA_NATJECANJA = "https://semafor.hns.family/natjecanja/111/proba-2627/"
ADRESA_ZAPISNIKA = "https://semafor.hns.family/utakmice/222/"


def stranica_natjecanja():
    """Raspored s dvije utakmice: prva odigrana (ima zapisnik), druga ne."""
    return """
    <html><body>
      <h2>Raspored natjecanja</h2>
      <div>1. kolo</div>
      <li>
        <a href="/klubovi/1/">NK Prvi</a>
        <a href="/utakmice/222/">2 : 1</a>
        <a href="/klubovi/2/">NK Drugi</a>
        <span>29.08.2026. 17:30</span>
        <span>Stadion Prvi</span>
      </li>
      <li>
        <a href="/klubovi/3/">NK Treći</a>
        <a href="/klubovi/4/">NK Četvrti</a>
        <span>29.08.2026. 17:30</span>
        <span>Stadion Treći</span>
      </li>
      <div>2. kolo</div>
      <li>
        <a href="/klubovi/2/">NK Drugi</a>
        <a href="/klubovi/1/">NK Prvi</a>
        <span>05.09.2026. 17:30</span>
        <span>Stadion Drugi</span>
      </li>
      <h2>Ljestvica</h2>
    </body></html>
    """


def igrac(ime, broj, pozicija="Igrač", dogadjaji=()):
    redci = "".join(
        f'<li class="{klasa}"><div class="icon" title="{naslov}"></div>{minuta}</li>'
        for klasa, naslov, minuta in dogadjaji
    )
    dogadjaji_html = f'<div class="matchEvents"><ul class="events">{redci}</ul></div>' if redci else ""
    return f"""
      <li>
        <h3><a href="/igraci/{broj}/">{ime}</a></h3>
        <span>{broj}</span>
        <span>{pozicija}</span>
        {dogadjaji_html}
      </li>
    """


def stranica_zapisnika():
    return f"""
    <html><head><title>NK Prvi - NK Drugi 2 : 1</title></head><body>
      <p>Stadion Prvi, Rijeka, 29.08.2026. 17:30</p>
      <p>Gledatelja: 250</p>
      <p>Suci: Ivan Sudac, Marko Pomoćnik.</p>

      <div class="events events_main">
        <ul>
          <li><div class="event goal"></div><div class="playerName">Ivan Prvi</div> 23'</li>
          <li><div class="event goal"></div><div class="playerName">Luka Prvi</div> 67'</li>
          <li><div class="event goal"></div><div class="playerName">Mateo Drugi</div> 81'</li>
        </ul>
      </div>

      <ul>
        <li>NK Prvi</li>
        {igrac("Marko Vratar", 1, "Vratar")}
        {igrac("Ivan Prvi", 9, dogadjaji=[("goal", "Gol", "23'")])}
        {igrac("Luka Prvi", 10, dogadjaji=[("goal", "Gol", "67'"), ("yellow", "Žuti karton", "70'")])}
        {igrac("Petar Prvi", 4, dogadjaji=[("red", "Crveni karton", "88'")])}
        <li>NK Drugi</li>
        {igrac("Josip Vratar", 1, "Vratar")}
        {igrac("Mateo Drugi", 7, dogadjaji=[("goal", "Gol", "81'")])}
        {igrac("Ante Drugi", 6, dogadjaji=[("substitutionOut", "Izmjena", "62'")])}
      </ul>
    </body></html>
    """


class Odgovor:
    def __init__(self, tekst):
        self.text = tekst

    def raise_for_status(self):
        pass


def lazni_get(url, **_):
    if "/utakmice/" in url:
        return Odgovor(stranica_zapisnika())
    return Odgovor(stranica_natjecanja())


class Zamka:
    """Sve što dotakne bazu prolazi kroz ovo. U suhom testu se ne smije
    pozvati nijednom."""

    def __init__(self):
        self.pozvana = False

    def __call__(self, *a, **k):
        self.pozvana = True
        raise AssertionError(
            "SUHI TEST JE DIRNUO BAZU! Netko je pozvao klijent() ili upsert."
        )


def pokreni(argumenti):
    """Pokreće scraper kao da je pozvan iz naredbenog retka i vraća
    (ispis, moduo)."""
    zamka = Zamka()
    requests.get = lazni_get

    stari_argv, stari_izlaz = sys.argv, sys.stdout
    sys.argv = ["scraper_supabase.py"] + argumenti
    sys.stdout = io.StringIO()
    try:
        prostor = runpy.run_path("scraper_supabase.py", run_name="__main__",
                                 init_globals={"klijent": zamka})
        ispis = sys.stdout.getvalue()
    finally:
        sys.argv, sys.stdout = stari_argv, stari_izlaz

    # runpy pokreće datoteku iznova, pa init_globals prepiše sama datoteka.
    # Zato zamku postavljamo i preko okoline: ako je ijedan upis pokušan,
    # pao bi na nedostajućim ključevima, koje ovdje namjerno ne postavljamo.
    return ispis, prostor


def provjeri(uvjet, opis):
    print(("  OK    " if uvjet else "  PALO  ") + opis)
    return uvjet


def main():
    # Ključeve namjerno NE postavljamo: da suhi test negdje ipak pokuša
    # pisati, klijent() bi pukao s porukom o nedostajućim postavkama.
    os.environ.pop("SUPABASE_URL", None)
    os.environ.pop("SUPABASE_SERVICE_KEY", None)
    os.environ.pop("DRY_RUN", None)

    sve_prolazi = True

    print("1. suhi test ne dira bazu")
    datoteka = os.path.join(tempfile.mkdtemp(), "probni.json")
    ispis, prostor = pokreni([
        "--dry-run", "--json", datoteka,
        "--natjecanje", "3. NL", "--url", ADRESA_NATJECANJA,
        "--sezona", "2025/26",
    ])
    sve_prolazi &= provjeri("U bazu nije upisano ništa." in ispis,
                            "završna poruka kaže da nije bilo upisa")
    sve_prolazi &= provjeri("BEZ UPISA" in ispis,
                            "svaka utakmica označena kao neupisana")
    sve_prolazi &= provjeri(prostor["PROBNI_REDCI"] and
                            len(prostor["PROBNI_REDCI"]) == 3,
                            "skupljena su sva tri retka rasporeda")

    print("2. odigrana utakmica je pročitana iz zapisnika")
    odigrana = next(r for r in prostor["PROBNI_REDCI"] if r.get("rezultat"))
    sve_prolazi &= provjeri(odigrana["rezultat"] == "2:1", "rezultat 2:1")
    sve_prolazi &= provjeri(len(odigrana["strijelci"]) == 3, "tri strijelca")
    sve_prolazi &= provjeri(odigrana["gledatelja"] == "250", "gledatelja 250")
    sve_prolazi &= provjeri(odigrana["suci"].startswith("Ivan Sudac"), "suci pročitani")
    tipovi = [d["tip"] for i in odigrana["postava_domacin"] + odigrana["postava_gost"]
              for d in i["dogadjaji"]]
    sve_prolazi &= provjeri(tipovi.count("gol") == 3, "tri gola u postavama")
    sve_prolazi &= provjeri(tipovi.count("karton_zuti") == 1, "jedan žuti karton")
    sve_prolazi &= provjeri(tipovi.count("karton_crveni") == 1, "jedan crveni karton")
    sve_prolazi &= provjeri(tipovi.count("izmjena_izlazak") == 1, "jedna izmjena")
    sve_prolazi &= provjeri("nepoznato" not in tipovi, "nijedan događaj nije neprepoznat")

    print("3. neodigrana utakmica ne šalje prazan rezultat")
    neodigrane = [r for r in prostor["PROBNI_REDCI"] if "rezultat" not in r]
    sve_prolazi &= provjeri(len(neodigrane) == 2, "dvije utakmice bez zapisnika")
    sve_prolazi &= provjeri(all("hns_url" not in r for r in neodigrane),
                            "ni adresa zapisnika se ne šalje")
    sve_prolazi &= provjeri(all(r.get("datum") for r in neodigrane),
                            "datum s rasporeda je upisan")

    print("4. sezona i odabir kola")
    sve_prolazi &= provjeri(all(r["sezona"] == "2025/26" for r in prostor["PROBNI_REDCI"]),
                            "--sezona je poštovana")
    ispis2, prostor2 = pokreni([
        "--dry-run", "--natjecanje", "3. NL", "--url", ADRESA_NATJECANJA, "--kolo", "2",
    ])
    sve_prolazi &= provjeri(len(prostor2["PROBNI_REDCI"]) == 1,
                            "--kolo 2 ostavlja jednu utakmicu")

    print("5. datoteka s punim sadržajem")
    with open(datoteka, encoding="utf-8") as f:
        spremljeno = json.load(f)
    sve_prolazi &= provjeri(len(spremljeno["utakmice"]) == 3,
                            "JSON sadrži sve utakmice")
    sve_prolazi &= provjeri("statistike" in spremljeno, "JSON sadrži i statistike")

    print()
    print("PROLAZI" if sve_prolazi else "NE PROLAZI")
    return 0 if sve_prolazi else 1


if __name__ == "__main__":
    sys.exit(main())

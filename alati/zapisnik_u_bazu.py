"""Zapisnik jedne utakmice iz datoteke u bazu. Pokreće ga posao
"Zapisnik u bazu".

ČEMU SLUŽI

HNS je 12.11.2026. zabranio automatsko preuzimanje podataka i scraper
više ne radi (pravilo 7 u CLAUDE.md). Rezultate, strijelce, postave,
kartone i izmjene od tada upisuje Andrej, uredničkim putem: snimi zaslon
dok prolazi kroz zapisnik na Semaforu, Claude iz snimke prepiše podatke
u datoteku `zapisnici/<slug>.txt`, a ovaj alat je upiše u bazu.

Utakmica se traži po ISTOM ključu kao u scraperu
(natjecanje, sezona, kolo, domacin, gost), nikad po id-ju, da se ne može
pogoditi tuđi redak. Imena klubova se pišu točno kako stoje u bazi.

Upisuju se oni stupci koje je upisivao i scraper, u istom obliku, pa
stranica prikazuje zapisnik kao i dosad:

    rezultat, stadion_datum, gledatelja, suci, strijelci,
    postava_domacin, postava_gost

Stupce koje scraper nikad nije dirao (derbi, tekst_clanka, slika_url,
autogolovi) ne dira ni ovaj alat.

OBLIK DATOTEKE

    natjecanje: 3. NL Zapad
    sezona: 2026/27
    kolo: 11
    domacin: NK Vinodol
    gost: NK Nehaj
    rezultat: 1:1
    stadion_datum: BAHALIN, NOVI VINODOLSKI, 07.11.2026. 14:30
    gledatelja: 100
    suci: Goran Krneta, David Ružić, Luka Mravić.
    ---
    [domacin]
    99 | Matija Ugrinović | vratar
    18 | Marcelo Suden | 16' gol
    11 | Luka Filipović | (C), 84' zuti
    9  | Edmar Junior Dos Santos Neves | 68' izlazak
    [domacin pricuva]
    23 | Din Pozderac | 68' ulazak
    [gost]
    1  | Lovro Pichler | vratar
    [gost pricuva]
    13 | Ante Prpić | 64' ulazak, 86' zuti

Redak igrača je "broj | ime | oznake", a oznake su odvojene zarezom.
Broj i oznake smiju izostati. Priznate oznake:

    vratar, (C)
    gol, autogol, zuti, crveni, drugi zuti, izlazak, ulazak

uz minutu ispred ("16'", "45+1'" ili samo "16"). Događaj bez minute se
upisuje s praznom minutom, jer HNS zna takav zapisnik, i to nije razlog
da se događaj izgubi (vidi CLAUDE.md).

ŠTO ALAT RAČUNA SAM

Popis strijelaca se NE prepisuje posebno nego se slaže iz golova u
postavama, poredan po minuti. Tako postoji samo jedan izvor istine i
dvije liste se ne mogu raziđi.

KOČNICA

Zbroj golova iz postava mora se slagati s rezultatom, pri čemu autogol
ide PROTIVNIKU strijelca. Kad se ne slaže, alat NE UPISUJE NIŠTA nego
javi grešku. Kod scrapera je to bilo upozorenje, jer je podatak dolazio
s HNS-a takav kakav je. Ovdje nesklad gotovo uvijek znači krivo
prepisanu minutu ili igrača, a kriva postava u bazi ostaje zauvijek i
nitko je ne primijeti. Namjerni nesklad se propušta zastavicom
--dopusti-nesklad.

RADNJE

    provjeri  (zadano) ništa ne upisuje, samo ispiše što bi upisao i
              kaže je li utakmica nađena
    upis      upiše zapisnik u redak utakmice
    skini     obriše zapisnik iz retka (rezultat ostaje)
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path

import requests

MAPA = Path("zapisnici")

# Ime oznake u datoteci -> tip događaja kakav je upisivao scraper.
# Redoslijed je bitan pri traženju: "drugi zuti" mora ići prije "zuti".
DOGADJAJI = (
    ("drugi zuti", "karton_zutocrveni"),
    ("drugi žuti", "karton_zutocrveni"),
    ("zutocrveni", "karton_zutocrveni"),
    ("autogol", "autogol"),
    ("gol", "gol"),
    ("zuti", "karton_zuti"),
    ("žuti", "karton_zuti"),
    ("crveni", "karton_crveni"),
    ("izlazak", "izmjena_izlazak"),
    ("ulazak", "izmjena_ulazak"),
)

ODJELJCI = {
    "[domacin]": ("postava_domacin", False),
    "[domacin pricuva]": ("postava_domacin", True),
    "[gost]": ("postava_gost", False),
    "[gost pricuva]": ("postava_gost", True),
}

KLJUC_UTAKMICE = ("natjecanje", "sezona", "kolo", "domacin", "gost")

STUPCI_ZAPISNIKA = ("rezultat", "stadion_datum", "gledatelja", "suci",
                    "strijelci", "postava_domacin", "postava_gost")


# ---------------------------------------------------------------------
# Čitanje datoteke
# ---------------------------------------------------------------------

def normaliziraj_minutu(tekst: str) -> str:
    """ "16" i "16'" daju "16'", a "45+1" daje "45+1'". Prazno ostaje prazno."""
    t = (tekst or "").strip().rstrip("'").strip()
    return f"{t}'" if t else ""


def procitaj_oznake(tekst: str, gdje: str):
    """Iz "vratar, (C), 16' gol" vadi poziciju, kapetana i događaje."""
    pozicija = "Igrač"
    kapetan = False
    dogadjaji = []

    for dio in (d.strip() for d in (tekst or "").split(",")):
        if not dio:
            continue

        nizak = dio.lower()

        if nizak == "vratar":
            pozicija = "Vratar"
            continue
        if nizak in ("(c)", "c", "kapetan"):
            kapetan = True
            continue

        # Minuta smije stajati ispred ili iza oznake, pa se traži gdje god bila.
        m = re.search(r"(\d{1,3}(?:\+\d{1,2})?)\s*'?", nizak)
        minuta = normaliziraj_minutu(m.group(1)) if m else ""
        bez_minute = re.sub(r"\d{1,3}(?:\+\d{1,2})?\s*'?", "", nizak).strip()

        tip = next((t for oznaka, t in DOGADJAJI if oznaka in bez_minute), None)
        if tip is None:
            raise SystemExit(
                f"{gdje}: ne razumijem oznaku '{dio}'.\n"
                "Priznate su: vratar, (C), gol, autogol, zuti, crveni, "
                "drugi zuti, izlazak, ulazak."
            )

        dogadjaji.append({"minuta": minuta, "tip": tip})

    return pozicija, kapetan, dogadjaji


def procitaj_igraca(redak: str, pricuvni: bool, gdje: str) -> dict:
    dijelovi = [d.strip() for d in redak.split("|")]

    broj = None
    if dijelovi and dijelovi[0].isdigit():
        broj = dijelovi.pop(0)

    if not dijelovi or not dijelovi[0]:
        raise SystemExit(f"{gdje}: redak nema ime igrača: {redak}")

    ime = dijelovi[0]
    oznake = dijelovi[1] if len(dijelovi) > 1 else ""

    # "(C)" iza imena je uobičajen zapis na Semaforu, pa se prima i tako.
    if "(C)" in ime.upper():
        ime = re.sub(r"\(C\)", "", ime, flags=re.I).strip()
        oznake = (oznake + ", (C)").strip(", ")

    pozicija, kapetan, dogadjaji = procitaj_oznake(oznake, gdje)

    return {
        "igrac": ime,
        "broj": broj,
        "pozicija": pozicija,
        "kapetan": kapetan,
        "pricuvni": pricuvni,
        "dogadjaji": dogadjaji,
    }


def procitaj_datoteku(putanja: Path) -> dict:
    sadrzaj = putanja.read_text(encoding="utf-8")

    if "---" not in sadrzaj:
        raise SystemExit(
            f"{putanja}: nedostaje redak '---' između zaglavlja i postava."
        )

    zaglavlje_tekst, postave_tekst = sadrzaj.split("---", 1)

    zaglavlje = {}
    for redak in zaglavlje_tekst.splitlines():
        redak = redak.strip()
        if not redak or redak.startswith("#"):
            continue
        if ":" not in redak:
            raise SystemExit(f"{putanja}: redak zaglavlja bez dvotočke: {redak}")
        kljuc, vrijednost = redak.split(":", 1)
        zaglavlje[kljuc.strip().lower()] = vrijednost.strip()

    for obavezno in KLJUC_UTAKMICE + ("rezultat",):
        if not zaglavlje.get(obavezno):
            raise SystemExit(f"{putanja}: u zaglavlju nedostaje '{obavezno}'.")

    if not re.fullmatch(r"\d+\s*:\s*\d+", zaglavlje["rezultat"]):
        raise SystemExit(
            f"{putanja}: rezultat mora biti oblika '1:1', a stoji "
            f"'{zaglavlje['rezultat']}'."
        )

    postave = {"postava_domacin": [], "postava_gost": []}
    odjeljak = None
    pricuvni = False

    for broj_retka, redak in enumerate(postave_tekst.splitlines(), 1):
        gol_redak = redak.strip()
        if not gol_redak or gol_redak.startswith("#"):
            continue

        if gol_redak.lower() in ODJELJCI:
            odjeljak, pricuvni = ODJELJCI[gol_redak.lower()]
            continue

        if odjeljak is None:
            raise SystemExit(
                f"{putanja}, redak {broj_retka}: igrač prije ijednog odjeljka. "
                "Prvi mora biti [domacin]."
            )

        postave[odjeljak].append(
            procitaj_igraca(gol_redak, pricuvni, f"{putanja}, redak {broj_retka}")
        )

    if not postave["postava_domacin"] or not postave["postava_gost"]:
        raise SystemExit(f"{putanja}: fali postava jedne od momčadi.")

    return {"zaglavlje": zaglavlje, **postave}


# ---------------------------------------------------------------------
# Izvedeni podaci i provjere
# ---------------------------------------------------------------------

def strijelci_iz_postava(postava_d, postava_g):
    """Popis strijelaca se slaže iz golova u postavama, ne prepisuje se.

    Autogol nosi oznaku, jednako kao kod scrapera, pa ga prikaz i
    pregled_kola() pripišu protivniku i izbace iz ljestvice strijelaca.
    """
    strijelci = []
    for postava in (postava_d, postava_g):
        for igrac in postava:
            for d in igrac["dogadjaji"]:
                if d["tip"] in ("gol", "autogol"):
                    zapis = {"igrac": igrac["igrac"], "minuta": d["minuta"]}
                    if d["tip"] == "autogol":
                        zapis["autogol"] = True
                    strijelci.append(zapis)

    def po_minuti(s):
        m = re.match(r"\d+", s["minuta"] or "")
        return int(m.group()) if m else 0

    strijelci.sort(key=po_minuti)
    return strijelci


def prebroji_golove(postava, protivnicka):
    """Golovi jedne momčadi: njezini pogoci plus autogoli protivnika."""
    svoji = sum(1 for i in postava for d in i["dogadjaji"] if d["tip"] == "gol")
    tudji = sum(1 for i in protivnicka for d in i["dogadjaji"] if d["tip"] == "autogol")
    return svoji + tudji


def provjeri_zbroj(rezultat, postava_d, postava_g, dopusti):
    d_rez, g_rez = (int(x) for x in re.split(r"\s*:\s*", rezultat))
    d_zbroj = prebroji_golove(postava_d, postava_g)
    g_zbroj = prebroji_golove(postava_g, postava_d)

    if (d_rez, g_rez) == (d_zbroj, g_zbroj):
        return

    poruka = (
        "ZBROJ GOLOVA SE NE SLAŽE S REZULTATOM.\n"
        f"  rezultat u zaglavlju: {d_rez}:{g_rez}\n"
        f"  zbroj iz postava:     {d_zbroj}:{g_zbroj}\n"
        "Autogol se broji protivniku. Provjeri minute i igrače."
    )

    if dopusti:
        print(poruka)
        print("Propušteno zbog --dopusti-nesklad.")
        print()
        return

    raise SystemExit(poruka + "\nNije upisano ništa.")


def upozori_na_postavu(postave):
    """Jedanaestorica po strani je pravilo, pa sve drugo treba pogledati."""
    for ime, postava in postave.items():
        pocetnika = sum(1 for i in postava if not i["pricuvni"])
        if pocetnika != 11:
            print(f"NAPOMENA: {ime} ima {pocetnika} početnika, a očekuje se 11.")


# ---------------------------------------------------------------------
# Baza
# ---------------------------------------------------------------------

class Utakmice:
    def __init__(self, adresa: str, kljuc: str):
        self.cilj = f"{adresa.rstrip('/')}/rest/v1/utakmice"
        # Supabase traži OBA zaglavlja s ključem (vidi CLAUDE.md).
        self.zaglavlja = {
            "apikey": kljuc,
            "Authorization": f"Bearer {kljuc}",
            "Content-Type": "application/json",
            "Prefer": "return=representation",
        }

    @staticmethod
    def _uvjet(kljuc_utakmice):
        return {k: f"eq.{v}" for k, v in kljuc_utakmice.items()}

    def dohvati(self, kljuc_utakmice):
        o = requests.get(self.cilj, headers=self.zaglavlja, timeout=30,
                         params={**self._uvjet(kljuc_utakmice),
                                 "select": "id,domacin,gost,rezultat,suci,gledatelja"})
        if o.status_code >= 400:
            raise SystemExit(f"Dohvat utakmice nije uspio ({o.status_code}): {o.text}")
        return o.json()

    def nadji_par(self, kljuc_utakmice):
        """Isti par, ali BEZ kola. Služi samo za poruku o grešci.

        Kad utakmica nije nađena, najčešći uzrok nije krivo ime nego
        krivo kolo: utakmica zna biti odgođena ili igrana unaprijed, pa
        datum ne govori kojem kolu pripada. Provjereno 12.11.2026. na
        Vinodol - Nehaj, odigranoj 07.11., koja nije u 11. kolu.

        Zato alat sam potraži par i kaže u kojem kolu stoji, umjesto da
        korisnik pogađa.
        """
        bez_kola = {k: v for k, v in kljuc_utakmice.items() if k != "kolo"}
        o = requests.get(self.cilj, headers=self.zaglavlja, timeout=30,
                         params={**self._uvjet(bez_kola),
                                 "select": "kolo,datum,rezultat"})
        if o.status_code >= 400:
            return []
        return o.json()

    def promijeni(self, kljuc_utakmice, podaci):
        o = requests.patch(self.cilj, headers=self.zaglavlja, timeout=30,
                           params=self._uvjet(kljuc_utakmice), json=podaci)
        if o.status_code >= 400:
            raise SystemExit(f"Upis u utakmicu nije uspio ({o.status_code}): {o.text}")
        return o.json()


def opis(kljuc_utakmice) -> str:
    k = kljuc_utakmice
    return (f"{k['domacin']} - {k['gost']} "
            f"({k['natjecanje']}, {k['sezona']}, {k['kolo']}. kolo)")


# ---------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Zapisnik iz datoteke u bazu.")
    parser.add_argument("datoteka", help="zapisnici/<slug>.txt ili samo <slug>")
    parser.add_argument("--radnja", default="provjeri",
                        choices=("provjeri", "upis", "skini"))
    parser.add_argument("--dopusti-nesklad", action="store_true",
                        help="upiši i kad se zbroj golova ne slaže s rezultatom")
    args = parser.parse_args()

    putanja = Path(args.datoteka)
    if not putanja.suffix:
        putanja = MAPA / f"{putanja.name}.txt"
    if not putanja.exists():
        raise SystemExit(f"Nema datoteke {putanja}.")

    podaci = procitaj_datoteku(putanja)
    z = podaci["zaglavlje"]

    kljuc_utakmice = {k: z[k] for k in KLJUC_UTAKMICE}
    postava_d = podaci["postava_domacin"]
    postava_g = podaci["postava_gost"]

    print("=" * 60)
    print(opis(kljuc_utakmice))
    print("=" * 60)

    upozori_na_postavu({"domaćin": postava_d, "gost": postava_g})

    if args.radnja != "skini":
        provjeri_zbroj(z["rezultat"], postava_d, postava_g, args.dopusti_nesklad)

    strijelci = strijelci_iz_postava(postava_d, postava_g)

    stupci = {
        "rezultat": z["rezultat"].replace(" ", ""),
        "strijelci": strijelci,
        "postava_domacin": postava_d,
        "postava_gost": postava_g,
    }
    for neobavezno in ("stadion_datum", "gledatelja", "suci"):
        if z.get(neobavezno):
            stupci[neobavezno] = z[neobavezno]

    print(f"Strijelci ({len(strijelci)}):")
    for s in strijelci:
        oznaka = " (ag)" if s.get("autogol") else ""
        print(f"  {s['minuta'] or '?'} {s['igrac']}{oznaka}")
    print(f"Postave: {len(postava_d)} i {len(postava_g)} igrača")
    print()

    adresa = os.environ.get("SUPABASE_URL") or ""
    kljuc = os.environ.get("SUPABASE_SERVICE_KEY") or ""
    if not adresa or not kljuc:
        raise SystemExit("Nedostaje SUPABASE_URL ili SUPABASE_SERVICE_KEY.")

    tablica = Utakmice(adresa, kljuc)

    redci = tablica.dohvati(kljuc_utakmice)
    if len(redci) != 1:
        poruka = [f"Utakmica nije pronađena jednoznačno ({len(redci)} redaka)."]

        if not redci:
            drugdje = tablica.nadji_par(kljuc_utakmice)
            if drugdje:
                poruka.append("Taj par u bazi POSTOJI, ali u drugom kolu:")
                for r in drugdje:
                    poruka.append(
                        f"  {r.get('kolo')}. kolo, datum {r.get('datum') or 'nepoznat'}, "
                        f"rezultat {r.get('rezultat') or 'nema'}"
                    )
                poruka.append("Ispravi 'kolo' u zaglavlju datoteke.")
            else:
                poruka.append(
                    "Par nije nađen ni bez kola, pa je vjerojatno krivo ime "
                    "kluba, natjecanja ili sezone. Imena moraju stajati točno "
                    "kako su u bazi."
                )

        raise SystemExit("\n".join(poruka))

    if args.radnja == "provjeri":
        print("Utakmica je pronađena. Ovo je samo provjera, ništa nije upisano.")
        print("Stanje u bazi:")
        print(json.dumps(redci[0], ensure_ascii=False, indent=2))
        return

    if args.radnja == "skini":
        tablica.promijeni(kljuc_utakmice, {s: None for s in STUPCI_ZAPISNIKA
                                           if s != "rezultat"})
        print("Zapisnik je maknut. Rezultat je ostao.")
        return

    tablica.promijeni(kljuc_utakmice, stupci)
    print("Zapisnik je upisan. Stranica utakmice osvježi se u nekoliko minuta.")


if __name__ == "__main__":
    sys.exit(main())

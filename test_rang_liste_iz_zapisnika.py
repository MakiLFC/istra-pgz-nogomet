"""
test_rang_liste_iz_zapisnika.py

Provjerava rang-liste strijelaca i kartona složene IZ ZAPISNIKA, dakle iz
postava koje su već u bazi, umjesto čekanja da HNS osvježi sastave klubova.

Zašto ovo postoji: 12.09.2026. je nakon 3. kola 3. NL Zapad tablica
poretka bila svježa, svi zapisnici potpuni, a golovi po igraču zaostajali.
Ahmed Durmo je po zapisnicima imao četiri gola, a u sastavu na stranici
dva. Podatak je dakle već bio kod nas, samo ga nitko nije zbrojio.

Provjerava se i kočnica: lista iz zapisnika objavljuje se samo kad nigdje
ne zaostaje za onom sa stranice natjecanja.

POKRETANJE:  python test_rang_liste_iz_zapisnika.py
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

from scraper_supabase import (  # noqa: E402
    ucinci_iz_zapisnika,
    uskladi_imena,
    zaostaje_za_sluzbenom,
    odaberi_rang_listu,
    slozi_pune_rang_liste,
    golovi_iz_trake,
    potvrdjeno_zapisnikom,
)

greske = []


def provjeri(uvjet, opis):
    if uvjet:
        print(f"  OK   {opis}")
    else:
        print(f"  PAO  {opis}")
        greske.append(opis)


def igrac(ime, *dogadjaji):
    """Igrač u postavi; događaji se pišu kao ("gol", "16'")."""
    return {"igrac": ime, "broj": "9", "pozicija": "Igrač", "kapetan": False,
            "pricuvni": False,
            "dogadjaji": [{"tip": t, "minuta": m} for t, m in dogadjaji]}


def utakmica(kolo, domacin, gost, rezultat, postava_d, postava_g,
             autogolovi=None):
    redak = {"kolo": kolo, "domacin": domacin, "gost": gost,
             "rezultat": rezultat,
             "postava_domacin": postava_d, "postava_gost": postava_g}
    if autogolovi is not None:
        redak["autogolovi"] = autogolovi
    return redak


def ucinak(ucinci, ime):
    for u in ucinci:
        if u["igrac"] == ime:
            return u
    return None


print("\n1) Golovi i kartoni se zbrajaju kroz kola, klub se uzima iz postave")
# Durmo zabija dva u 1. i dva u 3. kolu, dakle četiri, iako sastav na
# stranici natjecanja te večeri pokazuje dva.
utakmice = [
    utakmica(1, "NK Lokomotiva", "NK Halubjan", "2:1",
             [igrac("Ahmed Durmo", ("gol", "12'"), ("gol", "40'"))],
             [igrac("Karlo Josipović", ("gol", "70'"),
                    ("karton_zuti", "80'"))]),
    utakmica(3, "NK Halubjan", "NK Lokomotiva", "0:2",
             [igrac("Karlo Josipović", ("karton_zuti", "22'"))],
             [igrac("Ahmed Durmo", ("gol", "5'"), ("gol", "88'"))]),
]
ucinci, bez_postava = ucinci_iz_zapisnika(utakmice)
d = ucinak(ucinci, "Ahmed Durmo")
j = ucinak(ucinci, "Karlo Josipović")
provjeri(d and d["golovi"] == 4, "Durmo ima četiri gola iz dva kola")
provjeri(d and d["klub"] == "NK Lokomotiva",
         "Durmo je u Lokomotivi i kad igra kao gost")
provjeri(j and j["klub"] == "NK Halubjan",
         "Josipović je u Halubjanu, klub se čita iz postave u kojoj stoji")
provjeri(j and j["zuti"] == 2, "Josipović ima dva žuta kartona")
provjeri(bez_postava == [], "nijedna utakmica ne fali")

print("\n2) Autogol nije zasluga strijelca i ne ulazi u golove")
utakmice = [
    utakmica(1, "NK Jadran-Poreč", "NK Nehaj", "1:3",
             [igrac("Vedran Radman", ("autogol", "16'"))],
             [igrac("Marko Marić", ("gol", "20'"))]),
]
ucinci, _ = ucinci_iz_zapisnika(utakmice)
provjeri(ucinak(ucinci, "Vedran Radman") is None,
         "igrač s samim autogolom uopće nije na listi strijelaca")
provjeri(ucinak(ucinci, "Marko Marić")["golovi"] == 1,
         "obični gol protivnika se broji normalno")

print("\n3) Ručni popis autogolova vrijedi jednako kao oznaka iz zapisnika")
# Za utakmice odigrane prije nego je prepoznavanje dodano, i za pogotke
# koje HNS nije označio, autogol stoji u stupcu utakmice.autogolovi.
utakmice = [
    utakmica(2, "NK Rab", "NK Vihor", "4:2",
             [igrac("Ivan Ivić", ("gol", "10'"))],
             [igrac("Josip Radić", ("gol", "33'"), ("gol", "60'"))],
             autogolovi=[{"igrac": "Radić", "minuta": "33'"}]),
]
ucinci, _ = ucinci_iz_zapisnika(utakmice)
provjeri(ucinak(ucinci, "Josip Radić")["golovi"] == 1,
         "ručno označen autogol se oduzima, ostaje pravi gol")
provjeri(ucinak(ucinci, "Ivan Ivić")["golovi"] == 1,
         "ručni popis ne dira ostale strijelce")

print("\n4) Drugi žuti karton je crveni; žuti prije njega se broji sam")
utakmice = [
    utakmica(1, "NK Žminj", "NK Ližnjan", "1:1",
             [igrac("Petar Perić", ("karton_zuti", "30'"),
                    ("karton_zutocrveni", "70'"))],
             [igrac("Luka Lukić", ("karton_crveni", "85'"))]),
]
ucinci, _ = ucinci_iz_zapisnika(utakmice)
p = ucinak(ucinci, "Petar Perić")
provjeri(p["crveni"] == 1 and p["zuti"] == 1,
         "nakon drugog žutog: jedan crveni i jedan žuti")
provjeri(ucinak(ucinci, "Luka Lukić")["crveni"] == 1,
         "izravan crveni karton se broji")

print("\n5) Neodigrana utakmica se preskače, odigrana bez postava se prijavljuje")
utakmice = [
    utakmica(5, "NK Otočac", "NK Krk", None, [], []),
    utakmica(4, "NK Krk", "NK Otočac", "3:0", [], []),
]
ucinci, bez_postava = ucinci_iz_zapisnika(utakmice)
provjeri(ucinci == [], "bez postava nema se što zbrojiti")
provjeri(len(bez_postava) == 1 and "4. kolo" in bez_postava[0],
         "prijavljuje se samo odigrana utakmica bez postava")
provjeri("5. kolo" not in " ".join(bez_postava),
         "utakmica koja se tek igra nije propust")

print("\n6) Ime iz zapisnika se svodi na ono iz sastava klubova")
# Stranica igrača nastaje iz imena, pa isti igrač zapisan na dva načina
# ne smije postati dvije stranice.
svi_igraci = [
    {"igrac": "Sebastijan Antić", "klub": "NK Krk"},
    {"igrac": "Luka Lukić", "klub": "NK Krk"},
]
ucinci = uskladi_imena(
    [{"igrac": "Antić", "klub": "NK Krk", "vratar": False,
      "golovi": 2, "zuti": 0, "crveni": 0}],
    svi_igraci,
)
provjeri(ucinci[0]["igrac"] == "Sebastijan Antić",
         "kratko ime se zamjenjuje punim iz sastava")

# Dvojica koji oboje odgovaraju: ne pogađa se ništa.
svi_dva = svi_igraci + [{"igrac": "Mateo Antić", "klub": "NK Krk"}]
ucinci = uskladi_imena(
    [{"igrac": "Antić", "klub": "NK Krk", "vratar": False,
      "golovi": 2, "zuti": 0, "crveni": 0}],
    svi_dva,
)
provjeri(ucinci[0]["igrac"] == "Antić",
         "kad odgovaraju dvojica, ime ostaje kakvo je")

# Nakon usklađivanja dva zapisa istog igrača spajaju se u jedan.
ucinci = uskladi_imena(
    [{"igrac": "Antić", "klub": "NK Krk", "vratar": False,
      "golovi": 2, "zuti": 1, "crveni": 0},
     {"igrac": "Sebastijan Antić", "klub": "NK Krk", "vratar": False,
      "golovi": 1, "zuti": 0, "crveni": 1}],
    svi_igraci,
)
provjeri(len(ucinci) == 1 and ucinci[0]["golovi"] == 3
         and ucinci[0]["zuti"] == 1 and ucinci[0]["crveni"] == 1,
         "dva zapisa istog igrača se zbrajaju, ništa se ne gubi")

print("\n7) Kočnica: lista iz zapisnika smije biti ispred, ali ne iza")
sluzbeni = [{"pozicija": "1", "igrac": "Ahmed Durmo", "klub": "NK Lokomotiva",
             "golovi": "2"}]
nasi_ispred = [{"pozicija": "1", "igrac": "Ahmed Durmo",
                "klub": "NK Lokomotiva", "golovi": "4"}]
nasi_iza = [{"pozicija": "1", "igrac": "Ahmed Durmo",
             "klub": "NK Lokomotiva", "golovi": "1"}]

provjeri(zaostaje_za_sluzbenom(nasi_ispred, sluzbeni, ("golovi",)) == [],
         "četiri gola prema službena dva nije zaostajanje")
provjeri(len(zaostaje_za_sluzbenom(nasi_iza, sluzbeni, ("golovi",))) == 1,
         "jedan gol prema službena dva jest zaostajanje")
provjeri(len(zaostaje_za_sluzbenom([], sluzbeni, ("golovi",))) == 1,
         "igrač kojeg kod nas uopće nema računa se kao zaostajanje")

lista, otkud = odaberi_rang_listu(nasi_ispred, sluzbeni, ("golovi",))
provjeri(lista is nasi_ispred and "iz zapisnika" in otkud,
         "kad ne zaostaje, na stranicu ide lista iz zapisnika")
lista, otkud = odaberi_rang_listu(nasi_iza, sluzbeni, ("golovi",))
provjeri(lista is sluzbeni and "zaostaje" in otkud,
         "kad zaostaje, ostaje lista sa stranice natjecanja")
lista, otkud = odaberi_rang_listu([], sluzbeni, ("golovi",))
provjeri(lista is sluzbeni, "prazna lista iz zapisnika se ne objavljuje")

print("\n8) Kartoni se uspoređuju po žutima I po crvenima")
sluzbeni_k = [{"pozicija": "1", "igrac": "Petar Perić", "klub": "NK Žminj",
               "zuti": "3", "crveni": "1"}]
manje_zutih = [{"pozicija": "1", "igrac": "Petar Perić", "klub": "NK Žminj",
                "zuti": "2", "crveni": "1"}]
provjeri(len(zaostaje_za_sluzbenom(manje_zutih, sluzbeni_k,
                                   ("zuti", "crveni"))) == 1,
         "manje žutih nego službeno je zaostajanje")

print("\n9) Poredak je isti kao kod liste sa stranice natjecanja")
ucinci = [
    {"igrac": "B Drugi", "klub": "NK A", "vratar": False,
     "golovi": 2, "zuti": 1, "crveni": 0},
    {"igrac": "A Prvi", "klub": "NK A", "vratar": False,
     "golovi": 5, "zuti": 2, "crveni": 1},
]
strijelci, kartoni = slozi_pune_rang_liste(ucinci)
provjeri([s["igrac"] for s in strijelci] == ["A Prvi", "B Drugi"],
         "strijelci idu po broju golova")
provjeri([k["igrac"] for k in kartoni] == ["A Prvi", "B Drugi"],
         "kartoni idu po crvenima pa po žutima")

print("\n10) Vratar koji zabije ima gol")
# U sastavima klubova stupac golova kod vratara znači PRIMLJENE, pa se
# ondje vratari izbacuju. U zapisniku "gol" znači zabijeni gol, pa ovdje
# tog problema nema i ne smije se nasljepo primijeniti isto pravilo.
utakmice = [
    utakmica(1, "NK A", "NK B", "1:0",
             [{"igrac": "Vratar Vratarović", "broj": "1", "pozicija": "Vratar",
               "kapetan": False, "pricuvni": False,
               "dogadjaji": [{"tip": "gol", "minuta": "90'"}]}],
             [igrac("Netko Nikakav", ("izmjena_izlazak", "60'"))]),
]
ucinci, _ = ucinci_iz_zapisnika(utakmice)
strijelci, _ = slozi_pune_rang_liste(ucinci)
provjeri([s["igrac"] for s in strijelci] == ["Vratar Vratarović"],
         "vratarov gol iz zapisnika ostaje na listi strijelaca")
provjeri(ucinak(ucinci, "Netko Nikakav") is None,
         "izmjena nije ni gol ni karton")

print("\n11) HNS ispravi zapisnik, a stranica natjecanja kasni")
# Stvarni slučaj, 4. NL NS Rijeka 2026/27. Babić je Umagu zabio tri gola,
# a gol u Medulinu HNS je naknadno prepisao na Tomića. Zapisnici kažu tri,
# stranica natjecanja još pokazuje četiri. Kočnica tada ne smije vratiti
# HNS-ovu listu, jer nama ne fali ništa.
def strijelac(ime, minuta, autogol=False):
    s = {"igrac": ime, "minuta": minuta}
    if autogol:
        s["autogol"] = True
    return s

cres_umag = utakmica(2, "NK Cres", "NK Umag", "4:1",
                     [igrac("Boško Babić", ("gol", "35'"), ("gol", "44'"),
                            ("gol", "65'")),
                      igrac("Emir Slomić", ("gol", "80'"))],
                     [igrac("Netko Umaški", ("gol", "50'"))])
cres_umag["strijelci"] = [strijelac("Boško Babić", "35'"),
                          strijelac("Boško Babić", "44'"),
                          strijelac("Netko Umaški", "50'"),
                          strijelac("Boško Babić", "65'"),
                          strijelac("Emir Slomić", "80'")]
medulin_cres = utakmica(3, "NK Medulin", "NK Cres", "1:2",
                        [igrac("Luka Pamić", ("gol", "36'"))],
                        [igrac("Emir Slomić", ("gol", "7'")),
                         igrac("Željko Tomić", ("gol", "35'"))])
medulin_cres["strijelci"] = [strijelac("Emir Slomić", "7'"),
                             strijelac("Željko Tomić", "35'"),
                             strijelac("Luka Pamić", "36'")]
zapisnici = [cres_umag, medulin_cres]

ucinci, bez_postava = ucinci_iz_zapisnika(zapisnici)
nasi, _ = slozi_pune_rang_liste(ucinci)
hns = [{"pozicija": "1", "igrac": "Boško Babić", "klub": "NK Cres",
        "golovi": "4"}]
traka = golovi_iz_trake(zapisnici)
provjeri(traka("Boško Babić") == 3, "traka strijelaca daje Babiću tri")

lista, otkud = odaberi_rang_listu(nasi, hns, ("golovi",),
                                  potvrdjeno_zapisnikom(zapisnici, bez_postava))
provjeri(lista is nasi, "na stranicu ide lista iz zapisnika")
provjeri("ne potvrđuju" in otkud and "Boško Babić" in otkud,
         "ispis kaže da HNS pokazuje više nego zapisnici")
lista, _ = odaberi_rang_listu(nasi, hns, ("golovi",))
provjeri(lista is hns, "bez potvrde zapisnikom kočnica radi kao prije")

print("\n12) Zapisnik koji fali NE smije se oprostiti")
# Stvarni slučaj od 24.09.2026.: zapisnik Klana - Funtana izbrisan je
# nepotpunom stranicom HNS-a, pa su nestale i postave i traka. Merezhko
# tada ima jedan gol i u postavama i u traci, a stvarno ih ima tri.
klana_funtana = utakmica(3, "NK Klana", "NK Funtana", "3:0", [], [])
rijecina_klana = utakmica(2, "NK Rječina", "NK Klana", "3:1",
                          [igrac("Netko Riječki", ("gol", "10'"))],
                          [igrac("Tymur Merezhko", ("gol", "70'"))])
rijecina_klana["strijelci"] = [strijelac("Netko Riječki", "10'"),
                               strijelac("Tymur Merezhko", "70'")]
zapisnici = [rijecina_klana, klana_funtana]
ucinci, bez_postava = ucinci_iz_zapisnika(zapisnici)
nasi, _ = slozi_pune_rang_liste(ucinci)
hns = [{"pozicija": "1", "igrac": "Tymur Merezhko", "klub": "NK Klana",
        "golovi": "3"}]
provjeri(potvrdjeno_zapisnikom(zapisnici, bez_postava) is None,
         "uz utakmicu bez postava potvrde nema")
lista, _ = odaberi_rang_listu(nasi, hns, ("golovi",),
                              potvrdjeno_zapisnikom(zapisnici, bez_postava))
provjeri(lista is hns, "kočnica ostaje i vraća HNS-ovu listu")

print("\n13) Traka i postave se ne slažu: kočnica ostaje")
# Traka ima gol koji u postavi nije upisan: ne zna se kome vjerovati.
nesklad = utakmica(1, "NK A", "NK B", "1:0",
                   [igrac("Ivo Ivić")], [igrac("Netko Drugi")])
nesklad["strijelci"] = [strijelac("Ivo Ivić", "20'")]
ucinci, bez_postava = ucinci_iz_zapisnika([nesklad])
nasi, _ = slozi_pune_rang_liste(ucinci)
hns = [{"pozicija": "1", "igrac": "Ivo Ivić", "klub": "NK A", "golovi": "1"}]
lista, _ = odaberi_rang_listu(nasi, hns, ("golovi",),
                              potvrdjeno_zapisnikom([nesklad], bez_postava))
provjeri(lista is hns, "manjak koji traka ne potvrđuje se ne oprašta")

print("\n14) Autogol se ne broji ni u traci")
ag = utakmica(1, "NK A", "NK B", "1:0", [igrac("Ivo Ivić")],
              [igrac("Pero Perić", ("autogol", "30'"))])
ag["strijelci"] = [strijelac("Pero Perić", "30'", autogol=True)]
provjeri(golovi_iz_trake([ag])("Pero Perić") == 0,
         "autogol u traci nije gol strijelca")

print()
if greske:
    print(f"PALO: {len(greske)}")
    for g in greske:
        print(f"  - {g}")
    sys.exit(1)
print("Sve provjere prošle.")

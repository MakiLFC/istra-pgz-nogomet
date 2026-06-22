"""
generiraj_clanak.py

Uzima jednu utakmicu iz utakmice_2znl_pgz.json i šalje je Claude API-ju
da napiše kratki novinski članak na hrvatskom jeziku.

KAKO POKRENUTI:
    python generiraj_clanak.py
"""

import json
import os
from dotenv import load_dotenv
import anthropic

# Učitava ANTHROPIC_API_KEY iz .env datoteke u ovoj istoj mapi
load_dotenv()

client = anthropic.Anthropic()  # automatski čita ANTHROPIC_API_KEY iz okoline

DATOTEKA_S_UTAKMICAMA = "utakmice_2znl_pgz.json"


def ucitaj_utakmice():
    with open(DATOTEKA_S_UTAKMICAMA, encoding="utf-8") as f:
        return json.load(f)


def napravi_prompt(utakmica):
    """
    Sastavlja upit za Claude na temelju podataka jedne utakmice.
    Eksplicitno tražimo kratki, činjenični članak - bez izmišljanja
    detalja koji nisu u podacima (npr. atmosfera, navijači, vrijeme).
    """
    strijelci_tekst = "Nema zabilježenih strijelaca." if not utakmica["strijelci"] else "\n".join(
        f"- {s['igrac']} ({s['minuta']})" for s in utakmica["strijelci"]
    )

    return f"""Napiši kratki novinski članak na hrvatskom jeziku o ovoj nogometnoj utakmici
iz lokalne županijske lige. Članak treba biti 80-120 riječi, novinarski ton,
bez fraza poput "U ovom članku" ili "Prema podacima". Ne izmišljaj detalje
koji nisu navedeni (npr. atmosferu na stadionu, vremenske uvjete, mišljenja
trenera) - drži se isključivo činjenica iz podataka. Ako nema strijelaca,
to spomeni kao zanimljivost (npr. "bezgolski remi" ako je rezultat 0:0,
ili samo navedi rezultat ako su podaci o strijelcima nepotpuni).

PODACI O UTAKMICI:
Domaćin: {utakmica['domacin']}
Gost: {utakmica['gost']}
Naslov sa stranice (sadrži rezultat): {utakmica['naslov']}
Stadion i datum: {utakmica['stadion_datum']}
Broj gledatelja: {utakmica['gledatelja']}
Suci: {utakmica['suci']}
Strijelci:
{strijelci_tekst}

Napiši samo sam članak, bez naslova, bez dodatnih napomena."""


def generiraj_clanak(utakmica):
    prompt = napravi_prompt(utakmica)

    poruka = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=400,
        messages=[
            {"role": "user", "content": prompt}
        ]
    )

    return poruka.content[0].text


if __name__ == "__main__":
    utakmice = ucitaj_utakmice()
    print(f"Učitano {len(utakmice)} utakmica iz datoteke.\n")

    # Test - generiramo članak SAMO za prvu utakmicu
    prva_utakmica = utakmice[0]
    print(f"Generiram članak za: {prva_utakmica['domacin']} - {prva_utakmica['gost']}")
    print("(ovo šalje upit Claude API-ju, treba par sekundi...)\n")

    clanak = generiraj_clanak(prva_utakmica)

    print("=" * 60)
    print(clanak)
    print("=" * 60)

"""Ispis podataka za najavu ili pregled kola, IZ BAZE. Pokreće ga posao
"Podaci za kolo".

ČEMU SLUŽI

Do 12.11.2026. su se ti podaci vadili poslom "Ispis kola", koji je
pokretao scraper u suhom testu, dakle dohvaćao ih je sa Semafora. HNS je
12.11.2026. automatsko preuzimanje zabranio (vidi pravilo 7 u CLAUDE.md),
pa taj put više ne postoji.

Zamjena je ovaj alat. On ne dira Semafor nego zove funkcije koje u
Supabaseu već postoje i koje su cijelo vrijeme bile pravi izvor za
članke:

    public.najava_kola(sezona, liga, kolo)
    public.pregled_kola(sezona, liga, kolo)

Kad se kolo ne zada, najava uzima prvo neodigrano, a pregled zadnje koje
ima odigranih utakmica. To je ponašanje samih funkcija i ovdje se ne
pogađa.

ŠTO ISPISUJE

Cijeli JSON koji funkcija vrati, uljepšan. To je isto ono što se dobije
u SQL Editoru naredbom

    select jsonb_pretty(public.najava_kola('2026/27', '3. NL Zapad'));

samo što ne traži laptop ni Supabase, pa radi i s mobitela.

VAŽNO: ako funkcija u bazi nije pokrenuta nakon zadnje izmjene datoteke
u sql/, ispis će izgledati vjerodostojno, a zaostajati. To je stara
zamka iz CLAUDE.md i ovaj alat je ne može uhvatiti.
"""

import json
import os
import sys

import requests

SEZONA_ZADANA = "2026/27"

DOPUSTENE = ("najava", "pregled")


def zovi_funkciju(ime, parametri):
    """Poziv RPC funkcije u Supabaseu.

    Storage i REST traže OBA zaglavlja s ključem, apikey i Authorization.
    Bez prvog odgovaraju s 403 i porukom koja zvuči kao da ključ ne
    valja, a zapravo fali zaglavlje (vidi CLAUDE.md).
    """
    adresa = os.environ.get("SUPABASE_URL", "").rstrip("/")
    kljuc = os.environ.get("SUPABASE_SERVICE_KEY", "")

    if not adresa or not kljuc:
        print("Nedostaje SUPABASE_URL ili SUPABASE_SERVICE_KEY.")
        print("Postavljaju se u Settings, Secrets and variables, Actions.")
        sys.exit(1)

    odgovor = requests.post(
        f"{adresa}/rest/v1/rpc/{ime}",
        headers={
            "apikey": kljuc,
            "Authorization": f"Bearer {kljuc}",
            "Content-Type": "application/json",
        },
        json=parametri,
        timeout=60,
    )

    if odgovor.status_code != 200:
        print(f"Baza je odbila poziv {ime}: {odgovor.status_code}")
        print(odgovor.text[:800])
        # Najčešći uzrok: funkcija u bazi ne postoji ili ima druge
        # parametre, jer datoteka iz sql/ nije pokrenuta.
        sys.exit(1)

    return odgovor.json()


def main():
    vrsta = (os.environ.get("VRSTA") or "najava").strip().lower()
    liga = (os.environ.get("LIGA") or "").strip()
    kolo = (os.environ.get("KOLO") or "").strip()
    sezona = (os.environ.get("SEZONA") or "").strip() or SEZONA_ZADANA

    if vrsta not in DOPUSTENE:
        print(f"Vrsta mora biti 'najava' ili 'pregled', a stiglo je: {vrsta}")
        sys.exit(1)

    if not liga:
        print("Nije zadana liga. Upiši je točno kako stoji u bazi, npr.")
        print("  3. NL Zapad / 4. NL NS Rijeka / 1. ŽNL PGŽ / 2. ŽNL PGŽ")
        sys.exit(1)

    parametri = {"p_sezona": sezona, "p_liga": liga}
    if kolo:
        try:
            parametri["p_kolo"] = int(kolo)
        except ValueError:
            print(f"Kolo mora biti broj, a stiglo je: {kolo}")
            sys.exit(1)

    ime = "najava_kola" if vrsta == "najava" else "pregled_kola"

    print("=" * 60)
    print(f"{vrsta.upper()}: {liga}, sezona {sezona}, kolo {kolo or '(samo odredi)'}")
    print("=" * 60)
    print()

    podaci = zovi_funkciju(ime, parametri)

    if podaci is None:
        print("Funkcija nije vratila ništa. Provjeri naziv lige i sezonu.")
        sys.exit(1)

    print(json.dumps(podaci, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()

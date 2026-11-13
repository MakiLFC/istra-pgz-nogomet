"""Preimenovanje igrača u cijeloj bazi, bez SQL Editora.

ČEMU SLUŽI
Igrač se u bazi prepoznaje PO IMENU: iz imena se računa adresa njegove
stranice, i po imenu se spajaju njegovi nastupi, golovi i kartoni. Zato
dva zapisa istog imena znače dvije stranice i podijeljene brojke.

Otkad zapisnike prepisuje čovjek (pravilo 7 u CLAUDE.md), razlaz imena
je pitanje vremena. Prvi je nađen 13.11.2026. u probi: na Semaforu piše
"Jakob Šprem Veljavečki", a u bazi je stajalo "Jakob Šprem-Veljavečki".

ŠTO DIRA
  utakmice.postava_domacin, postava_gost, strijelci
  statistike.podaci, za sve tipove (tablica nema igrače, pa se preskoči)

Traži se TOČNO ime, nikad dio imena, da se "Luka Hodak" ne pretvori u
nešto drugo zbog "Marko Hodak".

KAKO SE POKREĆE
Actions -> "Preimenuj igrača" -> Run workflow, prvo s radnjom provjeri.
Ispis kaže u koliko je utakmica i rang-lista ime nađeno, i ništa ne mijenja.
"""

import argparse
import json
import os
import re
import sys
import unicodedata

import requests


STUPCI_IGRACA = ("postava_domacin", "postava_gost", "strijelci")


def slug_imena(ime):
    """Isto što radi slugKluba u lib/slug.ts, jer iz imena nastaje adresa.

    Važno: i razmak i spojnica daju istu crticu, pa se "Šprem-Veljavečki"
    i "Šprem Veljavečki" svode na isti slug. Zato se ne smije napamet
    tvrditi da preimenovanje mijenja adresu stranice.
    """
    s = (ime or "").replace("đ", "d").replace("Đ", "D")
    s = unicodedata.normalize("NFD", s)
    s = "".join(z for z in s if not unicodedata.combining(z))
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")


def zamijeni_u_popisu(popis, staro, novo):
    """Vraća (novi_popis, koliko_je_zamijenjeno). Traži TOČNO ime."""
    if not isinstance(popis, list):
        return popis, 0

    zamijenjeno = 0
    novi = []
    for stavka in popis:
        if isinstance(stavka, dict) and stavka.get("igrac") == staro:
            stavka = {**stavka, "igrac": novo}
            zamijenjeno += 1
        novi.append(stavka)
    return novi, zamijenjeno


def promjene_u_utakmici(redak, staro, novo):
    """Samo stupci u kojima se ime doista pojavljuje."""
    promjene = {}
    ukupno = 0
    for stupac in STUPCI_IGRACA:
        novi, koliko = zamijeni_u_popisu(redak.get(stupac), staro, novo)
        if koliko:
            promjene[stupac] = novi
            ukupno += koliko
    return promjene, ukupno


def opis_utakmice(redak):
    return (f"{redak.get('sezona')} {redak.get('natjecanje')} "
            f"{redak.get('kolo')}. kolo: {redak.get('domacin')} - {redak.get('gost')}")


class Baza:
    def __init__(self, adresa, kljuc):
        self.korijen = f"{adresa.rstrip('/')}/rest/v1"
        # Supabase traži OBA zaglavlja s ključem (vidi CLAUDE.md).
        self.zaglavlja = {
            "apikey": kljuc,
            "Authorization": f"Bearer {kljuc}",
            "Content-Type": "application/json",
            "Prefer": "return=minimal",
        }

    def _get(self, tablica, params):
        o = requests.get(f"{self.korijen}/{tablica}", headers=self.zaglavlja,
                         timeout=60, params=params)
        if o.status_code >= 400:
            raise SystemExit(f"Dohvat ({tablica}) nije uspio "
                             f"({o.status_code}): {o.text[:300]}")
        return o.json()

    def utakmice_s_imenom(self, ime):
        """Filtrira se U BAZI, preko jsonb sadržavanja, da se ne vuku sve
        postave lige. Isti postupak koristi i stranica igrača."""
        uvjet = json.dumps([{"igrac": ime}], ensure_ascii=False)
        nadjene = {}
        for stupac in STUPCI_IGRACA:
            for redak in self._get("utakmice", {
                stupac: f"cs.{uvjet}",
                "select": "id,natjecanje,sezona,kolo,domacin,gost,"
                          "postava_domacin,postava_gost,strijelci",
            }):
                nadjene[redak["id"]] = redak
        return [nadjene[k] for k in sorted(nadjene)]

    def statistike_s_imenom(self, ime):
        uvjet = json.dumps([{"igrac": ime}], ensure_ascii=False)
        return self._get("statistike", {
            "podaci": f"cs.{uvjet}",
            "select": "sezona,natjecanje,tip,podaci",
        })

    def promijeni_utakmicu(self, id_utakmice, podaci):
        o = requests.patch(f"{self.korijen}/utakmice", headers=self.zaglavlja,
                           timeout=60, params={"id": f"eq.{id_utakmice}"},
                           json=podaci)
        if o.status_code >= 400:
            raise SystemExit(f"Upis u utakmicu {id_utakmice} nije uspio "
                             f"({o.status_code}): {o.text[:300]}")

    def promijeni_statistiku(self, redak, podaci):
        o = requests.patch(f"{self.korijen}/statistike", headers=self.zaglavlja,
                           timeout=60,
                           params={"sezona": f"eq.{redak['sezona']}",
                                   "natjecanje": f"eq.{redak['natjecanje']}",
                                   "tip": f"eq.{redak['tip']}"},
                           json={"podaci": podaci})
        if o.status_code >= 400:
            raise SystemExit(f"Upis u statistike ({redak['tip']}) nije uspio "
                             f"({o.status_code}): {o.text[:300]}")


def main():
    p = argparse.ArgumentParser(description="Preimenovanje igrača u bazi")
    p.add_argument("--staro", required=True, help="ime kakvo je sada u bazi")
    p.add_argument("--novo", required=True, help="ispravno ime")
    p.add_argument("--radnja", choices=("provjeri", "upis"), default="provjeri")
    a = p.parse_args()

    staro, novo = a.staro.strip(), a.novo.strip()
    if not staro or not novo:
        raise SystemExit("Ime ne smije biti prazno.")
    if staro == novo:
        raise SystemExit("Staro i novo ime su jednaki, nema se što mijenjati.")

    adresa = os.environ.get("SUPABASE_URL")
    kljuc = os.environ.get("SUPABASE_SERVICE_KEY")
    if not adresa or not kljuc:
        raise SystemExit("Nedostaju SUPABASE_URL i SUPABASE_SERVICE_KEY.")

    baza = Baza(adresa, kljuc)

    print(f'"{staro}"  ->  "{novo}"')
    print()

    utakmice = baza.utakmice_s_imenom(staro)
    print(f"UTAKMICE: {len(utakmice)}")
    posao_utakmice = []
    for redak in utakmice:
        promjene, koliko = promjene_u_utakmici(redak, staro, novo)
        if not promjene:
            continue
        posao_utakmice.append((redak, promjene))
        print(f"  {opis_utakmice(redak)}  "
              f"({koliko} u {', '.join(sorted(promjene))})")

    statistike = baza.statistike_s_imenom(staro)
    print()
    print(f"RANG-LISTE: {len(statistike)}")
    posao_statistike = []
    for redak in statistike:
        novi, koliko = zamijeni_u_popisu(redak.get("podaci"), staro, novo)
        if not koliko:
            continue
        posao_statistike.append((redak, novi))
        print(f"  {redak['sezona']} {redak['natjecanje']} {redak['tip']}: "
              f"{koliko} zapis(a)")

    if not posao_utakmice and not posao_statistike:
        print()
        print("Ime nije nađeno nigdje. Provjeri piše li se točno tako u bazi.")
        return

    # Novo ime koje VEĆ postoji nije greška (upravo se spajaju dva zapisa),
    # ali mora se reći naglas, jer je to trenutak kad se dvije stranice
    # igrača spajaju u jednu.
    vec_postoji = baza.statistike_s_imenom(novo)
    if vec_postoji:
        print()
        print(f'NAPOMENA: "{novo}" već postoji u {len(vec_postoji)} rang-listi. '
              "Nakon upisa će se dva zapisa spojiti u jedan.")

    if a.radnja != "upis":
        print()
        print("Suhi prolaz, ništa nije promijenjeno. Za upis odaberi radnju 'upis'.")
        return

    for redak, promjene in posao_utakmice:
        baza.promijeni_utakmicu(redak["id"], promjene)
    for redak, novi in posao_statistike:
        baza.promijeni_statistiku(redak, novi)

    print()
    print(f"Upisano: {len(posao_utakmice)} utakmica, "
          f"{len(posao_statistike)} rang-lista.")

    stari_slug, novi_slug = slug_imena(staro), slug_imena(novo)
    if stari_slug == novi_slug:
        print(f"Adresa stranice igrača se NE mijenja (/igrac/{novi_slug}).")
    else:
        print(f"Adresa stranice se mijenja: /igrac/{stari_slug} "
              f"-> /igrac/{novi_slug}. Stara prestaje postojati.")


if __name__ == "__main__":
    sys.exit(main())

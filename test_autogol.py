#!/usr/bin/env python3
"""
Provjera prepoznavanja autogola.

POKRETANJE:
    python test_autogol.py

Ne dira bazu i ne ide na internet. Diže mali poslužitelj na 127.0.0.1
koji vraća isječak HTML-a prepisan iz STVARNOG zapisnika
Jadran-Poreč - Nehaj 1:3 (1. kolo 2026/27), dohvaćenog alatom
alati/zapisnik_html.py.

ZAŠTO POSTOJI
    HNS autogol označava klasom "own_goal" i ikonom s naslovom "Autogol".
    Ranije je provjera tražila TOČNO klasu "goal", pa je autogol ispadao
    iz popisa strijelaca, dok ga je postava bilježila kao običan gol, jer
    je "goal" podniz od "own_goal". Rezultat i strijelci se onda nisu
    slagali. Ovaj test čuva oba ponašanja.
"""

import http.server
import json
import os
import socketserver
import sys
import threading

os.environ.pop("SUPABASE_URL", None)
os.environ.pop("SUPABASE_SERVICE_KEY", None)

from scraper_supabase import (  # noqa: E402
    odredi_tip_dogadjaja,
    dohvati_detalje_utakmice,
    provjeri_zbroj_golova,
)

# Prepisano iz stvarnog zapisnika, vidi zaglavlje.
TRAKA_STRIJELACA = """<!doctype html><html><head><meta charset="utf-8"></head><body>
<div class="events events_main"><ul>
<li><div class="playerName">Dominik-Velin Mrvčić</div><div class="event goal">82'<div class="icon" title="Gol"></div></div></li>
<li><div class="event goal"><div class="icon" title="Gol"></div>10'</div><div class="playerName">Lucijan Tomac</div></li>
<li><div class="event own_goal"><div class="icon" title="Autogol"></div>16'</div><div class="playerName">Vedran Radman</div></li>
<li><div class="event goal"><div class="icon" title="Gol"></div>86'</div><div class="playerName">Ivan Vukelić</div></li>
</ul></div></body></html>"""

BROJ_PALIH = 0


def provjeri(opis, uvjet):
    global BROJ_PALIH
    if uvjet:
        print(f"  OK    {opis}")
    else:
        BROJ_PALIH += 1
        print(f"  PALO  {opis}")


class Rukovatelj(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        tijelo = TRAKA_STRIJELACA.encode("utf-8")
        self.send_response(200)
        # Sa zaglavljem koje navodi kodiranje, kao što ga šalje i Semafor.
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(tijelo)))
        self.end_headers()
        self.wfile.write(tijelo)

    def log_message(self, *args):
        pass


def main():
    print("1. tip događaja iz klase i naslova ikone")
    # Sve kombinacije viđene u stvarnom zapisniku.
    provjeri("own_goal u postavi je autogol",
             odredi_tip_dogadjaja(["own_goal"], "Autogol") == "autogol")
    provjeri("event own_goal u traci je autogol",
             odredi_tip_dogadjaja(["event", "own_goal"], "Autogol") == "autogol")
    provjeri("obični gol ostaje gol",
             odredi_tip_dogadjaja(["goal"], "Gol") == "gol")
    provjeri("event goal ostaje gol",
             odredi_tip_dogadjaja(["event", "goal"], "Gol") == "gol")
    provjeri("žuti karton nepromijenjen",
             odredi_tip_dogadjaja(["yellow"], "Žuti karton") == "karton_zuti")
    provjeri("izmjena van nepromijenjena",
             odredi_tip_dogadjaja(["substitutionOut"], "Izmjena") == "izmjena_izlazak")
    provjeri("izmjena unutra nepromijenjena",
             odredi_tip_dogadjaja(["substitutionIn"], "Izmjena") == "izmjena_ulazak")
    # Autogol se mora provjeriti PRIJE gola, jer je "goal" podniz "own_goal".
    provjeri("sam naslov Autogol dovoljan je i bez klase",
             odredi_tip_dogadjaja([], "Autogol") == "autogol")

    print("\n2. traka strijelaca")
    posluzitelj = socketserver.TCPServer(("127.0.0.1", 0), Rukovatelj)
    dretva = threading.Thread(target=posluzitelj.serve_forever, daemon=True)
    dretva.start()
    vrata = posluzitelj.server_address[1]
    try:
        detalji = dohvati_detalje_utakmice(f"http://127.0.0.1:{vrata}/zapisnik.html")
    finally:
        posluzitelj.shutdown()

    strijelci = detalji.get("strijelci") or []
    provjeri("sva četiri pogotka su u popisu, i autogol",
             len(strijelci) == 4)
    po_imenu = {s["igrac"]: s for s in strijelci}
    provjeri("Radman je u popisu", "Vedran Radman" in po_imenu)
    provjeri("Radman je označen kao autogol",
             po_imenu.get("Vedran Radman", {}).get("autogol") is True)
    provjeri("Radmanova minuta je 16'",
             po_imenu.get("Vedran Radman", {}).get("minuta") == "16'")
    provjeri("obični golovi nemaju oznaku autogola",
             all("autogol" not in po_imenu[i] for i in po_imenu if i != "Vedran Radman"))
    provjeri("hrvatska slova su čitljiva",
             "Dominik-Velin Mrvčić" in po_imenu)

    print("\n3. zbroj golova po stranama")
    postava_d = [{"igrac": "Vedran Radman"}, {"igrac": "Dominik-Velin Mrvčić"}]
    postava_g = [{"igrac": "Lucijan Tomac"}, {"igrac": "Ivan Vukelić"}]
    redak = {
        "rezultat": "1:3",
        "strijelci": strijelci,
        "postava_domacin": postava_d,
        "postava_gost": postava_g,
    }
    provjeri("s prepoznatim autogolom zbroj se slaže s 1:3",
             provjeri_zbroj_golova(redak) is None)

    # Isti podaci, ali bez oznake autogola: mora se javiti neslaganje.
    bez_oznake = [{k: v for k, v in s.items() if k != "autogol"} for s in strijelci]
    provjeri("bez oznake autogola javlja se neslaganje",
             provjeri_zbroj_golova({**redak, "strijelci": bez_oznake}) is not None)

    # Ručni popis iz stupca autogolovi mora dati isti ishod kao oznaka.
    provjeri("ručni popis autogolova rješava isto neslaganje",
             provjeri_zbroj_golova({
                 **redak,
                 "strijelci": bez_oznake,
                 "autogolovi": [{"igrac": "Vedran Radman", "minuta": "16'"}],
             }) is None)

    # Autogol gostujućeg igrača mora se brojati domaćinu.
    provjeri("autogol gosta broji se domaćinu",
             provjeri_zbroj_golova({
                 "rezultat": "1:0",
                 "strijelci": [{"igrac": "Lucijan Tomac", "minuta": "5'", "autogol": True}],
                 "postava_domacin": postava_d,
                 "postava_gost": postava_g,
             }) is None)

    print()
    if BROJ_PALIH:
        print(f"PALO: {BROJ_PALIH}")
        sys.exit(1)
    print("PROLAZI: autogol se prepoznaje i broji na pravu stranu.")


if __name__ == "__main__":
    main()

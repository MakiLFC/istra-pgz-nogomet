"""
test_dogadjaj_bez_minute.py

HNS zna upisati događaj BEZ MINUTE. Scraper je takav redak preskakao, pa
je događaj tiho nestajao.

Otkriveno 15.09.2026.: lista kartona složena iz zapisnika zaostajala je
za onom sa stranice natjecanja, svaki put za po jedan žuti. Alat
dijagnostika_kartoni.py je pokazao stvarni HTML i uzrok je bio ovakav
redak, bez ijedne brojke:

    <div class="matchEvents"><ul class="events">
      <li class="yellow"><div class="icon" title="Žuti karton"></div></li>
    </ul></div>

Tako su ispali žuti kartoni Bakira Delića (Rikard Benčić, 1. kolo 1. ŽNL)
i Admira Haznadara (Otočac, 2. kolo 4. NL). Kod Haznadara je uz karton u
istom bloku stajala i izmjena s minutom, pa se vidi da HNS oboje piše
jedno do drugoga, a minuta fali samo kartonu.

HTML u ovom testu prepisan je s tih zapisnika.

POKRETANJE:  python test_dogadjaj_bez_minute.py
Diže poslužitelj na 127.0.0.1, ne dira ni internet ni bazu.
"""

import http.server
import os
import socketserver
import sys
import threading

os.environ.pop("SUPABASE_URL", None)
os.environ.pop("SUPABASE_SERVICE_KEY", None)

from scraper_supabase import (  # noqa: E402
    dohvati_detalje_utakmice,
    provjeri_zbroj_golova,
    ucinci_iz_zapisnika,
)

# Zapisnik s tri stvari koje se testiraju:
#   - žuti karton bez minute (Delićev slučaj)
#   - izmjena s minutom i žuti bez nje u istom bloku (Haznadarov slučaj)
#   - gol koji u traci strijelaca ima minutu, a u postavi je bez nje
ZAPISNIK = """<!doctype html><html><head><meta charset="utf-8">
<title>NK Prvi - NK Drugi 1:0</title></head><body>
<div class="events events_main"><ul>
<li><div class="event goal"><div class="icon" title="Gol"></div>23'</div>
    <div class="playerName">Ivan Prvi</div></li>
</ul></div>

<ul>
<li>NK Prvi</li>
<li class="row match_lineup"><div><div class="shirtNumber">9</div>
  <div class="playerName"><h3><a href="/igraci/1/ivan-prvi/">Ivan Prvi</a></h3>Igrač</div>
  <div class="matchEvents"><ul class="events">
    <li class="goal"><div class="icon" title="Gol"></div></li>
  </ul></div></div></li>
<li class="row match_lineup"><div><div class="shirtNumber">5</div>
  <div class="playerName"><h3><a href="/igraci/2/bakir-delic/">Bakir Delić</a></h3>Igrač</div>
  <div class="matchEvents"><ul class="events">
    <li class="yellow"><div class="icon" title="Žuti karton"></div></li>
  </ul></div></div></li>
<li class="row match_lineup"><div><div class="shirtNumber">7</div>
  <div class="playerName"><h3><a href="/igraci/3/admir-haznadar/">Admir Haznadar</a></h3>Igrač</div>
  <div class="matchEvents"><ul class="events">
    <li class="substitutionOut"><div class="icon" title="Izmjena"></div>46'</li>
    <li class="yellow"><div class="icon" title="Žuti karton"></div></li>
  </ul></div></div></li>
<li>NK Drugi</li>
<li class="row match_lineup"><div><div class="shirtNumber">1</div>
  <div class="playerName"><h3><a href="/igraci/4/marko-drugi/">Marko Drugi</a></h3>Vratar</div>
  <div class="matchEvents"><ul class="events">
    <li class="yellow"><div class="icon" title="Žuti karton"></div>77'</li>
  </ul></div></div></li>
</ul>
</body></html>"""

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
        tijelo = ZAPISNIK.encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(tijelo)))
        self.end_headers()
        self.wfile.write(tijelo)

    def log_message(self, *args):
        pass


def dogadjaji(postava, ime):
    for igrac in postava:
        if igrac["igrac"] == ime:
            return igrac["dogadjaji"]
    return None


def main():
    posluzitelj = socketserver.TCPServer(("127.0.0.1", 0), Rukovatelj)
    dretva = threading.Thread(target=posluzitelj.serve_forever, daemon=True)
    dretva.start()
    vrata = posluzitelj.server_address[1]
    try:
        detalji = dohvati_detalje_utakmice(f"http://127.0.0.1:{vrata}/zapisnik.html")
    finally:
        posluzitelj.shutdown()

    doma = detalji.get("postava_domacin") or []
    vani = detalji.get("postava_gost") or []
    strijelci = detalji.get("strijelci") or []

    print("1. karton bez minute ostaje u postavi")
    delic = dogadjaji(doma, "Bakir Delić")
    provjeri("Delić ima točno jedan događaj", delic is not None and len(delic) == 1)
    provjeri("i to žuti karton",
             bool(delic) and delic[0]["tip"] == "karton_zuti")
    provjeri("s praznom minutom, ne izmišljenom",
             bool(delic) and delic[0]["minuta"] == "")

    print("\n2. karton bez minute uz izmjenu s minutom")
    haznadar = dogadjaji(doma, "Admir Haznadar")
    tipovi = [d["tip"] for d in haznadar or []]
    provjeri("oba događaja su tu", tipovi == ["izmjena_izlazak", "karton_zuti"])
    provjeri("izmjena je zadržala svoju minutu",
             bool(haznadar) and haznadar[0]["minuta"] == "46'")
    provjeri("karton je bez minute",
             bool(haznadar) and haznadar[1]["minuta"] == "")

    print("\n3. karton s minutom se nije pokvario")
    drugi = dogadjaji(vani, "Marko Drugi")
    provjeri("žuti u 77. minuti je nepromijenjen",
             bool(drugi) and drugi[0]["tip"] == "karton_zuti"
             and drugi[0]["minuta"] == "77'")

    print("\n4. gol bez minute u postavi ne udvostručuje strijelca")
    # U traci je pogodak s minutom 23', u postavi isti gol bez minute.
    # Usporedba po minuti tu ne pomaže, pa se gleda broj pogodaka igrača.
    provjeri("strijelac je upisan samo jednom", len(strijelci) == 1)
    provjeri("i to s minutom iz trake",
             bool(strijelci) and strijelci[0]["minuta"] == "23'")
    provjeri("zbroj golova slaže se s rezultatom 1:0",
             provjeri_zbroj_golova({
                 "rezultat": "1:0",
                 "strijelci": strijelci,
                 "postava_domacin": doma,
                 "postava_gost": vani,
             }) is None)

    print("\n5. kartoni bez minute ulaze u rang-listu iz zapisnika")
    ucinci, bez_postava = ucinci_iz_zapisnika([{
        "kolo": 1, "domacin": "NK Prvi", "gost": "NK Drugi",
        "rezultat": "1:0",
        "postava_domacin": doma, "postava_gost": vani,
    }])
    po_imenu = {u["igrac"]: u for u in ucinci}
    provjeri("Delić ima žuti karton",
             po_imenu.get("Bakir Delić", {}).get("zuti") == 1)
    provjeri("Haznadar ima žuti karton",
             po_imenu.get("Admir Haznadar", {}).get("zuti") == 1)
    provjeri("Marko Drugi ima žuti karton",
             po_imenu.get("Marko Drugi", {}).get("zuti") == 1)
    provjeri("Ivan Prvi ima gol",
             po_imenu.get("Ivan Prvi", {}).get("golovi") == 1)
    provjeri("nijedna utakmica ne fali", bez_postava == [])

    print()
    if BROJ_PALIH:
        print(f"PALO: {BROJ_PALIH}")
        sys.exit(1)
    print("PROLAZI: događaj bez minute se više ne gubi.")


if __name__ == "__main__":
    main()

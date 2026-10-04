"""
test_clanak_u_bazu.py

Provjerava alat koji članak iz mape "clanci" upisuje u bazu
(alati/clanak_u_bazu.py): čitanje datoteke, odbijanje crtica i krivog
sluga, te da novi članak ulazi neobjavljen, a postojećem se ne dira
objavljenost.

Nista se ne dohvaca s interneta i nista ne pise u bazu: baza je ovdje
zamijenjena rječnikom u memoriji.

POKRETANJE:  python test_clanak_u_bazu.py
"""

import sys

sys.path.insert(0, "alati")

from clanak_u_bazu import (  # noqa: E402
    GreskaDatoteke,
    je_sazetak,
    obrisi_neobjavljen,
    postavi_objavu,
    procitaj,
    procitaj_sazetak,
    putanja_clanka,
    sazetak_u_bazu,
    upisi,
)

DATOTEKA = """slug: najava-proba
naslov: NAJAVA 1. KOLA: PROBA
sazetak: Kratki sažetak.
natjecanje: 3. NL Zapad
slika_url: /slike/najave/proba.png
---
Prvi odlomak, Rab - Krk.

Drugi odlomak.
"""


class LaznaBaza:
    """Ponaša se kao Baza iz alata, ali drži retke u rječniku."""

    def __init__(self, redci=None):
        self.redci = dict(redci or {})

    def dohvati(self, slug):
        return self.redci.get(slug)

    def dodaj(self, podaci):
        self.redci[podaci["slug"]] = dict(podaci)
        return self.redci[podaci["slug"]]

    def promijeni(self, slug, podaci):
        if slug not in self.redci:
            return None
        self.redci[slug].update(podaci)
        return self.redci[slug]

    def obrisi(self, slug):
        self.redci.pop(slug, None)


def _ocekuj_gresku(sadrzaj, slug, dio_poruke):
    try:
        procitaj(sadrzaj, slug)
    except GreskaDatoteke as e:
        assert dio_poruke in str(e), f"poruka '{e}' ne spominje '{dio_poruke}'"
        return
    raise AssertionError(f"očekivala se greška: {dio_poruke}")


def test_ispravna_datoteka():
    r = procitaj(DATOTEKA, "najava-proba")
    assert r["slug"] == "najava-proba"
    assert r["naslov"] == "NAJAVA 1. KOLA: PROBA"
    assert r["natjecanje"] == "3. NL Zapad"
    assert r["slika_url"] == "/slike/najave/proba.png"
    # Spojnica u paru klubova je dopuštena, a odlomci ostaju odvojeni.
    assert r["tekst"] == "Prvi odlomak, Rab - Krk.\n\nDrugi odlomak."
    assert "slika_opis" not in r
    print("✓ ispravna datoteka se pročita")


def test_bez_lige():
    r = procitaj(DATOTEKA.replace("natjecanje: 3. NL Zapad", "natjecanje: nema"),
                 "najava-proba")
    assert r["natjecanje"] is None
    print("✓ 'nema' znači članak bez lige")


def test_crtice_se_odbijaju():
    _ocekuj_gresku(DATOTEKA.replace("Drugi odlomak.", "Drugi — odlomak."),
                   "najava-proba", "duga crta")
    _ocekuj_gresku(DATOTEKA.replace("PROBA", "PRO–BA"),
                   "najava-proba", "srednja crta")
    print("✓ duga i srednja crta se odbijaju")


def test_slug_mora_odgovarati_imenu():
    _ocekuj_gresku(DATOTEKA, "pregled-proba", "nije isti kao ime datoteke")
    print("✓ slug mora biti jednak imenu datoteke")


def test_nepoznato_polje():
    _ocekuj_gresku(DATOTEKA.replace("sazetak:", "sažetak:"), "najava-proba",
                   "nepoznato polje")
    print("✓ krivo napisano polje se javi")


def test_bez_teksta_i_bez_crte():
    _ocekuj_gresku(DATOTEKA.split("---")[0] + "---\n", "najava-proba", "nema teksta")
    _ocekuj_gresku(DATOTEKA.replace("---", ""), "najava-proba", "nema crte")
    print("✓ članak bez teksta ili bez crte se ne upisuje")


def test_putanja_iz_bilo_cega():
    for zadano in ("najava-proba", "najava-proba.txt", "clanci/najava-proba.txt"):
        assert putanja_clanka(zadano).name == "najava-proba.txt"
    print("✓ prima slug, ime datoteke i putanju")


def test_novi_ulazi_neobjavljen():
    baza = LaznaBaza()
    upisi(baza, procitaj(DATOTEKA, "najava-proba"))
    assert baza.redci["najava-proba"]["objavljen"] is False
    assert baza.redci["najava-proba"]["objavljeno_u"]
    print("✓ novi članak ulazi neobjavljen")


def test_ispravak_ne_dira_objavu():
    baza = LaznaBaza({"najava-proba": {"slug": "najava-proba", "naslov": "staro",
                                        "objavljen": True, "objavljeno_u": "2026-10-01"}})
    upisi(baza, procitaj(DATOTEKA, "najava-proba"))
    r = baza.redci["najava-proba"]
    assert r["naslov"] == "NAJAVA 1. KOLA: PROBA"
    assert r["objavljen"] is True and r["objavljeno_u"] == "2026-10-01"
    print("✓ ispravak objavljenog članka ga ne skida i ne mijenja datum")


def test_objava_nepostojeceg():
    try:
        postavi_objavu(LaznaBaza(), "najava-proba", True)
    except SystemExit as e:
        assert "nema u bazi" in str(e)
        print("✓ objava članka kojeg nema javi grešku")
        return
    raise AssertionError("očekivala se greška")


def test_objavljeni_se_ne_brise():
    baza = LaznaBaza({"najava-proba": {"slug": "najava-proba", "objavljen": True}})
    try:
        obrisi_neobjavljen(baza, "najava-proba")
    except SystemExit:
        assert "najava-proba" in baza.redci
        baza.redci["najava-proba"]["objavljen"] = False
        obrisi_neobjavljen(baza, "najava-proba")
        assert "najava-proba" not in baza.redci
        print("✓ objavljeni članak se ne briše, neobjavljeni se briše")
        return
    raise AssertionError("objavljeni članak je obrisan")


SAZETAK = """natjecanje: 1. ŽNL PGŽ
sezona: 2026/27
kolo: 5
domacin: NK Mune
gost: HNK Lovran
derbi: da
---
Mune su prve zaustavile Lovran.
"""


class LazneUtakmice:
    """Tablica utakmice u memoriji, s jednim retkom."""

    def __init__(self):
        self.redak = {"natjecanje": "1. ŽNL PGŽ", "sezona": "2026/27", "kolo": 5,
                      "domacin": "NK Mune", "gost": "HNK Lovran", "rezultat": "3:1",
                      "derbi": False, "tekst_clanka": None}

    def _odgovara(self, kljuc):
        return all(self.redak[k] == v for k, v in kljuc.items())

    def dohvati(self, kljuc):
        return [dict(self.redak)] if self._odgovara(kljuc) else []

    def promijeni(self, kljuc, podaci):
        if not self._odgovara(kljuc):
            return []
        self.redak.update(podaci)
        return [dict(self.redak)]


def test_sazetak_se_prepozna_i_procita():
    assert je_sazetak(SAZETAK) and not je_sazetak(DATOTEKA)
    kljuc, stupci = procitaj_sazetak(SAZETAK)
    assert kljuc == {"natjecanje": "1. ŽNL PGŽ", "sezona": "2026/27", "kolo": 5,
                     "domacin": "NK Mune", "gost": "HNK Lovran"}
    assert stupci == {"tekst_clanka": "Mune su prve zaustavile Lovran.", "derbi": True}
    bez_derbija = procitaj_sazetak(SAZETAK.replace("derbi: da\n", ""))[1]
    assert "derbi" not in bez_derbija
    print("✓ sažetak se prepozna po domaćinu i pročita")


def test_sazetak_pogreske():
    for kvar, poruka in ((SAZETAK.replace("kolo: 5", "kolo: peto"), "kolo mora biti broj"),
                         (SAZETAK.replace("derbi: da", "derbi: možda"), "derbi može biti"),
                         (SAZETAK.replace("gost: HNK Lovran\n", ""), "fali polje: gost"),
                         (SAZETAK.replace("prve", "prve \u2014"), "duga crta")):
        try:
            procitaj_sazetak(kvar)
        except GreskaDatoteke as e:
            assert poruka in str(e), e
            continue
        raise AssertionError(f"očekivala se greška: {poruka}")
    print("✓ krivi sažetak se ne upisuje")


def test_sazetak_upis_i_skidanje():
    tablica = LazneUtakmice()
    kljuc, stupci = procitaj_sazetak(SAZETAK)
    sazetak_u_bazu(tablica, "upis", kljuc, stupci)
    assert tablica.redak["tekst_clanka"] == "Mune su prve zaustavile Lovran."
    assert tablica.redak["derbi"] is True
    sazetak_u_bazu(tablica, "skini", kljuc, stupci)
    assert tablica.redak["tekst_clanka"] is None and tablica.redak["derbi"] is True
    print("✓ sažetak se upiše i makne, derbi ostaje")


def test_sazetak_kriva_utakmica():
    kljuc, stupci = procitaj_sazetak(SAZETAK.replace("HNK Lovran", "NK Lovran"))
    try:
        sazetak_u_bazu(LazneUtakmice(), "upis", kljuc, stupci)
    except SystemExit as e:
        assert "nije pronađena" in str(e)
        print("✓ utakmica s krivim imenom kluba javi grešku")
        return
    raise AssertionError("očekivala se greška")


if __name__ == "__main__":
    test_ispravna_datoteka()
    test_bez_lige()
    test_crtice_se_odbijaju()
    test_slug_mora_odgovarati_imenu()
    test_nepoznato_polje()
    test_bez_teksta_i_bez_crte()
    test_putanja_iz_bilo_cega()
    test_novi_ulazi_neobjavljen()
    test_ispravak_ne_dira_objavu()
    test_objava_nepostojeceg()
    test_objavljeni_se_ne_brise()
    test_sazetak_se_prepozna_i_procita()
    test_sazetak_pogreske()
    test_sazetak_upis_i_skidanje()
    test_sazetak_kriva_utakmica()
    print("\nSVE PROLAZI")

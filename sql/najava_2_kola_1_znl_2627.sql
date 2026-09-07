-- =====================================================================
-- NAJAVA: 2. kolo 1. ŽNL PGŽ 2026/27
-- subota 12. i nedjelja 13.09.2026. u 16:30
-- =====================================================================
-- KAKO SE KORISTI: pokreni po redu dva koraka na dnu datoteke.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Prvi korak (upis) je odmah ispod, clanak ulazi s objavljen = false,
--   dakle NIJE vidljiv na stranici. Objavljuje se KORAKOM 2, kad dodje
--   vrijeme.
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- ODAKLE STO
--   Termini, stadioni, bodovi, mjesta na ljestvici, forma, vodeci
--   strijelci i medjusobni susreti dolaze iz
--   public.najava_kola('2026/27','1. ŽNL PGŽ',2), dakle iz baze.
--   Nista nije dodano izvan toga: nema ocjena forme, izjava ni
--   ocekivanja.
--   Omladinac Vrata i Vrbovsko svoju utakmicu 1. kola igraju u
--   srijedu 09.09., pa u ovo kolo ulaze s odigranim susretom. To
--   je u tekstu receno, jer bi inace do objave zastarjelo.
--   Iskljucen Smolic (Mune) je iz pregleda 1. kola, ne iz najave.
--
-- AKO SE TERMIN PROMIJENI prije objave, dnevna "Provjera termina" to
-- javi na e-postu. Tada se tekst ispravi obicnim update-om nad
-- clanci.tekst, prije nego se clanak objavi.
--
-- BEZ FOTOGRAFIJE
--   Clanak nema sliku, pa se na kartici prikazuje zaglavlje lige, a pri
--   dijeljenju zajednicka slika Lokal-Arene. Fotografija se moze dodati
--   i kasnije, poslom "Fotografija za clanak".
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS NAJAVE (jos nije objavljena)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-2-kola-1-znl-pgz-2627',
  'VIDMAR I LOVRAN PRED DOMAĆOM PUBLIKOM',
  'Drugo kolo 1. ŽNL PGŽ igra se u subotu i nedjelju u 16:30, a vodeći Lovran s Patrikom Vidmarom dočekuje Rikard Benčić.',
'Drugo kolo 1. ŽNL PGŽ igra se u subotu 12. i nedjelju 13. rujna, sve utakmice u 16:30.

SUBOTA

Lovran - Rikard Benčić. Lovran je nakon 9:2 u Lokvama prvi na ljestvici, s gol razlikom plus sedam, a Patrik Vidmar je s pet pogodaka vodeći strijelac lige. Rikard Benčić ima bod nakon 2:2 s Munama. Prošle sezone 1:1 u Rijeci i 1:3 u Lovranu.

Rab - Turbina. Oba kluba imaju po tri boda nakon uvodnih pobjeda. Prošle sezone je Rab dobio oba susreta, 3:2 kod Turbine i 4:0 kod kuće.

Zamet - Omladinac Vrata. Zamet je bez bodova nakon 0:3 kod Turbine. Omladinac Vrata svoju utakmicu prvog kola igra u srijedu 9. rujna protiv Vrbovskog, pa u ovo kolo ulazi s odigranim susretom. Klubovi se u našoj bazi dosad nisu sastali.

NEDJELJA

Mune - Lošinj. Mune imaju bod, Lošinj tri nakon 2:0 protiv Drage. Domaći igraju bez Alena Smolića, isključenog u prvom kolu. Prošle sezone na Lošinju 5:1 za domaće, a u Munama 1:1.

Stari grad Rijeka - Risnjak. Domaći imaju bod, Risnjak je bez bodova i s gol razlikom minus sedam nakon 2:9 protiv Lovrana. Klubovi se u našoj bazi dosad nisu sastali.

Vihor (B) - Draga. Oba kluba su bez bodova nakon uvodnog poraza. Prošle sezone u Dragi 4:0 za domaće, a u Baški 4:1 za Vihor.

Vrbovsko - Goranin. Goranin ima bod nakon 0:0 protiv Starog grada. Vrbovsko do nedjelje igra i svoju utakmicu prvog kola, u srijedu protiv Omladinca Vrata. Prošle sezone 1:1 u Delnicama i 0:0 u Vrbovskom.

ZA OVO KOLO

Mune igraju bez Alena Smolića, isključenog u prvom kolu. Nitko nije na pragu žutih kartona.',
  '1. ŽNL PGŽ',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-2-kola-1-znl-pgz-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-2-kola-1-znl-pgz-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-2-kola-1-znl-pgz-2627';

-- =====================================================================
-- NAJAVA: 2. kolo 2. ŽNL PGŽ 2026/27
-- nedjelja 13.09.2026. u 16:30
-- =====================================================================
-- KAKO SE KORISTI: pokreni po redu dva koraka na dnu datoteke.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Prvi korak (upis) je odmah ispod, clanak ulazi s objavljen = false,
--   dakle NIJE vidljiv na stranici. Objavljuje se KORAKOM 2, kad dodje
--   vrijeme.
--
--   Upis se smije pokrenuti i vise puta. Ako clanak s ovim slugom vec
--   postoji, naslov, sazetak i tekst se prepisu, a stanje objavljen se
--   ne dira.
--
-- ODAKLE STO
--   Termini, stadioni, bodovi, mjesta na ljestvici, forma, vodeci
--   strijelci i medjusobni susreti dolaze iz
--   public.najava_kola('2026/27','2. ŽNL PGŽ',2), dakle iz baze.
--   Nista nije dodano izvan toga: nema ocjena forme, izjava ni
--   ocekivanja.
--   Snjeznik i Mrkopalj jos nemaju odigranu utakmicu, jer im je
--   susret 1. kola odgodjen, pa im ljestvica ne pokazuje bodove.
--
-- AKO SE TERMIN PROMIJENI prije objave, dnevna "Provjera termina" to
-- javi na e-postu. Tada se tekst ispravi obicnim update-om nad
-- clanci.tekst, prije nego se clanak objavi.
--
-- PROVJERENO 11.09.2026.
--   Sva tri termina 2. kola i dalje stoje na nedjelju 13.09. u 16:30,
--   nijedan nije pomaknut. Snjeznik - Mrkopalj iz 1. kola i dalje je
--   bez rezultata, a HNS mu vise ne pokazuje ni termin, pa u bazi stoji
--   zadnji poznati. Tekst je zato ostao nepromijenjen.
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
  'najava-2-kola-2-znl-pgz-2627',
  'GOMIRJE BRANI VRH PROTIV ŽELJEZNIČARA',
  'Drugo kolo 2. ŽNL PGŽ igra se u nedjelju 13. rujna u 16:30, a Snježnik i Mrkopalj ulaze u sezonu nakon odgođenog susreta.',
'Drugo kolo 2. ŽNL PGŽ igra se u nedjelju 13. rujna, sve tri utakmice u 16:30.

Gomirje - Željezničar (M). Gomirje je nakon 2:0 protiv Poleta prvo na ljestvici, a Željezničar ima bod nakon 0:0 s Gorankom. Klubovi su se prošle sezone sastali triput: 3:3 u Moravicama, pa 1:1 i 0:3 u Gomirju.

Goranka - Snježnik. Goranka ima bod, a Snježnik ulazi u sezonu, jer je njegova utakmica prvog kola protiv Mrkoplja odgođena. Prošle sezone tri susreta, sva tri Gorankina: 4:3 i 6:0 kod kuće te 8:0 u Gerovu.

Polet (Sk) - Mrkopalj. Polet je bez bodova, a Mrkopalj također ulazi u sezonu nakon odgođene utakmice. Prošle sezone su se sastali triput: Polet je slavio 2:0 u Mrkoplju, a Mrkopalj 5:2 u Skradu i 3:1 kod kuće.

ZA OVO KOLO

Nema isključenih igrača ni igrača na pragu žutih kartona.

Ljestvica je zasad nepotpuna, jer Snježnik i Mrkopalj još nemaju odigranu utakmicu.',
  '2. ŽNL PGŽ',
  false,
  now()
)
on conflict (slug) do update
set naslov     = excluded.naslov,
    sazetak    = excluded.sazetak,
    tekst      = excluded.tekst,
    natjecanje = excluded.natjecanje
returning slug, naslov, objavljen;


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-2-kola-2-znl-pgz-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-2-kola-2-znl-pgz-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-2-kola-2-znl-pgz-2627';

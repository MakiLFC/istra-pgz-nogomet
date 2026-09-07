-- =====================================================================
-- NAJAVA: 2. kolo 4. NL NS Rijeka 2026/27
-- subota 12.09.2026. u 17:00
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
--   public.najava_kola('2026/27','4. NL NS Rijeka',2), dakle iz baze.
--   Nista nije dodano izvan toga: nema ocjena forme, izjava ni
--   ocekivanja.
--   Iskljuceni igraci NISU iz najave, nego iz pregleda 1. kola:
--   Peteh (Funtana), Hrmic i Snajdar (Klana), Filipovic (Stinjan).
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
  'najava-2-kola-4-nl-ns-rijeka-2627',
  'LIŽNJAN DOČEKUJE FAŽANU, OTOČAC ULAZI U SEZONU',
  'Drugo kolo 4. NL NS Rijeka igra se u subotu 12. rujna u 17 sati, a Otočac nakon slobodnog kola gostuje u Svetvinčentu.',
'Drugo kolo 4. NL NS Rijeka igra se u subotu 12. rujna, sve utakmice u 17 sati. Otočac ulazi u sezonu, nakon što je prvo kolo proveo slobodan.

Ližnjan - Mladost Fažana. Ližnjan je nakon 5:0 protiv Žminja prvi na ljestvici, s gol razlikom plus pet. Fažana ima tri boda nakon 2:1 protiv Funtane. Prošle sezone je Ližnjan dobio oba susreta, 4:1 kod kuće i 4:1 u Fažani.

Cres - Umag-CC Umago. Oba kluba imaju po tri boda i gol razliku plus dva. Željko Tomić ima dva pogotka za Cres. Prošle sezone u Umagu 1:1, a na Cresu 2:0 za domaće.

Funtana - Borac (Ba). Borac ima tri boda nakon 3:0 protiv Klane, Funtana je bez bodova. Mihael Šušnjar ima dva pogotka. Funtana igra bez Abela Peteha, isključenog u prvom kolu. Prošle sezone 4:0 za Borac kod kuće i 0:0 u Funtani.

Smoljanci Sloboda - Otočac. Otočac igra prvu utakmicu sezone, a Smoljanci imaju bod nakon 1:1 protiv Medulina. Prošle sezone u Otočcu 3:0 za domaće, a u Svetvinčentu 1:1.

Rječina - Klana. Oba kluba su bez bodova nakon uvodnog poraza. Klana igra bez Nike Hrmića i Ronija Šnajdara, obojice isključenih u Krasici. Klubovi se u našoj bazi dosad nisu sastali.

Štinjan - Medulin 1921. Štinjan je bez bodova, Medulin ima bod. Domaći igraju bez Marina Filipovića, isključenog protiv Umaga. Klubovi se u našoj bazi dosad nisu sastali.

ZA OVO KOLO

Zbog isključenja u prvom kolu ovo kolo propuštaju Abel Peteh (Funtana), Niko Hrmić i Roni Šnajdar (Klana) te Marin Filipović (Štinjan). Nitko nije na pragu žutih kartona.',
  '4. NL NS Rijeka',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-2-kola-4-nl-ns-rijeka-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-2-kola-4-nl-ns-rijeka-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-2-kola-4-nl-ns-rijeka-2627';

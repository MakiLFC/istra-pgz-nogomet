-- =====================================================================
-- NAJAVA: 2. kolo 4. NL NS Rijeka 2026/27
-- subota 12.09.2026., 17:00, 17:15 i 18:00
-- =====================================================================
-- KAKO SE KORISTI: pokreni po redu dva koraka na dnu datoteke.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Prvi korak (upis) je odmah ispod, clanak ulazi s objavljen = false,
--   dakle NIJE vidljiv na stranici. Objavljuje se KORAKOM 2, kad dodje
--   vrijeme.
--
--   Upis se smije pokrenuti i vise puta. Ako clanak s ovim slugom vec
--   postoji, naslov, sazetak i tekst se prepisu, a stanje objavljen se
--   ne dira. Tako ista datoteka radi i za prvi upis i za ispravak.
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
-- ANDREJEVE IZMJENE, 10.09.2026.
--   Naslov, dopunjen sazetak (istupanje NK Novalje iz lige), dojam o
--   Liznjanu kao favoritu, usporedba Cresa i Umaga, ocekivanja od
--   Otocca i Martin Bogdanic kao istaknuto pojacanje, te "derbi juzne
--   Istre" i "domaci crveni vragovi" uz Stinjan. Sve je Andrejevo,
--   nije iz baze.
--
-- ISPRAVLJENI TERMINI, 10.09.2026.
--   HNS je nakon pisanja najave pomaknuo dvije utakmice ovog kola:
--   Cres - Umag na 17:15 i Funtana - Borac na 18:00. Tekst to navodi.
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
  'SAMOUVJERENI LIŽNJAN DOČEKUJE MLADOST, OTOČAC NAPOKON ZAPOČINJE SEZONU',
  'Drugo kolo 4. NL NS Rijeka igra se u subotu 12. rujna, a Otočac, nakon propuštanja prvog kola zbog istupanja NK Novalje iz lige, napokon započinje svoju sezonu.',
'Drugo kolo 4. NL NS Rijeka igra se u subotu 12. rujna. Cres - Umag počinje u 17:15, Funtana - Borac u 18 sati, ostale utakmice u 17. Otočac ulazi u sezonu, nakon što je prvo kolo proveo slobodan.

Ližnjan - Mladost Fažana. Ližnjan je nakon 5:0 protiv Žminja prvi na ljestvici, a u toj su utakmici pogađala petorica različitih strijelaca. Fažana ima tri boda nakon 2:1 protiv Funtane, gdje je pobjedu donijela u 85. minuti. Ipak, trenutačni dojam je da Ližnjan ulazi kao favorit u ovaj susret.

Cres - Umag-CC Umago, 17:15. Oba kluba imaju po tri boda i gol razliku plus dva. Cres je dobio 3:1 protiv Rječine, uz dva pogotka Željka Tomića, a Umag 2:0 protiv Štinjana. Iako je Cres i pojačanjima i rezultatom u prvom kolu pokazao da misli ozbiljno, Umag dolazi samouvjereno nakon pozitivnog rezultata protiv na papiru po kadru jačeg Štinjana.

Funtana - Borac (Ba), 18:00. Borac je u sezonu ušao pobjedom 3:0 protiv Klane, uz dva pogotka Mihaela Šušnjara. Funtana je bez bodova i igra bez Abela Peteha, isključenog u prvom kolu.

Smoljanci Sloboda - Otočac. Otočac igra prvu utakmicu sezone, a Smoljanci imaju bod nakon 1:1 protiv Medulina. Otočac je jedva dočekao početak sezone, te će nesporno htjeti uzeti sva tri boda na uvijek izazovnom gostovanju na Suhaču, predvođen brojnim ovosezonskim pojačanjima od kojih se posebno ističe Martin Bogdanić.

Rječina - Klana. Prva povijesna domaća utakmica Rječine u ovom rangu. Uz svoje vjerne "dive ribe" pokušat će do prvih bodova, nakon 1:3 na Cresu. Klana je također bez bodova i igra bez Nike Hrmića i Ronija Šnajdara, obojice isključenih u Krasici.

Štinjan - Medulin 1921. Derbi južne Istre. S obzirom na brojna pojačanja Štinjana, od domaćih crvenih vragova očekuje se pozitivan rezultat. Igraju bez Marina Filipovića, isključenog protiv Umaga. Medulin ima bod nakon 1:1 u Svetvinčentu.

ZA OVO KOLO

Zbog isključenja u prvom kolu ovo kolo propuštaju Abel Peteh (Funtana), Niko Hrmić i Roni Šnajdar (Klana) te Marin Filipović (Štinjan). Nitko nije na pragu žutih kartona.',
  '4. NL NS Rijeka',
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

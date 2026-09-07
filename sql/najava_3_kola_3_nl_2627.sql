-- =====================================================================
-- NAJAVA: 3. kolo 3. NL Zapad 2026/27
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
--   public.najava_kola('2026/27','3. NL Zapad',3), dakle iz baze.
--   Nista nije dodano izvan toga: nema ocjena forme, izjava ni
--   ocekivanja.
--   Kaznene bodove Crikvenice funkcija ne zna, pa tekst na to
--   izricito upozorava umjesto da navodi mjesta na ljestvici.
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
  'najava-3-kola-3-nl-zapad-2627',
  'LOKOMOTIVA NA KRKU, NEHAJ U OMIŠLJU',
  'Treće kolo 3. NL Zapad igra se u subotu 12. rujna u 17 sati, a vodeća Lokomotiva gostuje kod četvrtoplasiranog Krka.',
'Treće kolo 3. NL Zapad igra se u subotu 12. rujna, sve utakmice u 17 sati.

Krk - Lokomotiva (R). Utakmica kola. Lokomotiva je prva na ljestvici sa šest bodova i gol razlikom plus šest, nakon 2:0 u Bujama i 4:0 protiv Crikvenice. Karlo Josipović ima dva pogotka. Krk je četvrti s četiri boda, nakon 2:2 s Crikvenicom i pobjede 2:1 u Vinodolu.

OŠK Omišalj - Nehaj. Nehaj je u sezonu ušao uvjerljivo, s dvije pobjede, 3:1 u Poreču i 4:0 protiv Naprijeda, i drugi je na ljestvici s gol razlikom plus šest. Filip Zrilić ima dva pogotka. Omišalj je peti s tri boda, nakon 5:0 protiv Rudara i 1:4 u Kraljevici.

Halubjan - Kraljevica. Težak zadatak za Halubjan. Kraljevica je uz Lokomotivu i Nehaj jedina sa šest bodova, a čak tri njezina igrača imaju po dva pogotka: Filip Znamenaček, Franko Bosančić i Matija Čabrijan. Halubjan ima bod, nakon 2:2 s Banjolama i 0:4 u Labinu.

Buje - Rudar (L). Oba kluba imaju po tri boda i istu gol razliku, obojica nakon uvodnog poraza pa pobjede u drugom kolu. Buje su slavile 2:1 u Banjolama, Rudar 4:0 protiv Halubjana.

Crikvenica - Banjole. Susret dviju momčadi s po jednim bodom, obje još bez pobjede. Ahmed Durmo ima dva pogotka za goste. Crikvenica ima kaznene bodove, pa je na službenoj ljestvici niže nego što bi bila samo po odigranome.

Jadran-Poreč - Rovinj. Jadran je prošlo kolo preokretom slavio na Žuknici, a Dominik-Velin Mrvčić i Ilija Batrićević imaju po dva pogotka. Rovinj ima tri boda, pobjedu 1:0 protiv Vinodola i poraz 0:1 od Pazinke. Uz ovakav napad domaćina, potencijalno još jedna golijada.

Naprijed (H) - Pomorac. Hreljani se moraju probuditi: dva poraza, šest primljenih i nijedan postignut pogodak. Zadatak im nije lagan, jer Pomorac ima dvojicu s po dva pogotka, Jakoba Šprem-Veljavečkog i Marina Matkovića.

Pazinka-Pazin - Vinodol. Pazinka je prošlo kolo pobijedila 1:0 u Rovinju i ima tri boda. Vinodol je bez bodova nakon dva poraza.

ZA OVO KOLO

U ligi nema isključenih igrača ni igrača na pragu žutih kartona.',
  '3. NL Zapad',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-3-kola-3-nl-zapad-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-3-kola-3-nl-zapad-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-3-kola-3-nl-zapad-2627';

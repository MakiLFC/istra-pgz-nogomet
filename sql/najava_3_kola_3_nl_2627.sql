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

Krk - Lokomotiva (R). Utakmica kola. Vodeća Lokomotiva sa šest bodova i dvije pobjede zaredom gostuje kod četvrtoplasiranog Krka, koji ima četiri boda. Karlo Josipović ima dva pogotka, a kod domaćih je zasad jedini strijelac Ivan Golemac. Prošle sezone na Krku 0:2 za Lokomotivu, a na Kantridi 2:2.

OŠK Omišalj - Nehaj. Drugoplasirani Nehaj, s dvije pobjede i gol razlikom plus šest, gostuje kod Omišlja koji ima tri boda. Filip Zrilić i Luka Mijić imaju po dva pogotka. Prošle sezone u Omišlju 1:2, a u Senju 4:0 za Nehaj.

Halubjan - Kraljevica. Kraljevica je uz Lokomotivu i Nehaj jedina sa šest bodova, dok Halubjan nakon 0:4 u Labinu ima samo bod. Filip Znamenaček vodi kod gostiju s dva pogotka. Prošle sezone 1:1 u Kraljevici i 0:2 u Viškovu.

Buje - Rudar (L). Oba kluba imaju po tri boda i istu gol razliku, obojica nakon uvodnog poraza pa pobjede u drugom kolu. Prošle sezone u Bujama 4:1 za domaće, a u Labinu 1:1.

Crikvenica - Banjole. Susret dviju momčadi s po jednim bodom. Ahmed Durmo ima dva pogotka za goste. Prošle sezone u Banjolama 2:1, a u Crikvenici 1:3.

Jadran-Poreč - Rovinj. Oba kluba imaju po tri boda, Jadran nakon preokreta na Žuknici. Dominik-Velin Mrvčić ima dva pogotka. Klubovi se u našoj bazi dosad nisu sastali.

Naprijed (H) - Pomorac. Naprijed je uz Vinodol jedini bez osvojenog boda, s dva poraza i bez postignutog pogotka. Pomorac ima tri boda, a Jakob Šprem-Veljavečki dva pogotka. Prošle sezone u Hreljinu 0:2 za Pomorac, a u Kostreni 0:0.

Pazinka-Pazin - Vinodol. Pazinka ima tri boda, Vinodol je bez bodova i s dva poraza. Prošle sezone u Pazinu 1:2, a u Novom Vinodolskom 0:4 za Pazinku.

ZA OVO KOLO

U ligi nema isključenih igrača ni igrača na pragu žutih kartona.

Crikvenica ima kaznene bodove, pa se službena ljestvica na stranici lige razlikuje od poretka izračunatog samo iz odigranih utakmica.',
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

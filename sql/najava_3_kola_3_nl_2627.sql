-- =====================================================================
-- NAJAVA: 3. kolo 3. NL Zapad 2026/27
-- subota 12.09.2026., 16:30 i 17:00
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
--   public.najava_kola('2026/27','3. NL Zapad',3), dakle iz baze.
--   Nista nije dodano izvan toga: nema ocjena forme, izjava ni
--   ocekivanja.
--   Kaznene bodove Crikvenice funkcija ne zna, pa tekst na to
--   izricito upozorava umjesto da navodi mjesta na ljestvici.
--
-- ANDREJEVE IZMJENE, 10.09.2026.
--   Naslov, dopuna sazetka, pitanje o Popovicevoj mrezi uz Krk,
--   napomena o golijadi uz Omisalj, i podatak da se u Porec vraca
--   Dalibor Suran, nekadasnji trener i igrac Jadrana, sada na klupi
--   Rovinja. To je Andrejev podatak, nije iz baze.
--
-- ISPRAVLJENI TERMINI, 10.09.2026.
--   HNS je nakon pisanja najave pomaknuo dvije utakmice ovog kola
--   sa 17:00 na 16:30: Krk - Lokomotiva (prijava #90) i
--   Halubjan - Kraljevica (prijava #93). Tekst to sada navodi.
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
  'NAJAVA 3. KOLA 3. NL ZAPAD: VODEĆI NA IZAZOVNIM GOSTOVANJIMA - LOKOMOTIVA NA KRKU, NEHAJ U OMIŠLJU, A KRALJEVICA NA VIŠKOVU',
  'Treće kolo 3. NL Zapad igra se u subotu 12. rujna, a vodeća Lokomotiva u 16:30 gostuje kod četvrtoplasiranog Krka, dok su i ostali sa stopostotnim učinkom na gostovanjima.',
'Treće kolo 3. NL Zapad igra se u subotu 12. rujna. Krk - Lokomotiva i Halubjan - Kraljevica počinju u 16:30, ostale utakmice u 17 sati.

Krk - Lokomotiva (R), 16:30. Utakmica kola. Lokomotiva je prva na ljestvici sa šest bodova i gol razlikom plus šest, nakon 2:0 u Bujama i 4:0 protiv Crikvenice. Karlo Josipović ima dva pogotka. Krk je četvrti s četiri boda, nakon 2:2 s Crikvenicom i pobjede 2:1 u Vinodolu. Može li Popović očuvati mrežu netaknutom i treće kolo zaredom?

OŠK Omišalj - Nehaj. Nehaj je u sezonu ušao uvjerljivo, s dvije pobjede, 3:1 u Poreču i 4:0 protiv Naprijeda, i drugi je na ljestvici s gol razlikom plus šest. Filip Zrilić ima dva pogotka. Omišalj je peti s tri boda, nakon 5:0 protiv Rudara i 1:4 u Kraljevici. Potencijalna golijada u najavi.

Halubjan - Kraljevica, 16:30. Težak zadatak za Halubjan. Kraljevica je uz Lokomotivu i Nehaj jedina sa šest bodova, a čak tri njezina igrača imaju po dva pogotka: Filip Znamenaček, Franko Bosančić i Matija Čabrijan. Halubjan ima bod, nakon 2:2 s Banjolama i 0:4 u Labinu.

Buje - Rudar (L). Oba kluba imaju po tri boda i istu gol razliku, oboje nakon uvodnog poraza pa pobjede u drugom kolu. Buje su slavile 2:1 u Banjolama, Rudar 4:0 protiv Halubjana.

Crikvenica - Banjole. Susret dviju momčadi s po jednim bodom, obje još bez pobjede. Ahmed Durmo ima dva pogotka za goste. Crikvenica ima kaznene bodove, pa je na službenoj ljestvici niže nego što bi bila samo po odigranome.

Jadran-Poreč - Rovinj. Jadran je prošlo kolo preokretom slavio na Žuknici, a Dominik-Velin Mrvčić i Ilija Batrićević imaju po dva pogotka. Rovinj ima tri boda, pobjedu 1:0 protiv Vinodola i poraz 0:1 od Pazinke. U Poreč se vraća Dalibor Šuran, nekadašnji trener i igrač Jadrana, sada na klupi Rovinja.

Naprijed (H) - Pomorac. Hreljani se moraju probuditi: dva poraza, šest primljenih i nijedan postignut pogodak. Zadatak im nije lagan, jer Pomorac ima dvojicu s po dva pogotka, Jakoba Šprem-Veljavečkog i Marina Matkovića.

Pazinka-Pazin - Vinodol. Pazinka je prošlo kolo pobijedila 1:0 u Rovinju i ima tri boda. Vinodol je bez bodova nakon dva poraza.

ZA OVO KOLO

U ligi nema isključenih igrača ni igrača na pragu žutih kartona.',
  '3. NL Zapad',
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

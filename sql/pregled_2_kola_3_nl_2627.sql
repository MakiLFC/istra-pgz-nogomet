-- =====================================================================
-- ČLANAK: PREGLED 2. KOLA 3. NL ZAPAD 2026/27
-- Odigrano 04. i 05.09.2026.
-- =====================================================================
-- KAKO SE KORISTI: pokreni po redu dva koraka na dnu datoteke.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Prvi korak (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   Zatim ide KORAK 2 (objava).
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- PRIJE OVOGA POKRENI sql/autogol_vrhovac_rudar_halubjan.sql, jer se
-- tekst poziva na autogol u 7. minuti. Ako taj upis izostane, stranica
-- utakmice i ljestvica strijelaca govorit ce drukcije od clanka.
--
-- ODAKLE STO
--   Rezultati, strijelci, minute, gledatelji, iskljuceni igraci i pomaci
--   na ljestvici dolaze iz public.pregled_kola('2026/27','3. NL Zapad',2),
--   dakle iz zapisnika u bazi. Opisi tijeka utakmica i ocjene igre su
--   Andrejevi, iz njegove dopune skice 06.09.2026.
--
--   Sto NIJE iz baze, nego od Andreja: dominacija Lokomotive, ocjena
--   igre Rudara, pogodak Svasta izravno iz slobodnog udarca i obranjeni
--   jedanaesterac Pichlera. Toga u zapisniku nema.
--
-- LJESTVICA
--   pregled_kola() racuna tablicu iz utakmica i NE zna za kaznene bodove,
--   a Crikvenica ih ima tri. Zato u tekstu stoje samo vrh ljestvice i
--   pomaci, koje kazneni bodovi ne mijenjaju, uz uputu na sluzbenu
--   ljestvicu na stranici lige.
--
-- BEZ FOTOGRAFIJE
--   Clanak nema sliku, pa se na kartici prikazuje zaglavlje 3. NL Zapad,
--   a pri dijeljenju zajednicka slika Lokal-Arene.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'pregled-2-kola-3-nl-zapad-2627',
  'ČETIRI ČETVORKE U DRUGOM KOLU',
  'Lokomotiva, Nehaj i Kraljevica jedini su bez izgubljenog boda, Krk je skočio šest mjesta, a Rovinj je kod kuće ostao bez svega.',
'Drugo kolo 3. NL Zapad donijelo je 29 pogodaka u osam utakmica, pet više nego uvodno kolo. Četiri puta je domaćin na kraju imao četvorku na semaforu, a samo su tri kluba nakon dva kola bez izgubljenog boda.

Lokomotiva (R) - Crikvenica 4:0. Lokomotiva je na Kantridi povela pogotkom Karla Josipovića u 14. minuti, a u nastavku su Josipović u 49., Marin Grujević u 56. i Edin Junuzović u 72. minuti riješili pitanje pobjednika. Dominirali su domaći praktički od prve do posljednje minute. Druga je to uvjerljiva pobjeda riječkog kluba, nakon 2:0 u Bujama. Detaljniji pregled svih događaja opisan je u zasebnom članku na ovoj stranici.

Rudar (L) - Halubjan 4:0. Rudar je nakon poraza 0:5 u Omišlju odgovorio jednako uvjerljivo, na svom terenu. Kovari su bili konkretni i direktni, te je rezultat mogao biti i viši. Vodstvo je stiglo već u 7. minuti, autogolom Štefana Vrhovca, a dalje su redom pogađali Paolo Juričić u 26., Ivan Macan u 57. i Matteo Movrić u 62. minuti. Halubjan je nakon boda protiv Banjola u drugome kolu ostao i bez bodova i bez pogotka. Gostima posao nije olakšala ni činjenica da su u 43. minuti ostali bez stopera Vrhovca, koji je dobio crveni karton, pa je isti igrač u istoj utakmici upisao i autogol i isključenje. Uz 150 gledatelja, Labin je bio i najposjećenije igralište kola.

Kraljevica - OŠK Omišalj 4:1. Otočani su tjedan dana ranije zabili pet, a sada primili četiri. Kraljevica je nastavila s uspješnim ulaskom u sezonu, s dvije pobjede u dva kola. Filip Znamenaček doveo je domaće u vodstvo u 27. minuti, David Rožajac izjednačio je u 42., pa je prvo poluvrijeme završilo neriješeno. U drugom domaćini dodaju gasa: Franko Bosančić u 51., Znamenaček po drugi put u 58. i Matija Čabrijan u 62. minuti do sredine poluvremena rješavaju pitanje pobjednika.

Nehaj - Naprijed (H) 4:0. Nakon pobjede 3:1 u Poreču Nehaj je nastavio istim ritmom. Naprijed u Senju nije imao nikakve šanse, te je u dva kola primio šest golova, a nije zabio nijedan, što bi trebalo zabrinuti Hreljance. Nehaj je pitanje pobjednika riješio već u prvom poluvremenu, pogocima Filipa Zrilića u 8., Duje Tomljanovića u 14. i Davida Svasta u 40. minuti, a Zrilić je svoj drugi dodao u 47. Posebno treba istaknuti predivan pogodak Svasta izravno iz slobodnog udarca. Da bi mreža ostala netaknuta, pobrinuo se i Pichler, koji je u zadnjim trenucima utakmice obranio i jedanaesterac.

Pomorac - Jadran-Poreč 2:3. Derbi kola, i utakmica s najviše obrata. Jakob Šprem-Veljavečki doveo je domaće u vodstvo u 30. minuti, Ilija Batrićević izjednačio je u 44., Marino Matković vratio je Pomorcu prednost u 50., a onda su Dominik-Velin Mrvčić u 73. i Batrićević u 84. minuti donijeli gostima potpuni preokret. Utakmica o kojoj bi se moglo puno pisati, pa se upućuje na članak na ovoj stranici s posebnim osvrtom izravno sa Žuknice.

Vinodol - Krk 1:2. Lovre Travica poveo je Krk već u 11. minuti, Badara Seck izjednačio je za domaće u 52., a Mirko Valenčić je u 72. minuti donio otočanima prvu pobjedu u sezoni. Vinodol je uz Naprijed i dalje jedini klub lige bez osvojenog boda.

Banjole - Buje 1:2. Buje su poveli s 2:0 već do 34. minute, golovima Damira Bartulovića u 4. i Marka Bulešića u 34. Roni Vujičić smanjio je u 52., ali su gosti sačuvali prednost i stigli do prvih bodova nakon poraza od Lokomotive.

Rovinj - Pazinka-Pazin 0:1. Jedina utakmica kola bez golova domaćina i jedina odlučena jednim pogotkom, onim Mate Ivetića u 13. minuti. Rovinj je u prvom kolu istim rezultatom slavio u Vinodolu, pa je sada osjetio drugu stranu. Po odnosu snaga na ljestvici prije kola, ovo je i najveće iznenađenje kola.

STRIJELCI

Ljestvica strijelaca nakon dva kola nema samostalnog vodećeg: jedanaest igrača ima po dva pogotka. U drugom kolu po dvaput su zabili Filip Znamenaček, Filip Zrilić, Ilija Batrićević i Karlo Josipović. Hat-tricka nije bilo.

LJESTVICA

Bez izgubljenog boda su Lokomotiva, Nehaj i Kraljevica, sve tri sa šest bodova. Lokomotiva i Nehaj imaju gol razliku plus šest, Kraljevica plus pet. Slijedi Krk s četiri boda, a onda čak pet klubova s po tri.

Najveći skok kola napravio je Krk, s desetog na četvrto mjesto. Pazinka-Pazin i Rudar dobili su po pet mjesta, Buje i Jadran Poreč po četiri. Najviše su izgubili Banjole, Crikvenica i Halubjan, po pet mjesta.

Službena ljestvica je na stranici lige, jer ona uključuje i kaznene bodove Crikvenice.

ZA SLJEDEĆE KOLO

Halubjan će treće kolo igrati bez Štefana Vrhovca, isključenog u Labinu. Nitko nije na pragu žutih kartona.

Treće kolo na rasporedu je u subotu 12. rujna u 17 sati.',
  '3. NL Zapad',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-2-kola-3-nl-zapad-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'pregled-2-kola-3-nl-zapad-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-2-kola-3-nl-zapad-2627';

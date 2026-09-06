-- =====================================================================
-- ČLANAK: PREGLED 1. KOLA 4. NL NS RIJEKA 2026/27
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
-- ODAKLE STO
--   Rezultati, strijelci, minute, gledatelji, iskljuceni igraci i
--   ljestvica dolaze iz
--   public.pregled_kola('2026/27','4. NL NS Rijeka',1), dakle iz
--   zapisnika u bazi.
--
--   Sto NIJE iz baze, nego od Andreja (dopuna 06.09.2026.): ocjena
--   pojacanja Cresa i posveta pobjede, ocjena debija Rjecine, sporna
--   sudacka odluka u Krasici, ocjena Stinjana i njihova vratara, te
--   ustrajnost Fazane pred kraj. Toga u zapisniku nema.
--
-- LJESTVICA
--   pregled_kola() racuna tablicu iz odigranih utakmica, pa u njoj nema
--   ni Otocca (bio slobodan) ni Novalje (napustila natjecanje). Zato
--   tekst navodi samo vrh ljestvice i bodove, sto kazneni bodovi ne
--   mijenjaju. Sluzbena ljestvica je na stranici lige.
--
--   Recenicu o tome da Semafor jos prikazuje Novalju Andrej je izricito
--   trazio da se izostavi, da ne ispadne kako po tom pitanju nista nije
--   napravljeno. Njezine utakmice su obrisane iz rasporeda 03.09.2026.
--
-- BEZ FOTOGRAFIJE
--   Clanak nema sliku, pa se na kartici prikazuje zaglavlje
--   4. NL NS Rijeka, a pri dijeljenju zajednicka slika Lokal-Arene.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'pregled-1-kola-4-nl-ns-rijeka-2627',
  'LIŽNJAN PETICOM OTVORIO SEZONU',
  'Uvodno kolo donijelo je 19 pogodaka i čak četiri isključenja, a Klana je posljednjih osam minuta u Krasici odigrala s devet igrača. Osim Ližnjana u Rovinju, gosti nisu slavili nigdje.',
'Prvo kolo 4. NL NS Rijeka odigrano je u petak i subotu, 4. i 5. rujna. Šest utakmica donijelo je 19 pogodaka, četiri pobjede domaćina, jednu pobjedu gosta i jedan neriješen rezultat. Otočac je kolo proveo slobodan, jer je NK Novalja prije početka prvenstva napustila natjecanje.

Žminj - Ližnjan 0:5. Jedina utakmica odigrana u petak, jedina pobjeda gosta u kolu i najuvjerljiviji rezultat prvog kola. Domaćin je susret igrao na Valbruni u Rovinju. Ližnjan je poveo pogotkom Maura Čude u 11. minuti, Saša Urošević povisio je u 33., a Marko Kontošić na samom kraju prvog poluvremena, u 45. minuti. Konačnih 0:5 postavili su Nikola Perković u 88. i Antonio Jovanović u 90. minuti. Pet pogodaka, pet različitih strijelaca.

Cres - Rječina 3:1. Prva pobjeda otočana u sezoni i najposjećenija utakmica kola, uz 150 gledatelja. Željko Tomić poveo je domaće u 18. minuti, Patrik Corallini izjednačio je u 27., a onda je Tomić u 48. postigao svoj drugi pogodak i vratio Cresu prednost. Demis Seo Salihović potvrdio je pobjedu u 67. minuti. Tako su se ovosezonska pojačanja Cresa pokazala na najbolji mogući način. Svima koji imalo prate lokalni nogomet, jasno je kome je bila posvećena ova pobjeda. S druge strane, prva povijesna utakmica za NK Rječinu u višem rangu, koja se svakako nije osramotila u debiju.

Borac (Bakar) - Klana 3:0. Mihael Šušnjar doveo je domaće u vodstvo u 15. minuti, a onda je utakmicu prelomila sudačka odluka koju su gosti u najmanju ruku smatrali spornom. Naime, Klana je u 58. minuti ostala bez Nike Hrmića koji je isključen, a u 82. i bez Ronija Šnajdara, pa je posljednjih osam minuta odigrala s devet igrača. Josip Tkalčević povisio je rezultat u 81. minuti, a Šušnjar je svojim drugim pogotkom postavio "točku na i" u 89. minuti.

Umag-CC Umago - Štinjan 2:0. Dejan Đuričin doveo je domaće u vodstvo u 22. minuti. Štinjan je u 52. ostao bez Marina Filipovića, isključenog crvenim kartonom, a Kanađanin Jamu Akou Arum Iluya potvrdio je pobjedu u 69. minuti. Umag je tako do tri boda stigao bez primljenog gola, pred 110 gledatelja. Štinjan nije pokazao pravo lice s obzirom na kadar kojim raspolaže. Njihov je vratar cijelu utakmicu imao pune ruke posla i spasio ih većeg poraza.

Mladost Fažana - Funtana 2:1. Najdramatičniji završetak kola. Marin Ristić doveo je domaće u vodstvo u 21. minuti, Robert Vlizlo izjednačio je za Funtanu u 80., ali domaćini nisu odustajali u namjeri za tri boda te je Toni Nišević u 85. minuti donio Fažani pobjedu. U prvoj minuti nadoknade Funtana je ostala i bez Abela Peteha, koji je dobio drugi žuti karton.

Smoljanci Sloboda - Medulin 1921 1:1. Jedina podjela bodova u kolu, i utakmica u kojoj je sve bilo gotovo do 17. minute. Mike Amachi Ezemonye poveo je domaće u 6., a Matija Brizić izjednačio u 17. minuti. Do kraja mreže su mirovale.

STRIJELCI

Nakon uvodnog kola dva igrača imaju po dva pogotka, Mihael Šušnjar iz Borca i Željko Tomić iz Cresa. Hat-tricka nije bilo.

LJESTVICA

Nakon prvog kola vodi Ližnjan, ispred Borca, Cresa, Umaga i Mladosti Fažane, sve s po tri boda, a redoslijed određuje gol razlika. Medulin i Smoljanci Sloboda imaju po bod.

Otočac u ljestvici stoji bez odigrane utakmice, jer je kolo proveo slobodan, što nije poraz.

ZA SLJEDEĆE KOLO

Zbog isključenja drugo kolo propuštaju Niko Hrmić i Roni Šnajdar iz Klane, Marin Filipović iz Štinjana i Abel Peteh iz Funtane. Klana tako u Rječinu putuje bez dvojice, Štinjan protiv Medulina i Funtana protiv Borca bez po jednog igrača. Nitko nije na pragu žutih kartona.

Drugo kolo na rasporedu je u subotu 12. rujna u 17 sati.',
  '4. NL NS Rijeka',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-1-kola-4-nl-ns-rijeka-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'pregled-1-kola-4-nl-ns-rijeka-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-1-kola-4-nl-ns-rijeka-2627';

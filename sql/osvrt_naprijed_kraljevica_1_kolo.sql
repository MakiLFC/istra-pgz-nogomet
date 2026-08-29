-- =====================================================================
-- OSVRT UZ ZAPISNIK: NAPRIJED (H) - KRALJEVICA 0:2
-- 1. kolo 3. NL Zapad, 29.08.2026., Lonja, Hreljin
-- =====================================================================
-- RADNA VERZIJA, JOŠ SE NE POKREĆE.
--
-- Tekst je napisan po Andrejevim bilješkama s tribine (bio je na
-- utakmici). Brojevi dresova još nisu zamijenjeni imenima, jer se
-- imena čitaju iz postave u zapisniku, a zapisnik u trenutku pisanja
-- još nije bio u bazi.
--
-- ŠTO JOŠ TREBA (ujutro 30.08.2026.):
--   1. pokrenuti upit za postave (dolje, odjeljak POSTAVE)
--   2. brojeve 17, 47, 25, 9, 10, 11, 3, 4 i 6 zamijeniti imenima
--   3. potvrditi kapetana Naprijeda (u zapisniku postoji oznaka)
--   4. broj 25 kod Naprijeda Andrej je naveo s ogradom ("mislim
--      Jandrek"), pa se potvrđuje iz postave
--   5. odlučiti ostaje li puni tekst uz zapisnik ili se skraćuje, a
--      duga verzija ide kao zaseban članak u novosti
-- =====================================================================


-- ---------------------------------------------------------------------
-- BILJEŠKE S UTAKMICE (izvor teksta, ne briši dok osvrt nije objavljen)
-- ---------------------------------------------------------------------
-- Konačni rezultat 0:2 za Kraljevicu. N = Naprijed, K = Kraljevica.
--
--  1'  K 4   udarac sa 16 m po sredini, ravno u vratara, mirna obrana
--  3'  K 11  s lijevog boka, udarac po podu pored gola
-- 10'  K 9   sa 20-ak metara, pored gola
-- do 25'     Kraljevica kontrolira posjedom, Naprijed pokušava iz kontri
-- 29'  GOL   N 17 prekratko vratio vrataru, K 9 presjekao i zabio u
--            praznu mrežu (0:1)
-- 32'  K 10  prolaz desno nakon dubinske, povratna na K 9, blok odbija u
--            korner iako je lopta išla u okvir
-- 36'  N 47  udarac u okvir, od bloka u korner koji nije dosuđen; prvi
--            opasniji pokušaj domaćih
-- 40'  N 25  opasan ubačaj, vratar Kraljevice sigurno izbija
--            (Andrej misli da je 25 Jandrek, potvrditi)
-- POL. 1     prvih 30-ak minuta dominacija Kraljevice, Naprijed se pred
--            kraj digao ali bez konkretnijih šansi; zasluženo vodstvo
--
-- 48'  GOL   K 4 (Bosančić) nakon ubačaja iz slobodnog s desne strane,
--            glavom s 5 m; dojam da je vratar mogao bolje. Novo
--            pojačanje se odmah pokazalo kao dobra odluka (0:2)
-- 53'  N     kapetan domaćih puca nogom iz gužve nakon ubačaja iz
--            slobodnog, vratar mirno brani; najbolja prilika Naprijeda
-- 55'  N 47  slobodan udarac lukavo po podu, vratar izvlači iz kuta
-- 60'  K 6   sa 25 m, spor udarac pored gola
--            nakon drugog primljenog Naprijed življi, utakmica nervoznija
-- 71'  K     iz kornera zamalo gol iz gužve, lopta preko gola
-- 71'  N 7   Dukađin sam iskosa pred vratarom, odlučio dodati umjesto
--            pucati, presječeno u korner
-- 74'  K 4   solo prodor u kazneni prostor i ubačaj na drugu stranu,
--            nečuvani broj 3 gađa prečku
-- 80'        kratki prekid zbog baklji i raketa navijača Kraljevice
-- 89'  K     Paljokaj sa 16 m preko gola
-- ---------------------------------------------------------------------


-- ---------------------------------------------------------------------
-- POSTAVE (pokreni ujutro, iz ispisa se brojevi pretvaraju u imena)
-- ---------------------------------------------------------------------
with postave as (
  select u.domacin as klub, e as igrac
  from public.utakmice u, lateral jsonb_array_elements(u.postava_domacin) e
  where u.sezona = '2026/27' and u.natjecanje = '3. NL Zapad'
    and u.kolo = 1 and u.domacin ilike '%Naprijed%'
  union all
  select u.gost, e
  from public.utakmice u, lateral jsonb_array_elements(u.postava_gost) e
  where u.sezona = '2026/27' and u.natjecanje = '3. NL Zapad'
    and u.kolo = 1 and u.domacin ilike '%Naprijed%'
)
select klub,
       igrac ->> 'broj'     as broj,
       igrac ->> 'igrac'    as ime,
       igrac ->> 'kapetan'  as kapetan,
       igrac ->> 'pricuvni' as klupa
from postave
order by klub, nullif(igrac ->> 'broj', '')::int nulls last;


-- ---------------------------------------------------------------------
-- UPIS OSVRTA (pokreće se tek kad brojevi budu zamijenjeni imenima)
-- ---------------------------------------------------------------------
-- Polje tekst_clanka scraper nikad ne dira, pa osvrt preživi svako
-- sljedeće osvježavanje. Apostrof u tekstu piše se dvaput.
--
-- update public.utakmice
--    set tekst_clanka = 'Kraljevica je u Hreljinu otvorila sezonu pobjedom od 0:2 i tri boda odnijela zasluženo, nakon poluvremena u kojem je držala loptu i nastavka u kojem je iskoristila prekid.
--
-- Gosti su krenuli odmah. Već u prvoj minuti broj 4 pucao je sa šesnaest metara po sredini, ravno u vratara, koji je mirno obranio. U trećoj minuti broj 11 zaprijetio je s lijeve strane udarcem po podu, ali pored gola, a u desetoj je broj 9 s dvadesetak metara također promašio okvir.
--
-- Prvih dvadeset pet minuta Kraljevica je posjedom kontrolirala utakmicu. Naprijed je nešto pokušavao iz kontri, no bez konkretnog zaključka.
--
-- Pogodak je stigao u 29. minuti, i to iz pogreške. Domaći broj 17 prekratko je vratio loptu vrataru, to je nanjušio gostujući broj 9, presjekao i zabio u praznu mrežu.
--
-- Tri minute poslije Kraljevica je bila blizu drugog. Broj 10 prošao je desnom stranom nakon dubinske lopte i uputio povratnu loptu na broja 9, no u zadnji čas se od bloka odbila u korner, iako je išla u okvir vrata.
--
-- Prvi ozbiljniji pokušaj domaćih stigao je u 36. minuti. Udarac broja 47 išao je u okvir, ali se od bloka odbio u korner koji nije ni dosuđen. U 40. minuti broj 25 opasno je ubacio u kazneni prostor, a vratar Kraljevice sigurno je izbio loptu.
--
-- Prvih tridesetak minuta bilo je potpuna dominacija Kraljevice. Naprijed se prema kraju poluvremena počeo dizati, ali bez konkretnijih prilika, pa se na odmor otišlo uz zasluženo gostujuće vodstvo.
--
-- Nastavak je odlučen brzo. U 48. minuti, nakon ubačaja iz slobodnog udarca s desne strane, Bosančić je bio najviši i s pet metara glavom pogodio za 0:2. Dojam je bio da je vratar mogao bolje reagirati. Novo pojačanje Kraljevice tako se odmah pokazalo kao dobra odluka.
--
-- Naprijed je uzvratio najboljom prilikom dotad. U 53. minuti, također nakon ubačaja iz slobodnog udarca, kapetan domaćih pucao je nogom iz gužve, no vratar je mirno obranio i odbio loptu. Dvije minute poslije broj 47 lukavo je pucao po podu iz slobodnog udarca, a vratar je loptu izvukao iz samog kuta gola.
--
-- U 60. minuti gostujući broj 6 pokušao je s dvadeset pet metara, ali je udarac bio spor i završio pored gola. Nakon primljenog drugog pogotka Naprijed je krenuo življe, a utakmica je postala nervoznija.
--
-- U 71. minuti Kraljevica je iz kornera zamalo zabila i treći, lopta je iz gužve otišla preko gola. U istoj minuti, na drugoj strani, Dukađin je iskosa sam izašao pred vratara, no odlučio je dodati umjesto pucati i lopta je presječena u korner.
--
-- Tri minute kasnije Bosančić je solo prodro u kazneni prostor i ubacio na drugu stranu, gdje je nečuvan bio broj 3. Mirnoće je nedostajalo, pa je umjesto pogotka stigao udarac u prečku.
--
-- Igra je u 80. minuti nakratko prekinuta zbog baklji i raketa navijača Kraljevice. Posljednju priliku imao je Paljokaj u 89. minuti, sa šesnaest metara preko gola.',
--        derbi = true
--  where sezona = '2026/27' and natjecanje = '3. NL Zapad'
--    and kolo = 1 and domacin ilike '%Naprijed%';
--
-- Provjera nakon upisa:
-- select domacin, gost, rezultat, derbi, left(tekst_clanka, 80) as pocetak
-- from public.utakmice
-- where sezona = '2026/27' and natjecanje = '3. NL Zapad'
--   and kolo = 1 and domacin ilike '%Naprijed%';
-- =====================================================================

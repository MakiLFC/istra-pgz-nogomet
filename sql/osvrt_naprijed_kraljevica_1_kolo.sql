-- =====================================================================
-- OSVRT UZ ZAPISNIK: NAPRIJED (H) - KRALJEVICA 0:2
-- 1. kolo 3. NL Zapad, 29.08.2026., Lonja, Hreljin, 200 gledatelja
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Tekst se upisuje u polje tekst_clanka utakmice, koje scraper nikad
--   ne dira, pa osvrt prezivi svako sljedece osvjezavanje.
--
-- Tekst je napisan po Andrejevim biljeskama s tribine, a imena su
-- uzeta iz postava u zapisniku. Minute pogodaka su iz zapisnika
-- (30. i 50.), Andrej ih je s tribine zapisao kao 29. i 48.
--
-- OTVORENO PITANJE: u 40. minuti Andrej je zabiljezio ubacaj igraca
-- broj 25, uz ogradu da misli da je to Jandrek. U sastavu Naprijeda
-- nema broja 25, a Jandrek nosi 47. U tekstu je zato pripisano
-- Jandreku. Ako to nije tocno, ta se recenica moze skratiti.
-- =====================================================================

update public.utakmice
   set tekst_clanka = 'Kraljevica je u Hreljinu otvorila sezonu pobjedom od 0:2 i tri boda odnijela zasluženo, nakon poluvremena u kojem je držala loptu i nastavka u kojem je iskoristila prekid. Na Lonji je bilo 200 gledatelja, najviše na jednoj utakmici prvog kola.

Gosti su krenuli odmah. Već u prvoj minuti Franko Bosančić pucao je sa šesnaest metara po sredini, ravno u vratara, koji je mirno obranio. U trećoj minuti Paulo Kocijan zaprijetio je s lijeve strane udarcem po podu, ali pored gola, a u desetoj je Matija Čabrijan s dvadesetak metara također promašio okvir.

Prvih dvadeset pet minuta Kraljevica je posjedom kontrolirala utakmicu. Naprijed je nešto pokušavao iz kontri, no bez konkretnog zaključka.

Pogodak je stigao u 30. minuti, i to iz pogreške. Lovro Tomljanović prekratko je vratio loptu vrataru, to je nanjušio Čabrijan, presjekao i zabio u praznu mrežu.

Dvije minute poslije Kraljevica je bila blizu drugog. Maro Rosić prošao je desnom stranom nakon dubinske lopte i uputio povratnu loptu na Čabrijana, no u zadnji čas se od bloka odbila u korner, iako je išla u okvir vrata.

Prvi ozbiljniji pokušaj domaćih stigao je u 36. minuti. Udarac Roberta Jandreka išao je u okvir, ali se od bloka odbio u korner koji nije ni dosuđen. Četiri minute kasnije Jandrek je opasno ubacio u kazneni prostor, a vratar Kraljevice sigurno je izbio loptu.

Prvih tridesetak minuta bila je potpuna dominacija Kraljevice. Naprijed se prema kraju poluvremena počeo dizati, ali bez konkretnijih prilika, pa se na odmor otišlo uz zasluženo gostujuće vodstvo.

Nastavak je odlučen brzo. U 50. minuti, nakon ubačaja iz slobodnog udarca s desne strane, Bosančić je bio najviši i s pet metara glavom pogodio za 0:2. Dojam je bio da je vratar mogao bolje reagirati. Novo pojačanje Kraljevice tako se odmah pokazalo kao dobra odluka.

Naprijed je uzvratio najboljom prilikom dotad. U 53. minuti, također nakon ubačaja iz slobodnog udarca, kapetan Karlo Radošević pucao je nogom iz gužve, no vratar je mirno obranio i odbio loptu. Dvije minute poslije Jandrek je lukavo pucao po podu iz slobodnog udarca, a vratar je loptu izvukao iz samog kuta gola.

U 60. minuti Borna Znamenaček pokušao je s dvadeset pet metara, ali je udarac bio spor i završio pored gola. Nakon primljenog drugog pogotka Naprijed je krenuo življe, a utakmica je postala nervoznija.

U 71. minuti Kraljevica je iz kornera zamalo zabila i treći, lopta je iz gužve otišla preko gola. U istoj minuti, na drugoj strani, Dino Dukađin je iskosa sam izašao pred vratara, no odlučio je dodati umjesto pucati i lopta je presječena u korner.

Tri minute kasnije Bosančić je solo prodro u kazneni prostor i ubacio na drugu stranu, gdje je nečuvan bio Mikula Dunatov. Mirnoće je nedostajalo, pa je umjesto pogotka stigao udarac u prečku.

Igra je u 80. minuti nakratko prekinuta zbog baklji i raketa navijača Kraljevice. Posljednju priliku imao je Dominik Paljokaj u 89. minuti, sa šesnaest metara preko gola.'
 where sezona = '2026/27' and natjecanje = '3. NL Zapad'
   and kolo = 1 and domacin ilike '%Naprijed%';


-- ---------- PROVJERA ----------
-- Ocekivano: jedan redak, derbi = true, pocetak teksta o Kraljevici.
select domacin, gost, rezultat, derbi, gledatelja,
       left(tekst_clanka, 90) as pocetak
from public.utakmice
where sezona = '2026/27' and natjecanje = '3. NL Zapad'
  and kolo = 1 and domacin ilike '%Naprijed%';


-- ---------- BRISANJE OSVRTA (ako zatreba) ----------
-- update public.utakmice set tekst_clanka = null
-- where sezona = '2026/27' and natjecanje = '3. NL Zapad'
--   and kolo = 1 and domacin ilike '%Naprijed%';
-- =====================================================================

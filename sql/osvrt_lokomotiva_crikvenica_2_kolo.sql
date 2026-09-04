-- =====================================================================
-- OSVRT UZ ZAPISNIK: NK LOKOMOTIVA (R) - NK CRIKVENICA 4:0
-- 2. kolo 3. NL Zapad, 04.09.2026., Stadion Kantrida, Rijeka
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Tekst se upisuje u polje tekst_clanka utakmice, koje scraper nikad
--   ne dira, pa osvrt prezivi svako sljedece osvjezavanje.
--
-- ODAKLE STO
--   Tekst je napisan po Andrejevim biljeskama s tribine. Imena koja u
--   njima stoje (Monjac, Weitzer, Josipovic, Junuzovic) zadrzana su
--   doslovno. Nista drugo nije dodano: nema izjava, ocjena forme ni
--   atmosfere.
--
-- OTVORENA PITANJA (zato su neki igraci opisani bez imena)
--   1. Broj 28, strijelac za 3:0 u 56. minuti, kojemu je to bio
--      prvijenac. U zapisniku stoji ime strijelca, pa se ta recenica
--      moze dopuniti.
--   2. Broj 23, koji je asistirao kod 2:0 u 49. minuti i pucao glavom u
--      53.
--   3. Broj 17 (prodor u 66.) i broj 10 (udarac u 17. minuti).
--   4. Kod Crikvenice broj 18 (kontra i stativa u 20.) i broj 9 (udarac
--      glavom u 61.).
--
--   MINUTE su Andrejeve, s tribine. Kod prosle utakmice pokazalo se da
--   znaju odstupati od zapisnika za minutu ili dvije (29. i 48. prema
--   30. i 50.). Ako se s minutama pogodaka u zapisniku razilaze, mjerodavan
--   je zapisnik, pa javi i ispravlja se.
-- =====================================================================

update public.utakmice
   set tekst_clanka = 'Lokomotiva je na Kantridi svladala Crikvenicu 4:0 i drugo kolo otvorila uvjerljivom pobjedom. Prije početka Mateu Monjcu uručen je trofej za najboljeg asistenta prošle sezone.

Prvih deset minuta prošlo je bez ijedne konkretne prilike. Crikvenica se dobro branila, a Lokomotiva je držala loptu, ali bez opasnosti prema golu.

Vodstvo je stiglo u 13. minuti. Nakon povratne lopte Josipović je pucao s vrha kaznenog prostora, lopta se odbila od bloka i prevarila vratara.

U 17. minuti uslijedio je udarac s dvadesetak metara po sredini vrata, koji je vratar mirno uhvatio. Tri minute poslije Crikvenica je prvi put zaprijetila: nakon pogrešnog dodavanja Lokomotive krenula je u brzu kontru, ušla s desne strane u kazneni prostor i pogodila stativu.

Slijedila su dva opasna ubačaja Monjca. U 27. minuti obrana je izbila u korner, u 32. je vratar uhvatio loptu. U 37. minuti Weitzer je unutar šesnaesterca primio loptu nečuvan, ali je iz okreta pucao preko gola.

U 42. minuti Josipović je s lijeve strane kaznenog prostora prebacio vratara. Lopta je išla prema suigraču u sredini, no obrana ju je skrenula u korner. Odmah zatim, u 43., nakon tog kornera, Crikvenica je krenula u kontru. Iako su išli četiri na dva, njihov je igrač otišao sam, lažnjakom izbacio obojicu branitelja i našao se oči u oči s vratarom, koji je obranio u korner.

Nastavak je Lokomotiva otvorila drugim pogotkom. U 49. minuti, nakon savršene lopte u prostor, Josipović je ostao nečuvan i mirno pogodio u drugi kut.

U 53. minuti udarac glavom nakon ubačaja otišao je pored gola, a u 55. je Junuzović zabio nakon ubačaja iz slobodnog udarca, ali je poništeno zbog zaleđa. Treći pogodak stigao je u 56. minuti: nakon ubačaja po zraku domaći je igrač na drugoj stativi ostao nečuvan i mirno pogodio u mrežu. Bio mu je to prvijenac.

U 59. minuti Josipović se snalažljivo okrenuo u kaznenom prostoru i pucao, lopta se odbila u korner. U 61. je Crikvenica napokon zaprijetila nešto konkretnije, udarcem glavom nakon ubačaja iz slobodnog udarca, ali preko gola.

Domaći su nastavili. U 65. minuti udarac glavom s desetak metara, nečuvan, otišao je pored gola, a u 66. se udarac s dvadesetak metara nakon prodora odbio od bloka suigrača i završio pored gola. U 70. je opet ubačaj Monjca izbijen u korner.

Konačnih 4:0 postavio je Junuzović u 72. minuti, glavom iz kornera u drugi kut. U 82. minuti Weitzer je pucao iz slobodnog udarca po sredini gola, a do kraja se rezultat nije mijenjao.'
 where sezona = '2026/27'
   and natjecanje = '3. NL Zapad'
   and kolo = 2
   and domacin = 'NK Lokomotiva (R)'
   and gost = 'NK Crikvenica';


-- ---------- PROVJERA ----------
-- Ocekivano: jedan redak, rezultat 4:0, pocetak teksta o Kantridi.
select domacin, gost, rezultat, derbi, gledatelja,
       left(tekst_clanka, 90) as pocetak
from public.utakmice
where sezona = '2026/27' and natjecanje = '3. NL Zapad'
  and kolo = 2 and domacin ilike '%Lokomotiva%';


-- ---------- BRISANJE OSVRTA (ako zatreba) ----------
-- update public.utakmice set tekst_clanka = null
-- where sezona = '2026/27' and natjecanje = '3. NL Zapad'
--   and kolo = 2 and domacin = 'NK Lokomotiva (R)';

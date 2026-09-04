-- =====================================================================
-- OSVRT UZ ZAPISNIK: NK LOKOMOTIVA (R) - NK CRIKVENICA 4:0
-- 2. kolo 3. NL Zapad, 04.09.2026., Stadion Kantrida, Rijeka, 40 gledatelja
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Tekst se upisuje u polje tekst_clanka utakmice, koje scraper nikad
--   ne dira, pa osvrt prezivi svako sljedece osvjezavanje.
--
-- ODAKLE STO
--   Tekst je napisan po Andrejevim biljeskama s tribine i po njegovim
--   ispravcima od 04.09.2026. Imena igraca koji su u biljeskama stajali
--   samo po broju dresa dao je Andrej: 28 Marin Grujevic, 23 Edin
--   Junuzovic, 17 Mateo Monjac, 10 Franjo Ivancic, kod Crikvenice 18
--   Rhaillam Sousa Araujo i 9 Jakov Mendrila. Nista drugo nije dodano:
--   nema izjava, ocjena forme ni atmosfere.
--
-- MINUTE
--   Minute u tekstu su Andrejeve, s tribine, i takve ostaju po njegovoj
--   izricitoj uputi. Sluzbene minute pogodaka iz zapisnika su 14, 49, 56
--   i 72. Jedina razlika je prvi pogodak: u tekstu 13., u zapisniku 14.
--   minuta. Ostala tri se poklapaju. Ovo je zapisano da se kasnije ne
--   "ispravlja" kao omaska.
--
-- GLEDATELJI
--   Brojka 40 stoji i u zapisniku, pa je scraper sam upisao u stupac
--   gledatelja. Rucni unos nije potreban.
-- =====================================================================

update public.utakmice
   set tekst_clanka = 'Lokomotiva je na Kantridi svladala Crikvenicu 4:0 i drugo kolo otvorila uvjerljivom pobjedom. Prije početka Mateu Monjcu uručen je trofej za najboljeg asistenta prošle sezone.

Prvih deset minuta prošlo je bez ijedne konkretne prilike. Crikvenica se dobro branila, a Lokomotiva je držala loptu, ali bez opasnosti prema golu.

Vodstvo je stiglo u 13. minuti. Nakon povratne lopte Karlo Josipović pucao je s vrha kaznenog prostora, lopta se odbila od bloka i prevarila vratara.

U 17. minuti Franjo Ivančić pucao je s dvadesetak metara po sredini vrata, a vratar je mirno uhvatio. Tri minute poslije Crikvenica je prvi put zaprijetila: nakon pogrešnog dodavanja Lokomotive Rhaillam Sousa Araujo krenuo je u brzu kontru, ušao s lijeve strane u kazneni prostor i pogodio stativu.

Slijedila su dva opasna ubačaja Matea Monjca. U 27. minuti obrana je izbila u korner, a u 32. je vratar sigurno uhvatio loptu. U 37. minuti Ivor Weitzer je unutar šesnaesterca primio loptu nečuvan, ali je iz okreta pucao preko gola.

U 42. minuti Josipović je s lijeve strane kaznenog prostora prebacio vratara. Lopta je išla prema suigraču u sredini, no obrana ju je skrenula u korner. Minutu poslije, nakon kornera Crikvenice, Lokomotiva je krenula u kontru. Iako su sa četiri igrača išli izravno na dvojicu, Josipović je otišao sam, lažnjakom izbacio obojicu obrambenih igrača i našao se oči u oči s vratarom, koji je obranio u korner.

Nastavak je Lokomotiva otvorila drugim pogotkom. U 49. minuti, nakon savršene lopte Edina Junuzovića u prostor, Josipović je ostao nečuvan i mirno pogodio u drugi kut.

U 53. minuti Junuzović je nakon ubačaja pucao glavom pored gola, te je time najavio ono što slijedi. U 55. je zabio nakon ubačaja iz slobodnog udarca, ali je poništeno zbog zaleđa. Treći pogodak stigao je u 56. minuti: nakon ubačaja po zraku Marin Grujević ostao je nečuvan na drugoj stativi i mirno pogodio u mrežu. Bio mu je to prvijenac za Lokomotivu.

U 59. minuti Josipović se snalažljivo okrenuo u kaznenom prostoru i pucao, lopta se odbila u korner. U 61. je Crikvenica napokon zaprijetila nešto konkretnije, udarcem glavom Jakova Mendrile nakon ubačaja iz slobodnog udarca, ali preko gola.

Domaći su nastavili. U 65. minuti Grujević je nečuvan pucao glavom s desetak metara, pored gola, a u 66. se udarac Monjca s dvadesetak metara nakon prodora odbio od bloka suigrača i završio pored gola. U 70. je opet ubačaj Monjca izbijen u korner.

Konačnih 4:0 postavio je Junuzović u 72. minuti, glavom iz kornera u drugi kut, i time stavio točku na i, kako ishodu utakmice, tako i svojoj vrhunskoj izvedbi. U 82. minuti Weitzer je pucao iz slobodnog udarca po sredini gola, a do kraja se rezultat nije mijenjao.'
 where sezona = '2026/27'
   and natjecanje = '3. NL Zapad'
   and kolo = 2
   and domacin = 'NK Lokomotiva (R)'
   and gost = 'NK Crikvenica';


-- ---------- PROVJERA ----------
-- Ocekivano: jedan redak, rezultat 4:0, gledatelja 40, pocetak teksta o Kantridi.
select domacin, gost, rezultat, derbi, gledatelja,
       left(tekst_clanka, 90) as pocetak
from public.utakmice
where sezona = '2026/27' and natjecanje = '3. NL Zapad'
  and kolo = 2 and domacin ilike '%Lokomotiva%';


-- ---------- BRISANJE OSVRTA (ako zatreba) ----------
-- update public.utakmice set tekst_clanka = null
-- where sezona = '2026/27' and natjecanje = '3. NL Zapad'
--   and kolo = 2 and domacin = 'NK Lokomotiva (R)';

-- =====================================================================
-- ČLANAK: OSVRT S KANTRIDE, LOKOMOTIVA - CRIKVENICA 4:0
-- 2. kolo 3. NL Zapad, 04.09.2026., 40 gledatelja
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Clanak se upisuje s objavljen = false, dakle NIJE vidljiv na
--   stranici. Pogledaj ga u Supabaseu (Table editor -> clanci), pa ga
--   objavi naredbom iz odjeljka OBJAVA na dnu.
--
--   Pokrece se SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- TEKST je isti kao osvrt uz zapisnik te utakmice
-- (sql/osvrt_lokomotiva_crikvenica_2_kolo.sql), po Andrejevoj uputi.
-- Stoji na dva mjesta, u utakmice.tekst_clanka i ovdje u clanci.tekst,
-- pa ako se kasnije mijenja, mijenja se na oba.
--
-- SAZETAK je onaj koji je Andrej odabrao 04.09.2026. (treci prijedlog).
-- FOTOGRAFIJA je vec upisana, adresa je iz Supabase Storagea. Opis slike
-- je opcenit i treba ga zamijeniti, vidi odjeljak OPIS FOTOGRAFIJE.
-- =====================================================================


insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, slika_url, slika_opis,
   slika_potpis, objavljen, objavljeno_u)
values (
  'osvrt-lokomotiva-crikvenica-2-kolo-2627',
  'OSVRT S KANTRIDE: LOKOMOTIVA - CRIKVENICA 4:0',
  'Lokomotiva je vodila od 13. minute, a u nastavku je s tri pogotka u dvadesetak minuta riješila pitanje pobjednika. Crikvenica je ostala na stativi Rhaillama Souse Arauja i udarcu glavom Jakova Mendrile.',
'Lokomotiva je na Kantridi svladala Crikvenicu 4:0 i drugo kolo otvorila uvjerljivom pobjedom. Prije početka Mateu Monjcu uručen je trofej za najboljeg strijelca prošle sezone.

Prvih deset minuta prošlo je bez ijedne konkretne prilike. Crikvenica se dobro branila, a Lokomotiva je držala loptu, ali bez opasnosti prema golu.

Vodstvo je stiglo u 13. minuti. Nakon povratne lopte Karlo Josipović pucao je s vrha kaznenog prostora, lopta se odbila od bloka i prevarila vratara.

U 17. minuti Franjo Ivančić pucao je s dvadesetak metara po sredini vrata, a vratar je mirno uhvatio. Tri minute poslije Crikvenica je prvi put zaprijetila: nakon pogrešnog dodavanja Lokomotive Rhaillam Sousa Araujo krenuo je u brzu kontru, ušao s lijeve strane u kazneni prostor i pogodio stativu.

Slijedila su dva opasna ubačaja Matea Monjca. U 27. minuti obrana je izbila u korner, a u 32. je vratar sigurno uhvatio loptu. U 37. minuti Ivor Weitzer je unutar šesnaesterca primio loptu nečuvan, ali je iz okreta pucao preko gola.

U 42. minuti Josipović je s lijeve strane kaznenog prostora prebacio vratara. Lopta je išla prema suigraču u sredini, no obrana ju je skrenula u korner. Minutu poslije, nakon kornera Crikvenice, Lokomotiva je krenula u kontru. Iako su sa četiri igrača išli izravno na dvojicu, Josipović je otišao sam, lažnjakom izbacio obojicu obrambenih igrača i našao se oči u oči s vratarom, koji je obranio u korner.

Nastavak je Lokomotiva otvorila drugim pogotkom. U 49. minuti, nakon savršene lopte Edina Junuzovića u prostor, Josipović je ostao nečuvan i mirno pogodio u drugi kut.

U 53. minuti Junuzović je nakon ubačaja pucao glavom pored gola, te je time najavio ono što slijedi. U 55. je zabio nakon ubačaja iz slobodnog udarca, ali je poništeno zbog zaleđa. Treći pogodak stigao je u 56. minuti: nakon ubačaja po zraku Marin Grujević ostao je nečuvan na drugoj stativi i mirno pogodio u mrežu. Bio mu je to prvijenac za Lokomotivu.

U 59. minuti Josipović se snalažljivo okrenuo u kaznenom prostoru i pucao, lopta se odbila u korner. U 61. je Crikvenica napokon zaprijetila nešto konkretnije, udarcem glavom Jakova Mendrile nakon ubačaja iz slobodnog udarca, ali preko gola.

Domaći su nastavili. U 65. minuti Grujević je nečuvan pucao glavom s desetak metara, pored gola, a u 66. se udarac Monjca s dvadesetak metara nakon prodora odbio od bloka suigrača i završio pored gola. U 70. je opet ubačaj Monjca izbijen u korner.

Konačnih 4:0 postavio je Junuzović u 72. minuti, glavom iz kornera u drugi kut, i time stavio točku na i, kako ishodu utakmice, tako i svojoj vrhunskoj izvedbi. U 82. minuti Weitzer je pucao iz slobodnog udarca po sredini gola, a do kraja se rezultat nije mijenjao.',
  '3. NL Zapad',
  'https://wpvussvstbqhyovrojja.supabase.co/storage/v1/object/public/clanci/WhatsApp%20Image%202026-09-04%20at%2021.06.36.jpeg',
  'Fotografija s utakmice Lokomotiva - Crikvenica na Kantridi',
  'Foto: Lokal-Arena',
  false,
  '2026-09-04T22:00:00+02:00'
);


-- ---------------------------------------------------------------------
-- PROVJERA
-- ---------------------------------------------------------------------
select slug, naslov, natjecanje, objavljen, objavljeno_u, slika_url
from public.clanci
where slug = 'osvrt-lokomotiva-crikvenica-2-kolo-2627';


-- =====================================================================
-- OPIS FOTOGRAFIJE
-- =====================================================================
-- Adresa slike vec je upisana, Andrej ju je ucitao u Storage 04.09.2026.
--
-- Opis (slika_opis) je zasad opcenit, jer se slika iz ovog okruzenja ne
-- moze otvoriti. Sluzi citacima ekrana i dijeljenju na drustvenim
-- mrezama, pa ga zamijeni onim sto se na slici stvarno vidi:
--
-- update public.clanci
-- set slika_opis   = 'OPIS ONOGA STO JE NA SLICI',
--     slika_potpis = 'Foto: Lokal-Arena'
-- where slug = 'osvrt-lokomotiva-crikvenica-2-kolo-2627';


-- =====================================================================
-- OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'osvrt-lokomotiva-crikvenica-2-kolo-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'osvrt-lokomotiva-crikvenica-2-kolo-2627';

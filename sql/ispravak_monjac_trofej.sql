-- =====================================================================
-- ISPRAVAK: MONJCU JE URUCEN TROFEJ ZA NAJBOLJEG STRIJELCA
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Ponovno pokretanje ne skodi: ako je ispravak vec prosao, druga
--   naredba nema sto zamijeniti i tekst ostaje isti.
--
-- ZASTO POSTOJI
--   U osvrtu s utakmice Lokomotiva - Crikvenica 4:0 (2. kolo 3. NL
--   Zapad, 04.09.2026.) pisalo je da je Mateu Monjcu prije pocetka
--   urucen trofej za najboljeg asistenta prosle sezone. Andrej je
--   javio da je rijec o trofeju za najboljeg STRIJELCA.
--
--   Tekst stoji na dva mjesta, uz zapisnik utakmice i kao clanak u
--   novostima, pa se ispravlja na oba. Zato su ovdje dvije naredbe.
--
--   Mijenja se samo taj dio recenice, ne prepisuje se cijeli tekst, pa
--   ostale dorade ostaju netaknute.
-- =====================================================================


-- ---------- 1. OSVRT UZ ZAPISNIK UTAKMICE ----------
update public.utakmice
   set tekst_clanka = replace(tekst_clanka,
         'trofej za najboljeg asistenta prošle sezone',
         'trofej za najboljeg strijelca prošle sezone')
 where sezona = '2026/27'
   and natjecanje = '3. NL Zapad'
   and kolo = 2
   and domacin = 'NK Lokomotiva (R)'
   and gost = 'NK Crikvenica'
returning domacin, gost, left(tekst_clanka, 180) as pocetak;


-- ---------- 2. CLANAK U NOVOSTIMA ----------
update public.clanci
   set tekst = replace(tekst,
         'trofej za najboljeg asistenta prošle sezone',
         'trofej za najboljeg strijelca prošle sezone')
 where slug = 'osvrt-lokomotiva-crikvenica-2-kolo-2627'
returning slug, left(tekst, 180) as pocetak;


-- ---------- PROVJERA ----------
-- Ocekivano: nigdje vise ne pise "najboljeg asistenta".
select 'utakmica' as gdje,
       tekst_clanka like '%najboljeg strijelca%' as ima_strijelca,
       tekst_clanka like '%najboljeg asistenta%' as ima_jos_asistenta
from public.utakmice
where sezona = '2026/27' and natjecanje = '3. NL Zapad' and kolo = 2
  and domacin = 'NK Lokomotiva (R)' and gost = 'NK Crikvenica'
union all
select 'clanak',
       tekst like '%najboljeg strijelca%',
       tekst like '%najboljeg asistenta%'
from public.clanci
where slug = 'osvrt-lokomotiva-crikvenica-2-kolo-2627';

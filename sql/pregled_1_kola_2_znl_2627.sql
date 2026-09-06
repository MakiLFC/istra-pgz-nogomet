-- =====================================================================
-- ČLANAK: PREGLED 1. KOLA 2. ŽNL PGŽ 2026/27
-- Odigrano 06.09.2026. Snježnik - Mrkopalj je odgođen.
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
--   Sve je iz public.pregled_kola('2026/27','2. ŽNL PGŽ',1), dakle iz
--   zapisnika u bazi. U ovom clanku nema nicega izvan baze: nema ocjena
--   igre ni opisa tijeka utakmica, jer Andrej na tim susretima nije bio.
--
-- KOLO NIJE ZAVRSENO
--   Dvije od tri utakmice su odigrane. Snjeznik - Mrkopalj je odgodjen,
--   a HNS novi termin jos nije objavio. U bazi zato stoji stari termin,
--   06.09.2026. u 17:00, jer prazan termin s HNS-a ne brise onaj koji
--   imamo. Dnevna "Provjera termina" uhvatit ce novi cim se pojavi.
--
-- BEZ FOTOGRAFIJE
--   Clanak nema sliku, pa se na kartici prikazuje zaglavlje 2. ŽNL PGŽ,
--   a pri dijeljenju zajednicka slika Lokal-Arene.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'pregled-1-kola-2-znl-pgz-2627',
  'GOMIRJE JEDINI POBJEDNIK U UVODNOM KOLU',
  'Od tri utakmice prvog kola odigrane su dvije, a Snježnik i Mrkopalj svoj su susret odgodili.',
'Prvo kolo 2. ŽNL PGŽ otvorilo je sezonu s dvije odigrane utakmice. Susret Snježnika i Mrkoplja je odgođen, a novi termin još nije objavljen.

Gomirje - Polet (Sk) 2:0. Jedina pobjeda kola i jedina utakmica s pogocima. Ivan Petrović doveo je domaće u vodstvo u 16. minuti, a Milan Lončar potvrdio je pobjedu u 61. Uz 50 gledatelja bila je to i najposjećenija utakmica kola.

Željezničar (M) - Goranka 0:0. Podjela bodova u Moravicama, bez pogodaka.

STRIJELCI

Ivan Petrović i Milan Lončar, obojica iz Gomirja, jedini su strijelci kola, s po jednim pogotkom.

LJESTVICA

Vodi Gomirje s tri boda, slijede Goranka i Željezničar s po bodom, a Polet je bez osvojenog boda. Snježnik i Mrkopalj još nemaju odigranu utakmicu.

Ljestvica ostaje nepotpuna dok se odgođeni susret ne odigra. Službena ljestvica je na stranici lige.

ZA SLJEDEĆE KOLO

Nema isključenih igrača ni igrača na pragu žutih kartona.

Drugo kolo na rasporedu je u nedjelju 13. rujna u 16:30.',
  '2. ŽNL PGŽ',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-1-kola-2-znl-pgz-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'pregled-1-kola-2-znl-pgz-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-1-kola-2-znl-pgz-2627';

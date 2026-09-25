-- =====================================================================
-- ČLANAK: NAJAVA 4. KOLA 2. ŽNL PGŽ 2026/27
-- Igra se u nedjelju 27.09.2026., sve tri utakmice u 16 sati.
-- =====================================================================
-- KAKO SE KORISTI: dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   KORAK 2 (objava) je zakomentiran na dnu.
--
--   Upis se smije ponoviti: ako clanak vec postoji, prepisu se samo
--   naslov, sazetak i tekst, a objavljen i datum ostaju kakvi jesu.
--
-- SLUG MORA POCETI S "najava-"
--   Traka "Ovaj vikend" na naslovnici po tome prepoznaje najavu tog kola.
--
-- ODAKLE STO
--   Stanje, strijelci i iskljucenja iz
--   public.pregled_kola('2026/27','2. ŽNL PGŽ',3). Termini i stadioni iz
--   rasporeda 4. kola u bazi. Rezultati prva tri kola iz ispisa
--   scrapera; bodovi i gol razlika slazu se s ljestvicom u ispisu, a
--   ucinak kod kuce i u gostima izracunat je iz istih rezultata.
--   ANDREJEVO: da je Snjeznik - Mrkopalj iz 1. kola odgoden (25.09.;
--   termin je tada rucno obrisan iz baze, jer ga je HNS maknuo).
--
-- PADEŽ
--   Mrkopalj, genitiv Mrkoplja (Andrejeva ispravka).
--
-- STIL
--   Najava gleda unaprijed, kao i ona za 1. ZNL istog kola; vidi
--   CLAUDE.md, "Najava gleda UNAPRIJED".
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-4-kola-2-znl-pgz-2627',
  'NAJAVA 4. KOLA: PRVI PROTIV DRUGOG U GOMIRJU',
  'Gomirje i Mrkopalj jedini su bez izgubljenog boda, a u nedjelju se sastaju u Gomirju. Polet i Goranka igraju za treće mjesto, a na dnu se Željezničar i Snježnik bore za prvu pobjedu.',
'Četvrto kolo 2. ŽNL PGŽ igra se u nedjelju 27. rujna, sve tri utakmice u 16 sati.

Gomirje - Mrkopalj, na Kraj Dobre u Gomirju. Susret dviju jedinih momčadi bez izgubljenog boda. Gomirje vodi s tri boda prednosti, ali Mrkopalj ima utakmicu manje, jer je njegov susret prvog kola u Gerovu odgođen. Pobjeda Gomirja značila bi bijeg na šest bodova, a pobjeda Mrkoplja izjednačenje na vrhu, uz utakmicu u zaostatku. Kod kuće je Gomirje ove sezone dobilo obje utakmice, uz gol razliku 5:1, a Antonio Fenov je nakon hat-tricka u Gerovu s četiri pogotka drugi na listi strijelaca. Mrkopalj je jedinu gostujuću utakmicu dobio, 3:1 u Skradu, a Aleksandar Ilić i Antonio Krištof imaju po tri gola.

Polet (Skrad) - Goranka, u Skradskoj Dragi. Goranka je bod ispred Poleta, pa pobjednik ovog susreta preuzima treće mjesto. Polet dolazi s prvom pobjedom, izborenom u petoj minuti nadoknade u Moravicama, ali kod kuće ove sezone još nije slavio, a u nedjelju ostaje i bez isključenog Tomislava Purića. Goranka ima najopasnijeg strijelca lige, Šimu Božića s pet pogodaka, a kod kuće je Snježniku zabila sedam golova. U gostima joj ide slabije: iz dvije utakmice ima jedan bod.

Željezničar (Moravice) - Snježnik, na Kraj Dobre u Moravicama. Dvije momčadi s dna ljestvice, obje još bez pobjede, pa će jedna u nedjelju možda doći do prve. Željezničar ima jedan bod, osvojen upravo kod kuće u prvom kolu protiv Goranke, a Snježnik nijedan, uz utakmicu manje. Snježnik je u Gerovu protiv Gomirja zabio prva dva gola u sezoni, preko Matije Bunete i Arijana Jašarevića.

LJESTVICA

Gomirje vodi s devet bodova, ispred Mrkoplja sa šest, Goranke s četiri i Poleta s tri. Željezničar ima jedan bod, a Snježnik nijedan. Mrkopalj i Snježnik odigrali su utakmicu manje, jer je njihov susret prvog kola odgođen.

KAZNE

Četvrto kolo propušta Tomislav Purić (Polet) zbog crvenog kartona.',
  '2. ŽNL PGŽ',
  false,
  now()
)
on conflict (slug) do update
  set naslov  = excluded.naslov,
      sazetak = excluded.sazetak,
      tekst   = excluded.tekst;


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-4-kola-2-znl-pgz-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-4-kola-2-znl-pgz-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-4-kola-2-znl-pgz-2627';

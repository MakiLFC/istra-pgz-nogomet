-- =====================================================================
-- ČLANAK: NAJAVA 5. KOLA 2. ŽNL PGŽ 2026/27
-- Igra se u nedjelju 04.10.2026., sve tri utakmice u 16:00.
-- =====================================================================
-- KAKO SE KORISTI: Supabase -> SQL Editor -> zalijepi -> Run.
--   Upis se smije ponoviti: prepisu se naslov, sazetak, tekst i slika.
--   Objava je zakomentirana na dnu.
--
-- ODAKLE STO
--   Raspored, stadioni, svi rezultati sezone, ljestvica, strijelci i
--   kartoni: posao "Ispis kola" 02.10.2026. u 19:47 po nasem (2. ZNL,
--   5. kolo). Ucinak kod kuce i u gostima izracunat iz tih rezultata.
--   Iskljucenje Luke Mrsica: pregled 4. kola.
--
-- SLIKA
--   najava-redovi-2-znl-pgz-kolo-5.png slozio je drugi agent, produzena
--   na 1200x800 (-cijela), da je clanak u 3:2 ne odreze sa strana.
-- =====================================================================

insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, slika_url, slika_opis, objavljen, objavljeno_u)
values (
  'najava-5-kola-2-znl-pgz-2627',
  'NAJAVA 5. KOLA: GORANKA U RAVNOJ GORI DOČEKUJE NEPORAŽENO GOMIRJE',
  'Drugoplasirana Goranka dočekuje Gomirje, jedino bez izgubljenog boda, koje pobjedom može pobjeći na osam bodova. Mrkopalj bez isključenog Mršića dočekuje Željezničar, a Snježnik i dalje traži prve bodove.',
'Peto kolo 2. ŽNL PGŽ igra se u nedjelju 4. listopada, sve tri utakmice u 16 sati. Snježnik i Mrkopalj i dalje imaju utakmicu manje, jer njihov odgođeni susret iz prvog kola u rasporedu još nema termin.

Goranka - Gomirje, u Ravnoj Gori. Drugi protiv prvog, s pet bodova razlike. Gomirje je jedino bez izgubljenog boda, četiri pobjede iz četiri utakmice, i pobjedom bi Goranci pobjeglo na osam bodova. Pobjeda Goranke smanjila bi razliku na dva boda. Obje momčadi imaju istu gol razliku, 13:4. Goranka je kod kuće ove sezone igrala samo jednom i Snježniku zabila sedam golova, a u gostima je prošlog vikenda preokretom dobila Polet 4:1. Šime Božić s pet pogodaka vodi listu strijelaca lige. Gomirje je dosad samo jednom igralo u gostima, 6:2 u Gerovu. Antonio Fenov ima četiri pogotka, a Đorđe Mrvoš zabio je oba gola u pobjedi nad Mrkopljem.

Mrkopalj - Željezničar (M), Pod Čelimbašom. Mrkopalj je treći sa šest bodova, uz utakmicu manje, i pobjedom bi stigao na devet. Jedinu domaću utakmicu ove sezone dobio je, 3:2 protiv Goranke. U nedjelju ostaje bez Luke Mršića, isključenog u Gomirju. Aleksandar Ilić i Antonio Krištof imaju po tri gola. Željezničar dolazi nakon prve pobjede u sezoni, 7:0 protiv Snježnika, i ima četiri boda, pa bi pobjedom preskočio domaćina. Jedinu gostujuću utakmicu izgubio je u Gomirju 1:3. Dalibor Krebelj ima tri gola.

Snježnik - Polet (Sk), na Ponikvama u Gerovu. Snježnik je jedini bez boda: tri poraza, uz dva dana i dvadeset primljenih golova. Kod kuće je igrao jednom, 2:6 protiv Gomirja. Polet je s tri boda peti i jedinu pobjedu ove sezone upisao je upravo u gostima, 3:2 u Moravicama, golom u petoj minuti nadoknade. Kod kuće je izgubio obje utakmice. David Ožbolt ima tri gola.

LJESTVICA

Gomirje vodi s dvanaest bodova, ispred Goranke sa sedam i Mrkoplja sa šest. Željezničar ima četiri boda, Polet tri, a Snježnik nijedan. Mrkopalj i Snježnik imaju utakmicu manje.

KAZNE

Peto kolo propušta Luka Mršić (Mrkopalj) zbog crvenog kartona.',
  '2. ŽNL PGŽ',
  '/slike/najave/najava-redovi-2-znl-pgz-kolo-5-cijela.png',
  'Raspored 5. kola 2. ŽNL PGŽ, nedjelja 4. listopada 2026.',
  false,
  now()
)
on conflict (slug) do update
  set naslov     = excluded.naslov,
      sazetak    = excluded.sazetak,
      tekst      = excluded.tekst,
      slika_url  = excluded.slika_url,
      slika_opis = excluded.slika_opis;


-- OBJAVA
-- update public.clanci set objavljen = true
-- where slug = 'najava-5-kola-2-znl-pgz-2627'
-- returning slug, naslov, objavljen;

-- =====================================================================
-- ČLANAK: NAJAVA 5. KOLA 3. NL ZAPAD 2026/27
-- Igra se u subotu 19.09.2026.
-- =====================================================================
-- KAKO SE KORISTI: dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   KORAK 2 (objava) je zakomentiran na dnu.
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- SLUG MORA POCETI S "najava-"
--   Traka "Ovaj vikend" na naslovnici po tome prepoznaje najavu tog kola
--   i pokazuje poveznicu "Najava". Vidi components/OvajVikend.tsx.
--
-- ODAKLE STO
--   Termini, forma, ljestvica i medjusobni ogledi iz prosle sezone
--   dolaze iz public.najava_kola('2026/27','3. NL Zapad',5).
--   Strijelci po klubovima, kazne i pomaci iz
--   public.pregled_kola('2026/27','3. NL Zapad',4), jer najava po klubu
--   vraca samo jednog strijelca, a polje suspendirani joj je uvijek
--   prazno.
--   ANDREJEVO, cega u bazi nema: da je Jakob Sprem-Veljavecki stoper,
--   i da Naprijed s klupe privremeno vodi Andro Svrljuga.
--
-- ZUTI KARTONI
--   Navodi se SAMO tko ima tri, bez ijedne rijeci o tome sto slijedi.
--   Prag od cetiri je zadana vrijednost u najava_kola(), a ne podatak iz
--   propozicija. Kad se prag provjeri, smije se pisati odredjenije.
--
-- LJESTVICA
--   sluzbena_tablica_odstupa je true: Crikvenica ima kaznene bodove, pa
--   se navode samo vrh i uputa na sluzbenu ljestvicu na stranici lige.
--
-- ODGODJENA UTAKMICA
--   Lokomotiva (R) - Banjole premjestena je na 05.12.2026. u 13:00, pa
--   se u ovom kolu igra sedam utakmica.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-5-kola-3-nl-zapad-2627',
  'KRALJEVICI SE OTVARA PRILIKA DA PRIVREMENO ZASJEDNE NA VRH',
  'Utakmica Lokomotiva - Banjole premještena je za 5. prosinca, pa vodeća momčad ovaj vikend odmara. Kraljevica pobjedom u Crikvenici ide na prvo mjesto, a Pomorac u Brnasima brani niz od dvije pobjede.',
'Peto kolo 3. NL Zapad igra se u subotu 19. rujna. Prvi počinje Naprijed (H) - Pazinka-Pazin u 15 sati na Lonji u Hreljinu, a ostalih šest utakmica na rasporedu je u 17 sati.

Crikvenica - Kraljevica. Najvažnija utakmica kola. Kraljevica je jedina uz Lokomotivu bez poraza u četiri kola i pobjedom na Gradskom stadionu prvi put ove sezone preuzima vrh. U utorak je na Minti remizirala s Bujama 2:2, uz Bosančićev pogodak u 87. minuti. Crikvenica dolazi u kolo nakon pobjede 2:0 u Labinu, prve ove sezone izvan Crikvenice, a pogotke su dali Petar Vidović i Damjan Mendrila. Prošle sezone ovaj par nije dao pobjednika: 2:2 u Crikvenici i 0:0 u Kraljevici. Kod domaćih je na tri žuta kartona Ivan Lukarić, kod gostiju Paulo Kocijan.

Halubjan - Pomorac. Pomorac je treći s devet bodova i dvije pobjede zaredom, a Jakob Šprem-Veljavečki sa šest pogodaka vodi listu strijelaca lige, uz dva zabijena Omišlju u posljednjem kolu. Riječ je o stoperu, pa ta brojka zvuči nestvarno. Halubjan je u Senju priredio najveće iznenađenje četvrtog kola, pobjedu 2:1 protiv Nehaja s dva gola Antonija Dedića, ali u subotu igra bez Simona Simonaja, isključenog nakon drugog žutog kartona. Prošle sezone Pomorac je kod kuće slavio 3:1, a u Brnasima je bilo 0:0.

Buje - Nehaj. Nehaj je peti sa šest bodova, no niz mu je stao: nakon dvije pobjede slijedila su dva poraza, posljednji kod kuće od Halubjana. U Bujama će biti bez Luke Lopca, isključenog u sudačkoj nadoknadi te utakmice, a Matej Prizmić je na tri žuta kartona. Buje dolaze s bodom iz Kraljevice i s Damirom Bartulovićem kao najboljim strijelcem. Prošle sezone Buje su dobile oba susreta, 2:1 kod kuće i 1:0 u Senju.

Naprijed (H) - Pazinka-Pazin. Pazinka je napravila najveći skok četvrtog kola, šest mjesta, nakon 3:0 protiv Jadrana iz Poreča pred 500 gledatelja, najvećom posjećenošću kola. S tri utakmice bez poraza sada je četvrta. Naprijed je u Rovinju upisao prve bodove u sezoni, pobjedom 3:1 u kojoj je Robert Jandrek zabio dva gola. Ostaje za vidjeti hoće li ih i dalje uspješno voditi s klupe privremeni spasitelj Andro Švrljuga ili će osvanuti novi trener. Prošle sezone Pazinka je bila bolja u oba ogleda.

Jadran-Poreč - Vinodol. Jadran je nakon dvije uzastopne pobjede izgubio u Pazinu 0:3 i pao na osmo mjesto, a Ilija Batrićević ima tri pogotka. Vinodol je posljednji, s jednim bodom i četiri utakmice bez pobjede, a Veli Jože je teška utakmica za vađenje s fenjera nogometašima iz Novog Vinodolskog. Prošle sezone oba su susreta završila bez pobjednika, 0:0 i 1:1. Na tri žuta kartona su Vedran Radman kod domaćih i Marcelo Suden kod gostiju.

Krk - Rudar (L). Krk je u utorak u Banjolama poveo 2:1 golovima Marka Jelića i Emanuela Mrakovčića u razmaku od dvije minute, ali je Paolo Matteoni u 82. postavio 2:2. Rudar je nakon dvije pobjede izgubio kod kuće od Crikvenice i sada je sedmi, bod ispred Krka. Prošle sezone na Krku je bilo 2:2, a u Labinu je Krk slavio 3:1.

OŠK Omišalj - Rovinj. Omišalj je šesti sa šest bodova, nakon poraza 1:3 u Kostreni, gdje je David Rožajac zabio već u 5. minuti. Rovinj je u nizu od tri poraza i sada je četrnaesti, a Masimo Terlević mu je s tri pogotka najbolji strijelac. Kod gostiju je Matej Vladišković na tri žuta kartona.

LJESTVICA

Lokomotiva vodi s dvanaest bodova i gol razlikom plus dvanaest, ispred Kraljevice s deset i Pomorca s devet. Službena ljestvica je na stranici lige, jer ona uključuje i kaznene bodove Crikvenice.

KAZNE

Peto kolo propuštaju Simon Simonaj (Halubjan) nakon drugog žutog kartona i Luka Lopac (Nehaj) nakon crvenog. Osmorica su na tri žuta kartona: Filip Rosić (Banjole), Ivan Lukarić (Crikvenica), Vedran Radman (Jadran-Poreč), Paulo Kocijan (Kraljevica), Tin Jurica (Krk), Matej Prizmić (Nehaj), Matej Vladišković (Rovinj) i Marcelo Suden (Vinodol).',
  '3. NL Zapad',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-5-kola-3-nl-zapad-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-5-kola-3-nl-zapad-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-5-kola-3-nl-zapad-2627';

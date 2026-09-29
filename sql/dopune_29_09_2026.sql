-- =====================================================================
-- DOPUNE 29.09.2026.: Liznjan - Klana 1:0, Vinodol - Banjole 2:2, Rab - Krk 1:3
-- =====================================================================
-- Tri objavljena clanka dopunjuju se utakmicama odigranim u utorak.
-- Mijenjaju se samo pojedine recenice (replace), ne cijeli tekst, da se
-- ne prepise nista sto je mozda ispravljeno izravno u bazi.
-- Izvori: zapisnici sa Semafora (posao "Ispis kola", 29.09. u 19:13)
-- za prvenstvene utakmice; za kup slika ekrana sa Semafora koju je
-- Andrej poslao 29.09. (kup nije u scraperu).
-- Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run. Na kraju
-- ispis PROVJERA mora u svakom stupcu pokazati true.
-- =====================================================================

-- pregled-4-kola-4-nl-ns-rijeka-2627
update public.clanci
set tekst = replace(replace(replace(replace(replace(tekst,
    'igralo se u subotu 26. rujna, ali još nije završeno: Ližnjan - Klana na rasporedu je u utorak 29. rujna u 17 sati. Slobodan je bio Borac (Bakar). U pet odigranih utakmica palo je 15 pogodaka, tri po susretu, a remija nije bilo. Domaćini su slavili tri puta, gosti dva.',
    'igralo se u subotu 26. rujna, a zaključeno je u utorak 29. rujna susretom Ližnjana i Klane. Slobodan je bio Borac (Bakar). U šest utakmica palo je 16 pogodaka, a remija nije bilo. Domaćini su slavili četiri puta, gosti dva.'),
    'Medulin je ostao na jednom bodu i na dnu ljestvice.',
    'Medulin je ostao na jednom bodu i na dnu ljestvice.

Ližnjan - Klana 1:0. Kolo je zaključeno u utorak na Šaraji, pred 80 gledatelja. Jedini gol zabio je kapetan Ližnjana Dino Balde u 80. minuti. Ližnjan se time s devet bodova popeo na drugo mjesto, a Klana je ostala na tri.'),
    'Borac (Bakar) ima devet bodova iz tri utakmice, a slijede Ližnjan, Otočac i Žminj s po šest.',
    'Po devet bodova imaju Ližnjan, drugi po gol razlici, i Borac (Bakar), koji je odigrao utakmicu manje. Slijede Otočac i Žminj s po šest.'),
    'Najviše su izgubili Štinjan i Mladost Fažana, po tri mjesta.',
    'Najviše je izgubila Mladost Fažana, tri mjesta.'),
    'Prije petog kola u utorak se igra Ližnjan - Klana, posljednja utakmica ovog kola. Raspored je na stranici lige.',
    'Raspored petog kola je na stranici lige.'),
    sazetak = replace(sazetak, 'a Žminj je slavio u Štinjanu. Ližnjan - Klana igra se u utorak.', 'a Žminj je slavio u Štinjanu. Ližnjan je u utorak svladao Klanu i popeo se na drugo mjesto.')
where slug = 'pregled-4-kola-4-nl-ns-rijeka-2627';

-- pregled-6-kola-3-nl-zapad-2627
update public.clanci
set tekst = replace(replace(replace(tekst,
    'odigrano je u subotu 26. rujna, a nije još završeno: Vinodol i Banjole sastaju se u utorak 29. rujna. U sedam odigranih utakmica palo je dvadeset golova, od toga devet u jednoj.',
    'odigrano je u subotu 26. rujna, a zaključeno u utorak 29. rujna susretom Vinodola i Banjola. U osam utakmica palo je 24 gola, od toga devet u jednoj.'),
    'Za obje momčadi to je prvi remi u sezoni.',
    'Za obje momčadi to je prvi remi u sezoni.

Vinodol - Banjole 2:2. Kolo je zaključeno u utorak na Bahalinu, pred 70 gledatelja, a sva četiri gola zabila su dvojica igrača, po jedan sa svake strane. Badara Seck doveo je Vinodol u vodstvo u 15. minuti, Ivan Giljanović izjednačio je u 56., Seck je tri minute kasnije ponovno doveo domaćine u vodstvo, a Giljanović je u 76. minuti postavio konačnih 2:2. Sudac je podijelio osam žutih kartona, po četiri svakoj momčadi.'),
    'Znamenačekov hat-trick bio je jedini u kolu.',
    'Znamenačekov hat-trick bio je jedini u kolu. Badara Seck iz Vinodola s dva gola protiv Banjola stigao je na četiri.')
where slug = 'pregled-6-kola-3-nl-zapad-2627';

-- kup-1-16-finala-2627
update public.clanci
set tekst = replace(tekst,
    'Ostala je još jedna utakmica. NK Rab i NK Krk sastaju se 29. rujna u 16:30 na Blatu, Rab iz 1. ŽNL PGŽ, a Krk iz 3. NL Zapad, pa je i to susret dvaju rangova.',
    'NK Rab - NK Krk 1:3. Posljednja utakmica 1/16 finala odigrana je 29. rujna na Blatu, pred 200 gledatelja, a Krk iz 3. NL Zapad svladao je Rab iz 1. ŽNL PGŽ preokretom. Marin Macolić doveo je domaćine u vodstvo u 16. minuti, Jakov Delibegović izjednačio je u 44., Roko Begonja u 49. minuti doveo Krk u vodstvo, a Marko Jelić u 90. postavio konačnih 1:3. Begonja i Jelić zabili su po dva gola i tri dana ranije, u pobjedi Krka 5:4 na Minti.')
where slug = 'kup-1-16-finala-2627';

-- PROVJERA: svaki stupac mora biti true
select
  (select position('vladao Klanu i popeo se na drugo mjesto.' in sazetak) > 0 from public.clanci where slug = 'pregled-4-kola-4-nl-ns-rijeka-2627') as izmjena_1,
  (select position('aćini su slavili četiri puta, gosti dva.' in tekst) > 0 from public.clanci where slug = 'pregled-4-kola-4-nl-ns-rijeka-2627') as izmjena_2,
  (select position(' drugo mjesto, a Klana je ostala na tri.' in tekst) > 0 from public.clanci where slug = 'pregled-4-kola-4-nl-ns-rijeka-2627') as izmjena_3,
  (select position('manje. Slijede Otočac i Žminj s po šest.' in tekst) > 0 from public.clanci where slug = 'pregled-4-kola-4-nl-ns-rijeka-2627') as izmjena_4,
  (select position(' je izgubila Mladost Fažana, tri mjesta.' in tekst) > 0 from public.clanci where slug = 'pregled-4-kola-4-nl-ns-rijeka-2627') as izmjena_5,
  (select position('Raspored petog kola je na stranici lige.' in tekst) > 0 from public.clanci where slug = 'pregled-4-kola-4-nl-ns-rijeka-2627') as izmjena_6,
  (select position('palo je 24 gola, od toga devet u jednoj.' in tekst) > 0 from public.clanci where slug = 'pregled-6-kola-3-nl-zapad-2627') as izmjena_7,
  (select position('žutih kartona, po četiri svakoj momčadi.' in tekst) > 0 from public.clanci where slug = 'pregled-6-kola-3-nl-zapad-2627') as izmjena_8,
  (select position('gola protiv Banjola stigao je na četiri.' in tekst) > 0 from public.clanci where slug = 'pregled-6-kola-3-nl-zapad-2627') as izmjena_9,
  (select position('ana ranije, u pobjedi Krka 5:4 na Minti.' in tekst) > 0 from public.clanci where slug = 'kup-1-16-finala-2627') as izmjena_10;

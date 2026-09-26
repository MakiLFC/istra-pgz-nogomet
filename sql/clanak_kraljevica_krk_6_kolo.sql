-- =====================================================================
-- ČLANAK: NK KRALJEVICA - NK KRK 4:5
-- Derbi 6. kola 3. NL Zapad 2026/27, 26.09.2026., Minta, 80 gledatelja.
-- =====================================================================
-- KAKO SE KORISTI: dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   KORAK 2 (objava) je zakomentiran na dnu.
--   Upis se smije ponoviti: prepisu se samo naslov, sazetak i tekst.
--
-- ODAKLE STO
--   Tijek, prilike i opisi su Andrejevi s tribine (bio na utakmici).
--   Strijelci, minute golova, isključenje, izmjene i gledatelji iz
--   zapisnika u bazi (pregled_kola i upit nad postavama, 26.09.).
--   Brojeve iz Andrejevih bilješki prevela je postava: Kraljevica 5 Filip
--   Znamenaček, 6 Borna Znamenaček, 9 Matija Čabrijan, 20 Dominik
--   Paljokaj, 22 Luka Šupraha, 18 Lovro Šupraha, 23 Nino Jovanović;
--   Krk 3 Mathew Peter, 7 Mirko Valenčić, 9 Marko Jelić, 14 Lovre
--   Travica, 18 Luka Kuljiš, 19 Roko Begonja, 37 Tin Jurica.
--   Depeder i Kocijan: iz pregleda 5. kola (isključenje, četvrti žuti).
--
-- MINUTE: iz zapisnika, ne iz Andrejevih bilješki ni iz mobilne
--   aplikacije. Aplikacija je treći Znamenačekov gol pokazivala u 73.,
--   a zapisnik ga ima u 76., tri minute nakon isključenja u 73.
--
-- KAPETAN: zapisnik Znamenačeka vodi kao kapetana cijele utakmice, a
--   Andrej je vidio da je traku u prvom poluvremenu nosio Luka Šupraha,
--   pa ju je Znamenaček preuzeo na poluvremenu. Ostavljena je Andrejeva
--   verzija.
--
-- VRATARI nisu imenovani: upit nije vraćao poziciju, pa se ne zna
--   pouzdano tko je branio.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'kraljevica-krk-6-kolo-3-nl-zapad-2627',
  'DEVET GOLOVA NA MINTI: KRK SLAVIO U SUDAČKOJ NADOKNADI',
  'Kraljevica i Krk odigrali su derbi kola s tri preokreta i devet golova. Hat-trick Filipa Znamenačeka nije bio dovoljan domaćinima, koji su posljednjih dvadesetak minuta igrali s igračem manje, a pobjedu Krku donio je nesretan autogol u sudačkoj nadoknadi.',
'Kraljevica je u derbi šestog kola ušla desetkovana, što se vidjelo već iz početne postave. Uz ostale izostanke, bez Andre Depedera i Paula Kocijana, koji su zbog kartona propuštali ovo kolo, domaćin je na Minti dočekao Krk, a utakmica se pretvorila u jednu od najluđih ove sezone.

Početak je bio isprekidan s obje strane, a prva prava prilika odmah je urodila plodom. U 10. minuti, nakon ubačaja u šesnaesterac, lopta se odbila do Roka Begonje, koji ju je volejem snažno i neobranjivo poslao pod prečku za vodstvo gostiju. Krk je nastavio pritiskati: u 12. minuti Lovre Travica je ušao s lijevog krila prema sredini i pucao izvan šesnaesterca, ali pored gola, a u 15. minuti, opet nakon ubacivanja iz auta, udarac gostiju otišao je iznad vrata. Posebno treba istaknuti Mathewa Petera, koji je dalekim ubacivanjima rukom stalno stvarao probleme Kraljevičinoj obrani, i u kazneni prostor i uzduž linije.

Do 25. minute pokušaji Kraljevice bili su jalovi i bez ikakve opasnosti po gol gostiju. Tada je kapetan Luka Šupraha ostao sam na vrhu šesnaesterca, u dobroj poziciji, ali je prizemno pucao ravno u vratara. U 29. minuti Dominik Paljokaj je nakon naizgled bezopasnog ubačaja, leđima okrenut golu, lijepo zahvatio loptu volejem, koja je prošla blizu suprotne vratnice. Na drugoj strani Travica se u 36. minuti nije snašao nakon dobrog ubačaja i promašio loptu iz dobre prilike u šesnaestercu.

Kraljevica je rasla kako se poluvrijeme bližilo kraju. U 41. minuti, nakon osvojenog skoka, napadački trojac domaćina odigrao je lijepu akciju i doveo Matiju Čabrijana do najbolje prilike prvog dijela, no njegov prizemni udarac s desetak metara, s desne strane kaznenog prostora, prošao je slabo pored gola. Izjednačenje je ipak stiglo u prvoj minuti sudačke nadoknade: nakon savršene duge lopte Filip Znamenaček je mirno primio loptu s desne strane kaznenog prostora i prizemnim udarcem pogodio suprotni kut. Iako je Kraljevica sporo ušla u utakmicu, 1:1 na poluvremenu djelovao je kao pravedan rezultat.

Drugo poluvrijeme počelo je uraganski. Već u 47. minuti Kraljevica je odigrala lijepu kombinaciju po lijevoj strani, ušla u kazneni prostor, a Znamenaček je ponovno snažnim prizemnim udarcem zabio, ovaj put za vodstvo. Na poluvremenu je izašao Luka Šupraha, pa je kapetansku traku preuzeo upravo Znamenaček i odmah pokazao zašto. U 49. minuti uslijedila je ubojita kontra domaćina, ali je Borna Znamenaček s desne strane kaznenog prostora pucao ravno u vratara, a odmah zatim Filip Znamenaček je oduzeo loptu na centru i pokušao iznenaditi vratara Krka dugim udarcem, no on je bio siguran.

Krk je odgovorio. U 51. minuti Mirko Valenčić ostao je nečuvan na jedanaest metara i lopta mu se sretno odbila, ali ju je promašio. U 52. minuti Čabrijan je nakon ubačaja volejem s desetak metara poklopio loptu, no vratar Krka fantastično je obranio i izbacio je u korner. U prvih sedam minuta drugog poluvremena bilo je više prilika nego u cijelom prvom. U 54. minuti Begonja je lijepim samostalnim prodorom ušao s lijeve strane u kazneni prostor i pucao u okvir vrata, ali je vratar Kraljevice lijepo obranio.

U 57. minuti pala je nova izjednačujuća. Nakon duge lopte Krka stoper Kraljevice promašio je loptu glavom, Marko Jelić ju je primio, ostao sam protiv vratara i svladao ga za 2:2.

Kad se činilo da se igra malo smirila, stigao je najljepši pogodak utakmice. U 66. minuti Paljokaj je primio ubačaj s desne strane na vrhu šesnaesterca i bombom pogodio rašlje, potpuno neobranjivo, za 3:2. Radost domaćina nije dugo trajala. Nakon ubačaja Krka sa strane lopta je nespretno udarila obrambenog igrača Kraljevice, po ocjeni suca u ruku, i dosuđen je jedanaesterac. Jelić je u 69. minuti bio miran i poravnao na 3:3.

U 73. minuti Kraljevica je ostala s igračem manje: Lovro Šupraha, već opomenut u 49. minuti, dobio je drugi žuti karton nakon što je prekršajem zaustavio krilnog igrača Krka pri ulasku u šesnaesterac. Domaćin je odgovorio za tri minute. U 76. minuti vratar Krka pogriješio je i slabo izbio loptu po podu, Znamenaček ju je presjekao i mirno zabio za svoj hat-trick i novo vodstvo, 4:3.

Tko je mislio da je to kraj, prevario se. U 78. minuti Mathew Peter precizno je ubacio, a Begonja je glavom mirno zabio za 4:4, svoj drugi pogodak na utakmici. Obje su momčadi imale prilike za pobjedu: u 84. minuti Čabrijan je nakon duge lopte ostao sam u šesnaestercu, ali loptu nije najbolje primio i pucao je slabo, ravno u vratara, a u 88. minuti Begonja je opasno pucao po podu s dvadesetak metara, no vratar Kraljevice mirno je uhvatio.

Završnica je bila kao u filmu. U drugoj minuti sudačke nadoknade Tin Jurica prošao je kroz sredinu i uposlio Luku Kuljiša, čiji je udarac vratar Kraljevice odbio, ali se lopta od Nina Jovanovića nesretno odbila u vlastitu mrežu. Krk je tako slavio 5:4 na Minti, pred 80 gledatelja.',
  '3. NL Zapad',
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
-- where slug = 'kraljevica-krk-6-kolo-3-nl-zapad-2627'
-- returning slug, naslov, objavljen;


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, objavljen, left(tekst, 80) as pocetak
from public.clanci
where slug = 'kraljevica-krk-6-kolo-3-nl-zapad-2627';

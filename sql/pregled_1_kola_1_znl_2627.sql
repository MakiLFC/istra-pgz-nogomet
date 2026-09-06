-- =====================================================================
-- ČLANAK: PREGLED 1. KOLA 1. ŽNL PGŽ 2026/27
-- Odigrano 05. i 06.09.2026., utakmica Omladinac Vrata - Vrbovsko
-- igra se 09.09.2026.
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
--   Rezultati, strijelci, minute, gledatelji, iskljuceni igraci i
--   ljestvica dolaze iz public.pregled_kola('2026/27','1. ŽNL PGŽ',1),
--   dakle iz zapisnika u bazi.
--
--   Sto NIJE iz baze, nego od Andreja (dopuna 06.09.2026.): urucenje
--   trofeja Terzic-Strukan Antoniju Belobrajdicu prije utakmice u Rabu,
--   asistencije Belobrajdica, debitanti Fafandel i Brguljan, promasen
--   kazneni udarac Damira Basica, Ciceranov gol protiv bivse ekipe,
--   Draga bez pricuva, te ocjene igre i mjesta odigravanja. Toga u
--   zapisniku nema.
--
-- KOLO NIJE ZAVRSENO
--   Sest od sedam utakmica je odigrano. To pise i u prvoj recenici
--   teksta i u odjeljku o ljestvici, da citatelj ne pomisli da je
--   ljestvica konacna.
--
-- AUTOGOL U RABU
--   Pogodak Mihaela Radica u 6. minuti je autogol i tako je vec upisan
--   u bazi, oznakom koju je scraper sam prepoznao iz zapisnika. Nista se
--   rucno ne treba upisivati.
--
-- BEZ FOTOGRAFIJE
--   Clanak nema sliku, pa se na kartici prikazuje zaglavlje 1. ŽNL PGŽ,
--   a pri dijeljenju zajednicka slika Lokal-Arene.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'pregled-1-kola-1-znl-pgz-2627',
  'VIDMAROVA "PETARDA" ZA LOVRANOVIH DEVET U UVODNOM KOLU 1. ŽNL PGŽ',
  'Uvodno kolo donijelo je čak 26 pogodaka u šest odigranih utakmica, a od toga jedanaest ih je palo u Lokvama.',
'Kolo još nije završeno: Omladinac Vrata i Vrbovsko svoju utakmicu igraju u srijedu 9. rujna u 17:30 na Gmajni. Pa krenimo s pregledom.

Risnjak - Lovran 2:9. Utakmica kola po svemu, i fantastična predstava igrača kola, Patrika Vidmara. Lovranski napadač zabio je čak pet golova, u 3., 9., 17., 32. i 47. minuti. David Radan dodao je dva, u 13. i 58., a po jednom su pogodili Dominik Mohorovičić u 34. i Tin Sanković u 66. minuti. Za domaće su zabili Dino Magaš na isteku prvog poluvremena i Matija Turk u 65. minuti. Novopromovirana momčad jednostavno nije imala šanse protiv raspoloženih lovranaca predvođenih Vidmarom.

Rab - Vihor (B) 4:2. Najposjećenija utakmica kola, uz 70 gledatelja na Blatu. Utakmica je otvorena uručenjem trofeja Terzić-Strukan napadaču domaćih, Antoniju Belobrajdiću, kao priznanje za najboljeg strijelca županijskih nogometnih liga PGŽ-a prošle sezone. Hvalevrijedan projekt kao uspomena na nogometaše koji su prerano napustili lokalne terene. Na samoj utakmici gosti su poveli već u 1. minuti pogotkom Mazena Sharbinija, ali su ubrzo sami poništili prednost, i to na način da je u 6. minuti, nakon prekida Raba, Mihael Radić nesretno zabio autogol. Domaćine je zatim u vodstvo doveo Andro Mlacović u 35. minuti, nakon ubačaja Belobrajdića, a u 63. je minuti i sam Antonio Belobrajdić postigao svoj prvi ovosezonski pogodak i nastavio s navikama iz prošle sezone. Roko Ferenčić smanjio je u 79. minuti udarcem s oko 18 metara, a Franko Fafanđel, inače debitant u dresu Raba, u 89. je minuti postavio konačnih 4:2, ponovno nakon asistencije igrača utakmice, Belobrajdića.

Turbina - Zamet 3:0. Iako rezultat izgleda uvjerljivo, utakmica je riješena tek pri kraju susreta. Moreno Maretić doveo je domaće u vodstvo već u 3. minuti, a neizvjesnost je otklonjena tek u posljednjih petnaest minuta, pogocima Mihaela Ažića u 75. i Aleksandra Velkoskog u 88. minuti. Dobro poznata imena u Triblju povela su Turbinu u novu sezonu na kvalitetan način.

Lošinj - Draga 2:0. Na lošinjskom Čikatu domaći su se ponovno pokazali kao izrazito domaćinska ekipa kojoj se teško uzimaju bodovi na otoku. Kevin Kalanj zabio je u 15. minuti za vodstvo domaćina, Adrian Gardijan povećao je vodstvo u 39. minuti, a domaćini su potom prednost mirno čuvali do kraja. Draga je na susret došla bez pričuva, što je zasigurno pridonijelo nešto lošijoj izvedbi.

Rikard Benčić - Mune 2:2. Kao što se i očekivalo, na Omladinskom igralištu subotnji ogled bio je prepun događanja. Jan Ciceran poveo je domaće u 23. minuti golom protiv svoje bivše ekipe, a prekaljeni Karlo Šneler izjednačio je u 32. minuti. U drugom poluvremenu debitant Fran Ivan Brguljan donio je gostima vodstvo u 63. minuti. Mune su si čuvanje prednosti otežale same, jer su od 70. minute igrale s igračem manje, zbog isključenja Alena Smolića. U konačnici je Danijel Lazić u 75. minuti postavio konačnih 2:2. Valja napomenuti kako je za domaćina Damir Bašić promašio i kazneni udarac.

Goranin - Stari grad Rijeka 0:0. Jedina utakmica kola bez pogodaka. Delnice se i ove godine pokazuju kao tvrd orah za svaku gostujuću ekipu. S obzirom na sastave obiju ekipa, za očekivati je bolje rezultate u idućim kolima.

STRIJELCI

Vidmar je s pet pogodaka odmah sam na vrhu ljestvice strijelaca, ispred suigrača Davida Radana koji ih ima dva. Svi ostali strijelci imaju po jedan.

LJESTVICA

Nakon uvodnog kola vodi Lovran s tri boda i gol razlikom plus sedam, ispred Turbine, Lošinja i Raba, koji također imaju po tri boda. Goranin, Mune, Rikard Benčić i Stari grad Rijeka osvojili su po bod.

Ljestvica je zasad nepotpuna, jer Omladinac Vrata i Vrbovsko svoju utakmicu tek igraju. Službena ljestvica je na stranici lige.

ZA SLJEDEĆE KOLO

Mune će drugo kolo igrati bez Alena Smolića, isključenog u Rijeci. Nitko nije na pragu žutih kartona.

Drugo kolo na rasporedu je 12. i 13. rujna.',
  '1. ŽNL PGŽ',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-1-kola-1-znl-pgz-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'pregled-1-kola-1-znl-pgz-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-1-kola-1-znl-pgz-2627';

-- =====================================================================
-- ČLANAK: 1/16 FINALA HRVATSKOG NOGOMETNOG KUPA 26/27
-- Odigrano 22.09.2026., dvije utakmice kasnije.
-- =====================================================================
-- KAKO SE KORISTI: dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   KORAK 2 (objava) je zakomentiran na dnu.
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- BEZ LIGE, NAMJERNO
--   Stupac natjecanje je NULL, po Andrejevoj uputi: clanak ide samo u
--   novosti i na naslovnicu, a ne ni pod jedno natjecanje. Kartica i
--   stranica clanka prazno natjecanje uredno preskacu.
--
-- ODAKLE STO, VAZNO
--   Kup NIJE u scraperu, pa ovih podataka NEMA u bazi. Sve je procitano
--   sa slika ekrana koje je Andrej poslao 23.09.2026., sa stranica
--   utakmica na HNS Semaforu i s preglednog popisa natjecanja
--   (semafor.hns.family/natjecanja/115436767/).
--   Rangove klubova izvan nasih liga dao je Andrej: Orijent i Opatija
--   drugi rang, Grobnican treci. Uz to je rekao da je 3. NL cetvrti rang
--   hrvatskog nogometa, pa su izrazi "treceligas" i "cetvrtoligas" u
--   tekstu namjerno izbjegnuti; pisu se imena liga.
--   Podatak da je Rikard Bencic predao susret Lokomotivi takodjer je
--   Andrejev; na Semaforu uz tu utakmicu stoji samo "- : -".
--
-- PENALI, KAKO SU PROVJERENI
--   Izvodjaci i promasaji procitani su iz ikona na slikama, uvecanjem
--   izrezaka. Zbroj se u obje utakmice slaze s ishodom (4:3 i 4:5), sto
--   je i bila provjera. Pri prvom citanju je kod Pomorca promasaj bio
--   pripisan Sprem-Veljaveckom, a promasio je Matkovic; ispravljeno
--   prije objave.
--
-- DOPUNE NAKON OBJAVE
--   23.09.2026. je odigran Lovran - Opatija 0:7, pa je zadnji odlomak
--   zamijenjen rezultatom s Lokve. Clanak je tada vec bio objavljen, pa
--   se NIJE upisivao ponovno nego je promijenjen jednim update-om s
--   replace() nad starim odlomkom. Tekst gore je konacna verzija.
--   Kad 29.09. bude poznat Rab - Krk, isto se ponavlja nad zadnjim
--   odlomkom.
--   Napomena za ubuduce: duljina teksta u bazi bila je 20 znakova veca
--   od ove datoteke, dakle ono sto je upisano sitno se razlikuje. Zato
--   se prolaz zamjene NE provjerava duljinom nego s
--   position('...' in tekst) > 0, sto je i ovaj put dalo odgovor.
--
-- BUDUCE KOLO
--   Ako se kup bude pratio i dalje, vrijedi razmisliti o dodavanju
--   natjecanja u scraper. Tada se ID NE uzima po nazivu nego se potvrdi
--   popisom klubova, kao i za lige.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'kup-1-16-finala-2627',
  'KUP NE PITA ZA RANG, A DVA PARA ODLUČILI SU PENALI',
  'U 1/16 finala Hrvatskog nogometnog kupa 26/27 sastali su se klubovi iz različitih rangova i bilo je iznenađenja. Halubjan je nakon penala izbacio Pomorac, Rječina je svladala Naprijed, a Vinodol Kraljevicu. Lokomotiva je prošla bez igranja, jer je Rikard Benčić predao susret.',
'Utakmice 1/16 finala Hrvatskog nogometnog kupa 26/27 odigrane su u utorak 22. rujna, gotovo sve u 16:30. Susreti klubova iz različitih rangova dali su i najviše priče, jer su dva kluba iz 3. NL Zapad ispala od nižerazrednih protivnika, a u dvije je utakmice odlučivala bijela točka.

NK Halubjan - NK Pomorac 0:0, penali 4:3. Najveće iznenađenje kola. Oba su kluba iz 3. NL Zapad, ali Pomorac je pri vrhu ljestvice, a Halubjan u donjem dijelu. Devedeset minuta na Brnasima pred 35 gledatelja nije dalo pogodak, pa se odlučivalo s bijele točke. Za domaće su zabili Fran Knežević, Mihovil Jeronim Klapan, Ivan Paurević i Simon Simonaj, a promašio je Mario Jurković. Kod Pomorca su bili precizni Karlo Valjan, Jakob Šprem-Veljavečki i Artem Terletskyi, dok su promašili Marino Matković i Ivan Rupčić. Šprem-Veljavečki je inače prvi strijelac 3. NL Zapad sa šest pogodaka.

NK Cres - NK OŠK Omišalj 4:4, penali 4:5. Utakmica s najviše golova u kolu. Cres je iz 4. NL NS Rijeka, Omišalj iz 3. NL Zapad, a na Dariju se izmjenjivalo vodstvo do samog kraja. Za domaće su zabili Demis Seo Salihović u 3., Sead Slomić u 59. i 75. te Željko Tomić u 66. minuti. Za Omišalj su pogodili Mateo Ostović u 20., Matteo Todorović u 21. te David Rožajac u 38. i 71. Raspucavanje je trajalo sedam serija. Za Cres su zabili Sead Slomić, Željko Tomić, Emir Slomić i Boško Babić, a promašili Patrik Tarabocchia, Demis Seo Salihović i Ivan Francetić. Za Omišalj su bili precizni Mateo Ostović, Luka Mijić, Matteo Todorović, Marko Miculinić i Andrija Belina, dok su promašili David Rožajac i Leo Margan. Susret je pratilo 50 gledatelja.

NK Rječina - NK Naprijed (H) 2:1. Rječina iz 4. NL NS Rijeka izbacila je Naprijed iz Hreljina, klub iz 3. NL Zapad. Gosti su poveli golom Lovre Tomljanovića u 25. minuti, a onda su domaći preokrenuli: Mauro Magaš zabio je u 41., a Jeton Imeraj u 63. minuti. Utakmicu u Dražicama pratilo je 80 gledatelja.

NK Vinodol - NK Kraljevica 1:0. Susret dvaju klubova iz 3. NL Zapad s različitih krajeva ljestvice, Vinodola pri dnu i Kraljevice pri vrhu. Odlučio ga je pogodak Antonija Mazzarollija u 50. minuti, pred stotinu gledatelja na Bahalinu. Vinodolu je to druga pobjeda u nekoliko dana, nakon one u Poreču u petom kolu prvenstva.

NK Borac (Ba) - NK Crikvenica 1:4. Crikvenica je nastavila niz. Nakon pobjeda u Labinu i kod kuće protiv Kraljevice, svladala je na Krasici i Borac iz 4. NL NS Rijeka. Dean Županec zabio je u 27. minuti, Goran Minovski izjednačio u 39., a u nastavku su Damjan Mendrila u 73., Petar Vidović u 84. i Marin Marović u 85. minuti riješili pitanje prolaska.

HNK Goranin - NK Grobničan 1:3. Na Gradskom stadionu u Delnicama Goranin iz 1. ŽNL PGŽ ispao je od Grobničana, kluba trećeg ranga. Gosti su odlučili susret u prvom poluvremenu, golovima Dominika Antunovića u 7., Adriana Glažara u 20. i Dražena Pilčića u 37. minuti. Dominik Brajdić smanjio je u 55.

NK Klana - HNK Orijent 0:4. Najveća razlika u rangu u ovom kolu. Klana je iz 4. NL NS Rijeka, dakle petog ranga, a Orijent iz drugog. Riječani su na Grašćini pred stotinu gledatelja slavili golovima Luke Matića u 15., Davida Ružića u 35., Jakova Bilajca u 77. i Noe Arona Stašića u 82. minuti.

NK Lokomotiva (R) dalje bez borbe. Vodeća momčad 3. NL Zapad prošla je u sljedeće kolo bez odigrane utakmice, jer je Rikard Benčić predao susret zakazan na Belvederu.

HNK Lovran - NK Opatija 0:7. Razlika u rangu pokazala se u punoj mjeri. Opatija iz drugog ranga u srijedu je na Lokvi, pred 40 gledatelja, svladala Lovran iz 1. ŽNL PGŽ. Venis Havolli zabio je u 7., Leon Brlek u 34. i Gabriel Groznica u 43. minuti, a nakon odmora su pogodili Marino Miškulin u 47., Adriano Milanović u 65., Borna Bilobrk u 67. i Duje Ušalj u 70.

Ostala je još jedna utakmica. NK Rab i NK Krk sastaju se 29. rujna u 16:30 na Blatu, Rab iz 1. ŽNL PGŽ, a Krk iz 3. NL Zapad, pa je i to susret dvaju rangova.',
  null,
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'kup-1-16-finala-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'kup-1-16-finala-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'kup-1-16-finala-2627';

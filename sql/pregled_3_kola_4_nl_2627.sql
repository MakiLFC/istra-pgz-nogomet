-- =====================================================================
-- ČLANAK: PREGLED 3. KOLA 4. NL NS RIJEKA 2026/27
-- Odigrano 19.09.2026.
-- =====================================================================
-- KAKO SE KORISTI: dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   KORAK 2 (objava) je zakomentiran na dnu.
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- ODAKLE STO
--   Sve iz public.pregled_kola('2026/27','4. NL NS Rijeka',3), dakle iz
--   zapisnika u bazi: rezultati, strijelci, minute, gledatelji, crveni
--   kartoni i pomaci na ljestvici. Nema opisa igre ni ocjena.
--   Iznimka je derbi na Krasici, na koji se tekst samo poziva, jer o
--   njemu postoji poseban clanak pisan po Andrejevim biljeskama.
--
-- PROVJERENO PRIJE PISANJA
--   Zbroj strijelaca po stranama slaze se s rezultatom na svih sest
--   utakmica. Autogol Ivana Golica na Krasici HNS je oznacio sam i
--   pripisao ga Liznjanu.
--   Osamnaest golova u sest utakmica, cetiri pobjede domacina, jedna
--   gostujuca i jedan remi.
--
-- SLOBODAN KLUB
--   Liga ima trinaest klubova, pa svako kolo jedan ne igra. U trecem
--   kolu slobodna je bila Mladost Fazana i to u tekstu stoji izrijekom.
--
-- LJESTVICA
--   sluzbena_tablica_odstupa je true, pa se navode vrh i pomaci, uz
--   uputu na sluzbenu ljestvicu na stranici lige.
--
-- IME KLUBA
--   U bazi je "NK Borac (Ba)", u tekstu Borac (Bakar), po Andrejevoj
--   uputi od 17.09.2026.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'pregled-3-kola-4-nl-ns-rijeka-2627',
  'KLANA I ŽMINJ DO PRVIH BODOVA, CRES I BORAC NA VRHU',
  'U trećem kolu palo je osamnaest golova, a domaćini su slavili četiri puta. Derbi na Krasici pripao je Borcu 3:2, dok su Klana i Žminj upisali prve bodove u sezoni.',
'Treće kolo 4. NL NS Rijeka odigrano je u subotu 19. rujna i pripalo je domaćinima, koji su slavili u četiri od šest utakmica. Mreže su se zatresle osamnaest puta, u prosjeku tri puta po susretu. Slobodna je bila Mladost Fažana.

Borac (Bakar) - Ližnjan 3:2. Derbi kola i najviše golova u kolu. Filip Jagić doveo je domaće u vodstvo u 27. minuti, a Ližnjan je izjednačio autogolom Ivana Golića u prvoj minuti sudačke nadoknade prvog poluvremena. Josip Tkalčević zabio je u 63., Ivan Ferinac u 88., a Luka Pavić je u četvrtoj minuti nadoknade udarcem s 25 metara postavio konačnih 3:2. Detaljan izvještaj s Krasice je u posebnom članku.

Otočac - Štinjan 3:1. Pred sto gledatelja, najviše u kolu, Otočac je upisao drugu pobjedu iz dvije odigrane utakmice. Ante Majetić zabio je u 20. minuti, a u 48. su pogodili Alen Vuković za domaće i Antonio Gračić za goste. Antonijo Vujičić potvrdio je pobjedu u 76. i sa četiri pogotka stigao na vrh liste strijelaca lige.

Klana - Funtana 3:0. Klana je do prvih bodova došla najuvjerljivijom pobjedom kola. Tymur Merezhko zabio je u 65. i 81. minuti, a Ivan Laginja u 88. Tim je skokom Klana napravila najveći pomak u kolu, četiri mjesta, dok je Funtana ostala jedina bez osvojenog boda.

Medulin 1921 - Cres 1:2. Jedina gostujuća pobjeda kola. Emir Slomić pogodio je već u 7. minuti, Boško Babić povisio u 35., a Luka Pamić smanjio minutu poslije. Babić je s četiri gola izjednačen na vrhu sa Vujičićem, a Cres je trećom pobjedom preuzeo prvo mjesto.

Žminj - Smoljanci Sloboda 1:0. Prvi bodovi i prvi pogodak Žminja u sezoni. Marko Lepinjica zabio je u 51. minuti, a susret je završio s dva isključenja u 90. minuti, oba na strani gostiju: Antonio Ivančić i Sanjin Puh.

Umag-CC Umago - Rječina 1:1. Jedini remi kola. Jamu Akou Arum Iluya zabio je već u 2. minuti, a Ivan Fumić izjednačio u 51.

LJESTVICA

Na vrhu su Cres i Borac, oboje s devet bodova, a razlikuje ih gol razlika, plus šest prema plus pet. Slijede Ližnjan i Otočac sa šest. Bez poraza su samo Cres i Borac, a bez pobjede Funtana, Medulin i Smoljanci Sloboda. Službena ljestvica je na stranici lige.

Najveći skok kola napravila je Klana, četiri mjesta, a Žminj tri. Najviše su izgubili Ližnjan i Štinjan, po dva mjesta.

STRIJELCI

Vrh dijele Antonijo Vujičić iz Otočca i Boško Babić s Cresa, obojica s četiri pogotka. Slijede Jamu Akou Arum Iluya i Tymur Merezhko s po tri. Merezhko je jedini u kolu zabio dvaput. Hat-tricka nije bilo.

ZA SLJEDEĆE KOLO

Četvrto kolo propuštaju Antonio Ivančić i Sanjin Puh, obojica iz Smoljanaca Slobode, zbog crvenih kartona. Na pragu žutih nema nikoga. Raspored četvrtog kola je na stranici lige.',
  '4. NL NS Rijeka',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-3-kola-4-nl-ns-rijeka-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'pregled-3-kola-4-nl-ns-rijeka-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-3-kola-4-nl-ns-rijeka-2627';

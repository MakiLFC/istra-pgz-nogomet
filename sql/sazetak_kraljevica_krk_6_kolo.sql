-- =====================================================================
-- SAŽETAK UZ ZAPISNIK: NK KRALJEVICA - NK KRK 4:5
-- Derbi 6. kola 3. NL Zapad 2026/27, 26.09.2026., Minta.
-- =====================================================================
-- KAMO OVO IDE
--   U stupac utakmice.tekst_clanka, dakle u redak te utakmice, a NE u
--   tablicu clanci. Stranica ga prikazuje ispod zapisnika. Scraper taj
--   stupac ne dira. Pokretanje se smije ponoviti.
--
-- ODNOS PREMA CLANKU
--   Sažeta verzija sql/clanak_kraljevica_krk_6_kolo.sql, isti izvori.
-- =====================================================================

update public.utakmice
set tekst_clanka =
'Derbi kola s devet golova i tri preokreta pripao je Krku. Gosti su poveli u 10. minuti volejem Roka Begonje pod prečku, a Kraljevica je, iako je u susret ušla desetkovana, izjednačila u nadoknadi prvog poluvremena i povela odmah na početku drugog, oba puta prizemnim udarcima Filipa Znamenačeka.

Marko Jelić iskoristio je u 57. minuti pogrešku obrane za 2:2, Dominik Paljokaj je u 66. bombom s vrha šesnaesterca pogodio rašlje za 3:2, a Jelić je u 69. s bijele točke poravnao na 3:3. Domaćini su od 73. minute igrali s igračem manje, nakon drugog žutog kartona Lovre Šuprahe, ali su tri minute kasnije ponovno poveli: Znamenaček je iskoristio kiks vratara Krka i hat-trickom zabio za 4:3.

Begonja je već u 78. glavom, nakon ubačaja Mathewa Petera, zabio za 4:4. Pobjedu Krku donio je nesretan autogol Nina Jovanovića u 92. minuti, nakon što je vratar odbio udarac Luke Kuljiša.'
where natjecanje = '3. NL Zapad'
  and sezona     = '2026/27'
  and kolo       = 6
  and domacin    = 'NK Kraljevica'
  and gost       = 'NK Krk'
returning domacin, gost, rezultat, left(tekst_clanka, 60) as pocetak;

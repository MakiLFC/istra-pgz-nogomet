-- =====================================================================
-- SAŽETAK UZ ZAPISNIK: NK STARI GRAD RIJEKA - NK LOŠINJ 2:3
-- Derbi 4. kola 1. ŽNL PGŽ 2026/27, 27.09.2026., Belveder.
-- =====================================================================
-- KAMO OVO IDE
--   U stupac utakmice.tekst_clanka, dakle u redak te utakmice, a NE u
--   tablicu clanci. Stranica ga prikazuje ispod zapisnika. Scraper taj
--   stupac ne dira. Pokretanje se smije ponoviti.
--
-- ODNOS PREMA CLANKU
--   Sažeta verzija sql/clanak_stari_grad_losinj_4_kolo.sql, isti izvori.
-- =====================================================================

update public.utakmice
set tekst_clanka =
'Lošinj je na Belvederu nanio Starom gradu prvi poraz u sezoni. Gosti su poveli već u 9. minuti, kad je Antonio Matić slobodnim udarcem s ruba šesnaesterca prebacio živi zid. U 12. minuti Kevin Kalanj je s pet metara pogodio vratnicu, a Stari grad je odmah zatim, u 14., izjednačio golom Antonija Lukanovića. Domaćini su u nastavku poluvremena imali više posjeda i nekoliko udaraca izdaleka, a u 45. minuti, nakon greške Lošinja u sredini terena, Lukanović je iz brze kontre zabio i drugi put, za 2:1.

U drugom poluvremenu Marin Baković je u 67. minuti lobom pogodio prečku, a Lošinj je tri minute kasnije izjednačio: kapetan Vitorio Antoninić iskoristio je promašaj u obrani domaćina i prizemno zabio za 2:2. Nakon još jedne vratnice gostiju, Kalanjeve u 76. minuti, pobjedu je u 83. donio Šimun Simić, šest minuta nakon ulaska s klupe, udarcem po podu s dvadesetak metara u sam kut, nakon što je vratar Starog grada Marko Perić obranio samostalan bijeg Antoninića.'
where natjecanje = '1. ŽNL PGŽ'
  and sezona     = '2026/27'
  and kolo       = 4
  and domacin    = 'NK Stari grad Rijeka'
  and gost       = 'NK Lošinj'
returning domacin, gost, rezultat, left(tekst_clanka, 60) as pocetak;

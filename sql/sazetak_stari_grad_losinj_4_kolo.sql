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
'Lošinj je na Belvederu nanio Starom gradu prvi poraz u sezoni. Gosti su poveli već u 9. minuti, kad je [[L23]] slobodnim udarcem s ruba šesnaesterca prebacio živi zid. U 12. minuti [[L10]] je s pet metara pogodio vratnicu, a Stari grad je odmah zatim izjednačio preko [[strijelac]]. Domaćini su u nastavku poluvremena imali više posjeda i nekoliko udaraca izdaleka, a u 45. minuti, nakon greške Lošinja u sredini terena, [[Lukanović]] je iz brze kontre zabio za 2:1.

U drugom poluvremenu Marin Baković je u 67. minuti lobom pogodio prečku, a Lošinj je tri minute kasnije izjednačio: [[L24]] je iskoristio promašaj u obrani domaćina i prizemno zabio za 2:2. Nakon još jedne vratnice gostiju, [[L10]] u 76. minuti, pobjedu je u 82. donio [[L16]] udarcem po podu s dvadesetak metara u sam kut, nakon što je vratar Starog grada obranio samostalan bijeg [[L24]].'
where natjecanje = '1. ŽNL PGŽ'
  and sezona     = '2026/27'
  and kolo       = 4
  and domacin    = 'NK Stari grad Rijeka'
  and gost       = 'NK Lošinj'
returning domacin, gost, rezultat, left(tekst_clanka, 60) as pocetak;

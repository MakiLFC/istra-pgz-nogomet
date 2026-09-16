-- =====================================================================
-- ČLANAK: NK ZAMET - NK OMLADINAC VRATA 2:1
-- 2. kolo 1. ŽNL PGŽ 2026/27, odigrano 16.09.2026. u 18:45,
-- stadion Robert Komen u Rijeci, 48 gledatelja.
-- =====================================================================
-- KAKO SE KORISTI: dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   Zatim ide fotografija preko posla "Fotografija za clanak", pa tek
--   onda KORAK 2 (objava), koji je zakomentiran.
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- ODAKLE STO
--   SVE iz baze, jer Andrej na utakmici nije bio. Rezultat, strijelci s
--   minutama, gledatelji i pomaci na ljestvici dolaze iz
--   public.pregled_kola('2026/27','1. ŽNL PGŽ',2). Zuti kartoni ne
--   izlaze iz te funkcije nego su procitani iz postava, upitom koji
--   stoji na dnu datoteke.
--   Nema opisa igre, prilika ni ocjena: taj podatak ne postoji.
--
-- PROVJERENO PRIJE PISANJA
--   Zbroj strijelaca po stranama daje tocno 2:1. Iskljucenja nema.
--   Sva cetiri zuta kartona su gostujuca; Zamet je prosao bez opomene.
--   "Najvece iznenadjenje kola" nije procjena nego polje iznenadjenje
--   iz pregled_kola(): razlika u polozaju bila je devet mjesta
--   (Zamet 13., Omladinac 4.).
--
-- LJESTVICA
--   sluzbena_tablica_odstupa je false, dakle u 1. ŽNL nema kaznenih
--   bodova i izracunata tablica se poklapa sa sluzbenom. Zato se
--   polozaji smiju navesti izravno.
--
-- FOTOGRAFIJA
--   Ne upisuje se rucno nego preko posla "Fotografija za clanak" na
--   GitHubu, sa slugom zamet-omladinac-vrata-2-kolo-1-znl-2627.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'zamet-omladinac-vrata-2-kolo-1-znl-2627',
  'ZAMET UPISAO PRVE BODOVE I SRUŠIO OMLADINAC',
  'Din Murica i Hrvoje Ožanić zabili su u razmaku od pet minuta, Mateo Tomić je smanjio, a Zamet je pobjedom 2:1 skočio pet mjesta i nanio Omladincu iz Vrata prvi poraz u sezoni.',
'Zametova je utakmica u srijedu navečer zatvorila 2. kolo 1. ŽNL PGŽ, a donijela je i najveće iznenađenje kola. Na stadionu Robert Komen Zamet je pred 48 gledatelja svladao Omladinac iz Vrata 2:1, iako je prije početka bio trinaesti na ljestvici, bez osvojenog boda, dok je gost bio četvrti.

Prvo poluvrijeme prošlo je bez pogodaka, a sva tri pala su u razmaku od osamnaest minuta. Din Murica doveo je Zamet u vodstvo u 56. minuti, Hrvoje Ožanić je u 61. udvostručio prednost, a Mateo Tomić smanjio je u 74. minuti. Do kraja rezultat se nije mijenjao.

Sudac je podijelio četiri žuta kartona i svi su otišli gostima: Frano Mihelić u 21. minuti, Dominik Razmilić u 47., Petar Bitanga u 50. i Niko Kumir u drugoj minuti sudačke nadoknade. Zamet je utakmicu prošao bez ijedne opomene, a isključenja nije bilo.

Za Zamet su to prvi bodovi u sezoni, nakon poraza od Turbine 0:3 u prvom kolu. Na ljestvici je skočio s trinaestog na osmo mjesto, što je uz Vrbovsko najveći pomak u kolu. Omladinac Vrata ostaje na tri boda i četvrtom mjestu, a upisao je prvi poraz nakon pobjede nad Vrbovskim 4:2 u prvom kolu.

Murici i Ožaniću su ovo prvi pogoci u sezoni. Tomić je drugim golom stigao do dva i izjednačio se s Diegom Žicem na vrhu Omladinčeve liste strijelaca. Na vrhu ljestvice cijele lige i dalje je Patrik Vidmar iz Lovrana sa šest pogodaka.

Kolo je zaokruženo s Lovranom na prvom mjestu, ispred Raba i Lošinja, sve tri momčadi sa šest bodova. Cijela ljestvica i strijelci su na stranici 1. ŽNL PGŽ.

U trećem kolu, u subotu 19. rujna u 16:30, Zamet gostuje kod Goranina, a Omladinac Vrata dočekuje Rab.',
  '1. ŽNL PGŽ',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA (nakon fotografije)
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'zamet-omladinac-vrata-2-kolo-1-znl-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'zamet-omladinac-vrata-2-kolo-1-znl-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'zamet-omladinac-vrata-2-kolo-1-znl-2627';


-- =====================================================================
-- ODAKLE SU DOSLI ZUTI KARTONI (samo citanje, za ubuduce)
-- =====================================================================
-- select case s.strana when 'domacin' then u.domacin else u.gost end as klub,
--        i->>'igrac'  as igrac,
--        d->>'minuta' as minuta,
--        d->>'tip'    as tip
-- from public.utakmice u
-- cross join lateral (values ('domacin', u.postava_domacin),
--                            ('gost',    u.postava_gost)) as s(strana, postava)
-- cross join lateral jsonb_array_elements(s.postava) as i
-- cross join lateral jsonb_array_elements(i->'dogadjaji') as d
-- where u.natjecanje = '1. ŽNL PGŽ'
--   and u.sezona     = '2026/27'
--   and u.kolo       = 2
--   and u.domacin    = 'NK Zamet'
--   and u.gost       = 'NK Omladinac Vrata'
--   and d->>'tip' like 'karton%'
-- order by minuta;

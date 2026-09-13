-- =====================================================================
-- SAŽETAK UZ ZAPISNIK: NK VRBOVSKO - HNK GORANIN 2:0
-- Derbi 2. kola 1. ŽNL PGŽ 2026/27, odigrano 13.09.2026.
-- =====================================================================
-- KAMO OVO IDE
--   U stupac utakmice.tekst_clanka, dakle u sam redak te utakmice, a NE
--   u tablicu clanci. Stranica ga prikazuje ispod zapisnika, na adresi
--   te utakmice. Scraper taj stupac ne dira, pa prezivljava svako
--   osvjezavanje.
--
-- KAKO SE KORISTI
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Za razliku od clanaka, ovdje nema koraka "objava": cim se stupac
--   napuni, tekst je na stranici.
--   Pokretanje se smije ponoviti; drugi put samo prepise isti tekst.
--
-- ODAKLE STO
--   Rezultat, strijelci, minute, zuti kartoni i pomaci na ljestvici
--   dolaze iz zapisnika u bazi.
--   Nacin na koji su pali pogoci (korner, dubinska lopta i istrcavanje
--   vratara), podatak da je Jardas kapetan, te ocjene o pojacanjima
--   Vrbovskog i o ulasku Goranina u sezonu su ANDREJEVI. Toga u
--   zapisniku nema.
--
-- ZUTI KARTONI
--   Ne izlaze iz pregled_kola(), koja daje samo iskljucenja. Citaju se
--   iz postava, upitom koji stoji na dnu datoteke. Na ovoj utakmici ih
--   je osam, sest za domace i dva za goste, a iskljucenja nema.
-- =====================================================================


-- =====================================================================
-- UPIS SAŽETKA
-- =====================================================================
update public.utakmice
set tekst_clanka =
'Tvrda i borbena utakmica, kakva je između ove dvije momčadi gotovo pravilo, uz visok ritam od prve minute. Vrbovsko je povelo u 21. minuti, kada je kapetan Mihael Jardas bio precizan nakon kornera, a u 61. je Patrik Poljak nakon dubinske lopte iskoristio istrčavanje gostujućeg vratara i postavio konačnih 2:0.

Koliko se čvrsto igralo, govori osam žutih kartona, šest za domaće i dva za goste. Jardas je svoj dobio u 18. minuti, samo tri minute prije pogotka za vodstvo. Za Vrbovsko su opomenuti još Mate Cindrić, Josip Sabo, Roko Kasun, Mateo Vukelja i Ozren Mrvoš, a za Goranin Anton Lalić i Matija Markovčić. Isključenja nije bilo.

Brojna pojačanja koja je Vrbovsko dovelo očito se pokazuju opravdanima. Goranin se, s druge strane, mora probuditi nakon iznenađujuće lošeg ulaska u sezonu.

Vrbovskom je ovo prva pobjeda u sezoni i skok od šest mjesta na ljestvici, najveći u kolu. Goranin je istim porazom pao pet mjesta.'
where natjecanje = '1. ŽNL PGŽ'
  and sezona     = '2026/27'
  and kolo       = 2
  and domacin    = 'NK Vrbovsko'
  and gost       = 'HNK Goranin'
returning domacin, gost, rezultat, left(tekst_clanka, 60) as pocetak;


-- =====================================================================
-- PROVJERA
-- =====================================================================
select natjecanje, kolo, domacin, gost, rezultat, derbi,
       length(tekst_clanka) as duljina_teksta
from public.utakmice
where natjecanje = '1. ŽNL PGŽ'
  and sezona     = '2026/27'
  and kolo       = 2
  and domacin    = 'NK Vrbovsko'
  and gost       = 'HNK Goranin';


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
--   and u.domacin    = 'NK Vrbovsko'
--   and u.gost       = 'HNK Goranin'
--   and d->>'tip' like 'karton%'
-- order by minuta;

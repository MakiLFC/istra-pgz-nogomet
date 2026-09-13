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
--   Rezultat, strijelci, minute i pomaci na ljestvici dolaze iz
--   public.pregled_kola('2026/27','1. ZNL PGZ',2), dakle iz zapisnika.
--   Nacin na koji su pali pogoci (korner, dubinska lopta i istrcavanje
--   vratara), ocjena o pojacanjima Vrbovskog i ocjena o ulasku Goranina
--   u sezonu su ANDREJEVI, preneseni po onome sto je cuo i zna o
--   klubovima. Toga u zapisniku nema.
--
-- ZUTI KARTONI IDU ZASEBNO
--   pregled_kola() daje samo iskljucenja, a njih na ovoj utakmici nema.
--   Zuti kartoni stoje u postavama, pa ih cita KORAK 0 dolje. Kad se
--   imena znaju, pokrene se KORAK 2 koji recenicu o kartonima dopisuje
--   u vec upisani tekst. Do tada tekst stoji bez nje i posve je uredan.
-- =====================================================================


-- =====================================================================
-- KORAK 0: TKO JE DOBIO KARTON (samo citanje, nista ne mijenja)
-- =====================================================================
select case s.strana when 'domacin' then u.domacin else u.gost end as klub,
       i->>'igrac'  as igrac,
       d->>'minuta' as minuta,
       d->>'tip'    as tip
from public.utakmice u
cross join lateral (values ('domacin', u.postava_domacin),
                           ('gost',    u.postava_gost)) as s(strana, postava)
cross join lateral jsonb_array_elements(s.postava) as i
cross join lateral jsonb_array_elements(i->'dogadjaji') as d
where u.natjecanje = '1. ŽNL PGŽ'
  and u.sezona     = '2026/27'
  and u.kolo       = 2
  and u.domacin    = 'NK Vrbovsko'
  and u.gost       = 'HNK Goranin'
  and d->>'tip' like 'karton%'
order by minuta;


-- =====================================================================
-- KORAK 1: UPIS SAŽETKA
-- =====================================================================
update public.utakmice
set tekst_clanka =
'Tvrda i borbena utakmica, kakva je između ove dvije momčadi gotovo pravilo, uz visok ritam od prve minute. Vrbovsko je povelo u 21. minuti, kada je Mihael Jardas bio precizan nakon kornera, a u 61. je Patrik Poljak nakon dubinske lopte iskoristio istrčavanje gostujućeg vratara i postavio konačnih 2:0.

Igralo se čvrsto, ali bez isključenja: u zapisniku nema nijednog crvenog ni žuto-crvenog kartona.

Brojna pojačanja koja je Vrbovsko dovelo očito se pokazuju opravdanima. Goranin se, s druge strane, mora probuditi nakon iznenađujuće lošeg ulaska u sezonu.

Vrbovskom je ovo prva pobjeda u sezoni i skok od šest mjesta na ljestvici, najveći u kolu. Goranin je istim porazom pao pet mjesta.'
where natjecanje = '1. ŽNL PGŽ'
  and sezona     = '2026/27'
  and kolo       = 2
  and domacin    = 'NK Vrbovsko'
  and gost       = 'HNK Goranin'
returning domacin, gost, rezultat, left(tekst_clanka, 60) as pocetak;


-- =====================================================================
-- KORAK 2: DOPUNA REČENICOM O ŽUTIM KARTONIMA (kad se imena znaju)
-- =====================================================================
-- Upisi imena umjesto TRI TOCKE pa otkomentiraj i pokreni. Recenica se
-- ubacuje na mjesto postojece recenice o iskljucenjima, pa se KORAK 1 ne
-- mora ponavljati.
--
-- update public.utakmice
-- set tekst_clanka = replace(
--       tekst_clanka,
--       'Igralo se čvrsto, ali bez isključenja: u zapisniku nema nijednog crvenog ni žuto-crvenog kartona.',
--       'Igralo se čvrsto i to se vidi u zapisniku. Žute kartone dobili su ... Isključenja nije bilo.'
--     )
-- where natjecanje = '1. ŽNL PGŽ'
--   and sezona     = '2026/27'
--   and kolo       = 2
--   and domacin    = 'NK Vrbovsko'
--   and gost       = 'HNK Goranin'
-- returning domacin, gost, left(tekst_clanka, 80) as pocetak;


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

-- =====================================================================
-- public.pregled_kola() — podaci za osvrt NAKON odigranog kola, kao jedan JSON
-- =====================================================================
-- Parnjak funkcije public.najava_kola(): ista liga, ista sezona, isti
-- način razrješavanja naziva, samo pogled unatrag umjesto unaprijed.
--
-- KAKO SE KORISTI:
--   select jsonb_pretty(public.pregled_kola('2025/26', '3. NL Zapad', 15));
--   select jsonb_pretty(public.pregled_kola('2025/26', '3. NL Zapad'));
--     -- bez broja kola: zadnje kolo koje ima odigranih utakmica
--
-- Pokreni ovu datoteku JEDNOM u Supabase SQL Editoru, kao i najava_kola.sql.
--
-- ---------------------------------------------------------------------
-- ŠTO OVA FUNKCIJA MOŽE, A ŠTO NE (pročitaj prije nego se začudiš)
-- ---------------------------------------------------------------------
-- 1. TABLICA SE RAČUNA IZ UTAKMICA, ne čita se iz "statistike".
--    Isto kao u najava_kola(): tablica "statistike" drži samo JEDNO,
--    zadnje stanje po ligi i sezoni, bez povijesti. Zato se ovdje
--    računaju DVIJE tablice:
--      "prije"   iz utakmica s kolom MANJIM od traženog
--      "poslije" iz utakmica s kolom MANJIM ILI JEDNAKIM traženom
--    Razlika te dvije daje pomake na ljestvici.
--
--    CIJENA je ista: službena tablica UKLJUČUJE kaznene bodove (npr.
--    "NK Crikvenica (-3)"), a izračunata ih ne zna. Zato i ovdje u meta
--    ide "sluzbena_tablica_odstupa": kad je true, negdje u sezoni postoji
--    kazneni bod i brojkama ne treba slijepo vjerovati.
--
--    Poredak je po bodovima, pa gol-razlici, pa nazivu kluba. Propozicije
--    znaju imati i međusobni omjer kao kriterij; kod izjednačenih klubova
--    zato provjeri službenu tablicu.
--
-- 2. "suspendirani" OVDJE POSTOJI, za razliku od najave.
--    Crveni i žuto-crveni karton stoje u postavi utakmice, uz igrača i
--    minutu, pa se za odigrano kolo TOČNO zna tko je isključen i time
--    propušta sljedeće kolo. To najava ne može, jer gleda unaprijed.
--    Ne zna se trajanje kazne (dvije utakmice i više), ni odrađuje li
--    tko kaznu iz ranijeg kola: toga u bazi nema.
--
-- 3. "na_pragu" je stanje OD ZADNJEG SCRAPEA, ne "poslije ovog kola".
--    Žuti kartoni se u bazi drže samo kao zbroj za cijelu sezonu
--    (statistike, tip='kartoni'), bez podatka u kojem su kolu dobiveni.
--    Za osvrt zadnjeg odigranog kola to je točno; za neko starije kolo
--    taj popis pokazuje današnje stanje, ne ondašnje.
--
-- 4. PRAG ŽUTIH nije provjeren, isto kao u najavi. Zadano je 4 (kad se
--    preda null), a prag se razlikuje po natjecanjima. Kad ga potvrdiš u
--    propozicijama, predaj ga pri pozivu:
--      public.pregled_kola('2025/26','3. NL Zapad',15,5)
--
-- 5. VRATARI SE NE BROJE U STRIJELCE.
--    Na HNS Semaforu stupac "golovi" kod vratara znači PRIMLJENE golove.
--    Ova funkcija golove ne čita iz te rang-liste nego iz zapisnika
--    utakmice, gdje je gol stvarni događaj, ali se pravilo poštuje: u
--    ljestvici strijelaca, u "zabili_u_kolu" i u hat-trickovima vratara
--    nema. U popisu golova pojedine utakmice ostaje sve što u zapisniku
--    piše, jer je to zapis te utakmice.
--
-- 6. KLUB STRIJELCA se ne čita iz zapisa gola (ondje ga nema), nego se
--    strijelac traži u postavama obiju momčadi, isto kao na stranici
--    utakmice. Kad postave nema, klub ostaje null umjesto da se pogodi.
--
-- 7. VRSTA GOLA je "gol" ili "autogol". Zapisnik ne razlikuje jedanaesterac
--    od igre, pa se to ne izmišlja. Autogol se prepoznaje iz ručnog stupca
--    utakmice.autogolovi, vidi napomenu 11.
--
-- 8. MINUTA je broj (23), a uz nju stoji i "minuta_zapis" s izvornim
--    zapisom ("45+1'"), da se produžetak poluvremena ne izgubi.
--
-- 9. PRAZAN NIZ znači "provjereno, nema ničega". NULL znači "podatak ne
--    postoji". Zato je tablica prije prvog odigranog kola null, a ne
--    prazan niz, i pomaci su tada null.
--
-- 10. NAJUVJERLJIVIJA POBJEDA: prvo najveća razlika u golovima, a kod
--     iste razlike prednost ima utakmica s više postignutih golova
--     (6:1 ispred 5:0). Tako je Andrej odlučio, ne mijenjati.
--
-- 11. AUTOGOL stoji pod imenom igrača koji ga je zabio, pa bi ga pravilo
--     iz napomene 6 pripisalo njegovom klubu, dakle krivoj strani. Zato se
--     ovdje pripisuje PROTIVNIKU strijelca i izbacuje iz svih ljestvica
--     strijelaca, jer autogol nije zasluga strijelca.
--
--     Prepoznaje se na dva načina, i dovoljan je bilo koji:
--       a) zastavica "autogol" u polju strijelci, koju upisuje scraper
--          čitajući klasu "own_goal" iz zapisnika
--       b) ručni popis u stupcu utakmice.autogolovi (sql/autogolovi.sql),
--          za utakmice odigrane prije nego je prepoznavanje dodano i za
--          slučaj da HNS pogodak nije označio
--
--     Prvi slučaj: Jadran-Poreč - Nehaj 1:3, 1. kolo 2026/27, gdje je
--     zbroj strijelaca bez ove ispravke davao 2:2.
--
-- OZNAKE: promjena na ljestvici je pozitivna kad je klub napredovao
-- (bio 7., sad je 4. -> promjena 3).
-- =====================================================================


-- ---------------------------------------------------------------------
-- BRISANJE STARIH VERZIJA, prije nego ih ponovno stvorimo.
--
-- "create or replace" ne može promijeniti ono što funkcija VRAĆA. Kad se
-- popis izlaznih stupaca proširi, kao kad je funkciji golova dodan stupac
-- "autogol", Postgres odbija zamjenu porukom:
--   ERROR: cannot change return type of existing function
--
-- Zato se stare verzije prvo obrišu. "if exists" znači da ovo prolazi i
-- pri prvom pokretanju, kad funkcija još ne postoji. Nikakvi podaci se ne
-- diraju, funkcije samo čitaju iz tablica.
--
-- Ne treba "cascade": Postgres ne pamti da jedna funkcija poziva drugu,
-- pa brisanje pomoćne ne ruši glavnu.
-- ---------------------------------------------------------------------
drop function if exists public.pregled_kola(text, text, int, int);
drop function if exists public.pregled_kola_tablica(text, text, int);
drop function if exists public.pregled_kola_golovi(text, text, int);
drop function if exists public.pregled_kola_iskljucenja(text, text, int);
drop function if exists public.pregled_kola_serije(text, text, int);


-- ---------------------------------------------------------------------
-- Pomoćna funkcija: tablica poretka izračunata do uključivo zadanog kola.
-- Postoji da glavni upit može istu stvar zatražiti dvaput, za stanje
-- prije i poslije kola, bez prepisivanja izračuna.
-- ---------------------------------------------------------------------
create or replace function public.pregled_kola_tablica(
  p_liga    text,
  p_sezona  text,
  p_do_kola int
)
returns table (
  pozicija    int,
  klub        text,
  bodovi      int,
  gol_razlika int,
  dani        int,
  primljeni   int,
  odigrano    int
)
language sql
stable
as $$
  with odigrane as (
    select u.domacin,
           u.gost,
           split_part(replace(u.rezultat, ' ', ''), ':', 1)::int as g_dom,
           split_part(replace(u.rezultat, ' ', ''), ':', 2)::int as g_gos
    from public.utakmice u
    where u.natjecanje = p_liga
      and u.sezona = p_sezona
      and u.kolo <= p_do_kola
      and u.rezultat ~ '^\s*\d+\s*:\s*\d+\s*$'
  ),
  nastupi as (
    select o.domacin as klub, o.g_dom as dano, o.g_gos as primljeno from odigrane o
    union all
    select o.gost, o.g_gos, o.g_dom from odigrane o
  ),
  zbroj as (
    select n.klub,
           count(*)::int                                                  as odigrano,
           sum(case when n.dano > n.primljeno then 3
                    when n.dano = n.primljeno then 1 else 0 end)::int      as bodovi,
           sum(n.dano)::int                                               as dani,
           sum(n.primljeno)::int                                          as primljeni
    from nastupi n
    group by n.klub
  )
  select row_number() over (
           order by z.bodovi desc, (z.dani - z.primljeni) desc, z.klub
         )::int,
         z.klub,
         z.bodovi,
         (z.dani - z.primljeni)::int,
         z.dani,
         z.primljeni,
         z.odigrano
  from zbroj z;
$$;


-- ---------------------------------------------------------------------
-- Pomoćna funkcija: golovi iz zapisnika, s klubom i oznakom vratara.
-- Vraća SVE golove do uključivo zadanog kola, pa glavni upit iz istog
-- izvora slaže i golove pojedine utakmice i ljestvicu strijelaca.
-- ---------------------------------------------------------------------
create or replace function public.pregled_kola_golovi(
  p_liga    text,
  p_sezona  text,
  p_do_kola int
)
returns table (
  utakmica_id  bigint,
  kolo         int,
  ime          text,
  klub         text,
  vratar       boolean,
  minuta       int,
  minuta_zapis text,
  autogol      boolean
)
language sql
stable
as $$
  with odigrane as (
    select u.id, u.kolo, u.domacin, u.gost,
           u.strijelci, u.postava_domacin, u.postava_gost, u.autogolovi
    from public.utakmice u
    where u.natjecanje = p_liga
      and u.sezona = p_sezona
      and u.kolo <= p_do_kola
      and u.rezultat ~ '^\s*\d+\s*:\s*\d+\s*$'
  ),
  -- tko je u čijoj postavi (vidi napomenu 6 na vrhu datoteke)
  postave as (
    select o.id,
           p ->> 'igrac'                     as ime,
           o.domacin                         as klub,
           (p ->> 'pozicija') = 'Vratar'     as vratar
    from odigrane o,
         lateral jsonb_array_elements(coalesce(o.postava_domacin, '[]'::jsonb)) p
    union all
    select o.id,
           p ->> 'igrac',
           o.gost,
           (p ->> 'pozicija') = 'Vratar'
    from odigrane o,
         lateral jsonb_array_elements(coalesce(o.postava_gost, '[]'::jsonb)) p
  ),
  -- Ručno označeni autogoli te utakmice (vidi napomenu 11 na vrhu).
  -- Ostaje za utakmice odigrane prije nego je scraper naučio prepoznavati
  -- autogol, i za slučaj da ga HNS nije označio.
  autogoli as (
    select o.id,
           lower(trim(a ->> 'igrac')) as ime,
           trim(a ->> 'minuta')       as minuta_zapis
    from odigrane o,
         lateral jsonb_array_elements(coalesce(o.autogolovi, '[]'::jsonb)) a
  ),
  pogoci as (
    select o.id,
           o.kolo,
           o.domacin,
           o.gost,
           s ->> 'igrac'  as ime,
           s ->> 'minuta' as minuta_zapis,
           -- oznaka koju upisuje scraper, iz klase "own_goal" u zapisniku
           coalesce((s ->> 'autogol')::boolean, false) as autogol_iz_zapisnika
    from odigrane o,
         lateral jsonb_array_elements(coalesce(o.strijelci, '[]'::jsonb)) s
  )
  select g.id,
         g.kolo,
         g.ime,
         -- Autogol pripada PROTIVNIKU strijelca, pa se klub zamjenjuje.
         case
           when not (g.autogol_iz_zapisnika or ag.id is not null) then k.klub
           when k.klub = g.domacin then g.gost
           when k.klub = g.gost then g.domacin
           else k.klub
         end,
         coalesce(k.vratar, false),
         nullif(substring(g.minuta_zapis from '\d+'), '')::int,
         g.minuta_zapis,
         g.autogol_iz_zapisnika or ag.id is not null
  from pogoci g
  left join lateral (
    select p.klub, p.vratar
    from postave p
    where p.id = g.id
      and lower(p.ime) = lower(g.ime)
    limit 1
  ) k on true
  left join lateral (
    select a.id
    from autogoli a
    where a.id = g.id
      and a.ime = lower(trim(g.ime))
      and a.minuta_zapis = trim(g.minuta_zapis)
    limit 1
  ) ag on true;
$$;


-- ---------------------------------------------------------------------
-- Pomoćna funkcija: isključenja u zadanom kolu.
-- Crveni i žuto-crveni karton stoje uz igrača u postavi, s minutom.
-- ---------------------------------------------------------------------
create or replace function public.pregled_kola_iskljucenja(
  p_liga   text,
  p_sezona text,
  p_kolo   int
)
returns table (
  utakmica_id  bigint,
  ime          text,
  klub         text,
  tip          text,
  minuta       int,
  minuta_zapis text
)
language sql
stable
as $$
  with kolo_utakmice as (
    select u.id, u.domacin, u.gost, u.postava_domacin, u.postava_gost
    from public.utakmice u
    where u.natjecanje = p_liga
      and u.sezona = p_sezona
      and u.kolo = p_kolo
      and u.rezultat ~ '^\s*\d+\s*:\s*\d+\s*$'
  ),
  u_postavi as (
    select k.id,
           p ->> 'igrac'    as ime,
           k.domacin        as klub,
           p -> 'dogadjaji' as dogadjaji
    from kolo_utakmice k,
         lateral jsonb_array_elements(coalesce(k.postava_domacin, '[]'::jsonb)) p
    union all
    select k.id,
           p ->> 'igrac',
           k.gost,
           p -> 'dogadjaji'
    from kolo_utakmice k,
         lateral jsonb_array_elements(coalesce(k.postava_gost, '[]'::jsonb)) p
  )
  select i.id,
         i.ime,
         i.klub,
         d ->> 'tip',
         nullif(substring(d ->> 'minuta' from '\d+'), '')::int,
         d ->> 'minuta'
  from u_postavi i,
       lateral jsonb_array_elements(coalesce(i.dogadjaji, '[]'::jsonb)) d
  where d ->> 'tip' in ('karton_crveni', 'karton_zutocrveni');
$$;


-- ---------------------------------------------------------------------
-- Pomoćna funkcija: nizovi po klubu, od zadnje odigrane utakmice unatrag.
-- ---------------------------------------------------------------------
create or replace function public.pregled_kola_serije(
  p_liga    text,
  p_sezona  text,
  p_do_kola int
)
returns table (
  klub            text,
  neporazen       int,
  bez_primljenog  int,
  bez_pobjede     int
)
language sql
stable
as $$
  with odigrane as (
    select u.kolo, u.domacin, u.gost,
           split_part(replace(u.rezultat, ' ', ''), ':', 1)::int as g_dom,
           split_part(replace(u.rezultat, ' ', ''), ':', 2)::int as g_gos
    from public.utakmice u
    where u.natjecanje = p_liga
      and u.sezona = p_sezona
      and u.kolo <= p_do_kola
      and u.rezultat ~ '^\s*\d+\s*:\s*\d+\s*$'
  ),
  nastupi as (
    select o.domacin as klub, o.g_dom as dano, o.g_gos as primljeno, o.kolo from odigrane o
    union all
    select o.gost, o.g_gos, o.g_dom, o.kolo from odigrane o
  ),
  redom as (
    select n.klub, n.dano, n.primljeno,
           row_number() over (partition by n.klub order by n.kolo desc) as rn
    from nastupi n
  )
  select r.klub,
         (coalesce(min(r.rn) filter (where r.dano <  r.primljeno), count(*) + 1) - 1)::int,
         (coalesce(min(r.rn) filter (where r.primljeno > 0),       count(*) + 1) - 1)::int,
         (coalesce(min(r.rn) filter (where r.dano >  r.primljeno), count(*) + 1) - 1)::int
  from redom r
  group by r.klub;
$$;


-- =====================================================================
-- GLAVNA FUNKCIJA
-- =====================================================================
create or replace function public.pregled_kola(
  p_sezona     text,
  p_liga       text,
  p_kolo       int default null,   -- null = zadnje kolo koje ima odigranih utakmica
  p_prag_zutih int default null    -- null = ista vrijednost kao u najava_kola()
)
returns jsonb
language plpgsql
stable
security invoker
as $$
declare
  v_liga            text;
  v_sezona          text;
  v_kolo            int;
  v_prag            int := coalesce(p_prag_zutih, 4);   -- vidi napomenu 4
  v_zadnje_odigrano int;
  v_prvo_kolo       boolean;
  v_ukupno          int;
  v_odigrano        int;
  v_zavrseno        boolean;
  v_odstupa         boolean;
  v_tablica_prije   jsonb;
  v_tablica_poslije jsonb;
  v_pomaci          jsonb;
  v_rezultat        jsonb;
begin
  ------------------------------------------------------------------
  -- 1. Razriješi ligu i sezonu (fuzzy, preko ILIKE — isto kao najava)
  ------------------------------------------------------------------
  select u.natjecanje, u.sezona
    into v_liga, v_sezona
  from public.utakmice u
  where u.natjecanje ilike '%' || p_liga || '%'
    and u.sezona     ilike '%' || p_sezona || '%'
  group by u.natjecanje, u.sezona
  order by u.natjecanje
  limit 1;

  if v_liga is null then
    raise exception 'Liga % nije pronađena u sezoni %', p_liga, p_sezona;
  end if;

  ------------------------------------------------------------------
  -- 2. Odredi kolo
  ------------------------------------------------------------------
  select max(u.kolo) into v_zadnje_odigrano
  from public.utakmice u
  where u.natjecanje = v_liga
    and u.sezona = v_sezona
    and u.rezultat ~ '^\s*\d+\s*:\s*\d+\s*$';

  if p_kolo is null then
    if v_zadnje_odigrano is null then
      raise exception
        'U ligi % (sezona %) nema nijedne odigrane utakmice, pa nema ni kola za osvrt',
        v_liga, v_sezona;
    end if;
    v_kolo := v_zadnje_odigrano;
  else
    v_kolo := p_kolo;

    if not exists (
      select 1 from public.utakmice u
      where u.natjecanje = v_liga and u.sezona = v_sezona and u.kolo = v_kolo
    ) then
      raise exception 'Kolo % ne postoji u ligi % (sezona %)',
        v_kolo, v_liga, v_sezona;
    end if;

    -- Osvrt na kolo bez ijednog rezultata nema smisla, pa se ne vraća
    -- prazan JSON nego opisna iznimka s prijedlogom kola koje ima
    -- rezultate (za najavu takvog kola postoji najava_kola).
    if not exists (
      select 1 from public.utakmice u
      where u.natjecanje = v_liga and u.sezona = v_sezona and u.kolo = v_kolo
        and u.rezultat ~ '^\s*\d+\s*:\s*\d+\s*$'
    ) then
      if v_zadnje_odigrano is null then
        raise exception
          'Nijedna utakmica %. kola lige % (sezona %) nije odigrana; u toj sezoni još nema nijednog odigranog kola. Za najavu koristi public.najava_kola(''%'', ''%'', %).',
          v_kolo, v_liga, v_sezona, v_sezona, v_liga, v_kolo;
      else
        raise exception
          'Nijedna utakmica %. kola lige % (sezona %) nije odigrana; zadnje kolo s rezultatima je %. Probaj public.pregled_kola(''%'', ''%'', %).',
          v_kolo, v_liga, v_sezona, v_zadnje_odigrano, v_sezona, v_liga, v_zadnje_odigrano;
      end if;
    end if;
  end if;

  ------------------------------------------------------------------
  -- 3. Koliko je utakmica u kolu odigrano
  ------------------------------------------------------------------
  select count(*)::int,
         count(*) filter (where u.rezultat ~ '^\s*\d+\s*:\s*\d+\s*$')::int
    into v_ukupno, v_odigrano
  from public.utakmice u
  where u.natjecanje = v_liga and u.sezona = v_sezona and u.kolo = v_kolo;

  v_zavrseno := (v_odigrano = v_ukupno);

  ------------------------------------------------------------------
  -- 4. Ima li odigranih utakmica PRIJE ovog kola?
  --    Ako nema, tablice prije i pomaka nema (null, ne nule).
  ------------------------------------------------------------------
  select not exists (
    select 1 from public.utakmice u
    where u.natjecanje = v_liga and u.sezona = v_sezona
      and u.kolo < v_kolo
      and u.rezultat ~ '^\s*\d+\s*:\s*\d+\s*$'
  ) into v_prvo_kolo;

  ------------------------------------------------------------------
  -- 5. Tablice prije i poslije kola, pa pomaci
  ------------------------------------------------------------------
  select jsonb_agg(jsonb_build_object(
           'pozicija',    t.pozicija,
           'klub',        t.klub,
           'bodovi',      t.bodovi,
           'gol_razlika', t.gol_razlika
         ) order by t.pozicija)
    into v_tablica_poslije
  from public.pregled_kola_tablica(v_liga, v_sezona, v_kolo) t;

  if v_prvo_kolo then
    v_tablica_prije := null;
    v_pomaci        := null;
  else
    select jsonb_agg(jsonb_build_object(
             'pozicija', t.pozicija,
             'klub',     t.klub,
             'bodovi',   t.bodovi
           ) order by t.pozicija)
      into v_tablica_prije
    from public.pregled_kola_tablica(v_liga, v_sezona, v_kolo - 1) t;

    -- Klub koji prije ovog kola nije odigrao nijednu utakmicu nema
    -- prijašnju poziciju; tada su i "prije" i "promjena" null.
    select jsonb_agg(jsonb_build_object(
             'klub',     po.klub,
             'prije',    pr.pozicija,
             'poslije',  po.pozicija,
             'promjena', pr.pozicija - po.pozicija
           ) order by po.pozicija)
      into v_pomaci
    from public.pregled_kola_tablica(v_liga, v_sezona, v_kolo) po
    left join public.pregled_kola_tablica(v_liga, v_sezona, v_kolo - 1) pr
           on pr.klub = po.klub;
  end if;

  ------------------------------------------------------------------
  -- 6. Glavni izračun
  ------------------------------------------------------------------
  with
  -- sve utakmice traženog kola, odigrane i neodigrane
  kolo_utakmice as (
    select u.id,
           u.domacin,
           u.gost,
           u.rezultat,
           coalesce(u.derbi, false) as derbi,
           coalesce(nullif(u.stadion, ''), nullif(u.stadion_datum, '')) as stadion,
           -- coalesce, inace bi neodigrana utakmica (rezultat null) dala
           -- null umjesto false, a null znaci "nema podatka", ne "nije odigrana"
           (coalesce(u.rezultat, '') ~ '^\s*\d+\s*:\s*\d+\s*$') as odigrana,
           -- "Nepoznato" i prazno daju null; nula je zapis "nema podatka",
           -- ne prazan stadion, pa je i ona null (isto kao na stranici).
           nullif(nullif(regexp_replace(coalesce(u.gledatelja, ''), '\D', '', 'g'), '')::int, 0)
             as gledatelja,
           -- Datum s retka rasporeda; starije sezone ga nemaju, pa se
           -- vadi iz retka zapisnika ("Stadion, mjesto, 29.08.2026. 17:30").
           case
             when coalesce(u.datum, substring(u.stadion_datum from '\d{2}\.\d{2}\.\d{4}\.')) is null
               then null
             else (to_timestamp(
                     coalesce(u.datum, substring(u.stadion_datum from '\d{2}\.\d{2}\.\d{4}\.'))
                     || ' ' ||
                     coalesce(nullif(u.vrijeme, ''),
                              substring(coalesce(u.stadion_datum, '') from '\d{1,2}:\d{2}'),
                              '00:00'),
                     'DD.MM.YYYY. HH24:MI'
                   )::timestamp at time zone 'Europe/Zagreb')
           end as termin
    from public.utakmice u
    where u.natjecanje = v_liga and u.sezona = v_sezona and u.kolo = v_kolo
  ),
  odigrane_kolo as (
    select k.id, k.domacin, k.gost, k.rezultat, k.gledatelja,
           split_part(replace(k.rezultat, ' ', ''), ':', 1)::int as g_dom,
           split_part(replace(k.rezultat, ' ', ''), ':', 2)::int as g_gos
    from kolo_utakmice k
    where k.odigrana
  ),
  -- golovi cijele sezone do uključivo ovog kola
  golovi_do as (
    select g.* from public.pregled_kola_golovi(v_liga, v_sezona, v_kolo) g
  ),
  golovi_kolo as (
    select g.* from golovi_do g where g.kolo = v_kolo
  ),
  iskljucenja as (
    select i.* from public.pregled_kola_iskljucenja(v_liga, v_sezona, v_kolo) i
  ),
  -- ljestvica strijelaca poslije kola (bez vratara, vidi napomenu 5)
  strijelci_poslije as (
    select g.ime,
           count(*)::int as golova,
           (array_agg(g.klub order by g.kolo desc) filter (where g.klub is not null))[1] as klub
    from golovi_do g
    where not g.vratar and not g.autogol
    group by g.ime
  ),
  strijelci_prije as (
    select g.ime, count(*)::int as golova
    from golovi_do g
    where not g.vratar and not g.autogol and g.kolo < v_kolo
    group by g.ime
  ),
  vodeci_poslije as (
    select s.ime from strijelci_poslije s
    where s.golova = (select max(s2.golova) from strijelci_poslije s2)
  ),
  vodeci_prije as (
    select s.ime from strijelci_prije s
    where s.golova = (select max(s2.golova) from strijelci_prije s2)
  ),
  -- granica za prvih deset, uz izjednačene na zadnjem mjestu
  granica_deset as (
    select min(x.golova) as golova
    from (
      select s.golova from strijelci_poslije s
      order by s.golova desc, s.ime
      limit 10
    ) x
  ),
  zabili_u_kolu as (
    select g.ime, count(*)::int as golova_u_kolu
    from golovi_kolo g
    where not g.vratar and not g.autogol
    group by g.ime
  ),
  hat_trickovi as (
    select g.ime, g.klub, g.utakmica_id, count(*)::int as golova
    from golovi_kolo g
    where not g.vratar and not g.autogol
    group by g.ime, g.klub, g.utakmica_id
    having count(*) >= 3
  ),
  -- iznenađenje: pobjeda kluba koji je prije kola bio barem pet mjesta niže
  pobjede_kola as (
    select o.id, o.rezultat, o.domacin, o.gost,
           case when o.g_dom > o.g_gos then o.domacin else o.gost end as pobjednik,
           case when o.g_dom > o.g_gos then o.gost else o.domacin end as gubitnik
    from odigrane_kolo o
    where o.g_dom <> o.g_gos
  ),
  iznenadjenja as (
    select p.id, p.rezultat, p.domacin, p.gost, p.pobjednik, p.gubitnik,
           tp.pozicija as pozicija_pobjednika,
           tg.pozicija as pozicija_gubitnika,
           (tp.pozicija - tg.pozicija) as razlika_mjesta
    from pobjede_kola p
    join public.pregled_kola_tablica(v_liga, v_sezona, v_kolo - 1) tp on tp.klub = p.pobjednik
    join public.pregled_kola_tablica(v_liga, v_sezona, v_kolo - 1) tg on tg.klub = p.gubitnik
    where not v_prvo_kolo
      and tp.pozicija - tg.pozicija >= 5
  ),
  serije as (
    select s.* from public.pregled_kola_serije(v_liga, v_sezona, v_kolo) s
  ),
  -- igrači na korak od suspenzije (stanje od zadnjeg scrapea, napomena 3)
  na_pragu as (
    select e ->> 'igrac' as ime,
           e ->> 'klub'  as klub,
           nullif(e ->> 'zuti', '')::int as zutih
    from public.statistike s,
         lateral jsonb_array_elements(s.podaci) e
    where s.natjecanje = v_liga and s.sezona = v_sezona and s.tip = 'kartoni'
      and nullif(e ->> 'zuti', '')::int = greatest(v_prag - 1, 0)
  )
  select jsonb_build_object(
    'meta', jsonb_build_object(
      'liga',              v_liga,
      'sezona',            v_sezona,
      'kolo',              v_kolo,
      'prvo_kolo_sezone',  v_prvo_kolo,
      'utakmica_ukupno',   v_ukupno,
      'utakmica_odigrano', v_odigrano,
      'kolo_zavrseno',     v_zavrseno,
      'datum_od', (select to_char(min(k.termin) at time zone 'Europe/Zagreb', 'YYYY-MM-DD')
                   from kolo_utakmice k),
      'datum_do', (select to_char(max(k.termin) at time zone 'Europe/Zagreb', 'YYYY-MM-DD')
                   from kolo_utakmice k),
      'prag_zutih',        v_prag,
      'napomena', concat_ws(' ',
        'Tablica je IZRAČUNATA iz odigranih utakmica i ne uključuje kaznene bodove.',
        case when v_prvo_kolo
             then 'Ovo je prvo odigrano kolo sezone, pa tablice prije kola i pomaka nema.' end,
        case when not v_zavrseno
             then 'Kolo nije završeno: tablica poslije kola i ljestvica strijelaca računaju se iz onoga što je odigrano.' end
      )
    ),

    'utakmice', coalesce((
      select jsonb_agg(red order by red_termin nulls last, red_domacin)
      from (
        select
          k.termin  as red_termin,
          k.domacin as red_domacin,
          jsonb_build_object(
            'utakmica_id', k.id,
            'datum',       k.termin,
            -- Čitljiv termin po hrvatski, isto kao u najava_kola(): "datum"
            -- je ISO i prikazuje se u vremenskoj zoni sesije (u Supabaseu
            -- UTC), pa je ovo polje tu da se u osvrt može prepisati bez
            -- preračunavanja.
            'datum_hr', case when k.termin is null then null else
              (case extract(dow from k.termin at time zone 'Europe/Zagreb')::int
                 when 0 then 'nedjelja'  when 1 then 'ponedjeljak'
                 when 2 then 'utorak'    when 3 then 'srijeda'
                 when 4 then 'četvrtak'  when 5 then 'petak'
                 else 'subota' end)
              || ' ' || to_char(k.termin at time zone 'Europe/Zagreb', 'DD.MM.YYYY.')
              || ' u ' || to_char(k.termin at time zone 'Europe/Zagreb', 'HH24:MI')
            end,
            'stadion',     k.stadion,
            'domacin',     k.domacin,
            'gost',        k.gost,
            'rezultat',    case when k.odigrana then k.rezultat else null end,
            'odigrana',    k.odigrana,
            'derbi',       k.derbi,
            'gledatelja',  k.gledatelja,
            'strijelci', coalesce((
              select jsonb_agg(jsonb_build_object(
                       'ime',          g.ime,
                       'klub',         g.klub,
                       'minuta',       g.minuta,
                       'minuta_zapis', g.minuta_zapis,
                       'vrsta',        case when g.autogol then 'autogol'
                                                  else 'gol' end
                     ) order by g.minuta nulls last, g.ime)
              from golovi_kolo g
              where g.utakmica_id = k.id
            ), '[]'::jsonb),
            'crveni_kartoni', coalesce((
              select jsonb_agg(jsonb_build_object(
                       'ime',          i.ime,
                       'klub',         i.klub,
                       'minuta',       i.minuta,
                       'minuta_zapis', i.minuta_zapis,
                       'vrsta',        case when i.tip = 'karton_zutocrveni'
                                            then 'žuto-crveni karton'
                                            else 'crveni karton' end
                     ) order by i.minuta nulls last, i.ime)
              from iskljucenja i
              where i.utakmica_id = k.id
            ), '[]'::jsonb)
          ) as red
        from kolo_utakmice k
      ) t
    ), '[]'::jsonb),

    'tablica', jsonb_build_object(
      'prije',   v_tablica_prije,
      'poslije', coalesce(v_tablica_poslije, '[]'::jsonb),
      'pomaci',  v_pomaci
    ),

    'istaknuto', jsonb_build_object(
      -- najuvjerljivija pobjeda: neriješeni rezultati ovdje ne konkuriraju
      'najuvjerljivija_pobjeda', (
        select jsonb_build_object(
                 'utakmica_id', o.id,
                 'rezultat',    o.rezultat,
                 'domacin',     o.domacin,
                 'gost',        o.gost
               )
        from odigrane_kolo o
        where o.g_dom <> o.g_gos
        order by abs(o.g_dom - o.g_gos) desc, (o.g_dom + o.g_gos) desc, o.id
        limit 1
      ),
      'najvise_golova', (
        select jsonb_build_object(
                 'utakmica_id', o.id,
                 'rezultat',    o.rezultat,
                 'ukupno',      o.g_dom + o.g_gos,
                 'domacin',     o.domacin,
                 'gost',        o.gost
               )
        from odigrane_kolo o
        order by (o.g_dom + o.g_gos) desc, o.id
        limit 1
      ),
      'iznenadjenje', (
        select jsonb_build_object(
                 'utakmica_id',         z.id,
                 'rezultat',            z.rezultat,
                 'domacin',             z.domacin,
                 'gost',                z.gost,
                 'pobjednik',           z.pobjednik,
                 'pozicija_pobjednika', z.pozicija_pobjednika,
                 'gubitnik',            z.gubitnik,
                 'pozicija_gubitnika',  z.pozicija_gubitnika,
                 'razlika_mjesta',      z.razlika_mjesta
               )
        from iznenadjenja z
        order by z.razlika_mjesta desc, z.id
        limit 1
      ),
      'najveca_posjecenost', (
        select jsonb_build_object(
                 'utakmica_id', o.id,
                 'gledatelja',  o.gledatelja,
                 'domacin',     o.domacin,
                 'gost',        o.gost
               )
        from odigrane_kolo o
        where o.gledatelja is not null
        order by o.gledatelja desc, o.id
        limit 1
      ),
      'hat_trickovi', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'ime',         h.ime,
                 'klub',        h.klub,
                 'golova',      h.golova,
                 'utakmica_id', h.utakmica_id
               ) order by h.golova desc, h.ime)
        from hat_trickovi h
      ), '[]'::jsonb)
    ),

    'strijelci', jsonb_build_object(
      'poredak', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'ime',    s.ime,
                 'klub',   s.klub,
                 'golova', s.golova
               ) order by s.golova desc, s.ime)
        from strijelci_poslije s
        where s.golova >= (select g.golova from granica_deset g)
      ), '[]'::jsonb),
      -- ime samo ako je ovim kolom došao NOVI vodeći, i to jedan jedini
      'novi_vodeci', case
        when v_prvo_kolo then null
        when (select count(*) from vodeci_poslije) <> 1 then null
        when exists (
          select 1 from vodeci_poslije vp
          join vodeci_prije vr on vr.ime = vp.ime
        ) then null
        else (select vp.ime from vodeci_poslije vp)
      end,
      'zabili_u_kolu', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'ime',            z.ime,
                 'klub',           s.klub,
                 'golova_u_kolu',  z.golova_u_kolu,
                 'ukupno',         s.golova
               ) order by z.golova_u_kolu desc, z.ime)
        from zabili_u_kolu z
        join strijelci_poslije s on s.ime = z.ime
      ), '[]'::jsonb)
    ),

    'posljedice_za_sljedece_kolo', jsonb_build_object(
      'suspendirani', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'ime',   i.ime,
                 'klub',  i.klub,
                 'razlog', case when i.tip = 'karton_zutocrveni'
                                then 'žuto-crveni karton'
                                else 'crveni karton' end
               ) order by i.klub, i.ime)
        from iskljucenja i
      ), '[]'::jsonb),
      'na_pragu', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'ime',   n.ime,
                 'klub',  n.klub,
                 'zutih', n.zutih
               ) order by n.klub, n.ime)
        from na_pragu n
      ), '[]'::jsonb)
    ),

    'serije', jsonb_build_object(
      'neporazeni', coalesce((
        select jsonb_agg(jsonb_build_object('klub', s.klub, 'utakmica', s.neporazen)
                         order by s.neporazen desc, s.klub)
        from serije s where s.neporazen >= 3
      ), '[]'::jsonb),
      'bez_primljenog', coalesce((
        select jsonb_agg(jsonb_build_object('klub', s.klub, 'utakmica', s.bez_primljenog)
                         order by s.bez_primljenog desc, s.klub)
        from serije s where s.bez_primljenog >= 3
      ), '[]'::jsonb),
      'bez_pobjede', coalesce((
        select jsonb_agg(jsonb_build_object('klub', s.klub, 'utakmica', s.bez_pobjede)
                         order by s.bez_pobjede desc, s.klub)
        from serije s where s.bez_pobjede >= 3
      ), '[]'::jsonb)
    )
  ) into v_rezultat;

  ------------------------------------------------------------------
  -- 7. Kontrola: odstupa li izračun od službene tablice?
  --    Ako da, negdje u sezoni postoji kazneni bod (vidi napomenu 1).
  --    Isti izračun kao u najava_kola().
  ------------------------------------------------------------------
  select exists (
    select 1
    from public.statistike s,
         lateral jsonb_array_elements(s.podaci) e
    join lateral (
      select sum(case when n.dano > n.primljeno then 3
                      when n.dano = n.primljeno then 1 else 0 end)::int as bodovi
      from (
        select u.domacin as klub,
               split_part(replace(u.rezultat,' ',''),':',1)::int as dano,
               split_part(replace(u.rezultat,' ',''),':',2)::int as primljeno
        from public.utakmice u
        where u.natjecanje = v_liga and u.sezona = v_sezona
          and u.rezultat ~ '^\s*\d+\s*:\s*\d+\s*$'
        union all
        select u.gost,
               split_part(replace(u.rezultat,' ',''),':',2)::int,
               split_part(replace(u.rezultat,' ',''),':',1)::int
        from public.utakmice u
        where u.natjecanje = v_liga and u.sezona = v_sezona
          and u.rezultat ~ '^\s*\d+\s*:\s*\d+\s*$'
      ) n
      where n.klub ilike (e ->> 'klub')
    ) izracun on true
    where s.natjecanje = v_liga and s.sezona = v_sezona and s.tip = 'tablica'
      and nullif(regexp_replace(e ->> 'bodovi', '\D', '', 'g'), '')::int
          is distinct from izracun.bodovi
  ) into v_odstupa;

  v_rezultat := jsonb_set(
    v_rezultat,
    '{meta,sluzbena_tablica_odstupa}',
    to_jsonb(coalesce(v_odstupa, false))
  );

  return v_rezultat;
end;
$$;


-- =====================================================================
-- PRISTUP
-- =====================================================================
-- Kao i najava_kola(): "security invoker", dakle poštuje RLS pozivatelja
-- i ne otvara nikakav novi pristup podacima. Namijenjena je pisanju
-- osvrta, pa je javni ključ ne dobiva.
-- =====================================================================

revoke all on function public.pregled_kola(text, text, int, int) from public;
revoke all on function public.pregled_kola_tablica(text, text, int) from public;
revoke all on function public.pregled_kola_golovi(text, text, int) from public;
revoke all on function public.pregled_kola_iskljucenja(text, text, int) from public;
revoke all on function public.pregled_kola_serije(text, text, int) from public;

do $$
declare
  v_funkcija text;
begin
  foreach v_funkcija in array array[
    'public.pregled_kola(text,text,int,int)',
    'public.pregled_kola_tablica(text,text,int)',
    'public.pregled_kola_golovi(text,text,int)',
    'public.pregled_kola_iskljucenja(text,text,int)',
    'public.pregled_kola_serije(text,text,int)'
  ]
  loop
    if exists (select 1 from pg_roles where rolname = 'anon') then
      execute format('revoke all on function %s from anon', v_funkcija);
    end if;
    if exists (select 1 from pg_roles where rolname = 'authenticated') then
      execute format('revoke all on function %s from authenticated', v_funkcija);
    end if;
    if exists (select 1 from pg_roles where rolname = 'service_role') then
      execute format('grant execute on function %s to service_role', v_funkcija);
    end if;
  end loop;
end
$$;


-- =====================================================================
-- TESTOVI — pokreni ih JEDAN PO JEDAN i pošalji ispis
-- =====================================================================
-- 1. prvo kolo: tablica "prije" i pomaci moraju biti null
-- select jsonb_pretty(public.pregled_kola('2025/26', '3. NL Zapad', 1));
--
-- 2. sredina sezone
-- select jsonb_pretty(public.pregled_kola('2025/26', '3. NL Zapad', 15));
--
-- 3. bez broja kola: zadnje kolo koje ima rezultate
-- select jsonb_pretty(public.pregled_kola('2025/26', '3. NL Zapad'));
--
-- 4. druga liga
-- select jsonb_pretty(public.pregled_kola('2025/26', '4. NL NS Rijeka', 10));
--
-- 5. kolo koje se još nije odigralo (očekivano: opisna iznimka)
-- select public.pregled_kola('2026/27', '3. NL Zapad', 1);
-- =====================================================================

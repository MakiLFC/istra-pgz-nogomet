-- =====================================================================
-- public.najava_kola() — podaci za novinarsku najavu kola, kao jedan JSON
-- =====================================================================
-- KAKO SE KORISTI:
--   select jsonb_pretty(public.najava_kola('2026/27', '3. NL Zapad'));
--
-- Pokreni ovu datoteku JEDNOM u Supabase SQL Editoru. Nakon toga je
-- funkcija tu i zoveš je gornjom naredbom kad pišeš najavu.
--
-- ---------------------------------------------------------------------
-- ŠTO OVA FUNKCIJA NE MOŽE, I ZAŠTO (pročitaj prije nego se začudiš)
-- ---------------------------------------------------------------------
-- 1. TABLICA SE RAČUNA IZ UTAKMICA, ne čita se iz "statistike".
--    Tablica "statistike" drži samo JEDNO, zadnje stanje po ligi i
--    sezoni; scraper ga prepisuje pri svakom pokretanju. Povijesti nema,
--    pa se poredak prije nekog kola ne bi mogao rekonstruirati.
--    Zato se ovdje računa iz odigranih utakmica prethodnih kola.
--
--    CIJENA: službena tablica UKLJUČUJE kaznene bodove (npr.
--    "NK Crikvenica (-3)"), a izračunata ih ne zna. Zato funkcija uz
--    izračun vraća i "sluzbena_tablica_odstupa": kad je true, negdje
--    postoji kazneni bod i brojkama ne treba slijepo vjerovati.
--
-- 2. "suspendirani" je UVIJEK prazan.
--    U bazi ne postoji podatak o kaznama, niti u kojem je kolu karton
--    dobiven ("kartoni" je zbroj za cijelu sezonu). Tko baš ovo kolo
--    odrađuje kaznu ne može se izvesti ni na koji način. Polje postoji
--    da oblik JSON-a ostane stabilan, ali ostaje prazno.
--
-- 3. "na_pragu_suspenzije" je stanje OD ZADNJEG SCRAPEA, ne "prije ovog
--    kola" — iz istog razloga kao točka 1.
--
-- 4. PRAG ŽUTIH (p_prag_zutih) NIJE PROVJEREN.
--    Zadano je 4, ali to je pretpostavka, ne podatak iz propozicija.
--    Prag se razlikuje po natjecanjima. Kad ga potvrdiš u propozicijama
--    NS Rijeka odnosno HNS-a, ili promijeni zadanu vrijednost ovdje, ili
--    ga predaj pri pozivu:  public.najava_kola('2026/27','3. NL Zapad',null,5)
--
-- 5. VRATARI SE NE BROJE U STRIJELCE.
--    Na HNS Semaforu stupac "golovi" kod vratara znači PRIMLJENE golove.
--    Scraper ih već izbacuje iz liste strijelaca (slozi_pune_rang_liste),
--    pa ih u "statistike" tip='strijelci' nema. Ova funkcija čita baš tu
--    listu i zato je sigurna. NE računaj strijelce iz utakmice.strijelci
--    bez dodatnog filtriranja po pozicijama iz postava.
--
-- OZNAKE FORME:  P = pobjeda, N = neriješeno, I = izgubljeno
-- =====================================================================

create or replace function public.najava_kola(
  p_sezona     text,
  p_liga       text,
  p_kolo       int default null,   -- null = prvo kolo koje još nije odigrano
  p_prag_zutih int default 4       -- vidi napomenu 4 gore
)
returns jsonb
language plpgsql
stable
security invoker
as $$
declare
  v_liga        text;
  v_sezona      text;
  v_kolo        int;
  v_prvo_kolo   boolean;
  v_odstupa     boolean;
  v_rezultat    jsonb;
begin
  ------------------------------------------------------------------
  -- 1. Razriješi ligu i sezonu (fuzzy, preko ILIKE)
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
  if p_kolo is null then
    select min(u.kolo) into v_kolo
    from public.utakmice u
    where u.natjecanje = v_liga
      and u.sezona = v_sezona
      and coalesce(u.rezultat, '') !~ '^\s*\d+\s*:\s*\d+\s*$';

    if v_kolo is null then
      raise exception
        'Sve utakmice lige % u sezoni % su odigrane, nema nadolazećeg kola',
        v_liga, v_sezona;
    end if;
  else
    v_kolo := p_kolo;

    if not exists (
      select 1 from public.utakmice u
      where u.natjecanje = v_liga and u.sezona = v_sezona and u.kolo = v_kolo
    ) then
      raise exception 'Kolo % ne postoji u ligi % (sezona %)',
        v_kolo, v_liga, v_sezona;
    end if;

    -- sve utakmice traženog kola već odigrane -> iznimka s prijedlogom
    if not exists (
      select 1 from public.utakmice u
      where u.natjecanje = v_liga and u.sezona = v_sezona and u.kolo = v_kolo
        and coalesce(u.rezultat, '') !~ '^\s*\d+\s*:\s*\d+\s*$'
    ) then
      raise exception
        'Sve utakmice %. kola (%, %) su odigrane. Prvo neodigrano kolo je %.',
        v_kolo, v_liga, v_sezona,
        coalesce((
          select min(u.kolo)::text from public.utakmice u
          where u.natjecanje = v_liga and u.sezona = v_sezona
            and coalesce(u.rezultat,'') !~ '^\s*\d+\s*:\s*\d+\s*$'
        ), 'nijedno, sezona je gotova');
    end if;
  end if;

  ------------------------------------------------------------------
  -- 3. Ima li uopće odigranih kola prije ovoga?
  --    Ako nema, forma i tablica su null (ne nule).
  ------------------------------------------------------------------
  select not exists (
    select 1 from public.utakmice u
    where u.natjecanje = v_liga and u.sezona = v_sezona
      and u.kolo < v_kolo
      and u.rezultat ~ '^\s*\d+\s*:\s*\d+\s*$'
  ) into v_prvo_kolo;

  ------------------------------------------------------------------
  -- 4. Glavni izračun
  ------------------------------------------------------------------
  with
  -- odigrane utakmice ove lige i sezone, s razdvojenim golovima
  odigrane as (
    select u.kolo,
           u.domacin,
           u.gost,
           u.datum,
           split_part(replace(u.rezultat, ' ', ''), ':', 1)::int as g_dom,
           split_part(replace(u.rezultat, ' ', ''), ':', 2)::int as g_gos
    from public.utakmice u
    where u.natjecanje = v_liga
      and u.sezona = v_sezona
      and u.rezultat ~ '^\s*\d+\s*:\s*\d+\s*$'
  ),
  -- samo kola PRIJE traženog (to je "stanje prije ovog kola")
  prije as (
    select * from odigrane where kolo < v_kolo
  ),
  -- jedan redak po nastupu kluba
  nastupi as (
    select domacin as klub, g_dom as dano, g_gos as primljeno, kolo from prije
    union all
    select gost    as klub, g_gos as dano, g_dom as primljeno, kolo from prije
  ),
  zbroj as (
    select klub,
           count(*)                                                    as odigrano,
           sum(case when dano > primljeno then 3
                    when dano = primljeno then 1 else 0 end)::int      as bodovi,
           (sum(dano) - sum(primljeno))::int                           as gol_razlika
    from nastupi
    group by klub
  ),
  poredak as (
    select klub, bodovi, gol_razlika, odigrano,
           row_number() over (
             order by bodovi desc, gol_razlika desc, klub
           )::int as pozicija
    from zbroj
  ),
  -- oznake forme po nastupu, najnovija prva
  forma_redovi as (
    select klub, kolo,
           case when dano > primljeno then 'P'
                when dano = primljeno then 'N'
                else 'I' end as oznaka,
           row_number() over (partition by klub order by kolo desc) as rn
    from nastupi
  ),
  forma as (
    select klub, jsonb_agg(oznaka order by rn) as forma
    from forma_redovi
    where rn <= 5
    group by klub
  ),
  -- duljina niza od zadnje utakmice unatrag
  serije as (
    select klub,
           coalesce(min(rn) filter (where oznaka = 'I'), count(*) + 1) - 1 as bez_poraza,
           coalesce(min(rn) filter (where oznaka <> 'P'), count(*) + 1) - 1 as pobjeda_zaredom,
           coalesce(min(rn) filter (where oznaka <> 'I'), count(*) + 1) - 1 as poraza_zaredom
    from forma_redovi
    group by klub
  ),
  serija_tekst as (
    select klub,
           case
             when pobjeda_zaredom >= 2 then pobjeda_zaredom || ' pobjede zaredom'
             when poraza_zaredom  >= 2 then poraza_zaredom  || ' poraza zaredom'
             when bez_poraza      >= 3 then bez_poraza      || ' utakmice bez poraza'
             else null
           end as serija
    from serije
  ),
  -- vodeći strijelac po klubu (vratara ovdje nema, vidi napomenu 5)
  strijelci_svi as (
    select e ->> 'klub'          as klub,
           e ->> 'igrac'         as igrac,
           nullif(e ->> 'golovi', '')::int as golovi,
           row_number() over (
             partition by e ->> 'klub'
             order by nullif(e ->> 'golovi', '')::int desc nulls last, e ->> 'igrac'
           ) as rn
    from public.statistike s,
         lateral jsonb_array_elements(s.podaci) e
    where s.natjecanje = v_liga and s.sezona = v_sezona and s.tip = 'strijelci'
  ),
  vodeci as (
    select klub, jsonb_build_object('ime', igrac, 'golovi', golovi) as vodeci_strijelac
    from strijelci_svi
    where rn = 1 and golovi > 0
  ),
  -- igrači na korak od suspenzije (stanje od zadnjeg scrapea)
  na_pragu as (
    select e ->> 'klub' as klub,
           jsonb_agg(jsonb_build_object(
             'ime',  e ->> 'igrac',
             'zuti', nullif(e ->> 'zuti', '')::int
           ) order by e ->> 'igrac') as lista
    from public.statistike s,
         lateral jsonb_array_elements(s.podaci) e
    where s.natjecanje = v_liga and s.sezona = v_sezona and s.tip = 'kartoni'
      and nullif(e ->> 'zuti', '')::int = greatest(p_prag_zutih - 1, 0)
    group by 1
  ),
  -- utakmice traženog kola
  kolo_utakmice as (
    select u.id,
           u.domacin,
           u.gost,
           u.stadion,
           u.rezultat,
           case
             when u.datum is null then null
             else (to_timestamp(
                     u.datum || ' ' || coalesce(nullif(u.vrijeme, ''), '00:00'),
                     'DD.MM.YYYY. HH24:MI'
                   )::timestamp at time zone 'Europe/Zagreb')
           end as termin
    from public.utakmice u
    where u.natjecanje = v_liga and u.sezona = v_sezona and u.kolo = v_kolo
  )
  select jsonb_build_object(
    'meta', jsonb_build_object(
      'liga',   v_liga,
      'sezona', v_sezona,
      'kolo',   v_kolo,
      'prvi_termin',  (select min(termin) from kolo_utakmice),
      'zadnji_termin',(select max(termin) from kolo_utakmice),
      'prvo_kolo_sezone', v_prvo_kolo,
      'prag_zutih', p_prag_zutih,
      'napomena', case when v_prvo_kolo
                       then 'Prvo kolo sezone: forma, tablica i strijelci još ne postoje.'
                       else 'Tablica je IZRAČUNATA iz odigranih utakmica i ne uključuje kaznene bodove.'
                  end
    ),
    'utakmice', coalesce((
      select jsonb_agg(red order by red_termin nulls last, red_domacin)
      from (
        select
          k.termin as red_termin,
          k.domacin as red_domacin,
          jsonb_build_object(
            'utakmica_id', k.id,
            'termin',      k.termin,
            -- Čitljiv termin po hrvatski. "termin" je ISO i prikazuje se u
            -- vremenskoj zoni sesije (u Supabaseu UTC), pa je ovo polje tu
            -- da se u najavu može prepisati bez preračunavanja.
            'termin_hr',   case when k.termin is null then null else
              (case extract(dow from k.termin at time zone 'Europe/Zagreb')::int
                 when 0 then 'nedjelja'  when 1 then 'ponedjeljak'
                 when 2 then 'utorak'    when 3 then 'srijeda'
                 when 4 then 'četvrtak'  when 5 then 'petak'
                 else 'subota' end)
              || ' ' || to_char(k.termin at time zone 'Europe/Zagreb', 'DD.MM.YYYY.')
              || ' u ' || to_char(k.termin at time zone 'Europe/Zagreb', 'HH24:MI')
            end,
            'stadion',     k.stadion,
            'rezultat',    case when k.rezultat ~ '^\s*\d+\s*:\s*\d+\s*$'
                                then k.rezultat else null end,
            'domacin', public.najava_kola_klub(
                         k.domacin, v_prvo_kolo,
                         (select to_jsonb(p) from poredak p where p.klub = k.domacin),
                         (select f.forma from forma f where f.klub = k.domacin),
                         (select s.serija from serija_tekst s where s.klub = k.domacin),
                         (select v.vodeci_strijelac from vodeci v where v.klub ilike k.domacin),
                         (select n.lista from na_pragu n where n.klub ilike k.domacin)
                       ),
            'gost', public.najava_kola_klub(
                         k.gost, v_prvo_kolo,
                         (select to_jsonb(p) from poredak p where p.klub = k.gost),
                         (select f.forma from forma f where f.klub = k.gost),
                         (select s.serija from serija_tekst s where s.klub = k.gost),
                         (select v.vodeci_strijelac from vodeci v where v.klub ilike k.gost),
                         (select n.lista from na_pragu n where n.klub ilike k.gost)
                       ),
            'h2h', coalesce((
              select jsonb_agg(jsonb_build_object(
                       'sezona',  h.sezona,
                       'datum',   h.datum,
                       'domacin', h.domacin,
                       'gost',    h.gost,
                       'rezultat',h.rezultat
                     ) order by h.sezona desc, h.kolo desc)
              from (
                select u2.sezona, u2.datum, u2.domacin, u2.gost, u2.rezultat, u2.kolo
                from public.utakmice u2
                where u2.rezultat ~ '^\s*\d+\s*:\s*\d+\s*$'
                  and (   (u2.domacin ilike k.domacin and u2.gost ilike k.gost)
                       or (u2.domacin ilike k.gost    and u2.gost ilike k.domacin))
                  and not (u2.sezona = v_sezona and u2.kolo = v_kolo)
                order by u2.sezona desc, u2.kolo desc
                limit 4
              ) h
            ), '[]'::jsonb)
          ) as red
        from kolo_utakmice k
      ) t
    ), '[]'::jsonb)
  ) into v_rezultat;

  ------------------------------------------------------------------
  -- 5. Kontrola: odstupa li izračun od službene tablice?
  --    Ako da, negdje postoji kazneni bod (vidi napomenu 1).
  ------------------------------------------------------------------
  -- Ako u sezoni još nema nijedne odigrane utakmice, nema se što
  -- usporediti: izračun je prazan, a službena tablica ima klubove s
  -- nulama. Bez ove ograde to bi lažno javljalo odstupanje.
  if not exists (
    select 1 from public.utakmice u
    where u.natjecanje = v_liga and u.sezona = v_sezona
      and u.rezultat ~ '^\s*\d+\s*:\s*\d+\s*$'
  ) then
    v_odstupa := false;
  else
  select exists (
    select 1
    from public.statistike s,
         lateral jsonb_array_elements(s.podaci) e
    join lateral (
      select sum(case when dano > primljeno then 3
                      when dano = primljeno then 1 else 0 end)::int as bodovi
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
  end if;

  v_rezultat := jsonb_set(
    v_rezultat,
    '{meta,sluzbena_tablica_odstupa}',
    to_jsonb(coalesce(v_odstupa, false))
  );

  return v_rezultat;
end;
$$;


-- ---------------------------------------------------------------------
-- Pomoćna funkcija: složi blok jednog kluba.
-- Postoji samo da glavni upit ostane čitljiv; sve što radi je slaganje
-- JSON-a i pretvaranje "nema podataka" u null umjesto u nule.
-- ---------------------------------------------------------------------
create or replace function public.najava_kola_klub(
  p_naziv       text,
  p_prvo_kolo   boolean,
  p_poredak     jsonb,
  p_forma       jsonb,
  p_serija      text,
  p_strijelac   jsonb,
  p_na_pragu    jsonb
)
returns jsonb
language sql
immutable
as $$
  select jsonb_build_object(
    'naziv',       p_naziv,
    'pozicija',    case when p_prvo_kolo then null else p_poredak -> 'pozicija' end,
    'bodovi',      case when p_prvo_kolo then null else p_poredak -> 'bodovi' end,
    'gol_razlika', case when p_prvo_kolo then null else p_poredak -> 'gol_razlika' end,
    'forma',       case when p_prvo_kolo then null else p_forma end,
    'serija',      case when p_prvo_kolo then null else to_jsonb(p_serija) end,
    'vodeci_strijelac', p_strijelac,
    'na_pragu_suspenzije', coalesce(p_na_pragu, '[]'::jsonb),
    -- uvijek prazno, vidi napomenu 2 na vrhu datoteke
    'suspendirani', '[]'::jsonb
  );
$$;


-- =====================================================================
-- PRISTUP
-- =====================================================================
-- Funkcija je "security invoker", dakle poštuje RLS pozivatelja i ne
-- otvara nikakav novi pristup podacima. Svejedno je namijenjena samo
-- tebi za pisanje najava, pa se javnom ključu ne daje.
-- =====================================================================

revoke all on function public.najava_kola(text, text, int, int) from public;
revoke all on function public.najava_kola_klub(text, boolean, jsonb, jsonb, text, jsonb, jsonb) from public;

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    execute 'revoke all on function public.najava_kola(text,text,int,int) from anon';
    execute 'revoke all on function public.najava_kola_klub(text,boolean,jsonb,jsonb,text,jsonb,jsonb) from anon';
  end if;
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    execute 'revoke all on function public.najava_kola(text,text,int,int) from authenticated';
    execute 'revoke all on function public.najava_kola_klub(text,boolean,jsonb,jsonb,text,jsonb,jsonb) from authenticated';
  end if;
  if exists (select 1 from pg_roles where rolname = 'service_role') then
    execute 'grant execute on function public.najava_kola(text,text,int,int) to service_role';
    execute 'grant execute on function public.najava_kola_klub(text,boolean,jsonb,jsonb,text,jsonb,jsonb) to service_role';
  end if;
end
$$;


-- =====================================================================
-- TESTOVI — pokreni ih JEDAN PO JEDAN i pošalji ispis
-- =====================================================================
-- 1. nadolazeće kolo, nova sezona
--    očekivano: prvo_kolo_sezone = true, forma i tablica null
-- select jsonb_pretty(public.najava_kola('2026/27', '3. NL Zapad'));
--
-- 2. sredina prošle sezone
--    očekivano: puna forma, tablica, h2h, strijelci
--    PAZI: pozicije se NEĆE poklapati sa stranicom lige, jer ondje stoji
--    završna tablica sezone, a ovdje stanje prije 15. kola. To je točno.
-- select jsonb_pretty(public.najava_kola('2025/26', '3. NL Zapad', 15));
--
-- 3. fuzzy naziv lige (očekivano: true)
-- select public.najava_kola('2026/27', '3. nl zapad') is not null;
--
-- 4. nepostojeća liga (očekivano: opisna iznimka)
-- select public.najava_kola('2026/27', 'Nepostojeća liga');
--
-- 5. 4. NL
-- select jsonb_pretty(public.najava_kola('2026/27', '4. NL NS Rijeka'));
-- =====================================================================

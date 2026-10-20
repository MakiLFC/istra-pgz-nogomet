-- sql/igraci_rpc.sql
--
-- Dvije funkcije koje stranici daju SAMO ono što joj treba o igračima.
-- Pokreni ih u Supabaseu (SQL Editor), jednom. Dok ne budu pokrenute,
-- stranica radi po starom: lib/igraci.ts ima rezervu i sam se vrati na
-- puni dohvat ako funkcije nema.
--
-- ZAŠTO POSTOJE
--
-- Supabase je 19.10.2026. javio da je prijeđena kvota odlaznog prometa
-- besplatnog plana (5 GB), a raščlamba je pokazala da 98,7 posto otpada
-- na upite prema bazi, a samo 1,3 posto na fotografije.
--
-- Uzrok: da bi prikazala JEDNOG igrača, stranica je dohvaćala rang-liste
-- SVIH liga i OBIJU sezona, dakle oko 3850 stavki, jer se igrač po slugu
-- tražio tek u kodu. Isto je radila i stranica utakmice i lige, kojima
-- treba samo popis imena koja smiju biti poveznica.
--
-- S ovim funkcijama baza odradi izbor i pošalje nekoliko stavki umjesto
-- cijele lige.

-- ---------------------------------------------------------------------
-- Slug imena, isto kao slugKluba u lib/slug.ts
-- ---------------------------------------------------------------------
-- JavaScript to radi preko NFD razlaganja (č -> c + znak, pa se znak
-- makne), a đ zamjenjuje ručno, jer se ono ne razlaže. Ovdje je ista
-- stvar napisana kao zamjena znak za znak.
--
-- Ako se dvije strane ikad raziđu za neko ime, posljedica je samo da
-- brzi put ne nađe igrača, pa se stranica vrati na puni dohvat i
-- prikaže ga kao i dosad. Dakle ne može nastati kriva stranica.
create or replace function public.slug_imena(ime text)
returns text
language sql
immutable
as $$
  select trim(both '-' from
    regexp_replace(
      translate(
        lower(coalesce(ime, '')),
        'đčćžšáàâäãéèêëíìîïóòôöõúùûüýñç',
        'dcczsaaaaaeeeeiiiiooooouuuuync'
      ),
      '[^a-z0-9]+', '-', 'g'
    )
  );
$$;

-- ---------------------------------------------------------------------
-- Učinci jednog igrača, po ligi i sezoni
-- ---------------------------------------------------------------------
-- Vraća pojedine stavke rang-lista u kojima se taj igrač pojavljuje,
-- uz ligu, sezonu i tip liste. Kod od toga slaže isti profil kao i
-- prije, samo bez vučenja cijele baze.
create or replace function public.ucinci_igraca(p_slug text)
returns table (
  natjecanje text,
  sezona text,
  tip text,
  stavka jsonb
)
language sql
stable
as $$
  select s.natjecanje, s.sezona, s.tip, e.stavka
  from public.statistike s
  cross join lateral jsonb_array_elements(s.podaci) as e(stavka)
  where s.tip in ('strijelci', 'kartoni', 'nastupi')
    and coalesce(e.stavka ->> 'klub', '') <> ''
    and public.slug_imena(e.stavka ->> 'igrac') = p_slug;
$$;

-- ---------------------------------------------------------------------
-- Imena igrača jedne lige i sezone
-- ---------------------------------------------------------------------
-- Za poveznice u postavama. Vraća SAMO imena, ne i slugove, pa slug i
-- dalje računa ista funkcija u kodu kao i za adresu stranice igrača.
-- Tako se dvije strane ne mogu raziđi u tome što je čija adresa.
create or replace function public.imena_igraca_lige(
  p_natjecanje text,
  p_sezona text
)
returns table (ime text)
language sql
stable
as $$
  select distinct e.stavka ->> 'igrac'
  from public.statistike s
  cross join lateral jsonb_array_elements(s.podaci) as e(stavka)
  where s.natjecanje = p_natjecanje
    and s.sezona = p_sezona
    and s.tip in ('strijelci', 'kartoni', 'nastupi')
    and coalesce(e.stavka ->> 'klub', '') <> ''
    and coalesce(e.stavka ->> 'igrac', '') <> '';
$$;

-- ---------------------------------------------------------------------
-- Prava
-- ---------------------------------------------------------------------
-- Stranica čita bazu javnim anon ključem. Supabase je najavio da od
-- 30.10.2026. novo u shemi public ne dobiva prava samo od sebe, pa se
-- ovdje daju izričito. Pisanja nema, ovo su funkcije koje samo čitaju.
grant execute on function public.slug_imena(text) to anon, authenticated, service_role;
grant execute on function public.ucinci_igraca(text) to anon, authenticated, service_role;
grant execute on function public.imena_igraca_lige(text, text) to anon, authenticated, service_role;

-- ---------------------------------------------------------------------
-- Provjera nakon pokretanja
-- ---------------------------------------------------------------------
-- Prvo: koliko stavki vrati za jednog igrača (očekuje se nekoliko, ne
-- nekoliko tisuća).
--
--   select * from public.ucinci_igraca('marcelo-suden');
--
-- Drugo: koliko imena ima jedna liga (očekuje se nekoliko stotina).
--
--   select count(*) from public.imena_igraca_lige('3. NL Zapad', '2026/27');
--
-- Treće, najvažnije: slaže li se slug iz baze s onim iz koda. Popis
-- ispod pošalji Claudeu, koji ga usporedi s onim što računa stranica.
--
--   select distinct e.stavka ->> 'igrac' as ime,
--          public.slug_imena(e.stavka ->> 'igrac') as slug
--   from public.statistike s
--   cross join lateral jsonb_array_elements(s.podaci) as e(stavka)
--   where s.tip in ('strijelci', 'kartoni', 'nastupi')
--     and coalesce(e.stavka ->> 'klub', '') <> ''
--   order by ime;

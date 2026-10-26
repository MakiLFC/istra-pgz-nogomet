-- sql/nastupi_rpc.sql
--
-- Jedna funkcija, nastavak na sql/igraci_rpc.sql. Pokreni je u Supabaseu
-- (SQL Editor), jednom. Dok nije pokrenuta, stranica radi po starom:
-- lib/igraci.ts ima rezervu i sam se vrati na stari dohvat.
--
-- ZAŠTO POSTOJI
--
-- Stranica igrača pokazuje popis utakmica u kojima je igrač nastupio, s
-- njegovim golovima, kartonima i izmjenama. Da bi to dobila, dosad je
-- dohvaćala RETKE UTAKMICA, a u njima stupce postava_domacin i
-- postava_gost, dakle OBJE pune postave sa svim igračima i svim njihovim
-- događajima. Za igrača s petnaest nastupa to je petnaest cijelih
-- zapisnika, a iz svakog se koristio jedan redak.
--
-- Nakon prvog rezanja (20.10.2026.) odlazni promet je pao s oko 218 na
-- oko 125 MB dnevno, ali je i dalje 98,8 posto bio PostgREST. Ovo je
-- drugo mjesto koje je ostalo, zapisano tada kao "ostaje za sljedeći
-- put".
--
-- ŠTO VRAĆA
--
-- Po jedan redak za svaki nastup: podatke utakmice kao jsonb, ime kluba
-- za koji je igrao, je li bio pričuva i njegove događaje. Dakle samo
-- ono što stranica prikazuje.
--
-- Utakmica se vraća kao jsonb namjerno: tako funkcija ne ovisi o tome
-- kojeg su tipa stupci u tablici (id, kolo i datum su se već mijenjali),
-- pa je neće srušiti buduća promjena sheme.

create or replace function public.nastupi_igraca(p_ime text)
returns table (
  utakmica jsonb,
  klub text,
  pricuvni boolean,
  dogadjaji jsonb
)
language sql
stable
as $$
  -- Nastupi za domaću momčad
  select
    jsonb_build_object(
      'id', u.id,
      'natjecanje', u.natjecanje,
      'sezona', u.sezona,
      'kolo', u.kolo,
      'domacin', u.domacin,
      'gost', u.gost,
      'rezultat', u.rezultat,
      'datum', u.datum
    ),
    u.domacin,
    coalesce((e.stavka ->> 'pricuvni')::boolean, false),
    coalesce(e.stavka -> 'dogadjaji', '[]'::jsonb)
  from public.utakmice u
  cross join lateral jsonb_array_elements(
    case when jsonb_typeof(u.postava_domacin) = 'array'
         then u.postava_domacin
         else '[]'::jsonb end
  ) as e(stavka)
  where e.stavka ->> 'igrac' = p_ime

  union all

  -- Nastupi za gostujuću momčad
  select
    jsonb_build_object(
      'id', u.id,
      'natjecanje', u.natjecanje,
      'sezona', u.sezona,
      'kolo', u.kolo,
      'domacin', u.domacin,
      'gost', u.gost,
      'rezultat', u.rezultat,
      'datum', u.datum
    ),
    u.gost,
    coalesce((e.stavka ->> 'pricuvni')::boolean, false),
    coalesce(e.stavka -> 'dogadjaji', '[]'::jsonb)
  from public.utakmice u
  cross join lateral jsonb_array_elements(
    case when jsonb_typeof(u.postava_gost) = 'array'
         then u.postava_gost
         else '[]'::jsonb end
  ) as e(stavka)
  where e.stavka ->> 'igrac' = p_ime;
$$;

-- Stranica čita bazu javnim anon ključem, a od 30.10.2026. novo u shemi
-- public ne dobiva prava samo od sebe. Funkcija samo čita.
grant execute on function public.nastupi_igraca(text) to anon, authenticated, service_role;

-- ---------------------------------------------------------------------
-- Provjera nakon pokretanja
-- ---------------------------------------------------------------------
-- Očekuje se po jedan redak za svaki nastup tog igrača, a ne cijeli
-- zapisnici. Usporedi broj redaka s brojem utakmica na njegovoj
-- stranici na lokalarena.com.
--
--   select * from public.nastupi_igraca('Marcelo Suden');
--
-- Ime se piše TOČNO kako stoji u zapisniku, s kvačicama, jer se ovdje
-- traži po imenu, ne po adresi.

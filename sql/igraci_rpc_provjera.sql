-- sql/igraci_rpc_provjera.sql
--
-- Tri provjere nakon pokretanja sql/igraci_rpc.sql. Pokreću se JEDNA PO
-- JEDNA: SQL Editor prikazuje rezultat samo zadnje naredbe.

-- 1. Koliko baza šalje za jednog igrača.
--    Očekuje se nekoliko redaka, po jedan za svaku ligu, sezonu i vrstu
--    liste u kojoj se pojavljuje. Prije ove izmjene stranica je za istog
--    igrača vukla oko 3850 stavki.
select * from public.ucinci_igraca('marcelo-suden');


-- 2. Koliko imena ima jedna liga, za poveznice u postavama.
--    Očekuje se nekoliko stotina.
select count(*) from public.imena_igraca_lige('3. NL Zapad', '2026/27');


-- 3. Slaže li se adresa koju računa baza s onom koju računa stranica.
--    Ispis ima oko dvije tisuće redaka; preuzmi ga kao CSV i pošalji
--    Claudeu, koji ga usporedi sa slugKluba iz lib/slug.ts.
--
--    Razilaženje nije kvar: igrač se tada nađe starim, skupljim putem.
--    Ali bolje da se zna.
select distinct e.stavka ->> 'igrac' as ime,
       public.slug_imena(e.stavka ->> 'igrac') as slug
from public.statistike s
cross join lateral jsonb_array_elements(s.podaci) as e(stavka)
where s.tip in ('strijelci', 'kartoni', 'nastupi')
  and coalesce(e.stavka ->> 'klub', '') <> ''
order by ime;

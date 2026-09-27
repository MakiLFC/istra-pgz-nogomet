-- =====================================================================
-- ČLANAK: PREGLED 4. KOLA 1. ŽNL PGŽ 2026/27
-- Odigrano 26. i 27.09.2026.; Rab - Goranin odgođen.
-- =====================================================================
-- NACRT, NE POKRETATI. Subotnje utakmice su napisane, nedjeljne se
-- dopisuju nakon utakmica (mjesta oznacena s [[...]]).
--
-- KAKO SE KORISTI: dva koraka, kao i kod ostalih clanaka.
--   Upis se smije ponoviti: prepisu se samo naslov, sazetak i tekst.
--
-- ODAKLE STO
--   Subota (Lovran - Draga, Zamet - Risnjak): zapisnici sa Semafora,
--   posao "Ispis kola" 27.09.2026. u 14:45 po nasem.
--   Nedjelja: [[public.pregled_kola('2026/27','1. ŽNL PGŽ',4) nakon
--   utakmica]].
--   Kup (Lovran - Opatija 0:7) iz clanka o 1/16 finala i najave 4. kola.
--   Ucinak kod kuce izracunat iz rezultata sezone: Lovran je prije ovog
--   kola kod kuce dobio obje utakmice, Zamet je kod kuce dobio Omladinac
--   2:1 (najava 4. kola).
--   ANDREJEVO: "susjedski derbi" za Lovran - Draga (iz najave). Odlomak
--   o Lovranu je njegova verzija (27.09.). Za Risnjak: "kao da nikada
--   nije ni ispao iz ove lige" (27.09.).
--
-- RISNJAK
--   Rupe je u 3. kolu zabio pobjednicki gol protiv Vrbovskog u trecoj
--   minuti nadoknade (najava 4. kola), a sada u 49. gol za 1:2, koji je
--   ostao konacan. Zato "drugo kolo zaredom pobjednicki gol".
-- =====================================================================

insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'pregled-4-kola-1-znl-pgz-2627',
  '[[NASLOV, npr. LOVRAN ČETIRI OD ČETIRI I PET BODOVA ISPRED RABA]]',
  '[[SAZETAK]]',
'Četvrto kolo 1. ŽNL PGŽ odigrano je u subotu 26. i nedjelju 27. rujna. Susret Rab - Goranin je odgođen. [[BROJ GOLOVA U KOLU, NAJVIŠE GLEDATELJA]]

Lovran - Draga 2:1. Lovran je u susjedskom derbiju na Lokvi, pred čak 300 gledatelja, upisao četvrtu pobjedu iz četiri utakmice i treću kod kuće. Do 77. minute bilo je bez golova, a onda je Mateo Mandić doveo domaćina u vodstvo. Potom je Patrik Vidmar u 84. povisio na 2:0, dok je Andrea Štemberger smanjio za Dragu u 88. minuti. Vidmar je sa sedam pogodaka i dalje prvi strijelac lige. Lovran se tako tri dana nakon poraza od Opatije u kupu, 0:7 na istom terenu, vratio pobjedom, a kako Rab nije igrao, ima pet bodova prednosti ispred njega.

Zamet - Risnjak 1:2. Zamet je na igralištu Robert Komen poveo već u 7. minuti golom Hrvoja Ožanića, ali je Risnjak preokrenuo. Erik Grgurić izjednačio je u 39. minuti, a Karlo Rupe u 49. zabio za 1:2, drugo kolo zaredom pobjednički gol. Risnjak je upisao drugu pobjedu zaredom, a Zamet prvi poraz kod kuće ove sezone. I ovaj rezultat pokazuje da Risnjak igra kao da nikada nije ni ispao iz ove lige.

[[Stari grad Rijeka - Lošinj]]

[[Turbina - Omladinac Vrata]]

[[Vihor - Mune]]

[[Vrbovsko - Rikard Benčić]]

LJESTVICA

[[Nakon nedjelje. Lovran 12 bodova iz četiri utakmice, Rab 7 iz tri (nije igrao). Provjeriti da svi klubovi koji su igrali imaju isti broj utakmica, vidi CLAUDE.md.]]

STRIJELCI

[[Vidmar 7. Šneler (Mune) ima 4 i igra u nedjelju.]]

KAZNE

[[U suboti nije bilo isključenja. Nedjelja iz pregled_kola.]]',
  '1. ŽNL PGŽ',
  false,
  now()
)
on conflict (slug) do update
  set naslov  = excluded.naslov,
      sazetak = excluded.sazetak,
      tekst   = excluded.tekst;

-- OBJAVA:
-- update public.clanci set objavljen = true
-- where slug = 'pregled-4-kola-1-znl-pgz-2627'
-- returning slug, naslov, objavljen;

-- =====================================================================
-- ČLANAK: PREGLED 4. KOLA 1. ŽNL PGŽ 2026/27
-- Odigrano 26. i 27.09.2026.; Rab - Goranin odgođen.
-- =====================================================================
-- KAKO SE KORISTI: dva koraka, kao i kod ostalih clanaka.
--   Upis se smije ponoviti: prepisu se samo naslov, sazetak i tekst.
--
-- ODAKLE STO
--   Subota (Lovran - Draga, Zamet - Risnjak): zapisnici sa Semafora,
--   posao "Ispis kola" 27.09.2026. u 14:45 po nasem.
--   Nedjelja: isti posao s postavama, 27.09.2026. u 18:35 po nasem.
--   Stari grad - Losinj: zapisnik objavljen tek oko 19:25, ispis u 19:27.
--   Tijek te utakmice je Andrejev (bio na utakmici), vidi
--   sql/clanak_stari_grad_losinj_4_kolo.sql.
--   Ljestvica je sluzbena, iz istog ispisa (svi klubovi koji su igrali
--   imaju po cetiri utakmice, Rab i Goranin tri).
--
-- POMACI
--   Ljestvica prije kola izracunata je tako da se od sluzbene oduzme ovo
--   kolo: Lovran 9, Rab 7, Turbina 6 (+3), Losinj 6 (+2), Stari grad 5,
--   Mune 4 (+3), Omladinac 4 (+1), Goranin 4 (-1), Risnjak 4 (-6),
--   Vrbovsko 3 (-1), Zamet 3 (-3), Draga 3 (-5), Rikard Bencic 1, Vihor 0.
--   Poredak se slaze s najavom 4. kola (Draga dvanaesta). Poslije kola:
--   Losinj 4 -> 2, Mune 6 -> 3, Risnjak 9 -> 6, Rikard Bencic 13 -> 10,
--   Stari grad 5 -> 8, Rab 2 -> 4, Turbina 3 -> 5.
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
  'LOVRAN ČETIRI OD ČETIRI I TRI BODA ISPRED LOŠINJA',
  'Lovran je svladao Dragu i ostao jedini bez izgubljenog boda. Lošinj je preokretom u završnici derbija na Belvederu skočio na drugo mjesto, a Mune, Risnjak i Rikard Benčić slavili su u gostima.',
'Četvrto kolo 1. ŽNL PGŽ odigrano je u subotu 26. i nedjelju 27. rujna. Susret Rab - Goranin je odgođen. U šest odigranih utakmica palo je 17 golova, a gosti su slavili četiri puta, domaćini samo jednom, uz jedan remi.

Lovran - Draga 2:1. Lovran je u susjedskom derbiju na Lokvi, pred čak 300 gledatelja, upisao četvrtu pobjedu iz četiri utakmice i treću kod kuće. Do 77. minute bilo je bez golova, a onda je Mateo Mandić doveo domaćina u vodstvo. Potom je Patrik Vidmar u 84. povisio na 2:0, dok je Andrea Štemberger smanjio za Dragu u 88. minuti. Vidmar je sa sedam pogodaka i dalje prvi strijelac lige. Lovran se tako tri dana nakon poraza od Opatije u kupu, 0:7 na istom terenu, vratio pobjedom, a kako Rab nije igrao, ima pet bodova prednosti ispred njega.

Zamet - Risnjak 1:2. Zamet je na igralištu Robert Komen poveo već u 7. minuti golom Hrvoja Ožanića, ali je Risnjak preokrenuo. Erik Grgurić izjednačio je u 39. minuti, a Karlo Rupe u 49. zabio za 1:2, drugo kolo zaredom pobjednički gol. Risnjak je upisao drugu pobjedu zaredom, a Zamet prvi poraz kod kuće ove sezone. I ovaj rezultat pokazuje da Risnjak igra kao da nikada nije ni ispao iz ove lige.

Stari grad Rijeka - Lošinj 2:3. Derbi kola na Belvederu riješen je u 83. minuti. Lošinj je poveo u 9. minuti, kad je Antonio Matić slobodnim udarcem s ruba šesnaesterca prebacio živi zid, a Stari grad je izjednačio i poveo s dva gola Antonija Lukanovića, u 14. i 45. minuti. Marin Baković je u 67. minuti lobom pogodio prečku, a gosti su tri minute kasnije izjednačili preko kapetana Vitorija Antoninića. Pobjedu je Lošinju donio Šimun Simić, šest minuta nakon ulaska s klupe, udarcem po podu s dvadesetak metara u sam kut. Lošinj je dvaput pogodio i vratnicu. Stari grad je upisao prvi poraz u sezoni, a Lošinj je drugu gostujuću pobjedu, nakon one u Munama, iskoristio za skok na drugo mjesto. Detaljan izvještaj s Belvedera je u posebnom članku.

Vihor - Mune 0:3. Mune su na Zablaću u Baški riješile susret u prvih šesnaest minuta: David Gulan zabio je u 13., a Karlo Šneler u 16. minuti. Antonio Džaja postavio je konačnih 0:3 u 80. minuti. Mune su upisale drugu pobjedu zaredom, obje bez primljenog gola, i popele se na treće mjesto. Šneler je s pet pogodaka drugi strijelac lige. Vihor je izgubio i četvrtu utakmicu i jedini je bez boda.

Vrbovsko - Rikard Benčić 0:1. Jedini gol u Vrbovskom zabio je Bakir Delić u 37. minuti, i time donio Rikard Benčiću prvu pobjedu u sezoni. Vrbovsko je doživjelo prvi poraz kod kuće. Susret je pratilo 80 gledatelja, a sudac je podijelio devet žutih kartona, četiri domaćima i pet gostima.

Turbina - Omladinac Vrata 1:1. Moreno Maretić doveo je Turbinu u vodstvo u 25. minuti, a Diego Žic, koji je ušao na poluvremenu, izjednačio je u 69. Turbina je tako na Gradskom stadionu prvi put ove sezone ostala bez pobjede, a Omladinac je u gostima osvojio prvi bod. Žic ima tri gola.

LJESTVICA

Lovran vodi s dvanaest bodova, tri ispred Lošinja, koji je pobjedom na Belvederu skočio na drugo mjesto. Po sedam bodova imaju Mune, Rab, Turbina i Risnjak. Na dnu je Vihor, jedini bez boda. Rab i Goranin odigrali su utakmicu manje, jer je njihov susret odgođen.

Najviše su napredovali Mune, Risnjak i Rikard Benčić, po tri mjesta, a najviše je pao Stari grad Rijeka, s petog na osmo mjesto. Uz Lovran, bez poraza je ostao još samo Rab.

STRIJELCI

Patrik Vidmar iz Lovrana vodi sa sedam pogodaka, a Karlo Šneler iz Muna drugi je s pet. Po tri gola imaju Diego Žic (Omladinac Vrata), Kristijan Kurti (Draga), Mazen Sharbini (Vihor) i Vitorio Antoninić (Lošinj). Antonio Lukanović iz Starog grada jedini je u kolu zabio dvaput.

KAZNE

U četvrtom kolu nije bilo isključenja.',
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

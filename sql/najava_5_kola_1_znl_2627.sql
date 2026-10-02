-- =====================================================================
-- ČLANAK: NAJAVA 5. KOLA 1. ŽNL PGŽ 2026/27
-- Igra se u subotu 3. i nedjelju 4.10.2026.
-- =====================================================================
-- KAKO SE KORISTI: dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   KORAK 2 (objava) je zakomentiran na dnu.
--
--   Upis se smije ponoviti: ako clanak vec postoji, prepisu se samo
--   naslov, sazetak i tekst, a objavljen i datum ostaju kakvi jesu.
--
-- SLUG MORA POCETI S "najava-"
--   Traka "Ovaj vikend" na naslovnici po tome prepoznaje najavu tog kola.
--
-- ODAKLE STO
--   Raspored, satnica i stadioni 5. kola, svi rezultati sezone, ljestvica,
--   strijelci i kartoni: posao "Ispis kola" 02.10.2026. u 19:25 po nasem
--   (1. ZNL, 5. kolo). Ucinak kod kuce i u gostima izracunat je iz tih
--   rezultata.
--   Rab u kupu (Rab - Krk 1:3, 29.09.): clanak o utakmicama 29.09.2026.
--
-- RISNJAK - RAB NA GMAJNI
--   Raspored na Semaforu za tu utakmicu navodi "Gmajna, Vrata", a ne
--   igraliste Risnjaka u Lokvama. Tako je i upisano; ako je to greska
--   HNS-a, ispravlja se replace() nad tekstom.
--
-- ZUTI KARTONI
--   Prag za ZNL nije potvrden, pa se navodi samo broj kartona, bez
--   posljedice (vidi CLAUDE.md).
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-5-kola-1-znl-pgz-2627',
  'NAJAVA 5. KOLA: LOVRAN S ČETIRI POBJEDE IZ ČETIRI UTAKMICE GOSTUJE KOD TREĆIH MUNA',
  'Vodeći Lovran u Munama igra protiv momčadi koja dvije utakmice nije primila gol, a Vidmar i Šneler, prva dva strijelca lige, nalaze se jedan nasuprot drugome. Lošinj dočekuje Vrbovsko, a Risnjak i Rab, oba sa sedam bodova, igraju na Gmajni.',
'Peto kolo 1. ŽNL PGŽ igra se u subotu 3. i nedjelju 4. listopada. U subotu u 16 sati igraju Omladinac Vrata - Vihor i Draga - Stari grad Rijeka, a u nedjelju Goranin - Turbina u 14 sati, Lošinj - Vrbovsko u 15:30 te ostale tri utakmice u 16 sati. Igraju svi klubovi. Rab i Goranin i dalje imaju utakmicu manje, jer njihov odgođeni susret iz četvrtog kola u rasporedu još nema termin.

Mune - Lovran, u nedjelju na Crikvenoj dragi. Lovran je jedini bez izgubljenog boda: četiri utakmice, četiri pobjede, gol razlika 14:4. Pobjedom bi zadržao najmanje tri boda prednosti, kako god igrao Lošinj. Ako izgubi, a Lošinj pobijedi, izjednačit će se na vrhu. Lovran je dosad samo jednom igrao u gostima, u prvom kolu, kad je u Lokvama slavio 9:2. Mune su treće sa sedam bodova i dolaze s dvije pobjede zaredom, obje bez primljenog gola, a pobjedom bi se Lovranu primaknule na dva boda. Kod kuće su ove sezone dobile Dragu 4:0, a izgubile od Lošinja 2:3. Sastaju se i dvojica najboljih strijelaca lige: Patrik Vidmar iz Lovrana ima sedam pogodaka, a Karlo Šneler iz Muna pet.

Lošinj - Vrbovsko, u nedjelju na Čikatu. Lošinj je drugi s devet bodova, tri iza Lovrana, i pobjedom ostaje u izravnoj potjeri za vodećim. Na Čikatu je ove sezone igrao samo jednom, 2:0 protiv Drage, a u gostima je pobijedio dvaput, u Munama i prošlog vikenda na Belvederu. Vitorio Antoninić ima tri pogotka. Vrbovsko je jedanaesto s tri boda i izgubilo je dvije utakmice zaredom. U gostima je ove sezone izgubilo obje utakmice, uz gol razliku 3:6.

Risnjak - Rab, u nedjelju na Gmajni u Vratima. Obje momčadi imaju po sedam bodova, a Rab utakmicu manje. Pobjednik dolazi na deset bodova i u vrh ljestvice. Rab je, uz Lovran, jedini bez poraza, ali prvenstvenu utakmicu nije odigrao od 19. rujna, jer mu je susret s Goraninom odgođen. U utorak je u kupu ispao od Krka. Jedino gostovanje ove sezone odigrao je upravo na Gmajni, 0:0 protiv Omladinca. Antonio Belobrajdić ima dva gola. Risnjak dolazi s dvije pobjede zaredom, a u obje je pobjednički gol zabio Karlo Rupe. U gostima ove sezone nije izgubio: remi na Belvederu i pobjeda na Zametu.

Goranin - Turbina, u nedjelju u 14 sati na Gradskom stadionu u Delnicama. Turbina ima sedam bodova i pobjedom bi stigla na deset. U gostima je dosad igrala samo jednom i izgubila na Rabu 2:4, dok je kod kuće neporažena. Marin Ribarić, Mihael Ažić i Moreno Maretić imaju po dva pogotka. Goranin je deveti s četiri boda, uz utakmicu manje, i u Delnicama ove sezone ne gubi: remi sa Starim gradom i pobjeda nad Zametom 2:1. Kao i Rab, prvenstveno nije igrao od 19. rujna.

Draga - Stari grad Rijeka, u subotu na Slatini u Mošćeničkoj Dragi. Draga ove sezone prvi put igra kod kuće, nakon četiri gostovanja. Jedinu pobjedu upisala je u Baški, 4:3, i trinaesta je s tri boda. Kristijan Kurti ima tri pogotka. Stari grad je osmi s pet bodova i u gostima ove sezone nije izgubio: remi u Delnicama i pobjeda kod Rikard Benčića 3:1. Dolazi nakon prvog poraza u sezoni, 2:3 protiv Lošinja na Belvederu. Antonio Lukanović i Marin Baković imaju po dva gola.

Omladinac Vrata - Vihor, u subotu na Gmajni. Vihor je posljednji i jedini bez boda: četiri poraza, uz četrnaest primljenih golova. Mazen Sharbini je s tri pogotka zabio polovicu njegovih golova. Omladinac je sedmi s pet bodova i bez poraza je u dvije utakmice, uz remije s Rabom i u Crikvenici. Na Gmajni ove sezone ne gubi: pobjeda nad Vrbovskim 4:2 i remi s Rabom. Diego Žic ima tri pogotka, a Mateo Tomić dva.

Rikard Benčić - Zamet, u nedjelju na Belvederu. Rikard Benčić je deseti s četiri boda i dolazi nakon prve pobjede u sezoni, 1:0 u Vrbovskom. Kod kuće još nije pobijedio: remi s Munama i poraz od Starog grada. Zamet je dvanaesti s tri boda, izgubio je dvije utakmice zaredom, a u gostima ove sezone nije osvojio bod. Pobjedom bi stigao na šest bodova i preskočio domaćina. Hrvoje Ožanić ima dva gola.

LJESTVICA

Lovran vodi s dvanaest bodova, ispred Lošinja s devet. Po sedam bodova imaju Mune, Rab, Turbina i Risnjak. Omladinac Vrata i Stari grad Rijeka imaju pet, Goranin i Rikard Benčić četiri, a Vrbovsko, Zamet i Draga po tri boda. Vihor je jedini bez boda. Rab i Goranin imaju utakmicu manje.

KAZNE

U četvrtom kolu nije bilo isključenja, pa u petom nitko ne pauzira zbog crvenog kartona. Po tri žuta kartona imaju Aleksandar Cupać (Rikard Benčić) i Mateo Vukelja (Vrbovsko).',
  '1. ŽNL PGŽ',
  false,
  now()
)
on conflict (slug) do update
  set naslov  = excluded.naslov,
      sazetak = excluded.sazetak,
      tekst   = excluded.tekst;


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-5-kola-1-znl-pgz-2627'
-- returning slug, naslov, objavljen;


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-5-kola-1-znl-pgz-2627';

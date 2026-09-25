-- =====================================================================
-- ČLANAK: NAJAVA 4. KOLA 1. ŽNL PGŽ 2026/27
-- Igra se u subotu 26. i nedjelju 27.09.2026.; Rab - Goranin odgođen.
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
--   Stanje, strijelci i iskljucenja iz
--   public.pregled_kola('2026/27','1. ŽNL PGŽ',3). Termini i stadioni iz
--   rasporeda 4. kola u bazi (upit od 25.09.). Rezultati prva tri kola
--   iz ispisa scrapera; bodovi i gol razlika svakog kluba izracunati iz
--   njih slazu se s ljestvicom u ispisu. Ucinak kod kuce i u gostima
--   izracunat je iz istih rezultata.
--   Kup (Lovran - Opatija 0:7, Rab - Krk 29.09.) iz clanka o 1/16
--   finala.
--   ANDREJEVO: da je Rab - Goranin odgoden (vidio na Semaforu 25.09.,
--   novi termin nije poznat) i "susjedski derbi" za Lovran - Draga.
--
-- STIL
--   Ovo je prva najava pisana tako da gleda unaprijed (sto je na kocki,
--   kako klub stoji kod kuce ili u gostima), a ne da prepricava proslo
--   kolo. Andrej je trazio da se tako pise i ubuduce, vidi CLAUDE.md.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-4-kola-1-znl-pgz-2627',
  'NAJAVA 4. KOLA: LOVRAN JEDINI BEZ IZGUBLJENOG BODA DOČEKUJE DRAGU',
  'Vodeći Lovran u susjedskom derbiju dočekuje Dragu i, dok Rab ovaj vikend ne igra, može pobjeći na pet bodova. Na Belveder dolazi Lošinj, koji je bod ispred Starog grada.',
'Četvrto kolo 1. ŽNL PGŽ igra se u subotu 26. i nedjelju 27. rujna. Lovran i Draga otvaraju ga u subotu u 15 sati, Zamet - Risnjak igra se u subotu u 16 sati, a ostale četiri utakmice u nedjelju, također u 16 sati. Susret Rab - Goranin je odgođen.

Lovran - Draga. Susjedski derbi. Lovran je jedini s tri pobjede iz tri utakmice, a kako drugoplasirani Rab ovaj vikend ne igra, pobjedom na Lokvi može mu pobjeći na pet bodova. Kod kuće je ove sezone dobio obje utakmice, a Patrik Vidmar sa šest pogodaka vodi listu strijelaca lige. Lovran pritom dolazi nakon teške večeri u kupu, u kojoj je u srijedu na istom terenu izgubio od drugoligaške Opatije 0:7. Draga je dvanaesta s tri boda i jedinu pobjedu upisala je upravo u gostima, 4:3 u Baški. Kristijan Kurti ima tri gola.

Zamet - Risnjak. Obje momčadi dosad imaju po jednu pobjedu, a Risnjak bod više, pa bi Zamet pobjedom na igralištu Robert Komen preskočio gosta. Kod kuće je Zamet ove sezone dobio Omladinac 2:1. Risnjak dolazi nabrijan nakon prve pobjede, izborene golom Karla Rupea u trećoj minuti nadoknade protiv Vrbovskog, a u gostima je dosad upisao remi kod Starog grada.

Stari grad Rijeka - Lošinj, u nedjelju na Belvederu. Uz Lovran i Rab, Stari grad je jedini bez poraza, a Lošinj je samo bod ispred njega, pa je ovo izravan dvoboj za gornju polovicu ljestvice. Pobjednik se, uz Rabovu stanku, može približiti i drugom mjestu. Stari grad je u prošlom kolu prvi put pobijedio i skočio četiri mjesta, a Marin Baković ima dva gola. Lošinj je u gostima već slavio u Munama, 3:2, a Vitorio Antoninić s dva pogotka mu je najbolji strijelac.

Turbina - Omladinac Vrata, u Crikvenici. Turbina je treća, a na Gradskom stadionu ove sezone ne gubi: dvije utakmice, dvije pobjede, uz gol razliku 6:1. Pobjedom bi s devet bodova stigla do drugog mjesta, ispred Raba koji ne igra. Marin Ribarić i Mihael Ažić imaju po dva pogotka. Omladinac je jedini koji je zaustavio Rab, 0:0 u Vratima, ali jedinu gostujuću utakmicu izgubio je na Zametu. Diego Žic i Mateo Tomić imaju po dva gola.

Vihor - Mune, u nedjelju na Zablaću u Baški. Vihor još traži prve bodove, a Mazen Sharbini s tri gola pokazuje da mu zabijanje nije problem: momčad je zabila šest pogodaka, ali primila jedanaest. Mune dolaze u zamahu, nakon 4:0 protiv Drage i hat-tricka Karla Šnelera, koji je s četiri gola drugi na listi strijelaca. U gostima su Mune dosad odigrale samo jednom, 2:2 kod Rikard Benčića.

Vrbovsko - Rikard Benčić. Vrbovsko je obje gostujuće utakmice izgubilo, a jedinu domaću dobilo, 2:0 protiv Goranina, pa se kod kuće nada popravku nakon poraza u Lokvama u sudačkoj nadoknadi. Rikard Benčić ima jedan bod i u Vrbovskom traži prvu pobjedu u sezoni.

Rab i Goranin ovaj vikend ne igraju. Rab je na Blatu u utorak domaćin Krku iz 3. NL Zapad u kupu.

LJESTVICA

Lovran vodi s devet bodova, ispred Raba sa sedam te Turbine i Lošinja sa šest. Stari grad Rijeka ima pet bodova, a četiri boda dijele Mune, Omladinac, Goranin i Risnjak. Bez pobjede su Rikard Benčić i Vihor, koji je jedini bez boda.

KAZNE

U četvrtom kolu nitko ne pauzira zbog isključenja.',
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
-- where slug = 'najava-4-kola-1-znl-pgz-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-4-kola-1-znl-pgz-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-4-kola-1-znl-pgz-2627';

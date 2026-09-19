-- =====================================================================
-- ČLANAK: NK BORAC (Ba) - NK LIŽNJAN 3:2
-- Derbi 3. kola 4. NL NS Rijeka 2026/27, odigrano 19.09.2026. u 17:00,
-- stadion Krasica, 50 gledatelja, bez iskljucenja.
-- =====================================================================
-- KAKO SE KORISTI: dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   Zatim ide fotografija preko posla "Fotografija za clanak", pa tek
--   onda KORAK 2 (objava), koji je zakomentiran.
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- ODAKLE STO
--   Tijek utakmice, opisi prilika i ocjene su ANDREJEVI, s tribine na
--   Krasici, poslani jos s puta kuci.
--   Iz zapisnika dolaze rezultat, strijelci, minute pogodaka, broj
--   gledatelja, podatak da iskljucenja nije bilo te pomaci na ljestvici.
--   Imena uz brojeve dresova preslikana su iz postava u bazi:
--   Borac 7 Filip Jagic, 9 Josip Tkalcevic, 10 Ivan Golic,
--   15 Mihael Susnjar, 17 Ivan Ferinac; Liznjan 1 Luka Jukic,
--   4 Luka Pavic, 5 Hisa Ramadani, 7 Sasa Urosevic.
--
-- MINUTE
--   Za POGOTKE su uzete minute iz zapisnika (27, 45+1, 63, 88, 90+4).
--   Andrejeve s tribine bile su 25, 44 i 94; razlika je sitna i ovdje je
--   zapisana da se kasnije ne "ispravlja" kao omaska.
--   Za PRILIKE su minute Andrejeve, jer ih u zapisniku nema.
--
-- AUTOGOL
--   Pogodak u 45+1 HNS je uredno oznacio kao autogol Ivana Golica i
--   pripisao ga Liznjanu, pa rucni unos u stupac utakmice.autogolovi
--   NIJE potreban. Zbroj po stranama daje tocno 3:2.
--
-- IME KLUBA
--   U bazi je klub "NK Borac (Ba)", jer tako stoji na HNS-u. U tekstu se
--   po Andrejevoj uputi pise Borac, odnosno Borac (Bakar) u najavama.
--
-- SAZETAK UZ ZAPISNIK
--   Kraca verzija ide u utakmice.tekst_clanka i stoji u zasebnoj
--   datoteci sql/sazetak_borac_liznjan_3_kolo.sql.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'borac-liznjan-3-kolo-4-nl-ns-rijeka-2627',
  'TRI KONTRE ZA BORAC, EUROGOL ZA NEIZVJESTAN KRAJ',
  'Derbi 3. kola 4. NL NS Rijeka pripao je domaćinima 3:2. Borac je pogotke zabijao iz kontri, a Luka Pavić je u sudačkoj nadoknadi udarcem s 25 metara u rašlje unio neizvjesnost u sam kraj.',
'Na Krasici su se pred pedesetak gledatelja sastale dvije momčadi koje su u prva dva kola upisale po dvije pobjede, a derbi je pripao domaćinima. Borac je slavio 3:2 i došao do devet bodova iz tri utakmice.

Prvi su zaprijetili gosti. U 13. minuti Hisa Ramadani ušao je s lijevog krila u kazneni prostor i pucao srednjevisoko i snažno, ali pored desne vratnice. Odgovor je stigao u 17., kada je Mihael Šušnjar lažnjakom prevario čuvara unutar šesnaesterca, no njegov prizemni udarac vratar je dobro obranio i odbio u korner. U 20. je Ramadani nakon kornera ostao sam na drugoj vratnici, ali je glavom pucao pored gola.

Vodstvo je stiglo u 27. minuti, i to nakon kontre. Josip Tkalčević vukao je loptu iako mu je s druge strane bio slobodan Filip Jagić, a pred njima samo jedan obrambeni igrač Ližnjana. Odlučio se za lažnjak i udarac, vratar Luka Jukić je obranio, ali se lopta odbila do Jagića, koji je mirno pogodio praznu mrežu.

Tijekom prvih pola sata upravo se Tkalčević istaknuo kao najopasniji igrač na terenu, stalnim prodorima nakon dubinskih lopti suigrača. Obrana Ližnjana teško se nosila s njegovom brzinom.

U 36. minuti Ivan Golić pucao je nakon povratne lopte s vrha šesnaesterca, ali je lopta završila u bloku. Činilo se da bi bez bloka bila neobranjiva. Najopasniju priliku gostiju imao je u 39. Saša Urošević: primio je loptu dvadesetak metara od gola, leđima okrenut, snalažljivo se okrenuo i snažno pucao, no lopta je odsjela na vratnici.

Izjednačenje je palo u prvoj minuti sudačke nadoknade prvog poluvremena. Ližnjan je probio desnu stranu, koju je i prije toga već nekoliko puta otvarao, a prizemni ubačaj iznenadio je obranu Borca i nespretno je skrenut u vlastita vrata, uz Golićevo ime u zapisniku. Bilo je to tvrdo prvo poluvrijeme koje je moglo otići na obje strane.

Nastavak je počeo još jačim intenzitetom. U 50. minuti, nakon Golićeva ubačaja rukom, lopta se odbila do Jagića, koji je opasno pucao volejem, ali je obrana Ližnjana blokirala udarac. U 56. je Urošević pucao nakon povratne lopte s vrha šesnaesterca, no lopta je otišla sporo pored vratiju, a dojam je da se moglo puno bolje. U 59. je Šušnjar pucao iz daljine po podu, opasno, ali ipak pored gola.

Novo vodstvo stiglo je u 63. minuti, istim rukopisom kao prvo. Tkalčević je pobjegao svom jedinom čuvaru u kontri nakon kornera Ližnjana, suočio se s vratarom oči u oči i mirno pogodio u kut mreže.

Nakon tog pogotka osjetila se nervoza, uz nekoliko grubljih startova, ali je dojam da je sudac držao utakmicu pod kontrolom. Isključenja nije bilo.

U 80. minuti Šušnjar je pokušao iz slobodnog udarca s lijeve strane izravno pogoditi vrata, a Jukić je pomalo iznenađujuće, ali vrlo sigurno, obranio nogom. U 84. je Golić pucao s tridesetak metara, ponovno ravno u sigurnog golmana.

Ližnjan nije posustao, ali nije uspio stvoriti ništa konkretnije, dok je Borac svakim prelaskom sredine terena bio opasniji. U 87. su gosti opasno ubacili iz prekida i lopta se odbijala u gužvi pred golom, no obrana je očistila.

Činilo se da je zaključak stigao u 88., istim modusom operandi, samo s drugim izvršiteljem. Iz kontre je u kazneni prostor ušao Ivan Ferinac, ostao sam pred vratarom i mirno zabio od stative za 3:1.

No kraj je ipak bio neizvjestan. U četvrtoj minuti sudačke nadoknade Luka Pavić pogodio je s 25 metara u rašlje, eurogolom za 3:2, i unio nemir u posljednje trenutke susreta. Za preokret više nije bilo vremena, pa je Borac zasluženo odnio tri boda.

Pet pogodaka na Krasici najviše je u kolu. Borac je pobjedom skočio na drugo mjesto, s devet bodova, koliko ima i vodeći Cres, dok je Ližnjan pao na treće, sa šest. Službena ljestvica je na stranici lige.',
  '4. NL NS Rijeka',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA (nakon fotografije)
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'borac-liznjan-3-kolo-4-nl-ns-rijeka-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'borac-liznjan-3-kolo-4-nl-ns-rijeka-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'borac-liznjan-3-kolo-4-nl-ns-rijeka-2627';

-- =====================================================================
-- ČLANAK: NK KRALJEVICA - NK BUJE 2:2
-- Derbi 4. kola 3. NL Zapad 2026/27, odigrano 15.09.2026. na Minti,
-- 100 gledatelja, bez iskljucenja.
-- =====================================================================
-- KAKO SE KORISTI: pokreni po redu dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   Zatim ide KORAK 2 (objava), koji je zakomentiran.
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- ODAKLE STO
--   Tijek utakmice, opisi prilika i ocjene su ANDREJEVI, s tribine.
--   Iz zapisnika u bazi dolaze rezultat, strijelci, minute pogodaka,
--   broj gledatelja i podatak da iskljucenja nije bilo.
--   Imena uz brojeve dresova iz biljezaka preslikana su iz postava u
--   bazi: k17 Leon Sedlic, k6 Borna Znamenacek, k3 Mikula Dunatov,
--   k9 Matija Cabrijan, k4 Franko Bosancic, k5 Filip Znamenacek,
--   k11 Paulo Kocijan, k20 Dominik Paljokaj, b7 Masimo Krizmanic,
--   b14 Damir Bartulovic, b18 Matija Kalizan, b4 Matija Susterajter,
--   b9 Enis Soskic, b11 Marko Cukon, vratar Buja Matteo Fabac.
--   Nista izvan toga nije dopisano: nema izjava, forme ni atmosfere.
--
-- AUTOGOL
--   Pogodak u 17. minuti HNS je uredno oznacio kao autogol Matije
--   Susterajtera i pripisao ga Kraljevici. Rucni unos u stupac
--   utakmice.autogolovi zato NIJE potreban.
--
-- SAZETAK UZ ZAPISNIK
--   Kraca verzija istog teksta ide u utakmice.tekst_clanka i stoji u
--   zasebnoj datoteci sql/sazetak_kraljevica_buje_4_kolo.sql.
--
-- BEZ FOTOGRAFIJE
--   Ako fotografija stigne, ne upisuje se rucno nego preko posla
--   "Fotografija za clanak" na GitHubu, sa slugom iz KORAKA 1.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'kraljevica-buje-4-kolo-3-nl-zapad-2627',
  'BOSANČIĆ U 87. MINUTI SPASIO BOD KRALJEVICI',
  'Kraljevica je na Minti dvaput gubila protiv Buja, a bod je donio Franko Bosančić osam minuta prije kraja. Vratar gostiju Matteo Fabac obranio je dvije stopostotne prilike.',
'Derbi 4. kola 3. NL Zapad odigran je u utorak popodne na Minti pred stotinjak gledatelja i završio je bez pobjednika, 2:2. Kraljevica je dvaput gubila i dvaput se vratila.

Počelo je dosta čvrsto s obje strane. Do prve opasnije prilike došlo je u 7. minuti, kada je Leon Sedlić pucao s ruba kaznenog prostora, iskosa s lijeve strane, ali je lopta otišla preko gola.

U 15. minuti Masimo Krizmanić poslao je odličnu dugu loptu sa sredine igrališta na lijevu stranu, u prostor. Damir Bartulović ju je smirio, ušao u kazneni prostor i plasiranim udarcem pogodio desnu vratnicu. Lopta se pomalo sretno odbila do nečuvanog Matije Kalizana, koji je zabio u praznu mrežu.

Kraljevica nije dugo čekala na izjednačenje. Već u 17. minuti, nakon prizemnog ubačaja iz kuta, promašaj lopte domaćeg igrača koji je pokušao pucati prevario je obranu Buja. Matija Šusterajter htio je izbiti loptu izvan kaznenog prostora, ali ju je uz pomoć neravnog terena pogrešno zahvatio i poslao u vlastitu mrežu.

Pomalo jalovu i isprekidanu igru prekinuo je u 30. minuti udarac Damira Bartulovića, nakon lijepog ubačaja Krizmanića iz slobodnog udarca s lijeve strane, ali je lopta otišla ravno u vratara. U 33. je uzvratila Kraljevica, kada je Borna Znamenaček pucao iz daljine po podu, no golman je bio siguran. U 39. je Kalizan nakon izravnog ubačaja rukom, iz dobre pozicije, volejem pucao visoko preko gola. Za zaključenje prvog dijela, u 45. minuti Kraljevičani su pokušali udarcem s dvadesetak metara, ali je prohujalo pored gola.

Obje su ekipe u drugo poluvrijeme ušle puno življe. U 48. minuti Enis Šoškić imao je stopostotnu priliku: sam je ušao u kazneni prostor nakon dubinske lopte koja se odbila od poda, odmah ju je zahvatio, ali je promašio cijeli gol. Minutu poslije Mikula Dunatov proigrao je solo prodor s lijevog krila i pucao iznad gola.

U 62. je Marko Cukon, nakon dugačkog ubačaja na desnoj strani kaznenog prostora, pucao u drugi kut i lopta je prošla zamalo pored vratnice. Iako je Kraljevica imala određenu dominaciju, Buje su djelovale vrlo opasno svakim ulaskom u kazneni prostor.

Tada je počeo Kraljevičin najjači niz. U 64. je Matija Čabrijan osvojio duel tridesetak metara od gola na desnoj strani i pokušao dalekometnim udarcem iznenaditi vratara koji je bio izvan crte, ali je lopta otišla pored gola. Minutu poslije domaći su imali novi opasan udarac s lijeve strane, ovaj put prizeman, i golman Buja bio je siguran. U 66. je Čabrijan ušao u kazneni prostor s lijeve strane nakon dubinske lopte, ali je pucao ravno u vratara.

U 67. minuti, nakon ubačaja s lijeve strane, igrač Kraljevice glavom je vratio loptu u sredinu na Franka Bosančića, koji ju je s pet metara usmjerio u okvir vratiju. Matteo Fabac fenomenalno je obranio i odbio u korner. Buje su djelovale grogirano. Odmah nakon tog kornera opet je bilo opasno u kaznenom prostoru, pa je nakon nekoliko blokiranih udaraca dosuđen faul sa sedamnaest metara. Iz slobodnog udarca pokušao je Filip Znamenaček, ali je lopta pogodila vrh živog zida i odbila se u korner. U 74. je Bosančić pucao s lijeve strane prizemno, no lopta je prošla pored desne stative.

I onda kazna. U 78. minuti, nakon prvotne greške Kraljevice iz koje je uslijedio ubačaj sa strane, Victor Kargbo primirio je visoku loptu i smireno s desne strane unutar kaznenog prostora pogodio lijevi dio mreže. Klasično pravilo, kad ne zabiješ svoje prilike, budeš kažnjen, opet se pokazalo točnim.

U 82. je Bartulović nakon spuštene duge lopte glavom od suigrača pucao s dvadeset metara preko gola, iako je dojam da se moglo smirenije odigrati. No Kraljevica nije odustajala od pokušaja izjednačenja. Prvo je u 85. Paulo Kocijan pucao iz daljine preko gola, a onda je u 87. Filip Znamenaček izveo slobodni udarac i usmjerio loptu unutar okvira vratiju. Vratar je odbio loptu ispred sebe, a Bosančić je bio najbrži i pospremio ju je u praznu mrežu za 2:2. Mora se priznati, potpuno zasluženo.

Imali su domaći šanse i za potpuni preokret. U istoj je minuti Čabrijan s desne strane ušao u kazneni prostor i otišao sam na vratara, ali je Fabac ponovno fantastično obranio. U 93. je Dominik Paljokaj imao priliku riješiti susret, no nakon povratne lopte s vrha kaznenog prostora njegov je udarac otišao preko gola. Pokušao je odmah idući napad još i Bosančić svojim solo prodorom i udarcem, ali isto iznad gola.

Nakon prvog, relativno mirnijeg poluvremena, drugo je bilo itekako živo, a Buje mogu ići zadovoljno kući s osvojenim bodom na teškom gostovanju.',
  '3. NL Zapad',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'kraljevica-buje-4-kolo-3-nl-zapad-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'kraljevica-buje-4-kolo-3-nl-zapad-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'kraljevica-buje-4-kolo-3-nl-zapad-2627';

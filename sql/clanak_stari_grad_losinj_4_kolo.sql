-- =====================================================================
-- ČLANAK: NK STARI GRAD RIJEKA - NK LOŠINJ 2:3
-- Derbi 4. kola 1. ŽNL PGŽ 2026/27, 27.09.2026., Belveder.
-- =====================================================================
-- BROJEVI DRESOVA iz Andrejevog sazetka prevedeni su postavom iz
-- zapisnika (posao "Ispis kola" s postavama, 27.09. u 19:27):
--   Stari grad: 4 Neven Karajkovic, 5 Marin Bakovic, 8 Ivan Baricevic,
--   11 Leo Bajcic, 13 Mateo Pendic, 16 Antonio Lukanovic, 18 Luka
--   Majetic, vratar 12 Marko Peric.
--   Losinj: 10 Kevin Kalanj, 16 Simun Simic (usao u 77.), 20 Adrian
--   Gardijan, 23 Antonio Matic, 24 Vitorio Antoninic (kapetan), vratar
--   1 Domagoj Stupicic.
--   Broja 22 u postavi Losinja NEMA, pa taj igrac nije imenovan.
--   Andrejev "nepoznati strijelac" izjednacenja je Lukanovic, 14. minuta.
--
-- MINUTE: iz zapisnika. Pobjednicki gol je u zapisniku u 83., Andrej
--   ga je zapisao u 82.; ostavljena je minuta iz zapisnika.
--
-- KAKO SE KORISTI: dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   KORAK 2 (objava) je zakomentiran na dnu.
--   Upis se smije ponoviti: prepisu se samo naslov, sazetak i tekst.
--
-- ODAKLE STO
--   Tijek, prilike i opisi su Andrejevi s tribine (bio na utakmici,
--   sazetak poslan 27.09.). Rezultat 2:3 i ljestvica iz sluzbene tablice
--   na Semaforu (Stari grad 6:5, Losinj 9:6 nakon kola).
--   Stanje prije kola iz najave 4. kola: Stari grad bez poraza, pet
--   bodova; Losinj sest bodova, u gostima vec slavio u Munama 3:2.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'stari-grad-losinj-4-kolo-1-znl-pgz-2627',
  'PREOKRET U 83. MINUTI: LOŠINJ SLAVIO NA BELVEDERU',
  'Lošinj je u derbiju kola nanio Starom gradu prvi poraz u sezoni i skočio na drugo mjesto. Domaćini su pogodili prečku, a gosti dvaput vratnicu, prije nego je pobjedu donio udarac Šimuna Simića s dvadesetak metara u 83. minuti.',
'Stari grad Rijeka dočekao je Lošinj kao jedna od tri momčadi lige bez poraza, a s Belvedera je otišao bez bodova. U derbiju četvrtog kola palo je pet golova, a Lošinj je preokretom u završnici slavio 2:3 i skočio na drugo mjesto.

Početak je bio živ. Već u 2. minuti, nakon ubačaja Ivana Baričevića, Stari grad je došao u dobru priliku, no udarac je u posljednji trenutak blokiran i lopta je otišla tik pored vratnice. U 5. minuti Mateo Pendić je pucao izvana, a vratar Lošinja Domagoj Stupičić dobro je obranio i odbio u korner. Iz tog kornera Neven Karajković je glavom ponovno natjerao vratara na obranu, za novi korner.

Lošinj je iskoristio prvu priliku. U 9. minuti gosti su nakon pokušaja ulaska u kazneni prostor izborili slobodan udarac na rubu polukruga šesnaesterca, a Antonio Matić ga je mirno prebacio preko živog zida u nebranjeni dio mreže za 0:1. U 11. minuti Leo Bajčić je ušao s lijeve strane u kazneni prostor, ali je vratar Lošinja obranio i njegov prizemni udarac.

U 12. minuti uslijedio je nevjerojatan promašaj. Nakon lijepe akcije gostiju, koja je unijela zbrku u obranu domaćina, Kevin Kalanj je primio loptu pet metara od gola, s već svladanim vratarom, ali je pogodio vratnicu. Lopta se odbila opet do gostiju, no i novi udarac iz kaznenog prostora vratar je obranio. Kazna je stigla odmah: nakon, kako se činilo, prelakog ulaska u kazneni prostor gostiju, Antonio Lukanović je u 14. minuti mirno zabio za 1:1.

Stari grad je nastavio tražiti gol izdaleka. U 16. minuti Lukanović je pucao s dvadesetak metara malo iznad gola, u 21. Luka Majetić s iste udaljenosti pored gola, a u 22. minuti ponovno Lukanović, s nešto veće udaljenosti, gađao je kut, ali je vratar još jednom skrenuo loptu u korner. Potom se igra smirila. Stari grad je imao inicijativu kroz posjed, a Lošinj je bio opasan iz polukontri, loptama u prostor za brza krila.

U 40. minuti Marin Baković je ostao sam na vrhu šesnaesterca, ali je pucao neprecizno, pored gola. Kad se već činilo da se na odmor ide s 1:1, Lošinj je u 45. minuti napravio veliku grešku i izgubio loptu u sredini terena, tamo gdje se ne smije izgubiti. Stari grad je brzom kontrom pronašao usamljenog Lukanovića, koji je mirno zabio svoj drugi gol, za vodstvo domaćina.

U 50. minuti Lukanović je ušao s lijeve strane u kazneni prostor, prevario svog čuvara i pokušao mudro prebaciti vratara koji je izašao, ali ga je Stupičić ipak zaustavio. U 55. minuti jedan od igrača Lošinja je iz naizgled bezopasnog dalekog ubačaja umalo pogodio rašlje, no lopta je pala na gornju mrežu. U 60. minuti, nakon ubacivanja rukom sa strane, Kalanj je pobjegao obrani domaćina, ali je vratar Starog grada Marko Perić bio siguran. Drugo poluvrijeme bilo je puno grublje od prvog, osobito s gostujuće strane.

U 67. minuti Baković je nakon duge lopte pobjegao obrani Lošinja i snalažljivo lobom prebacio vratara, ali je lopta odskočila s prečke. Kao i u prvom poluvremenu, promašaj domaćina odmah je kažnjen. U 70. minuti Karajković je promašio loptu pokušavajući je izbiti iz obrane, kapetan Lošinja Vitorio Antoninić ju je preuzeo, krenuo ravno prema golu i prizemnim udarcem mirno svladao vratara za 2:2.

U 76. minuti Kalanj je sjajnim samostalnim prodorom ušao s lijeve strane u kazneni prostor i gađao prvi kut, no pogodio je vratnicu. U 83. minuti stigao je potpuni preokret. Kalanj je sjajnom loptom u prostor poslao Antoninića samog pred vratara, a Perić je sjajno pročitao udarac i obranio. Domaćini su mislili da su spašeni, ali se u nastavku akcije lopta odbila do Šimuna Simića, koji je šest minuta ranije ušao s klupe i odmjerenim udarcem po podu s dvadesetak metara pogodio sam kut vrata za 2:3 i bacio goste u ekstazu.

Stari grad je potom sve bacio u napad, a Lošinj je u 91. minuti iz kontre mogao riješiti sve dvojbe. Adrian Gardijan je ostao sam protiv vratara, ali je pucao pored gola. Ishod se time nije promijenio: Lošinj je slavio 2:3 i s devet bodova drugi je na ljestvici, tri boda iza Lovrana, a Stari grad je upisao prvi poraz u sezoni i pao na osmo mjesto.',
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
-- where slug = 'stari-grad-losinj-4-kolo-1-znl-pgz-2627'
-- returning slug, naslov, objavljen;


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, objavljen, left(tekst, 80) as pocetak
from public.clanci
where slug = 'stari-grad-losinj-4-kolo-1-znl-pgz-2627';

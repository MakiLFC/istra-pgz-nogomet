-- =====================================================================
-- ČLANAK: NK STARI GRAD RIJEKA - NK LOŠINJ 2:3
-- Derbi 4. kola 1. ŽNL PGŽ 2026/27, 27.09.2026., Belveder.
-- =====================================================================
-- NACRT. Brojevi dresova u [[...]] zamjenjuju se imenima iz zapisnika
-- (posao "Ispis kola" s postavama) cim ga HNS objavi.
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
  'PREOKRET U 82. MINUTI: LOŠINJ SLAVIO NA BELVEDERU',
  'Lošinj je u derbiju kola nanio Starom gradu prvi poraz u sezoni i skočio na drugo mjesto. Domaćini su zatresli okvir vrata, a gosti dvaput pogodili vratnicu, prije nego je pobjedu donio udarac s dvadesetak metara u 82. minuti.',
'Stari grad Rijeka dočekao je Lošinj kao jedna od tri momčadi lige bez poraza, a s Belvedera je otišao bez bodova. U derbiju četvrtog kola palo je pet golova, a Lošinj je preokretom u završnici slavio 2:3 i skočio na drugo mjesto.

Početak je bio živ. Već u 2. minuti, nakon ubačaja [[Baričević]], Stari grad je došao u dobru priliku, no udarac je u posljednji trenutak blokiran i lopta je otišla tik pored vratnice. U 5. minuti [[S13]] je pucao izvana, a vratar Lošinja dobro je obranio i odbio u korner. Iz tog kornera [[S4]] je glavom ponovno natjerao vratara na obranu, za novi korner.

Lošinj je iskoristio prvu priliku. U 9. minuti gosti su nakon pokušaja ulaska u kazneni prostor izborili slobodan udarac na rubu polukruga šesnaesterca, a [[L23]] ga je mirno prebacio preko živog zida u nebranjeni dio mreže za 0:1. U 11. minuti [[S11]] je ušao s lijeve strane u kazneni prostor, ali je vratar Lošinja obranio i njegov prizemni udarac.

U 12. minuti uslijedio je nevjerojatan promašaj. Nakon lijepe akcije gostiju, koja je unijela zbrku u obranu domaćina, [[L10]] je primio loptu pet metara od gola, s već svladanim vratarom, ali je pogodio vratnicu. Lopta se odbila opet do gostiju, no i novi udarac iz kaznenog prostora vratar je obranio. Kazna je stigla odmah: nakon, kako se činilo, prelakog ulaska u kazneni prostor gostiju, [[strijelac]] je mirno zabio za 1:1.

Stari grad je nastavio tražiti gol izdaleka. U 16. minuti [[S16]] je pucao s dvadesetak metara malo iznad gola, u 21. [[S18]] s iste udaljenosti pored gola, a u 22. minuti ponovno [[S16]], s nešto veće udaljenosti, gađao je kut, ali je vratar još jednom skrenuo loptu u korner. Potom se igra smirila. Stari grad je imao inicijativu kroz posjed, a Lošinj je bio opasan iz polukontri, loptama u prostor za brza krila.

U 40. minuti [[S5]] je ostao sam na vrhu šesnaesterca, ali je pucao neprecizno, pored gola. Kad se već činilo da se na odmor ide s 1:1, Lošinj je u 45. minuti napravio veliku grešku i izgubio loptu u sredini terena, tamo gdje se ne smije izgubiti. Stari grad je brzom kontrom pronašao usamljenog [[Lukanović]], koji je mirno zabio za vodstvo domaćina.

U 50. minuti [[S16]] je ušao s lijeve strane u kazneni prostor, prevario svog čuvara i pokušao mudro prebaciti vratara koji je izašao, ali ga je vratar ipak zaustavio. U 55. minuti [[L22]] je iz naizgled bezopasnog dalekog ubačaja umalo pogodio rašlje, no lopta je pala na gornju mrežu. U 60. minuti, nakon ubacivanja rukom sa strane, [[L10]] je pobjegao obrani domaćina, ali je vratar Starog grada bio siguran. Drugo poluvrijeme bilo je puno grublje od prvog, osobito s gostujuće strane.

U 67. minuti Marin Baković je nakon duge lopte pobjegao obrani Lošinja i snalažljivo lobom prebacio vratara, ali je lopta odskočila s prečke. Kao i u prvom poluvremenu, promašaj domaćina odmah je kažnjen. U 70. minuti [[S4]] je promašio loptu pokušavajući je izbiti iz obrane, [[L24]] ju je preuzeo, krenuo ravno prema golu i prizemnim udarcem mirno svladao vratara za 2:2.

U 76. minuti [[L10]] je sjajnim samostalnim prodorom ušao s lijeve strane u kazneni prostor i gađao prvi kut, no pogodio je vratnicu. U 82. minuti stigao je potpuni preokret. [[L10]] je sjajnom loptom u prostor poslao [[L24]] samog pred vratara, a vratar Starog grada sjajno je pročitao udarac i obranio. Domaćini su mislili da su spašeni, ali se u nastavku akcije lopta odbila do [[L16]], koji je odmjerenim udarcem po podu s dvadesetak metara pogodio sam kut vrata za 2:3 i bacio goste u ekstazu.

Stari grad je potom sve bacio u napad, a Lošinj je u 91. minuti iz kontre mogao riješiti sve dvojbe. [[L20]] je ostao sam protiv vratara, ali je pucao pored gola. Ishod se time nije promijenio: Lošinj je slavio 2:3 i s devet bodova drugi je na ljestvici, tri boda iza Lovrana, a Stari grad je upisao prvi poraz u sezoni i pao na osmo mjesto.',
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

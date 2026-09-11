-- =====================================================================
-- NAJAVA: 2. kolo 1. ŽNL PGŽ 2026/27
-- subota 12. i nedjelja 13.09.2026., uz Zamet - Omladinac u srijedu 16.09.
-- =====================================================================
-- KAKO SE KORISTI: pokreni po redu dva koraka na dnu datoteke.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Prvi korak (upis) je odmah ispod, clanak ulazi s objavljen = false,
--   dakle NIJE vidljiv na stranici. Objavljuje se KORAKOM 2, kad dodje
--   vrijeme.
--
--   Upis se smije pokrenuti i vise puta. Ako clanak s ovim slugom vec
--   postoji, naslov, sazetak i tekst se prepisu, a stanje objavljen se
--   ne dira.
--
-- ODAKLE STO
--   Termini, stadioni, bodovi, mjesta na ljestvici, forma, vodeci
--   strijelci i medjusobni susreti dolaze iz
--   public.najava_kola('2026/27','1. ŽNL PGŽ',2), dakle iz baze.
--   Nista nije dodano izvan toga: nema ocjena forme, izjava ni
--   ocekivanja.
-- PISANO IZNOVA 11.09.2026.
--   Prva verzija je pisana dok Omladinac Vrata i Vrbovsko jos nisu
--   odigrali svoju utakmicu 1. kola. Ona je odigrana 09.09. i zavrsila
--   4:2, pa su odlomci o ta dva kluba napisani iznova.
--   Ispravljena su i dva termina koja je HNS u medjuvremenu pomaknuo:
--   Mune - Losinj na 15:45, a Zamet - Omladinac Vrata na srijedu
--   16.09. u 18:45.
--   Rezultat, strijelci i iskljuceni dolaze iz pregled_kola() 1. kola.
--   Iskljucen Smolic (Mune) je iz pregleda 1. kola, ne iz najave.
--
-- AKO SE TERMIN PROMIJENI prije objave, dnevna "Provjera termina" to
-- javi na e-postu. Tada se tekst ispravi obicnim update-om nad
-- clanci.tekst, prije nego se clanak objavi.
--
-- BEZ FOTOGRAFIJE
--   Clanak nema sliku, pa se na kartici prikazuje zaglavlje lige, a pri
--   dijeljenju zajednicka slika Lokal-Arene. Fotografija se moze dodati
--   i kasnije, poslom "Fotografija za clanak".
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS NAJAVE (jos nije objavljena)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-2-kola-1-znl-pgz-2627',
  'VIDMAR I LOVRAN PRED DOMAĆOM PUBLIKOM',
  'Drugo kolo 1. ŽNL PGŽ igra se u subotu i nedjelju, a vodeći Lovran s Patrikom Vidmarom dočekuje Rikard Benčić.',
'Drugo kolo 1. ŽNL PGŽ igra se u subotu 12. i nedjelju 13. rujna. Mune i Lošinj počinju u 15:45, ostale utakmice u 16:30, a Zamet i Omladinac Vrata svoju igraju tek u srijedu 16. rujna.

SUBOTA

Lovran - Rikard Benčić. Pitanje je mogu li Lovranci nastaviti s impresivnim ulaskom u sezonu. Nakon 9:2 u Lokvama prvi su na ljestvici s gol razlikom plus sedam, a Patrik Vidmar je s pet pogodaka vodeći strijelac lige. Rikard Benčić ima bod nakon 2:2 s Munama.

Rab - Turbina. Oba kluba imaju po tri boda nakon uvodnih pobjeda, Rab 4:2 protiv Vihora, Turbina 3:0 protiv Zameta. Prošle sezone je Rab dobio oba susreta, 3:2 u Triblju i 4:0 kod kuće.

NEDJELJA

Mune - Lošinj, 15:45. Mune imaju bod, Lošinj tri nakon 2:0 protiv Drage. Domaći igraju bez Alena Smolića, isključenog u prvom kolu.

Stari grad Rijeka - Risnjak. Risnjaku je gostovanje izazovno, ali mora bolje od onoga u prvom kolu, kad je kod kuće primio devet pogodaka. Stari grad ima bod nakon 0:0 u Delnicama.

Vihor (B) - Draga. Oba kluba su bez bodova nakon uvodnog poraza, Vihor 2:4 na Rabu, Draga 0:2 na Lošinju.

Vrbovsko - Goranin. Derbi kola. Vrbovsko je u srijedu odigralo svoju utakmicu prvog kola i izgubilo 4:2 u Vratima, uz pogotke Josipa Matovine i Živka Blagojevića. Goranin ima bod nakon 0:0 protiv Starog grada i još nije primio pogodak.

SRIJEDA

Zamet - Omladinac Vrata, 16. rujna u 18:45. Zamet je bez bodova nakon 0:3 protiv Turbine. Omladinac Vrata ima tri boda nakon 4:2 protiv Vrbovskog, a dvaput je zabio Diego Žic, i to ušavši s klupe.

ZA OVO KOLO

Mune igraju bez Alena Smolića, isključenog u prvom kolu. Nitko nije na pragu žutih kartona.',
  '1. ŽNL PGŽ',
  false,
  now()
)
on conflict (slug) do update
set naslov     = excluded.naslov,
    sazetak    = excluded.sazetak,
    tekst      = excluded.tekst,
    natjecanje = excluded.natjecanje
returning slug, naslov, objavljen;


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-2-kola-1-znl-pgz-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-2-kola-1-znl-pgz-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-2-kola-1-znl-pgz-2627';

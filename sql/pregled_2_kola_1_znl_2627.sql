-- =====================================================================
-- ČLANAK: PREGLED 2. KOLA 1. ŽNL PGŽ 2026/27
-- Odigrano 12. i 13.09.2026., jedna utakmica tek 16.09.2026.
-- =====================================================================
-- KAKO SE KORISTI: pokreni po redu dva koraka na dnu datoteke.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Prvi korak (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   Zatim ide KORAK 2 (objava).
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- KOLO NIJE DOVRSENO
--   Zamet - Omladinac Vrata igra se u srijedu 16.09.2026. u 18:45. Tekst
--   je zato pisan tako da stoji i bez tog rezultata, a u zadnjem odlomku
--   pise kada se igra. Nakon srijede se dopisuje odlomak i ispravlja
--   ljestvica.
--
-- ODAKLE STO
--   Rezultati, strijelci, minute, gledatelji, crveni kartoni i pomaci na
--   ljestvici dolaze iz public.pregled_kola('2026/27','1. ŽNL PGŽ',2),
--   dakle iz zapisnika u bazi. Ocjene i dojmovi u tekstu su Andrejevi,
--   iz njegove dopune 13.09.2026.: "na krilima Kurtija", "jos jedna
--   golijada", "veseli povratak na otok", "ponosni povratak u Lokve" i
--   recenica o Lovranu na vrhu zbog bolje gol razlike.
--
-- PROVJERENO PRIJE PISANJA
--   Zbroj strijelaca po stranama slaze se s rezultatom na svih sest
--   odigranih utakmica.
--   Autogol u Baski: Dante Bujas je igrac Drage, pa se pogodak pripisuje
--   Vihoru. Potvrdio Andrej. Bez toga rezultat 3:4 ne bi izlazio.
--   Ovaj put funkcija javlja da sluzbena tablica NE odstupa, pa se o
--   ljestvici moglo pisati bez ograde o kaznenim bodovima.
--
-- FOTOGRAFIJA
--   Ide zasebno, poslom "Fotografija za clanak" na GitHubu, i to TEK
--   NAKON sto ovaj upis prodje, jer poslu treba slug clanka.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'pregled-2-kola-1-znl-pgz-2627',
  'KURTIJEVA TRI POGOTKA ZA PREOKRET U BAŠKI',
  'Sedam golova na Zablaću i hat-trick Kristijana Kurtija, Vrbovsko srušilo Goranin i skočilo šest mjesta, a Lovran ostao na vrhu unatoč igraču manje.',
'Drugo kolo 1. ŽNL PGŽ nije odigrano u jednom danu. Dvije utakmice bile su u subotu, četiri u nedjelju, a susret Zameta i Omladinca Vrata na rasporedu je tek u srijedu 16. rujna. U šest odigranih palo je 23 pogotka, a trojica igrača napustila su teren prije kraja.

Vihor (B) - Draga 3:4. Utakmica kola odigrana je na Zablaću u Baški i donijela je sedam pogodaka i dva preokreta. Đerđ Kurti doveo je goste u vodstvo već u 5. minuti, autogol Dantea Bujasa u 24. donio je domaćima izjednačenje, a Mihael Radić je u 42. minuti prvi put okrenuo rezultat. U nastavku je Kristijan Kurti izjednačio u 48., Mazen Sharbini vratio je Vihoru prednost u 55., a onda je Kristijan Kurti odlučio nastaviti gdje je stao i sam odlučio susret pogocima u 66. i 76. minuti. Tri gola u dvadeset osam minuta, i to za pobjedu iz zaostatka. Na krilima Kurtija, tri boda lete iz Baške u Dragu.

Vrbovsko - Goranin 2:0. Derbi kola pripao je domaćinima i donio najveće iznenađenje vikenda, jer je Vrbovsko prije ovog susreta bilo dvanaesto, a Goranin šesti. Mihael Jardas zabio je u 21., Patrik Poljak u 61. minuti. Vrbovsko je tako došlo do prve pobjede u sezoni i skočilo šest mjesta, najviše u kolu, dok je Goranin pao pet mjesta.

Rab - Turbina 4:2. Na Blatu je pred 150 gledatelja, najviše u kolu, viđena još jedna golijada. Marin Macolić otvorio je u 34., Niko Šanić povisio u 39., Mihael Ažić smanjio je za goste u 40., a Antonio Belobrajdić je na isteku prvog poluvremena vratio dva gola prednosti. Marin Ribarić je u 51. ponovno smanjio, ali je Dominik Grgurić u 60. minuti postavio konačnih 4:2. Rab je od 65. minute igrao s igračem manje, nakon drugog žutog kartona Stipe Kordića.

Mune - Lošinj 2:3. I u Munama je odigrana utakmica bogata golovima. Lošinj je poveo pogocima Vitorija Antoninića u 35. i Nikole Dlake u 43. minuti. Fran Ivan Brguljan smanjio je u 53., Tin Gršković vratio je gostima dva gola prednosti u 66., a pogodak Patrika Bonicioli u 74. minuti stigao je prekasno, pa će Lošinjani imati veseli povratak na otok sa dalekog gostovanja.

Lovran - Rikard Benčić 1:0. Jedina utakmica kola bez primljenog gola na jednoj strani, i jedina odlučena jednim pogotkom. Patrik Vidmar zabio je u 36. minuti, a domaći su od 43. igrali s igračem manje, nakon crvenog kartona Mihaela Gazdeka. Prednost su sačuvali do kraja. Uz otočke klubove, Rab i Lošinj, jedini su sa šest bodova, ali su na vrhu zbog bolje gol razlike.

Stari grad Rijeka - Risnjak 1:1. Na Belvederu je Marin Baković doveo domaće u vodstvo u 28. minuti, a Adrian Godeša izjednačio u 48. Risnjak je od 62. minute ostao bez Miroslava Dukića, isključenog crvenim kartonom, ali je bod sačuvao. Gostima je to prvi osvojeni bod u sezoni, i to na vrlo zahtjevnom gostovanju, pa se stoga mogu ponosni vratiti u Lokve.

STRIJELCI

Na vrhu liste strijelaca uvjerljivo je Patrik Vidmar iz Lovrana sa šest pogodaka. Slijedi Kristijan Kurti iz Drage s tri, sva tri postignuta u ovom kolu, i to je jedini hat-trick kola. S po dva gola u sezoni prate ih Antonio Belobrajdić, David Radan, Diego Žic, Fran Ivan Brguljan, Mazen Sharbini i Mihael Ažić.

LJESTVICA

Lovran je i dalje prvi, sa šest bodova i gol razlikom plus osam. Isto toliko bodova imaju Rab i Lošinj, s plus četiri odnosno plus tri. Slijede Omladinac Vrata, Turbina, Vrbovsko i Draga, svi s po tri boda.

Najveći skok kola napravilo je Vrbovsko, šest mjesta. Rab i Draga dobili su po tri, Risnjak dva. Najviše je izgubio Goranin, pet mjesta, a Turbina tri.

Poredak se još mijenja, jer kolo nije dovršeno.

ZA SLJEDEĆE KOLO

Zbog isključenja kaznu odrađuju Mihael Gazdek iz Lovrana, Miroslav Dukić iz Risnjaka i Stipe Kordić s Raba. Nitko nije na pragu žutih.

Drugo kolo zaključuju Zamet i Omladinac Vrata u srijedu 16. rujna u 18:45 na Robertu Komenu.',
  '1. ŽNL PGŽ',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-2-kola-1-znl-pgz-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'pregled-2-kola-1-znl-pgz-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, slika_url,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-2-kola-1-znl-pgz-2627';

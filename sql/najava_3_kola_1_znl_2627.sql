-- =====================================================================
-- ČLANAK: NAJAVA 3. KOLA 1. ŽNL PGŽ 2026/27
-- Igra se u subotu 19. i nedjelju 20.09.2026.
-- =====================================================================
-- KAKO SE KORISTI: dva koraka.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   KORAK 1 (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   KORAK 2 (objava) je zakomentiran na dnu.
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- SLUG MORA POCETI S "najava-"
--   Traka "Ovaj vikend" na naslovnici po tome prepoznaje najavu tog kola
--   i pokazuje poveznicu "Najava". Vidi components/OvajVikend.tsx.
--
-- ODAKLE STO
--   Termini, rezultati dosadasnjih kola, ljestvica, strijelci po
--   klubovima i iskljucenja dolaze iz
--   public.pregled_kola('2026/27','1. ŽNL PGŽ',2) i iz rasporeda u bazi.
--   ANDREJEVO, cega u bazi nema: ocjena da je Goraninov ulazak u sezonu
--   iznenadjujuc uz zahtjevne protivnike, da Turbina nije lako gostovanje
--   za Vihorove prve bodove, da bi Risnjak - Vrbovsko mogao biti cvrst
--   goranski derbi, nadimak "grdi pasi" za Mune, te "derbi della
--   Omladinsko igraliste" i podatak da Stari grad na tom terenu igra i
--   svoje domace utakmice.
--
-- LJESTVICA
--   sluzbena_tablica_odstupa je false, dakle u 1. ŽNL nema kaznenih
--   bodova i izracunata tablica poklapa se sa sluzbenom.
--
-- KAZNE
--   Iskljucenja iz 2. kola: Mihael Gazdek (Lovran, crveni karton u 43.),
--   Miroslav Dukic (Risnjak, crveni u 62.) i Stipe Kordic (Rab, drugi
--   zuti u 65.). Polje "na_pragu" je prazno.
--   Izraz "zuto-crveni karton" iz podataka u tekstu se prevodi u "drugi
--   zuti karton".
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'najava-3-kola-1-znl-pgz-2627',
  'LOVRAN DOČEKUJE LOŠINJ U OGLEDU MOMČADI BEZ PORAZA',
  'Vodeći Lovran u nedjelju na Lokvi ugošćuje Lošinj, treću momčad ljestvice, a obje su kolo otvorile s po šest bodova. U subotu Omladinac Vrata dočekuje Rab.',
'Treće kolo 1. ŽNL PGŽ igra se u subotu i nedjelju. U subotu 19. rujna u 16:30 na rasporedu su Omladinac Vrata - Rab, Goranin - Zamet i Rikard Benčić - Stari grad Rijeka. U nedjelju 20. rujna prvi počinje Lovran - Lošinj u 14:30, a u 16:30 slijede Turbina - Vihor (B), Risnjak - Vrbovsko i Mune - Draga.

Lovran - Lošinj. Susret kola. Lovran je jedini klub lige s maksimalnim učinkom i najboljom gol razlikom, plus osam, nakon 9:2 u Risnjaku i 1:0 protiv Rikarda Benčića. Lošinj je također pri vrhu sa šest bodova, uz pobjede nad Dragom 2:0 i Munama 3:2. Patrik Vidmar je sa šest pogodaka prvi strijelac lige i sam ima više golova nego devet klubova, no Lovran u ovom susretu ostaje bez Mihaela Gazdeka, koji odrađuje kaznu nakon crvenog kartona u 43. minuti protiv Rikarda Benčića. Lošinjeve pogotke dosad je zabilo pet različitih igrača.

Omladinac Vrata - Rab. Rab je s dvije pobjede i dvanaest zabijenih golova druga momčad ljestvice, ali u Vrata putuje bez Stipe Kordića, koji je protiv Turbine isključen nakon drugog žutog kartona. Omladinac je u srijedu izgubio u Rijeci od Zameta, a najviše su pogodaka za klub dosad dali Diego Žic i Mateo Tomić, obojica po dva.

Risnjak - Vrbovsko. Vrbovsko je pobjedom nad Goraninom 2:0 skočilo šest mjesta, najviše u kolu, i došlo do prvih bodova. Risnjak je na jednom bodu i s gol razlikom minus sedam, najlošijom u ligi, a protiv Vrbovskog neće moći računati na Miroslava Dukića, isključenog protiv Starog grada. Mogao bi ovo biti pravi čvrsti goranski derbi.

Goranin - Zamet. Goraninov ulazak u sezonu je iznenađujuć, s jednim bodom i bez zabijenog gola, no protivnici su bili zahtjevni: remi 0:0 sa Starim gradom i poraz u Vrbovskom. Zamet dolazi nakon prve pobjede u sezoni, one nad Omladincem, kojom je skočio pet mjesta.

Turbina - Vihor (B). Turbina je nakon uvodne pobjede nad Zametom 3:0 izgubila na Rabu 4:2. Vihor je jedini klub bez osvojenog boda, a u oba je susreta primio četiri i tri gola, uz 3:4 protiv Drage u kojem je vodio. Gostovanje u Turbini nije lako mjesto za traženje prvih bodova.

Mune - Draga. Draga stiže na Crikvenu dragu nakon gostujuće pobjede u Baški, gdje je Kristijan Kurti briljirao s tri gola i drugi je strijelac lige. Mune su na jednom bodu, nakon remija 2:2 s Rikardom Benčićem. Grdi pasi će htjeti više.

Rikard Benčić - Stari grad Rijeka. Derbi della Omladinsko igralište. Stari grad je oba svoja susreta remizirao, 0:0 s Goraninom i 1:1 s Risnjakom, a sada će kao formalno gosti na terenu na kojem također igraju i domaće utakmice tražiti prvu ovosezonsku pobjedu.

LJESTVICA

Nakon dva kola vode Lovran, Rab i Lošinj, sva tri sa šest bodova, a razlikuje ih gol razlika. Slijedi skupina od pet klubova s po tri boda. Vihor (B) je jedini bez bodova. Cijela ljestvica i strijelci su na stranici 1. ŽNL PGŽ.

KAZNE

Treće kolo zbog crvenog kartona propuštaju Mihael Gazdek (Lovran) i Miroslav Dukić (Risnjak), a Stipe Kordić (Rab) zbog drugog žutog kartona. Na pragu žutih nema nikoga.',
  '1. ŽNL PGŽ',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-3-kola-1-znl-pgz-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'najava-3-kola-1-znl-pgz-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'najava-3-kola-1-znl-pgz-2627';

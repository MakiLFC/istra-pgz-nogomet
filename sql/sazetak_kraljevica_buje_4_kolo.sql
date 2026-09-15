-- =====================================================================
-- SAŽETAK UZ ZAPISNIK: NK KRALJEVICA - NK BUJE 2:2
-- Derbi 4. kola 3. NL Zapad 2026/27, odigrano 15.09.2026. na Minti,
-- 100 gledatelja, bez iskljucenja.
-- =====================================================================
-- KAMO OVO IDE
--   U stupac utakmice.tekst_clanka, dakle u sam redak te utakmice, a NE
--   u tablicu clanci. Stranica ga prikazuje ispod zapisnika, na adresi
--   te utakmice. Scraper taj stupac ne dira, pa prezivljava svako
--   osvjezavanje.
--
-- KAKO SE KORISTI
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Nema koraka "objava": cim se stupac napuni, tekst je na stranici.
--   Pokretanje se smije ponoviti; drugi put samo prepise isti tekst.
--
-- ODNOS PREMA CLANKU
--   Ovo je sazeta verzija clanka iz sql/clanak_kraljevica_buje_4_kolo.sql.
--   Isti su izvori: tijek i prilike su Andrejevi s tribine, a rezultat,
--   strijelci, minute, gledatelji i podatak da iskljucenja nije bilo
--   dolaze iz zapisnika u bazi.
--
-- AUTOGOL
--   Pogodak u 17. minuti HNS je uredno oznacio kao autogol Matije
--   Susterajtera i pripisao ga Kraljevici, pa rucni unos u stupac
--   utakmice.autogolovi nije potreban.
--
-- DERBI KOLA
--   Utakmica je vec oznacena kao derbi kola. Ako oznaka ikad nestane,
--   vraca se s: update public.utakmice set derbi = true where ... .
-- =====================================================================


-- =====================================================================
-- UPIS SAŽETKA
-- =====================================================================
update public.utakmice
set tekst_clanka =
'Derbi kola završio je bez pobjednika, a Kraljevica je dvaput gubila i dvaput se vratila. U 15. minuti Damir Bartulović pogodio je vratnicu, a odbijenu loptu u praznu mrežu poslao je Matija Kalizan. Izjednačenje je stiglo već u 17., i to nespretno: nakon ubačaja iz kuta Matija Šusterajter je pokušao izbiti loptu, uz pomoć neravnog terena pogrešno ju je zahvatio i poslao u vlastitu mrežu.

Ostatak prvog poluvremena bio je isprekidan i bez pravog naboja. Prvu opasniju priliku imao je Leon Sedlić u 7. minuti, pucao je iskosa s lijeve strane preko gola. U 30. je Bartulović nakon Krizmanićeva slobodnog udarca pucao ravno u vratara, u 33. je Borna Znamenaček pokušao iz daljine po podu, a u 39. je Kalizan volejem iz dobre pozicije poslao loptu visoko preko gola.

Drugo poluvrijeme bilo je znatno življe i otvorilo se najvećim promašajem susreta. U 48. minuti Enis Šoškić sam je ušao u kazneni prostor nakon dubinske lopte i promašio cijeli gol. Minutu poslije Mikula Dunatov pucao je iznad gola nakon solo prodora, a u 62. je Marko Cukon zamalo pogodio drugi kut.

Kraljevica je stisnula između 64. i 74. minute. Matija Čabrijan je u 66. ušao u kazneni prostor, ali je pucao ravno u vratara, a vrhunac je bio udarac Franka Bosančića s pet metara u 67., koji je vratar Buja Matteo Fabac fenomenalno obranio. Iz slobodnog udarca sa sedamnaest metara Filip Znamenaček je potom pogodio vrh živog zida.

Kazna je stigla u 78., kada je Victor Kargbo smireno pogodio lijevi dio mreže za 1:2. Klasično pravilo, kad ne zabiješ svoje prilike, budeš kažnjen. No u 87. je Filip Znamenaček izveo slobodni udarac, vratar je odbio loptu ispred sebe, a Bosančić je bio najbrži za 2:2, potpuno zasluženo.

Kraljevica je imala i priliku za preokret. U istoj je minuti Fabac obranio Čabrijanov izlazak sam na vratara, a u 93. je Dominik Paljokaj pucao preko gola nakon povratne lopte. Buje mogu ići zadovoljno kući s bodom na teškom gostovanju.'
where natjecanje = '3. NL Zapad'
  and sezona     = '2026/27'
  and kolo       = 4
  and domacin    = 'NK Kraljevica'
  and gost       = 'NK Buje'
returning domacin, gost, rezultat, left(tekst_clanka, 60) as pocetak;


-- =====================================================================
-- PROVJERA
-- =====================================================================
-- Stupac se zove "gledatelja", ne "gledatelji". Prvo pokretanje je zbog
-- toga palo, a kako Supabase cijelu datoteku vrti kao jednu transakciju,
-- pala je i izmjena iznad. Nista nije upisano dok cijela datoteka ne prodje.
select natjecanje, kolo, domacin, gost, rezultat, derbi, gledatelja,
       length(tekst_clanka) as duljina_teksta
from public.utakmice
where natjecanje = '3. NL Zapad'
  and sezona     = '2026/27'
  and kolo       = 4
  and domacin    = 'NK Kraljevica'
  and gost       = 'NK Buje';

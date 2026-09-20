-- =====================================================================
-- ČLANAK: PREGLED 3. KOLA 2. ŽNL PGŽ 2026/27
-- Odigrano u subotu 19. i nedjelju 20.09.2026.
-- =====================================================================
-- KAKO SE KORISTI: pokreni po redu dva koraka na dnu datoteke.
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Prvi korak (upis) je odmah ispod, clanak ulazi s objavljen = false.
--   Zatim ide KORAK 2 (objava).
--
--   Upis se pokrece SAMO JEDNOM. Drugo pokretanje javlja gresku zbog
--   jedinstvenog sluga, sto znaci da je prvo proslo.
--
-- ODAKLE STO
--   Sve dolazi iz zapisnika sve tri utakmice: rezultati, strijelci,
--   minute, kartoni i gledatelji. Nista nije dopisano izvan toga.
--   Nitko od nas nije bio ni na jednoj utakmici, pa u tekstu NEMA
--   opisa tijeka igre ni ocjena.
--
--   Podaci su procitani preko posla "Ispis kola" (2. ŽNL, kolo 3),
--   jer okruzenje u kojem je clanak pisan nema pristup Supabaseu.
--
-- PROVJERENO PRIJE PISANJA
--   Zbroj strijelaca po stranama slaze se s rezultatom na sve tri
--   utakmice (3:2, 2:3 i 2:6).
--   Samoprovjera strijelaca: nasa lista poklapa se sa sluzbenom.
--   Ljestvica je izracunata iz rezultata i poklapa se sa sluzbenom,
--   klub po klub, u svih sest redaka. Uz to je izracunato i stanje
--   nakon 2. kola i usporedjeno s onim sto je pisalo u najavi 3. kola
--   (Gomirje 6, Goranka 4, Mrkopalj 3, Zeljeznicar 1, Polet 0,
--   Snjeznik 0), pa se zna da je polaziste bilo tocno.
--   Svi klubovi koji su igrali imaju 3. kolo upisano u ljestvicu,
--   dakle HNS je ovaj put sve dijelove stranice osvjezio.
--
-- NEJEDNAK BROJ ODIGRANIH UTAKMICA
--   Mrkopalj i Snjeznik i dalje imaju po jednu utakmicu manje, jer im
--   je susret 1. kola odgodjen i novi termin jos nije objavljen. To je
--   u tekstu receno naglas, inace tablica ne izgleda smisleno.
--
-- GLEDATELJI
--   Mrkopalj 70, Moravice 50, a u Gerovu je u zapisniku "Nepoznato",
--   sto znaci da podatka nema, a ne da je stadion bio prazan.
--
-- BEZ FOTOGRAFIJE
--   Clanak nema sliku, pa se na kartici prikazuje zaglavlje lige, a
--   pri dijeljenju zajednicka slika Lokal-Arene.
-- =====================================================================


-- =====================================================================
-- KORAK 1: UPIS CLANKA (jos nije objavljen)
-- =====================================================================
insert into public.clanci
  (slug, naslov, sazetak, tekst, natjecanje, objavljen, objavljeno_u)
values (
  'pregled-3-kola-2-znl-pgz-2627',
  'TRI GOLA ANTONIJA FENOVA, GOMIRJE I DALJE BEZ POGREŠKE',
  'Gomirje je u Gerovu slavilo 6:2 i ostalo jedino sa svim bodovima, Mrkopalj je svladao Goranku 3:2 i preuzeo drugo mjesto, a Polet je u Moravicama s igračem manje došao do pobjede golom u sudačkoj nadoknadi.',
'Treće kolo 2. ŽNL PGŽ odigrano je u subotu 19. i nedjelju 20. rujna, a donijelo je 18 pogodaka u tri utakmice, dakle šest po utakmici. To je tri više nego u prethodnom kolu. Gosti su slavili dvaput, domaćin jednom, remija ni ovaj put nije bilo.

Mrkopalj - Goranka 3:2. Susret drugoplasiranog i trećeplasiranog Pod Čelimbašom pratilo je 70 gledatelja, najviše u kolu. Goranka je povela u 7. minuti, pogotkom Tihomira Cindrića, ali je Antonio Krištof izjednačio već dvije minute kasnije. Aleksandar Ilić doveo je domaće u vodstvo u 16., a Šime Božić je u 26. minuti vratio goste u igru. Odluka je pala u 58. minuti, kada je Ilić zabio svoj drugi pogodak na utakmici. Goranki je to prvi poraz u sezoni, a Mrkoplju druga pobjeda iz dvije utakmice. Suci su podijelili šest žutih kartona, četiri gostima.

Željezničar (M) - Polet (Sk) 2:3. U Moravicama je Polet došao do prvih bodova u sezoni, i to u sudačkoj nadoknadi i s igračem manje. Karlo Jurković zabio je u 7., a Josip Purić u 18. minuti, pa su gosti poluvrijeme dočekali s dva gola prednosti. Darin Goršić smanjio je u 59., a Dalibor Krebelj izjednačio u 72. minuti. Pet minuta poslije Polet je ostao bez Tomislava Purića, isključenog crvenim kartonom, ali je David Ožbolt u petoj minuti nadoknade postavio konačnih 2:3. Utakmicu je gledalo 50 gledatelja, a uz crveni je podijeljeno i sedam žutih kartona.

Snježnik - Gomirje 2:6. Na Ponikvama u Gerovu Gomirje je upisalo treću pobjedu iz tri utakmice. Milan Latinčić zabio je već u 3. minuti, Nikola Vučinić povisio u 20., a onda je Antonio Fenov pogodio tri puta, u 26., 30. i 46. minuti. Latinčić je svoj drugi pogodak dodao u 51., za 0:6. Snježnik se upisao u drugom dijelu, golovima Matije Bunete u 64. i Arijana Jašarevića u 69. minuti. To su prvi pogoci Snježnika u sezoni, nakon 0:7 u prethodnom kolu. Broj gledatelja u zapisniku nije upisan.

STRIJELCI

Šime Božić iz Goranke ostao je na vrhu liste s pet pogodaka, ali mu se Antonio Fenov iz Gomirja svojom trojkom u Gerovu približio na jedan, sa četiri. Slijede Aleksandar Ilić i Antonio Krištof, obojica iz Mrkoplja, s po tri. Po dva pogotka imaju David Ožbolt iz Poleta, Ivan Petrović, Milan Latinčić i Milan Lončar iz Gomirja te Tihomir Cindrić iz Goranke. Gomirje time ima četvoricu igrača s po dva ili više pogodaka, najviše u ligi.

LJESTVICA

Gomirje vodi s devet bodova iz tri utakmice i jedino je sa stopostotnim učinkom. Mrkopalj je pobjedom skočio na drugo mjesto, sa šest bodova iz dvije utakmice, pa je i on još bez izgubljenog boda. Goranka je pala na treće mjesto, s četiri boda, ali i dalje ima drugu najbolju gol razliku u ligi, plus šest. Polet je prvom pobjedom došao do tri boda i četvrtog mjesta, Željezničar ima bod, a Snježnik je bez bodova.

Mrkopalj i Snježnik i dalje imaju po utakmicu manje, jer njihov susret iz prvog kola još nije odigran i novi termin nije objavljen. Poredak iza Gomirja zato još nije konačan. Cijela ljestvica i lista strijelaca su na stranici 2. ŽNL PGŽ.

ZA SLJEDEĆE KOLO

Četvrto kolo zbog crvenog kartona propušta Tomislav Purić iz Poleta, isključen u 77. minuti u Moravicama. Zbog žutih kartona nitko nije u opasnosti, jer u cijeloj ligi nitko još nema više od jednog.

Četvrto kolo na rasporedu je u nedjelju 27. rujna u 16:00. Igraju Polet (Sk) - Goranka, Gomirje - Mrkopalj i Željezničar (M) - Snježnik. Susret kola je onaj u kojem se sastaju jedine dvije momčadi koje još nisu izgubile bod.',
  '2. ŽNL PGŽ',
  false,
  now()
);


-- =====================================================================
-- KORAK 2: OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'pregled-3-kola-2-znl-pgz-2627'
-- returning slug, naslov, objavljen;
--
-- Skidanje sa stranice (clanak ostaje u bazi):
-- update public.clanci set objavljen = false
-- where slug = 'pregled-3-kola-2-znl-pgz-2627';


-- =====================================================================
-- PROVJERA
-- =====================================================================
select slug, naslov, natjecanje, objavljen, objavljeno_u,
       left(tekst, 80) as pocetak
from public.clanci
where slug = 'pregled-3-kola-2-znl-pgz-2627';

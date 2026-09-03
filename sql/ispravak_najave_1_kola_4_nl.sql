-- =====================================================================
-- ISPRAVAK NAJAVE 1. KOLA: 4. NL NS RIJEKA
-- =====================================================================
-- KAKO SE KORISTI:
--   Supabase -> SQL Editor -> zalijepi cijelu datoteku -> Run.
--   Pokreće se jednom. Ponovno pokretanje ne škodi, jer je ovo update,
--   ne insert: samo prepiše iste vrijednosti preko istih.
--
-- ZAŠTO POSTOJI
--   NK Novalja je 02.09.2026., dan prije 1. kola, napustila natjecanje.
--   Najava napisana prije toga najavljivala je utakmicu Otočac - Novalja
--   i imala je krivog domaćina u paru Medulin - Smoljanci. Tekst i
--   sažetak ovdje dolaze od Andreja.
--
--   Naslovna ploča (slika) ispravljena je zasebno, u repozitoriju:
--   public/slike/najave/najava-ploca-4-nl-ns-rijeka-kolo-1.png.
--   Ime datoteke je isto, pa se slika_url ne mijenja.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. POGLED PRIJE ZAHVATA (nije obavezno, ali je korisno)
-- ---------------------------------------------------------------------
select slug, naslov, objavljen, slika_url, left(sazetak, 80) as pocetak_sazetka
from public.clanci
where slug = 'najava-1-kola-4-nl-ns-rijeka-2627';


-- ---------------------------------------------------------------------
-- 2. ISPRAVAK SAŽETKA I TEKSTA
-- ---------------------------------------------------------------------
update public.clanci
set
  sazetak = 'Prva utakmica prvog kola 4. NL NS Rijeka na rasporedu je već u petak, 4. rujna na stadionu Valbruna u Rovinju, dok se kolo nastavlja u subotu 5. rujna, tjedan dana nakon starta 3. NL. Uoči početka je pak sve šokiralo napuštanje NK Novalje iz natjecanja.',
  tekst = 'Prvo kolo 4. NL NS Rijeka počinje u petak, 4. rujna 2026. s utakmicom NK Žminj - NK Ližnjan, dok se preostali susreti svi igraju u subotu, u 17:30. Ligu je napustio prvak Rovinj, koji je izborio 3. NL, a iz nje je stigla, kako se prvotno mislilo, Novalja. No međutim, lokalni ali i širi hrvatski nogometni svijet šokirala je vijest o napuštanju natjecanja NK Novalje, tako da će ova liga brojati 13 klubova ove sezone. Rječina i Štinjan novopromovirane su momčadi iz nižih liga.

Žminj - Ližnjan (Kunfin, Rovinjsko Selo). Najzvučniji par kola. Ližnjan je prošlu sezonu završio drugi, odmah iza Rovinja, i sada je bez njega među prvim kandidatima za vrh. Žminj je prošle godine bio šesti. Domaćin utakmicu igra u Rovinjskom Selu.

Borac (Bakar) - Klana. Treći protiv petog iz prošle sezone na novouređenoj bakarskoj ljepotici od stadiona.

Umag-CC Umago - Štinjan (Stella Maris, Umag). Umag je prošlu sezonu završio četvrti, sa 44 boda. Štinjan u ligu ulazi kao novopromovirana momčad, a iza sebe ima solidan pripremni period.

Cres - Rječina (Dari, Cres). Cres je prošle sezone bio osmi, te u novu sezonu ulazi s brojnim prinovama, dok je pak Rječina druga novopromovirana momčad u ligi sa možda najzvučnijim pojačanjem na golu.

Mladost Fažana - Funtana (Oliva, Fažana). Sedmoplasirani dočekuje dvanaestoplasiranog iz prošle sezone i sa dvije uvjerljive pobjede u ovosezonskom kupu iza sebe. Fažana je prošlu sezonu završila sa šest bodova više.

Smoljanci Sloboda - Medulin 1921 (Suhača, Svetvinčenat). Susret jedanaestog i devetog iz prošle sezone, uz četiri boda razlike.

Otočac, koji je prošlu sezonu završio deseti, u novu ulazi znatno pojačan, no međutim pojačanja se neće moći pokazati u prvome kolu obzirom da je njihova predviđena utakmica s Novaljom otkazana zbog već navedenog istupanja paške ekipe iz natjecanja.'
where slug = 'najava-1-kola-4-nl-ns-rijeka-2627';


-- ---------------------------------------------------------------------
-- 3. PROVJERA
-- ---------------------------------------------------------------------
-- Očekivano: u sažetku i tekstu više nema para Otočac - Novalja kao
-- utakmice, Smoljanci su domaćini, a tekst spominje 13 klubova.
select slug, objavljen, slika_url,
       tekst like '%Smoljanci Sloboda - Medulin 1921%' as smoljanci_su_domacini,
       tekst like '%Otočac - Novalja%'                 as ima_li_jos_stari_par,
       tekst like '%13 klubova%'                       as spominje_13_klubova
from public.clanci
where slug = 'najava-1-kola-4-nl-ns-rijeka-2627';


-- =====================================================================
-- STADION UTAKMICE ŽMINJ - LIŽNJAN
-- =====================================================================
-- U sažetku sada piše da se prva utakmica igra na Valbruni u Rovinju,
-- kako je Andrej rekao. U tekstu članka na tom mjestu i dalje stoji
-- "(Kunfin, Rovinjsko Selo)" i rečenica da domaćin igra u Rovinjskom
-- Selu, kako je pisalo u prvoj verziji najave.
--
-- Ako je Valbruna točna, pokreni i ovo, pa se tekst uskladi sa sažetkom.
-- Ako je pak u tekstu sve u redu, ne pokreći ništa, nego javi, pa se
-- ispravlja sažetak.
--
-- update public.clanci
-- set tekst = replace(
--       replace(tekst,
--         'Žminj - Ližnjan (Kunfin, Rovinjsko Selo).',
--         'Žminj - Ližnjan (Valbruna, Rovinj).'),
--       'Domaćin utakmicu igra u Rovinjskom Selu.',
--       'Domaćin utakmicu igra u Rovinju, na Valbruni.')
-- where slug = 'najava-1-kola-4-nl-ns-rijeka-2627';


-- =====================================================================
-- AKO SLIKA NE STOJI UZ ČLANAK
-- =====================================================================
-- Gornji select pokazuje slika_url. Ako je prazan, a želiš naslovnu
-- ploču, pokreni i ovo. Ako ondje već stoji neka druga slika, NE
-- pokreći, jer bi je prepisalo.
--
-- update public.clanci
-- set slika_url  = '/slike/najave/najava-ploca-4-nl-ns-rijeka-kolo-1.png',
--     slika_opis = 'Ploča s parovima prvog kola 4. NL NS Rijeka'
-- where slug = 'najava-1-kola-4-nl-ns-rijeka-2627';
--
-- =====================================================================
-- OBJAVA
-- =====================================================================
-- update public.clanci set objavljen = true
-- where slug = 'najava-1-kola-4-nl-ns-rijeka-2627';

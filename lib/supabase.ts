import { createClient } from "@supabase/supabase-js";

// Ove dvije vrijednosti dolaze iz .env.local datoteke (vidi .env.local.example)
// NEXT_PUBLIC_ prefiks je bitan u Next.js-u - to govori da je vrijednost
// sigurna za korištenje u pregledniku (frontend), ne samo na serveru.
// VAŽNO: ovdje koristimo "anon" javni ključ, NIKAD "service_role" ključ -
// service_role ključ ima ovlasti pisanja i mora ostati samo u scraperu
// na tvom računalu, nikad u kodu koji se šalje pregledniku korisnika.
// ---------------------------------------------------------------------
// PROVJERA POSTAVKI - namjerno ruši build kad su krive
// ---------------------------------------------------------------------
// U kolovozu 2026. je NEXT_PUBLIC_SUPABASE_URL u Vercelu greškom
// prepisan adresom same stranice (postavljala se domena). Build je
// prošao, objava je uspjela, a stranica je ostala prazna: svaki upit
// išao je na lokalarena.com/rest/v1/... i vraćao njezinu 404 stranicu.
// Kod je grešku uhvatio, vratio prazan popis i ispisao poruku "Trenutno
// nema učitanih utakmica", pa je izgledalo kao da su podaci nestali.
//
// Zato se postavke sada provjeravaju pri gradnji. Kriva vrijednost ruši
// build, a Vercel u tom slučaju ostavlja zadnju ispravnu verziju na
// zraku. Bolje neuspjela objava nego uspješna objava prazne stranice.
//
// Poruke namjerno NE ispisuju ključ, jer build zapisi nisu tajni.

function greska(sto: string): never {
  throw new Error(
    `[Lokal-Arena] ${sto}\n` +
      "Provjeri Environment Variables u Vercelu (Settings -> Environment " +
      "Variables), odnosno .env.local na računalu. Nakon izmjene treba " +
      "pokrenuti novi deployment, jer se NEXT_PUBLIC_ vrijednosti upisuju " +
      "u stranicu u trenutku gradnje."
  );
}

function provjeriAdresu(adresa: string | undefined): string {
  if (!adresa) greska("NEXT_PUBLIC_SUPABASE_URL nije postavljen.");

  let url: URL;
  try {
    url = new URL(adresa);
  } catch {
    greska("NEXT_PUBLIC_SUPABASE_URL nije ispravna adresa.");
  }

  // Adresa Supabase projekta izgleda ovako: https://xxxx.supabase.co
  // Ako u imenu domaćina nema "supabase", upisano je nešto drugo, u
  // pravilu adresa same stranice. Ako Supabase ikad bude na vlastitoj
  // domeni, ovaj uvjet treba popustiti.
  if (!url.hostname.includes("supabase")) {
    greska(
      `NEXT_PUBLIC_SUPABASE_URL pokazuje na "${url.hostname}", a to nije ` +
        "adresa Supabase projekta. Očekuje se nešto poput " +
        "https://xxxxxxxx.supabase.co (Supabase -> Project Settings -> API " +
        "-> Project URL). Ovdje NE ide adresa stranice; za nju postoji " +
        "zasebna varijabla NEXT_PUBLIC_SITE_URL."
    );
  }

  return adresa;
}

/** Uloga zapisana u JWT ključu, ili null ako se ne može pročitati. */
function ulogaIzKljuca(kljuc: string): string | null {
  try {
    const sredina = kljuc.split(".")[1];
    if (!sredina) return null;
    const json = atob(sredina.replace(/-/g, "+").replace(/_/g, "/"));
    return (JSON.parse(json) as { role?: string }).role ?? null;
  } catch {
    return null;
  }
}

function provjeriKljuc(kljuc: string | undefined): string {
  if (!kljuc) greska("NEXT_PUBLIC_SUPABASE_ANON_KEY nije postavljen.");

  if (kljuc.startsWith("http")) {
    greska(
      "NEXT_PUBLIC_SUPABASE_ANON_KEY sadrži adresu, a treba sadržavati ključ."
    );
  }

  // Stariji ključevi su JWT i počinju s "eyJ", noviji s "sb_publishable_".
  if (!kljuc.startsWith("eyJ") && !kljuc.startsWith("sb_publishable_")) {
    greska(
      "NEXT_PUBLIC_SUPABASE_ANON_KEY ne izgleda kao Supabase ključ " +
        "(očekuje se početak \"eyJ\" ili \"sb_publishable_\")."
    );
  }

  // Ovaj ključ završava u pregledniku svakog posjetitelja, pa ovdje
  // service_role ključ ne smije doći ni slučajno: on ima pravo pisanja
  // i brisanja po cijeloj bazi.
  if (ulogaIzKljuca(kljuc) === "service_role") {
    greska(
      "NEXT_PUBLIC_SUPABASE_ANON_KEY sadrži service_role ključ. Taj ključ " +
        "ima pravo pisanja po cijeloj bazi i nikad ne smije biti javan. " +
        "Ovdje ide anon ključ; service_role ostaje samo u scraperu."
    );
  }

  return kljuc;
}

const supabaseUrl = provjeriAdresu(process.env.NEXT_PUBLIC_SUPABASE_URL);
const supabaseAnonKey = provjeriKljuc(process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export type DogadjajIgraca = {
  minuta: string;
  // Vrijednosti koje piše scraper: "gol", "autogol", "karton_zuti",
  // "karton_crveni", "karton_zutocrveni", "izmjena_ulazak",
  // "izmjena_izlazak", "nepoznato".
  tip: string;
};

export type IgracPostave = {
  igrac: string;
  broj: string | null;
  pozicija: "Vratar" | "Igrač";
  kapetan: boolean;
  pricuvni: boolean;
  dogadjaji: DogadjajIgraca[];
};

// Tip podataka koji odgovara strukturi naše Supabase tablice "utakmice"
export type Utakmica = {
  id: number;
  hns_url: string;
  natjecanje: string;
  sezona: string | null;
  kolo: number | null;
  domacin: string;
  gost: string;
  rezultat: string | null;
  stadion_datum: string | null;
  // Sirovi podaci s retka rasporeda - popunjeni i za utakmice koje se tek
  // trebaju odigrati (dok stadion_datum ostaje prazan sve do zapisnika).
  datum: string | null;
  vrijeme: string | null;
  stadion: string | null;
  gledatelja: string | null;
  suci: string | null;
  /**
   * Strijelci iz zapisnika. Oznaka "autogol" dolazi od scrapera, koji je
   * čita iz klase "own_goal" u zapisniku. Stariji redci je nemaju, pa za
   * njih vrijedi ručni popis u polju "autogolovi".
   */
  strijelci: { igrac: string; minuta: string; autogol?: boolean }[] | null;
  /**
   * Autogolovi, RUČNI popravak, scraper ih ne dira.
   *
   * Scraper autogol prepoznaje sam, iz klase "own_goal" u zapisniku, i
   * označava ga u polju "strijelci". Ovaj popis ostaje za dva slučaja:
   * utakmice odigrane prije nego je prepoznavanje dodano, i one gdje HNS
   * pogodak nije označio kao autogol iako jest. Djeluje isto: pogodak se
   * pripisuje protivniku strijelca.
   */
  autogolovi: { igrac: string; minuta: string }[] | null;
  postava_domacin: IgracPostave[] | null;
  postava_gost: IgracPostave[] | null;
  tekst_clanka: string | null;
  slika_url: string | null;
  created_at: string;
  derbi: boolean | null;
};

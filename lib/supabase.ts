import { createClient } from "@supabase/supabase-js";

// Ove dvije vrijednosti dolaze iz .env.local datoteke (vidi .env.local.example)
// NEXT_PUBLIC_ prefiks je bitan u Next.js-u - to govori da je vrijednost
// sigurna za korištenje u pregledniku (frontend), ne samo na serveru.
// VAŽNO: ovdje koristimo "anon" javni ključ, NIKAD "service_role" ključ -
// service_role ključ ima ovlasti pisanja i mora ostati samo u scraperu
// na tvom računalu, nikad u kodu koji se šalje pregledniku korisnika.
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export type DogadjajIgraca = {
  minuta: string;
  tip: string; // "Žuti karton" | "Crveni karton" | "Izmjena" | "Nepoznato"
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
  gledatelja: string | null;
  suci: string | null;
  strijelci: { igrac: string; minuta: string }[] | null;
  postava_domacin: IgracPostave[] | null;
  postava_gost: IgracPostave[] | null;
  tekst_clanka: string | null;
  slika_url: string | null;
  created_at: string;
};

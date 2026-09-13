import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  images: {
    // Fotografije uz članke stoje u Supabase Storageu, a next/image smije
    // dohvaćati samo s adresa navedenih ovdje. Uzorak pokriva javni dio
    // Storagea bilo kojeg Supabase projekta, pa se ne mora mijenjati ako
    // se projekt jednom preseli.
    //
    // Lokalne slike iz mape "public" (npr. /slike/dijeljenje.png) ovdje se
    // ne navode; njih next/image poslužuje bez dodatnih postavki.
    remotePatterns: [
      {
        protocol: "https",
        hostname: "*.supabase.co",
        pathname: "/storage/v1/object/public/**",
      },
    ],
  },

  // -------------------------------------------------------------------
  // PREUSMJERAVANJE STARE ADRESE, BEZ IJEDNE SEKUNDE PROCESORA
  // -------------------------------------------------------------------
  // Ovo je prije radila datoteka proxy.ts (do Nexta 16 middleware.ts).
  // Problem je bio što se takva datoteka pokreće pri SVAKOM zahtjevu na
  // stranicu, pa je u dvanaest sati imala 2400 pokretanja, a posao joj je
  // bio da u 2399 slučajeva ne napravi ništa. Sve to troši Fluid Active
  // CPU, isto ograničenje zbog kojeg je 13.09.2026. stigla obavijest o
  // 75 posto potrošenih besplatnih četiri sata.
  //
  // Ovdje zapisano preusmjeravanje rješava Vercelov usmjerivač, prije
  // nego se ijedna funkcija uopće pokrene. Ponašanje je isto: trajno
  // (308) preusmjeravanje na domenu, uz očuvanu putanju i upitni dio.
  //
  // NAMJERNO se traži TOČNO ta jedna adresa, a ne nastavak ".vercel.app"
  // ni uzorak: adrese pojedinih preview deploymenata moraju i dalje
  // raditi normalno, inače se promjene ne mogu isprobati prije puštanja
  // u produkciju. Njihova imena imaju dodatak (npr.
  // istra-pgz-nogomet-a1b2c3.vercel.app), pa pod ovaj uvjet ne potpadaju.
  async redirects() {
    return [
      {
        source: "/:putanja*",
        has: [{ type: "host", value: "istra-pgz-nogomet.vercel.app" }],
        destination: "https://lokalarena.com/:putanja*",
        permanent: true,
      },
    ];
  },
};

export default nextConfig;

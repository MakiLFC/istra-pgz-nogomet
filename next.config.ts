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
};

export default nextConfig;

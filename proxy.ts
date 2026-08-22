// proxy.ts, trajno preusmjeravanje stare Vercel adrese na domenu.
//
// Datoteka se do Nexta 16 zvala middleware.ts. Nova konvencija je proxy,
// a stari naziv izaziva upozorenje pri gradnji. Sadržaj je isti.
//
// Stranica je prešla na lokalarena.com, a stara adresa
// istra-pgz-nogomet.vercel.app i dalje odgovara. Ovdje se svaki zahtjev
// s te jedne adrese trajno (308) preusmjerava na novu domenu, uz očuvanu
// putanju i upitni dio.
//
// NAMJERNO se uspoređuje TOČNO ta jedna adresa, a ne nastavak
// ".vercel.app" ni uzorak: adrese pojedinih preview deploymenata moraju
// i dalje raditi normalno, inače se promjene ne mogu isprobati prije
// puštanja u produkciju.

import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function proxy(request: NextRequest) {
  const host = request.headers.get("host") ?? "";

  if (host === "istra-pgz-nogomet.vercel.app") {
    const url = new URL(request.url);
    url.protocol = "https:";
    url.host = "lokalarena.com";
    return NextResponse.redirect(url, 308);
  }

  return NextResponse.next();
}

export const config = {
  matcher: "/((?!_next/static|_next/image|favicon.ico).*)",
};

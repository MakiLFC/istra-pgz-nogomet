import { IgracPostave, DogadjajIgraca } from "@/lib/supabase";
import { IkonaLopta } from "./Ikone";

function StrelicaIzlazak() {
  return (
    <svg width="11" height="11" viewBox="0 0 24 24" aria-hidden="true" style={{ display: "inline-block", verticalAlign: "-1px" }}>
      <path d="M12 4v13M6 11l6 6 6-6" fill="none" stroke="var(--card-red)" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function StrelicaUlazak() {
  return (
    <svg width="11" height="11" viewBox="0 0 24 24" aria-hidden="true" style={{ display: "inline-block", verticalAlign: "-1px" }}>
      <path d="M12 20V7M6 13l6-6 6 6" fill="none" stroke="var(--pitch-light)" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function Karton({ boja }: { boja: string }) {
  return (
    <svg width="8" height="11" viewBox="0 0 8 11" aria-hidden="true" style={{ display: "inline-block", verticalAlign: "-1px" }}>
      <rect x="0.5" y="0.5" width="7" height="10" rx="1.2" fill={boja} />
    </svg>
  );
}

function KartonZutoCrveni() {
  return (
    <span className="inline-flex" aria-hidden="true">
      <Karton boja="var(--card-yellow)" />
      <span style={{ marginLeft: "-3px" }}>
        <Karton boja="var(--card-red)" />
      </span>
    </span>
  );
}

// Tip događaja sad dolazi GOTOV iz baze (scraper ga čita direktno iz HTML-a:
// div.matchEvents -> klasa/title svakog događaja). Ovdje samo biramo ikonu.
function IkonaDogadjaja({ tip }: { tip: string }) {
  switch (tip) {
    case "gol":
      return <IkonaLopta size={11} />;
    case "izmjena_izlazak":
      return <StrelicaIzlazak />;
    case "izmjena_ulazak":
      return <StrelicaUlazak />;
    case "karton_zuti":
      return <Karton boja="var(--card-yellow)" />;
    case "karton_crveni":
      return <Karton boja="var(--card-red)" />;
    case "karton_zutocrveni":
      return <KartonZutoCrveni />;
    default:
      return null;
  }
}

const minutaUBroj = (m: string) => parseInt(m, 10) || 0;

function redakIgraca(igrac: IgracPostave, goloviIgraca: Set<string>) {
  // Događaji iz scrapera (imaju tip). Kao sigurnosnu mrežu dodajemo golove iz
  // liste strijelaca ako ih matchEvents slučajno ne bi sadržavao - da lopta
  // uz strijelca nikad ne izostane.
  const dogadjaji: DogadjajIgraca[] = [...(igrac.dogadjaji ?? [])];
  goloviIgraca.forEach((minuta) => {
    const vecImaGol = dogadjaji.some((d) => d.minuta === minuta && d.tip === "gol");
    if (!vecImaGol) {
      dogadjaji.push({ minuta, tip: "gol" } as DogadjajIgraca);
    }
  });
  dogadjaji.sort((a, b) => minutaUBroj(a.minuta) - minutaUBroj(b.minuta));

  return (
    <li
      key={`${igrac.igrac}-${igrac.broj}`}
      className="flex items-baseline gap-2 py-0.5"
    >
      <span
        className="font-mono w-5 shrink-0 text-right"
        style={{ color: "var(--ink-muted)" }}
      >
        {igrac.broj ?? "–"}
      </span>
      <span className={igrac.kapetan ? "font-medium" : ""}>
        {igrac.igrac}
        {igrac.kapetan && (
          <span className="ml-1" style={{ color: "var(--card-yellow)" }}>
            (C)
          </span>
        )}
        {igrac.pozicija === "Vratar" && (
          <span className="ml-1 text-xs" style={{ color: "var(--ink-muted)" }}>
            (GK)
          </span>
        )}
        {dogadjaji.map((d: DogadjajIgraca, idx: number) => (
          <span key={idx} className="ml-1 inline-flex items-baseline gap-0.5">
            <IkonaDogadjaja tip={d.tip} />
            <span className="font-mono text-xs" style={{ color: "var(--ink-muted)" }}>
              {d.minuta}
            </span>
          </span>
        ))}
      </span>
    </li>
  );
}

export default function Postava({
  nazivKluba,
  igraci,
  strijelci,
}: {
  nazivKluba: string;
  igraci: IgracPostave[];
  strijelci?: { igrac: string; minuta: string }[];
}) {
  const prvih11 = igraci.filter((i) => !i.pricuvni);
  const pricuvni = igraci.filter((i) => i.pricuvni);

  // Golovi po igraču iz liste strijelaca - koristi se samo kao sigurnosna
  // mreža u redakIgraca (glavni izvor tipa je sad d.tip iz baze).
  const goloviPoIgracu = (ime: string): Set<string> =>
    new Set(
      (strijelci ?? [])
        .filter((s) => s.igrac === ime)
        .map((s) => s.minuta)
    );

  return (
    <div>
      <p
        className="font-display mb-1 text-xs font-semibold uppercase tracking-wide"
        style={{ color: "var(--ink-muted)" }}
      >
        {nazivKluba}
      </p>
      <ul className="font-sans text-sm">
        {prvih11.map((i) => redakIgraca(i, goloviPoIgracu(i.igrac)))}
      </ul>
      {pricuvni.length > 0 && (
        <>
          <p className="mb-1 mt-2 font-sans text-xs" style={{ color: "var(--ink-muted)" }}>
            Pričuvni:
          </p>
          <ul className="font-sans text-sm" style={{ color: "var(--ink-muted)" }}>
            {pricuvni.map((i) => redakIgraca(i, goloviPoIgracu(i.igrac)))}
          </ul>
        </>
      )}
    </div>
  );
}

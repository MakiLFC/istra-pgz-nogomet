import { IgracPostave } from "@/lib/supabase";

function ikonaZaDogadjaj(tip: string) {
  if (tip === "Žuti karton") return "🟨";
  if (tip === "Crveni karton") return "🟥";
  if (tip === "Izmjena") return "🔄";
  return "•";
}

function redakIgraca(igrac: IgracPostave) {
  return (
    <li
      key={`${igrac.igrac}-${igrac.broj}`}
      className="flex items-baseline gap-2 py-0.5"
    >
      <span className="w-5 shrink-0 text-right text-[#999]">
        {igrac.broj ?? "–"}
      </span>
      <span className={igrac.kapetan ? "font-semibold" : ""}>
        {igrac.igrac}
        {igrac.kapetan && <span className="ml-1 text-[#d4a13d]">(C)</span>}
        {igrac.pozicija === "Vratar" && (
          <span className="ml-1 text-xs text-[#999]">(GK)</span>
        )}
      </span>
      {igrac.dogadjaji.length > 0 && (
        <span className="text-xs text-[#999]">
          {igrac.dogadjaji
            .map((d) => `${ikonaZaDogadjaj(d.tip)} ${d.minuta}`)
            .join("  ")}
        </span>
      )}
    </li>
  );
}

export default function Postava({
  nazivKluba,
  igraci,
}: {
  nazivKluba: string;
  igraci: IgracPostave[];
}) {
  const prvih11 = igraci.filter((i) => !i.pricuvni);
  const pricuvni = igraci.filter((i) => i.pricuvni);

  return (
    <div>
      <p className="mb-1 font-sans text-xs font-bold uppercase tracking-wide text-[#999]">
        {nazivKluba}
      </p>
      <ul className="font-sans text-sm text-[#1a1a1a]">
        {prvih11.map(redakIgraca)}
      </ul>
      {pricuvni.length > 0 && (
        <>
          <p className="mb-1 mt-2 font-sans text-xs text-[#999]">Pričuvni:</p>
          <ul className="font-sans text-sm text-[#666]">
            {pricuvni.map(redakIgraca)}
          </ul>
        </>
      )}
    </div>
  );
}

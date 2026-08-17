// ZaglavljeStranice.tsx — slikovno zaglavlje stranice lige i novosti.
//
// Naslov je UCRTAN u sliku (tipografija sjeda na greben, ime lige stoji
// kao duh iza planina, u moru pada odraz). Zato pravi <h1> ostaje na
// stranici, ali skriven klasom "sr-only": čitači ekrana i tražilice ga
// i dalje čitaju, a oko ga ne vidi jer isti tekst već stoji na slici.
//
// Namjerno PNG, ne SVG: slova u SVG-u trebala bi Playfair, a kad se SVG
// učita kroz <img> ne vidi fontove stranice pa bi pao na Georgiju.
// Datoteka s "@2x" je za ekrane veće gustoće.

type Props = {
  /** Ime datoteke bez nastavka, npr. "3-nl-zapad" ili "novosti". */
  slika: string;
  /** Tekst pravog naslova stranice (skriven, za čitače ekrana). */
  naslov: string;
};

export default function ZaglavljeStranice({ slika, naslov }: Props) {
  const osnovna = `/slike/zaglavlja/${slika}`;

  return (
    <>
      <h1 className="sr-only">{naslov}</h1>
      {/* Na uskim ekranima ide zasebna, "približena" verzija. Široko
          zaglavlje stisnuto na 340px daje naslov od jedva 13px, pa se
          ništa ne pročita; mobilna inačica je viša i ima krupniji slog. */}
      <picture>
        <source
          media="(max-width: 639px)"
          srcSet={`${osnovna}-mob.png 1x, ${osnovna}-mob@2x.png 2x`}
          width={640}
          height={400}
        />
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          src={`${osnovna}.png`}
          srcSet={`${osnovna}.png 1x, ${osnovna}@2x.png 2x`}
          alt=""
          width={1200}
          height={336}
          className="mb-8 block w-full [aspect-ratio:640/400] sm:[aspect-ratio:1200/336]"
        />
      </picture>
    </>
  );
}

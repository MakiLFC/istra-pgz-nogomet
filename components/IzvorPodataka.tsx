// IzvorPodataka.tsx
//
// Atribucija izvora podataka - OBVEZNA prema pisanom dopuštenju HNS-a
// (dopušteno javno prikazivanje podataka uz navođenje HNS Semafora kao izvora).
//
// UGRADNJA: u app/layout.tsx dodaj <IzvorPodataka /> na dno, unutar <body>,
// tako da se prikazuje na SVAKOJ stranici:
//
//   import IzvorPodataka from "@/components/IzvorPodataka";
//   ...
//   <body>
//     {children}
//     <IzvorPodataka />
//   </body>

export default function IzvorPodataka() {
  return (
    <footer
      className="mt-8 border-t px-4 py-3 text-center font-sans text-xs"
      style={{ color: "var(--ink-muted)", borderColor: "var(--ink-muted)" }}
    >
      Izvor podataka o utakmicama:{" "}
      <a
        href="https://semafor.hns.family"
        target="_blank"
        rel="noopener noreferrer"
        className="underline"
      >
        HNS Semafor
      </a>
      . Podaci se prikazuju uz dopuštenje HNS-a i nisu namijenjeni komercijalnoj
      upotrebi.
    </footer>
  );
}

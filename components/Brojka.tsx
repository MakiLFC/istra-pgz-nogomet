"use client";

// Brojka.tsx — broj se odbroji od nule kad uđe u vidno polje.
// Koristi se za statistiku (golovi, gledatelji, utakmice).

import { useEffect, useRef, useState } from "react";

export default function Brojka({
  vrijednost,
  trajanje = 1000,
  className = "",
}: {
  vrijednost: number;
  trajanje?: number;
  className?: string;
}) {
  const ref = useRef<HTMLSpanElement | null>(null);
  const [prikaz, setPrikaz] = useState(0);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    if (
      typeof window !== "undefined" &&
      window.matchMedia?.("(prefers-reduced-motion: reduce)").matches
    ) {
      setPrikaz(vrijednost);
      return;
    }

    let zahtjev = 0;
    const promatrac = new IntersectionObserver(([unos]) => {
      if (!unos.isIntersecting) return;
      promatrac.disconnect();

      const pocetak = performance.now();
      const korak = (sada: number) => {
        const t = Math.min((sada - pocetak) / trajanje, 1);
        // usporavanje pred kraj - brojka "sjedne" umjesto da naglo stane
        const lakoca = 1 - Math.pow(1 - t, 3);
        setPrikaz(Math.round(vrijednost * lakoca));
        if (t < 1) zahtjev = requestAnimationFrame(korak);
      };
      zahtjev = requestAnimationFrame(korak);
    });

    promatrac.observe(el);
    return () => {
      promatrac.disconnect();
      cancelAnimationFrame(zahtjev);
    };
  }, [vrijednost, trajanje]);

  return (
    <span ref={ref} className={className}>
      {prikaz.toLocaleString("hr-HR")}
    </span>
  );
}

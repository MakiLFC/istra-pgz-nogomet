"use client";

// Otkrivanje.tsx — sadržaj se blago podigne i pojavi kad uđe u vidno polje.
// Radi preko IntersectionObservera, bez biblioteka. Kad je korisnik u
// sustavu isključio animacije, sadržaj je odmah vidljiv.

import { useEffect, useRef, useState } from "react";

export default function Otkrivanje({
  children,
  kasnjenje = 0,
  className = "",
}: {
  children: React.ReactNode;
  kasnjenje?: number;
  className?: string;
}) {
  const ref = useRef<HTMLDivElement | null>(null);
  const [vidljivo, setVidljivo] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    if (
      typeof window !== "undefined" &&
      window.matchMedia?.("(prefers-reduced-motion: reduce)").matches
    ) {
      setVidljivo(true);
      return;
    }

    const promatrac = new IntersectionObserver(
      ([unos]) => {
        if (unos.isIntersecting) {
          setVidljivo(true);
          promatrac.disconnect();
        }
      },
      { rootMargin: "0px 0px -8% 0px", threshold: 0.05 }
    );

    promatrac.observe(el);
    return () => promatrac.disconnect();
  }, []);

  return (
    <div
      ref={ref}
      className={`otkrij ${vidljivo ? "otkrij-vidljivo" : ""} ${className}`}
      style={kasnjenje ? { transitionDelay: `${kasnjenje}ms` } : undefined}
    >
      {children}
    </div>
  );
}

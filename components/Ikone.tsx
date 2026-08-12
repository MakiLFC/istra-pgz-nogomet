// Ikone.tsx
//
// Ikone su crtane da ostanu čitljive na 11-14 px, gdje se prikazuju.
// Zato koriste PUNE plohe i jak kontrast: tanki potezi (ispod ~1 px)
// na telefonima se izglade i ikona se pretvori u običan kružić.

export function IkonaLopta({ size = 13 }: { size?: number }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      aria-hidden="true"
      style={{ display: "inline-block", verticalAlign: "-2px", flexShrink: 0 }}
    >
      <circle cx="12" cy="12" r="11" fill="var(--pitch)" />
      {/* središnji peterokut i rubna polja - svijetla, pune plohe */}
      <path d="M12 5.4 l4.9 3.55 -1.87 5.75h-6.06l-1.87-5.75z" fill="var(--paper)" />
      <path d="M12 1.6 l3.1 2.25 -1.15 1.55 -1.95-1.42 -1.95 1.42 -1.15-1.55z" fill="var(--paper)" />
      <path d="M1.9 10.2 l2.95 2.15 -0.9 1.55 -2.3-1.7z" fill="var(--paper)" />
      <path d="M22.1 10.2 l-2.95 2.15 0.9 1.55 2.3-1.7z" fill="var(--paper)" />
      <path d="M7.3 21.6 l1.15-3.35 1.8 0.6 -0.9 2.95z" fill="var(--paper)" />
      <path d="M16.7 21.6 l-1.15-3.35 -1.8 0.6 0.9 2.95z" fill="var(--paper)" />
    </svg>
  );
}

export function IkonaTeren({ size = 14 }: { size?: number }) {
  return (
    <svg
      width={size * 1.3}
      height={size}
      viewBox="0 0 36 26"
      aria-hidden="true"
      style={{ display: "inline-block", verticalAlign: "-2px", flexShrink: 0 }}
    >
      {/* potezi podebljani da prežive prikaz na ~14 px */}
      <rect x="1.2" y="1.2" width="33.6" height="23.6" rx="1.5"
            fill="none" stroke="var(--pitch)" strokeWidth="2.4" />
      <line x1="18" y1="1.2" x2="18" y2="24.8" stroke="var(--pitch)" strokeWidth="2" />
      <circle cx="18" cy="13" r="3.6" fill="none" stroke="var(--pitch)" strokeWidth="2" />
      <path d="M1.2 7.5 h5.4 v11 h-5.4" fill="none" stroke="var(--pitch)" strokeWidth="2" />
      <path d="M34.8 7.5 h-5.4 v11 h5.4" fill="none" stroke="var(--pitch)" strokeWidth="2" />
    </svg>
  );
}

// Grb.tsx — znak Lokal-Arene: mini nogometni teren, a na centru stara
// kožna lopta s panelima i vezicama.
//
// viewBox je skraćen na sam teren (64x44) pa je znak POLOŽEN - tako može
// ispuniti široku, nisku prazninu lijevo od naslova.
//
// Veličina: ili prop `size` (širina u px), ili Tailwind klase preko
// `className` (npr. "w-14 2xl:w-40") kad treba biti responzivan.
//
// Lopta pada na teren ~1,8 s nakon otvaranja stranice (klasa .lopta-pada,
// animacija definirana u globals.css).

export default function Grb({
  size,
  className = "",
}: {
  size?: number;
  className?: string;
}) {
  return (
    <svg
      {...(size ? { width: size, height: Math.round((size * 44) / 64) } : {})}
      className={className}
      viewBox="0 10 64 44"
      role="img"
      aria-label="Lokal-Arena"
      style={{ display: "block", flexShrink: 0 }}
    >
      {/* teren */}
      <rect x="2" y="12" width="60" height="40" rx="2" fill="var(--pitch-dark)" />
      <rect
        x="2" y="12" width="60" height="40" rx="2"
        fill="none" stroke="var(--oxide-light)" strokeWidth="3"
      />
      <g fill="none" stroke="var(--chalk)" strokeWidth="1.4" strokeOpacity="0.6">
        <rect x="7" y="17" width="50" height="30" />
        <path d="M32 17v30" />
        <rect x="7" y="24" width="6" height="16" />
        <rect x="51" y="24" width="6" height="16" />
      </g>

      {/* kožna lopta - pada na teren pri otvaranju stranice */}
      <g className="lopta-pada">
        <circle cx="32" cy="32" r="11.5" fill="#b06a37" />
        {/* šavovi između panela */}
        <g fill="none" stroke="#5c3218" strokeWidth="1.5" strokeLinecap="round" strokeOpacity="0.85">
          <path d="M24.9 23.0 q 3.4 10.9 0 17.9" />
          <path d="M39.1 23.0 q -3.4 10.9 0 17.9" />
          <path d="M20.8 29.1 q 11.2 -2.5 22.3 0" />
          <path d="M20.8 37.2 q 11.2 2.5 22.3 0" />
        </g>
        {/* vezice */}
        <g stroke="#3a2110" strokeWidth="1.5" strokeLinecap="round">
          <path d="M32 25.7 v 10.9" />
          <path d="M28.6 27.6 h 6.9" />
          <path d="M28.6 30.9 h 6.9" />
          <path d="M28.6 34.1 h 6.9" />
        </g>
      </g>
    </svg>
  );
}

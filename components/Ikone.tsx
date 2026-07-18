export function IkonaLopta({ size = 13 }: { size?: number }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      aria-hidden="true"
      style={{ display: "inline-block", verticalAlign: "-2px", flexShrink: 0 }}
    >
      <circle cx="12" cy="12" r="10.5" fill="white" stroke="var(--ink)" strokeWidth="1.4" />
      <circle cx="12" cy="9" r="2.6" fill="var(--ink)" />
      <circle cx="7" cy="15.5" r="2.6" fill="var(--ink)" />
      <circle cx="17" cy="15.5" r="2.6" fill="var(--ink)" />
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
      <rect x="1" y="1" width="34" height="24" rx="1.5" fill="none" stroke="var(--pitch)" strokeWidth="1.6" />
      <line x1="18" y1="1" x2="18" y2="25" stroke="var(--pitch)" strokeWidth="1.2" />
      <circle cx="18" cy="13" r="3.4" fill="none" stroke="var(--pitch)" strokeWidth="1.2" />
      <rect x="1" y="7" width="6" height="12" fill="none" stroke="var(--pitch)" strokeWidth="1.2" />
      <rect x="29" y="7" width="6" height="12" fill="none" stroke="var(--pitch)" strokeWidth="1.2" />
    </svg>
  );
}

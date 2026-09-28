// Štit na koji se stavlja pravi grb kluba (Andrejeva odluka 28.09.2026.,
// vidi PROCITAJ.md). Svi grbovi tako dobiju isti obris štita, i okrugli i
// kvadratni: metalni rub s ukošenjem, svijetlo polje, sjena. Sam grb se
// ne mijenja, samo stoji na štitu.
(function () {
  const VANJSKI = 'M50 3 C62 9 78 10 94 8 V52 C94 84 74 104 50 115 C26 104 6 84 6 52 V8 C22 10 38 9 50 3 Z';
  const UNUTARNJI = 'M50 10 C61 15 75 16 87 15 V52 C87 80 70 97 50 107 C30 97 13 80 13 52 V15 C25 16 39 15 50 10 Z';
  let n = 0;
  window.stitGrba = function (src) {
    const id = 's' + (n++);
    return `<span class="stit-grba">
      <svg viewBox="0 0 100 118" aria-hidden="true">
        <defs>
          <linearGradient id="${id}m" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0" stop-color="#fdf6e3"/><stop offset=".45" stop-color="#d9cfb4"/>
            <stop offset=".55" stop-color="#b9ad8d"/><stop offset="1" stop-color="#8a7f62"/>
          </linearGradient>
          <linearGradient id="${id}p" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stop-color="#ffffff"/><stop offset="1" stop-color="#e6e0d0"/>
          </linearGradient>
          <linearGradient id="${id}s" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stop-color="#fff" stop-opacity=".55"/><stop offset=".5" stop-color="#fff" stop-opacity="0"/>
          </linearGradient>
        </defs>
        <path d="${VANJSKI}" fill="url(#${id}m)"/>
        <path d="${VANJSKI}" fill="none" stroke="#5e5540" stroke-width="1.4"/>
        <path d="${UNUTARNJI}" fill="url(#${id}p)"/>
        <path d="${UNUTARNJI}" fill="none" stroke="#7d735a" stroke-width="1.2"/>
        <path d="M50 10 C61 15 75 16 87 15 V40 C70 44 30 44 13 40 V15 C25 16 39 15 50 10 Z" fill="url(#${id}s)"/>
      </svg>
      <img src="${src}" alt="">
    </span>`;
  };
})();

// Znakovi klubova za slike najava i pregleda kola.
//
// NISU pravi grbovi. Pravi klupski grbovi nisu dio dopuštenja koje je HNS
// dao, pa se crta vlastiti znak: oblik štita, boje kluba i jedan simbol
// izveden iz imena kluba ili mjesta (sidro, kula, grozd...). Boje, oblik i
// simbol po klubu stoje u klubovi.json. Klub kojeg ondje nema dobije
// neutralan znak u bojama stranice, pa slika nikad ne pada.

(function () {
  const OBRISI = {
    stit: 'M10 8 H90 V54 C90 84 70 102 50 112 C30 102 10 84 10 54 Z',
    stari: 'M8 12 Q29 4 50 12 Q71 4 92 12 V54 C92 84 71 102 50 112 C29 102 8 84 8 54 Z',
    krug: 'M50 8 A48 48 0 1 1 49.99 8 Z',
    kruna: 'M8 20 L22 8 L36 18 L50 6 L64 18 L78 8 L92 20 V56 C92 86 71 103 50 112 C29 103 8 86 8 56 Z',
  };

  // Polje štita: dvije boje u jednom od uzoraka.
  function polje(u, b2) {
    switch (u) {
      case 'polovice': return `<rect x="50" y="0" width="50" height="116" fill="${b2}"/>`;
      case 'pruge': return [22, 50, 78].map(x => `<rect x="${x - 6}" y="0" width="12" height="116" fill="${b2}"/>`).join('');
      case 'koso': return `<polygon points="0,116 100,16 100,116" fill="${b2}"/>`;
      case 'glava': return `<rect x="0" y="0" width="100" height="34" fill="${b2}"/>`;
      case 'pojas': return `<rect x="0" y="44" width="100" height="26" fill="${b2}"/>`;
      case 'krst': return `<rect x="42" y="0" width="16" height="116" fill="${b2}"/><rect x="0" y="40" width="100" height="16" fill="${b2}"/>`;
      default: return '';
    }
  }

  // Simboli su crtani potezima i plohama u koordinatama 100 x 116, oko
  // središta (50, 60). Svaki se crta dvaput: prvo taman i deblji (obrub),
  // pa svijetao, da se čita na svakoj boji polja.
  const SIMBOLI = {
    sidro: {
      s: 'M50 38 V86 M38 47 H62 M29 68 Q31 86 50 87 Q69 86 71 68 M29 68 L25 75 M29 68 L36 71 M71 68 L75 75 M71 68 L64 71',
      c: [[50, 32, 5.5]],
    },
    kormilo: (() => {
      let s = '';
      for (let i = 0; i < 8; i++) {
        const a = i * Math.PI / 4;
        s += `M${(50 + 5 * Math.cos(a)).toFixed(1)} ${(60 + 5 * Math.sin(a)).toFixed(1)} L${(50 + 27 * Math.cos(a)).toFixed(1)} ${(60 + 27 * Math.sin(a)).toFixed(1)} `;
      }
      return { s, c: [[50, 60, 17]], f: '<circle cx="50" cy="60" r="6"/>' };
    })(),
    kotac: (() => {
      let s = '';
      for (let i = 0; i < 6; i++) {
        const a = i * Math.PI / 3 + 0.3;
        s += `M${(50 + 6 * Math.cos(a)).toFixed(1)} ${(60 + 6 * Math.sin(a)).toFixed(1)} L${(50 + 19 * Math.cos(a)).toFixed(1)} ${(60 + 19 * Math.sin(a)).toFixed(1)} `;
      }
      return { s: s + 'M20 86 H80', c: [[50, 60, 21]], f: '<circle cx="50" cy="60" r="6.5"/>' };
    })(),
    kruna: {
      f: '<path d="M29 76 L27 46 L39 58 L50 38 L61 58 L73 46 L71 76 Z"/><rect x="28" y="79" width="44" height="7" rx="2"/><circle cx="27" cy="44" r="4"/><circle cx="50" cy="36" r="4.5"/><circle cx="73" cy="44" r="4"/>',
    },
    kula: {
      f: '<path d="M33 88 V52 H36 V42 H43 V49 H47 V42 H53 V49 H57 V42 H64 V52 H67 V88 Z"/>',
      tamno: '<path d="M45 88 V74 A5 5 0 0 1 55 74 V88 Z"/><rect x="47.5" y="57" width="5" height="9" rx="2.5"/>',
    },
    riba: {
      f: '<path d="M24 60 C34 44 56 42 68 60 C56 78 34 76 24 60 Z"/><path d="M66 60 L82 48 L79 60 L82 72 Z"/>',
      tamno: '<circle cx="36" cy="57" r="2.6"/>',
      s: 'M26 90 Q32 85 38 90 T50 90 T62 90 T74 90',
    },
    krampovi: {
      s: 'M34 88 L64 42 M66 88 L36 42 M52 36 Q66 34 76 46 M48 36 Q34 34 24 46',
    },
    sunce: (() => {
      let s = '';
      for (let i = 0; i < 12; i++) {
        const a = i * Math.PI / 6;
        s += `M${(50 + 19 * Math.cos(a)).toFixed(1)} ${(58 + 19 * Math.sin(a)).toFixed(1)} L${(50 + 28 * Math.cos(a)).toFixed(1)} ${(58 + 28 * Math.sin(a)).toFixed(1)} `;
      }
      return { s, f: '<circle cx="50" cy="58" r="13"/>' };
    })(),
    svjetionik: {
      f: '<path d="M42 88 L45.5 50 H54.5 L58 88 Z"/><rect x="43" y="40" width="14" height="9" rx="1.5"/><path d="M41 40 L50 31 L59 40 Z"/>',
      tamno: '<rect x="43.4" y="60" width="13.2" height="5"/><rect x="42.4" y="74" width="15.2" height="5"/>',
      s: 'M34 42 L24 38 M34 47 L24 51 M66 42 L76 38 M66 47 L76 51',
    },
    zir: {
      f: '<ellipse cx="50" cy="70" rx="12" ry="15"/><path d="M34 60 Q34 46 50 45 Q66 46 66 60 Q58 63 50 63 Q42 63 34 60 Z"/>',
      s: 'M50 45 Q50 38 55 34',
    },
    zvijezda: {
      f: (() => {
        let p = '';
        for (let i = 0; i < 10; i++) {
          const r = i % 2 ? 11 : 27, a = -Math.PI / 2 + i * Math.PI / 5;
          p += `${(50 + r * Math.cos(a)).toFixed(1)},${(62 + r * Math.sin(a)).toFixed(1)} `;
        }
        return `<polygon points="${p}"/>`;
      })(),
    },
    galeb: {
      s: 'M22 58 Q34 44 50 60 Q66 44 78 58',
      s2: 'M28 84 Q34 79 40 84 T52 84 T64 84 T76 84',
    },
    valovi: {
      s: 'M22 46 Q29 39 36 46 T50 46 T64 46 T78 46 M22 62 Q29 55 36 62 T50 62 T64 62 T78 62 M22 78 Q29 71 36 78 T50 78 T64 78 T78 78',
    },
    strelica: {
      s: 'M30 42 L48 60 L30 78 M50 42 L68 60 L50 78',
    },
    grozd: {
      f: [[36, 52], [50, 52], [64, 52], [43, 65], [57, 65], [50, 78]]
        .map(([x, y]) => `<circle cx="${x}" cy="${y}" r="7.5"/>`).join('') +
        '<path d="M53 42 Q64 28 77 35 Q67 45 53 42 Z"/>',
      s: 'M50 45 V34',
    },
    jedro: {
      f: '<path d="M50 32 V76 H28 Z"/><path d="M54 40 V76 H70 Z"/><path d="M24 80 H76 L68 90 H32 Z"/>',
    },
    jela: {
      f: '<path d="M50 30 L64 50 H57 L70 66 H60 L74 82 H26 L40 66 H30 L43 50 H36 Z"/><rect x="46" y="82" width="8" height="8"/>',
    },
    lopta: {
      c: [[50, 60, 22]],
      f: '<polygon points="50,52 58,58 55,67 45,67 42,58"/>',
    },
  };

  function tamnije(hex, k) {
    const n = parseInt(hex.slice(1), 16);
    const f = (v) => Math.max(0, Math.min(255, Math.round(v * k)));
    return `rgb(${f(n >> 16)},${f((n >> 8) & 255)},${f(n & 255)})`;
  }

  let brojac = 0;
  window.znakKluba = function (klub, opcije) {
    const c = klub || { b1: '#1c5a61', b2: '#dde2db', uzorak: 'glava', oblik: 'stit', simbol: 'lopta' };
    const id = 'g' + (brojac++);
    const obris = OBRISI[c.oblik] || OBRISI.stit;
    const sim = SIMBOLI[c.simbol] || SIMBOLI.lopta;
    const rub = c.rub || '#f1e9d2';
    const tam = '#0a2226';
    const svijetlo = c.znak || '#fbf8ef';

    const crtaj = (boja, debljina, dodatak) => {
      let t = '';
      const stroke = `stroke="${boja}" stroke-width="${debljina}" stroke-linecap="round" stroke-linejoin="round" fill="none"`;
      if (sim.s) t += `<path d="${sim.s}" ${stroke}/>`;
      if (sim.s2) t += `<path d="${sim.s2}" ${stroke}/>`;
      (sim.c || []).forEach(([x, y, r]) => { t += `<circle cx="${x}" cy="${y}" r="${r}" ${stroke}/>`; });
      if (sim.f) t += `<g fill="${boja}" stroke="${boja}" stroke-width="${dodatak}" stroke-linejoin="round">${sim.f}</g>`;
      return t;
    };

    return `<svg class="${(opcije && opcije.klasa) || 'klupski-znak'}" viewBox="0 0 100 116" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <clipPath id="${id}o"><path d="${obris}"/></clipPath>
        <linearGradient id="${id}s" x1="0" y1="0" x2="0.35" y2="1">
          <stop offset="0" stop-color="#fff" stop-opacity=".28"/>
          <stop offset=".45" stop-color="#fff" stop-opacity=".04"/>
          <stop offset="1" stop-color="#000" stop-opacity=".30"/>
        </linearGradient>
        <linearGradient id="${id}r" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stop-color="#fffaf0"/>
          <stop offset="1" stop-color="${tamnije(rub.startsWith('#') ? rub : '#f1e9d2', 0.72)}"/>
        </linearGradient>
      </defs>
      <path d="${obris}" fill="url(#${id}r)"/>
      <g transform="translate(50 60) scale(.84) translate(-50 -60)">
        <g clip-path="url(#${id}o)">
          <rect width="100" height="116" fill="${c.b1}"/>
          ${polje(c.uzorak, c.b2)}
          <rect width="100" height="116" fill="url(#${id}s)"/>
        </g>
        <path d="${obris}" fill="none" stroke="${tam}" stroke-opacity=".55" stroke-width="2.2"/>
        <g transform="translate(50 62) scale(1.02) translate(-50 -60)">
          <g opacity=".55" transform="translate(1.2 2)">${crtaj(tam, 9, 5)}</g>
          ${crtaj(tam, 9, 5)}
          ${crtaj(svijetlo, 5, 0)}
          ${sim.tamno ? `<g fill="${tam}">${sim.tamno}</g>` : ''}
        </g>
      </g>
      <path d="${obris}" fill="none" stroke="${tam}" stroke-opacity=".7" stroke-width="1.6"/>
    </svg>`;
  };
})();

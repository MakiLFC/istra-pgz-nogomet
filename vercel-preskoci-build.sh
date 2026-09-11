#!/usr/bin/env bash
# Odlucuje treba li Vercel uopce graditi ovaj push.
#
# ZASTO POSTOJI
#   Besplatni Deployment Storage je 10 GB, a puni ga BROJ deploymenata,
#   ne njihova velicina (cijeli public je 2,7 MB). Vecina nasih pusheva
#   mijenja samo SQL za clanke, alate u Pythonu i tekstove, dakle nista
#   sto stranica prikazuje, a svejedno bi pokrenula cijeli build.
#
# KAKO SE KORISTI
#   vercel.json -> "ignoreCommand": "bash vercel-preskoci-build.sh"
#   Naredba u vercel.json smije imati najvise 256 znakova, zato skripta.
#
# IZLAZNI KODOVI
#   0 = preskoci build, 1 = gradi. Vercel priznaje samo ta dva, pa je
#   svaki drugi ishod ovdje pretvoren u 1. Pravilo je: kad god nesto
#   nije jasno, GRADI. Preskocen build ne mijenja zivu stranicu, ostaje
#   zadnja objavljena verzija, ali propusten build znaci zastarjelu
#   stranicu, a to je gore.
#
# GASI SE brisanjem "ignoreCommand" iz vercel.json.

set -u

# Datoteke o kojima stranica ovisi. Sve ostalo (sql/, alati/, *.py,
# *.md, .github/) ne utjece na ono sto posjetitelj vidi.
PRACENE="app components lib public
         package.json package-lock.json
         next.config.ts tsconfig.json postcss.config.mjs
         eslint.config.mjs next-env.d.ts proxy.ts
         vercel.json vercel-preskoci-build.sh"

# PRVO PITANJE: koja grana?
#   Gradi se samo ono sto je na main, jer samo to posjetitelj vidi.
#   Buildovi s radnih grana (preview) bili su glavni trosak: 11.09.2026.
#   je Deployment Storage presao 10 GB, a Build CPU Minutes bio 13 h 44
#   u trideset dana, uz stranicu ciji je cijeli public 2,7 MB.
#
#   Mreza koju time gubimo (da se greska tipova vidi na grani prije
#   spajanja) nadoknaduje se pravilom iz CLAUDE.md: prije svakog pusha
#   pokrece se npm run build. I da nesto prode, Vercel pri padu ostavlja
#   zadnju ispravnu verziju na zraku.
#
#   Kad ime grane nije poznato, gradi se, jer ne znati nije razlog za
#   preskakanje.
GRANA="${VERCEL_GIT_COMMIT_REF:-}"

if [ -z "$GRANA" ]; then
  echo "Ime grane nije poznato, gradim."
  exit 1
fi

if [ "$GRANA" != "main" ]; then
  echo "Grana je $GRANA, a ne main, preskacem build."
  exit 0
fi

# DRUGO PITANJE: je li dirnuta stranica?
# Bez podatka o proslom deploymentu nema se s cim usporediti, pa se gradi.
if [ -z "${VERCEL_GIT_PREVIOUS_SHA:-}" ]; then
  echo "Nema VERCEL_GIT_PREVIOUS_SHA, gradim."
  exit 1
fi

# git diff --quiet: 0 kad razlike nema, 1 kad je ima, 128 kad nesto
# pukne (npr. plitki klon nema taj commit). Sve osim nule zavrsava
# gradnjom, ali se razlikuje u ispisu, da se kasnije zna sto se dogodilo.
git diff --quiet "$VERCEL_GIT_PREVIOUS_SHA" "$VERCEL_GIT_COMMIT_SHA" \
    -- $PRACENE 2>/dev/null
ISHOD=$?

if [ "$ISHOD" -eq 0 ]; then
  echo "Stranica nije dirnuta od proslog deploymenta, preskacem build."
  exit 0
fi

if [ "$ISHOD" -eq 1 ]; then
  echo "Dirnuta je barem jedna pracena datoteka, gradim."
  exit 1
fi

echo "Usporedba nije uspjela (git je vratio $ISHOD), za svaki slucaj gradim."
exit 1

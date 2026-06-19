#!/usr/bin/env bash
# Genera el PDF de cada Practica*.md usando pandoc + typst (sin LaTeX).
# Uso: ./_template/build.sh             -> compila todos los capítulos
#      ./_template/build.sh Capitulo01  -> compila solo ese capítulo
set -euo pipefail
cd "$(dirname "$0")/.."

export PATH="$HOME/.local/bin:$PATH"

PREAMBLE="_template/preamble.typ"
CAPS="${1:-Capitulo*}"

for dir in $CAPS; do
  [ -d "$dir" ] || continue
  for md in "$dir"/Practica*.md; do
    [ -f "$md" ] || continue
    pdf="${md%.md}.pdf"
    echo "Compilando $md -> $pdf"
    pandoc "$md" -o "$pdf" --pdf-engine=typst \
      --resource-path=".:$dir" \
      --lua-filter="_template/strip-mermaid.lua" \
      --include-in-header="$PREAMBLE"
  done
done
echo "Listo."

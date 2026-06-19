#!/usr/bin/env bash
# Compila TODOS los capítulos en un único PDF monolítico — esa es la
# entrega exigida por el cliente. Las fuentes siguen separadas por
# capítulo (00_Portada.md, Capitulo01.md, ... Capitulo09.md) para que
# revisar/corregir un capítulo no implique tocar los demás, pero el
# artefacto final siempre es UN solo documento.
set -euo pipefail
cd "$(dirname "$0")/.."

export PATH="$HOME/.local/bin:$PATH"

SALIDA="Manual-Teorico-Robot-Framework.pdf"
FUENTES=$(ls 00_Portada.md Capitulo*.md 2>/dev/null | sort)

if [ -z "$FUENTES" ]; then
  echo "No hay fuentes .md todavía." >&2
  exit 1
fi

echo "Compilando: $FUENTES"
pandoc $FUENTES -o "$SALIDA" --pdf-engine=typst \
  --resource-path=".:images" \
  --lua-filter="_template/strip-mermaid.lua" \
  --include-in-header="_template/preamble.typ" \
  --toc --toc-depth=2

echo "Generado: $SALIDA"

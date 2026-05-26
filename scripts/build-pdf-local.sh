#!/bin/bash
set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INPUT_FILES=("${PROJECT_DIR}/examples/advanced/deckblatt.md" "${PROJECT_DIR}/examples/advanced/documentation.md")
OUTPUT_DIR="${PROJECT_DIR}/out"
BUILD_DIR="${OUTPUT_DIR}/build"
OUTPUT_NAME="documentation"
TEMPLATE="/usr/local/share/pandoc/templates/custom-template.tex"
HEADER="/usr/local/share/pandoc/templates/header.tex"
HIGHLIGHT_THEME="/usr/local/share/pandoc/styles/code/vscode-light.theme"
KROKI_FILTER="${PROJECT_DIR}/docker/scripts/pandoc-kroki-filter.py"
CODE_CAPTION_FILTER="/usr/local/share/pandoc/filters/code-caption.lua"
SVG_TO_RASTER_FILTER="${PROJECT_DIR}/pandoc/filters/svg-to-raster.lua"
COMMON_ARGS=(-interaction=nonstopmode -halt-on-error)

mkdir -p "${BUILD_DIR}"

# 1. Run Pandoc (from build dir so kroki-images are created next to .tex)
(cd "${BUILD_DIR}" && pandoc \
  --to=latex \
  --output "${BUILD_DIR}/${OUTPUT_NAME}.tex" \
  --template="$TEMPLATE" \
  -H "$HEADER" \
  --highlight-style="$HIGHLIGHT_THEME" \
  --filter "$KROKI_FILTER" \
  --lua-filter "$SVG_TO_RASTER_FILTER" \
  --lua-filter "$CODE_CAPTION_FILTER" \
  --toc \
  --toc-depth=3 \
  --number-sections \
  --standalone \
  "${INPUT_FILES[@]}")

# 3. Compile TeX to PDF
cd "${BUILD_DIR}"
xelatex "${COMMON_ARGS[@]}" "${OUTPUT_NAME}.tex"

# Bibliography
if [ -f "${OUTPUT_NAME}.bcf" ] && command -v biber >/dev/null 2>&1; then
  biber "${OUTPUT_NAME}" || true
elif grep -q "citation" "${OUTPUT_NAME}.aux" || grep -q "bibdata" "${OUTPUT_NAME}.aux"; then
  bibtex "${OUTPUT_NAME}" || true
fi

xelatex "${COMMON_ARGS[@]}" "${OUTPUT_NAME}.tex"
xelatex "${COMMON_ARGS[@]}" "${OUTPUT_NAME}.tex"

# 4. Move final PDF
mv -f "${OUTPUT_NAME}.pdf" "${OUTPUT_DIR}/${OUTPUT_NAME}.pdf"

echo "Success! PDF created at: ${OUTPUT_DIR}/${OUTPUT_NAME}.pdf"

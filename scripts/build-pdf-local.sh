#!/bin/bash

set -e

# Configuration
INPUT_FILES=("examples/advanced/deckblatt.md" "examples/advanced/documentation.md")
OUTPUT_DIR="./out"
BUILD_DIR="${OUTPUT_DIR}/build"
OUTPUT_NAME="documentation"
TEMPLATE="pandoc/templates/custom-template.tex"
HEADER="pandoc/templates/header.tex"
HIGHLIGHT_THEME="pandoc/templates/styles/code/vscode-light.theme"
COMMON_ARGS="-halt-on-error"

# Create output directories if they don't exist
mkdir -p "${BUILD_DIR}"

# Build TeX with custom VSCode Light highlighting theme
pandoc "${INPUT_FILES[@]}" \
  --to=latex \
  --output "${BUILD_DIR}/${OUTPUT_NAME}.tex" \
  --template="$TEMPLATE" \
  -H "$HEADER" \
  --highlight-style="$HIGHLIGHT_THEME" \
  --toc \
  --toc-depth=3 \
  --number-sections \
  --standalone \
  --verbose \
  --biblatex \
  --top-level-division=chapter \
  -V lang=de-DE \
  -V documentclass=scrartcl \
  -V papersize=a4 \
  -V fontsize=11pt \
  > "${BUILD_DIR}/pandoc.log" 2>&1

cd "${BUILD_DIR}"
pdflatex ${COMMON_ARGS} "${OUTPUT_NAME}.tex"
bibtex "${OUTPUT_NAME}"
pdflatex ${COMMON_ARGS} "${OUTPUT_NAME}.tex"
pdflatex ${COMMON_ARGS} "${OUTPUT_NAME}.tex"
mv -f "${BUILD_DIR}/${OUTPUT_NAME}.pdf" "${OUTPUT_DIR}/${OUTPUT_NAME}.pdf"

echo "PDF created: ${OUTPUT_DIR}/${OUTPUT_NAME}.pdf"
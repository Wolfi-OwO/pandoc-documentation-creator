#!/bin/bash

set -e

# Configuration
INPUT_FILE="example/documentation.md"
OUTPUT_FILE="./output/documentation.pdf"
TEMPLATE="core/custom-template.tex"
HEADER="core/header.tex"
HIGHLIGHT_THEME="styles/code/vscode-light.theme"

# Create output directory if it doesn't exist
mkdir -p output

# Build PDF with custom VSCode Light highlighting theme
pandoc "$INPUT_FILE" \
  -o "$OUTPUT_FILE" \
  --template="$TEMPLATE" \
  -H "$HEADER" \
  --highlight-style="$HIGHLIGHT_THEME" \
  --toc \
  --toc-depth=3 \
  --number-sections \
  --pdf-engine=xelatex \
  -V lang=de-DE \
  -V documentclass=scrartcl \
  -V papersize=a4 \
  -V fontsize=11pt

echo "PDF created: $OUTPUT_FILE"
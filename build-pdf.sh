#!/bin/bash

set -e

# Pandoc Documentation Builder
IMAGE_NAME="pandoc-documentation-creator:latest"
OUTPUT_DIR="./output"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}Building PDF Documentation${NC}"
echo -e "${GREEN}=======================================${NC}"
echo ""

# Check if image exists
if ! docker images | grep -q "pandoc-documentation-creator"; then
    echo -e "${YELLOW}Image not found. Building...${NC}"
    ./init.sh
    echo ""
fi

echo -e "${YELLOW}Processing markdown files...${NC}"

# Using custom VSCode Light theme for syntax highlighting
docker run --rm \
  -v "$(pwd):/data" \
  -e PUPPETEER_CFG=/root/.puppeteer.json \
  ${IMAGE_NAME} \
    example/deckblatt.md example/documentation.md \
    --template=custom-template.tex \
    --highlight-style=/usr/local/share/pandoc/templates/styles/code/vscode-light.theme \
    --pdf-engine=xelatex \
    --toc \
    --number-sections \
    --filter pandoc-plantuml \
    --filter pandoc-mermaid \
    -o /data/output/documentation.pdf

if [ -f "$OUTPUT_DIR/documentation.pdf" ]; then
    echo ""
    echo -e "${GREEN}Success!${NC}"
    echo -e "${GREEN}Output: $OUTPUT_DIR/documentation.pdf${NC}"
    ls -lah "$OUTPUT_DIR/documentation.pdf"
else
    echo -e "${RED}Error: PDF was not created${NC}"
    exit 1
fi
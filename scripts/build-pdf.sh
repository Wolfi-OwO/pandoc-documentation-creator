#!/bin/bash

# Pandoc Documentation Creator - Example Build Script
# This script builds the example documentation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
IMAGE_NAME="registry.gitlab.com/woofi4/public/pandoc-documentation-creator:1.0.0"
OUTPUT_NAME="example-documentation"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}Building Example Documentation${NC}"
echo -e "${BLUE}=======================================${NC}"
echo ""

# Check if Docker image exists
if ! docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
    echo -e "${RED}Error: Docker image not found${NC}"
    echo -e "${YELLOW}Run ./init.sh build first${NC}"
    exit 1
fi

# Create output directories
mkdir -p "${PROJECT_DIR}/out/build"

# Build PDF from example files
echo -e "${YELLOW}Generating PDF from examples...${NC}"

if docker run --rm \
    -v "${PROJECT_DIR}:/data" \
    --entrypoint=/bin/sh \
    -e OUTPUT_NAME="${OUTPUT_NAME}" \
    -e INPUT_FILES="/data/examples/advanced/deckblatt.md /data/examples/advanced/documentation.md" \
    -e PANDOC_EXTRA_ARGS="--template=/usr/local/share/pandoc/templates/custom-template.tex --highlight-style=/usr/local/share/pandoc/templates/styles/code/vscode-light.theme --metadata=title:Example\\ Documentation --metadata=author:Pandoc\\ Documentation\\ Creator --metadata=lang:de" \
    "${IMAGE_NAME}" \
    -c "/data/buildPDF"; then
    echo ""
    echo -e "${GREEN}Build successful!${NC}"
    echo -e "${GREEN}Output: out/${OUTPUT_NAME}.pdf${NC}"

    if [ -f "${PROJECT_DIR}/out/${OUTPUT_NAME}.pdf" ]; then
        SIZE=$(du -h "${PROJECT_DIR}/out/${OUTPUT_NAME}.pdf" | cut -f1)
        echo -e "${BLUE}File size: ${SIZE}${NC}"
    fi

    echo ""
    echo -e "${BLUE}To create your own project:${NC}"
    echo -e "  ./init.sh new"
else
    echo ""
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi

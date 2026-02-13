#!/bin/bash

# Pandoc Documentation Creator - Example Build Script
# This script builds the example documentation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
IMAGE_REGISTRY="registry.gitlab.com/woofi4/public/pandoc-documentation-creator"
IMAGE_NAME="${IMAGE_REGISTRY}:latest"
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

# Ensure latest image is available
if ! docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
    echo -e "${YELLOW}Pulling latest Docker image...${NC}"
    docker pull "${IMAGE_NAME}" >/dev/null
fi

# Prefer the current release tag if it is available in image labels
IMAGE_VERSION=$(docker inspect --format='{{index .Config.Labels "org.opencontainers.image.version"}}' "${IMAGE_NAME}" 2>/dev/null || echo "")
if [ -n "${IMAGE_VERSION}" ] && [ "${IMAGE_VERSION}" != "unknown" ]; then
    IMAGE_NAME="${IMAGE_REGISTRY}:${IMAGE_VERSION}"
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
    -e TEMPLATE="/usr/local/share/pandoc/templates/custom-template.tex" \
    -e HEADER="/usr/local/share/pandoc/templates/header.tex" \
    -e HIGHLIGHT_THEME="/usr/local/share/pandoc/styles/code/vscode-light.theme" \
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

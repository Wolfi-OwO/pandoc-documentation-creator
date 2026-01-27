#!/bin/bash

set -e

# Pandoc Documentation Creator - Initialization Script
# This script builds the Docker image and sets up the environment

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="pandoc-documentation-creator"
VERSION="1.0.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}Pandoc Documentation Creator${NC}"
echo -e "${BLUE}Initialization${NC}"
echo -e "${BLUE}=======================================${NC}"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

echo -e "${YELLOW}Building Docker image...${NC}"
docker build -t "${IMAGE_NAME}:${VERSION}" -t "${IMAGE_NAME}:latest" "$SCRIPT_DIR"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}Build successful!${NC}"
    echo -e "${GREEN}Image: ${IMAGE_NAME}:${VERSION}${NC}"
    echo ""
    echo -e "${BLUE}Usage:${NC}"
    echo "  docker run --rm -v \$(pwd):/data ${IMAGE_NAME}:${VERSION} \\"
    echo "    example/deckblatt.md example/00-example.md \\"
        echo "    --template=custom-template.tex \\"
    echo "    --listings \\"
    echo "    --pdf-engine=xelatex \\"
    echo "    -o /data/output/documentation.pdf"
    echo ""
    echo -e "${BLUE}Or use build script:${NC}"
    echo "  ./build-pdf.sh"
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi

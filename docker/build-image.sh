#!/bin/bash

set -e

########
# Version Resolution
# ---
# Read the version from the repository root when available.
VERSION=$(cat ../VERSION 2>/dev/null || echo "1.0.0")
IMAGE_NAME="registry.gitlab.com/woofi4/public/pandoc-documentation-creator"
BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
VCS_REF=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
VCS_URL=$(git config --get remote.origin.url 2>/dev/null || echo "https://gitlab.com/woofi4/public/pandoc-documentation-creator")

echo "Building Docker image with version: ${VERSION}"

########
# Docker Build
# ---
# Build the image with metadata labels and tag both the release and latest.
docker build \
  --build-arg VERSION="${VERSION}" \
  --build-arg BUILD_DATE="${BUILD_DATE}" \
  --build-arg VCS_REF="${VCS_REF}" \
  --build-arg VCS_URL="${VCS_URL}" \
  -t "${IMAGE_NAME}:${VERSION}" \
  -t "${IMAGE_NAME}:latest" \
  -f Dockerfile \
  ..

echo ""
echo "✓ Build complete!"
echo ""
echo "Tagged as:"
echo "  - ${IMAGE_NAME}:${VERSION}"
echo "  - ${IMAGE_NAME}:latest"
echo ""
echo "Build metadata:"
echo "  - Version: ${VERSION}"
echo "  - Build Date: ${BUILD_DATE}"
echo "  - VCS Ref: ${VCS_REF}"
echo ""
echo "To push to registry:"
echo "  docker push ${IMAGE_NAME}:${VERSION}"
echo "  docker push ${IMAGE_NAME}:latest"

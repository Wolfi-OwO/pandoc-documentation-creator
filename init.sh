#!/bin/bash

set -e

# Pandoc Documentation Creator - Initialization Script
# This script sets up the documentation project structure

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_REGISTRY="registry.gitlab.com/woofi4/public/pandoc-documentation-creator"
VERSION="unknown"

# Repository URL for templates
REPO_RAW_URL="https://gitlab.com/woofi4/public/pandoc-documentation-creator/-/raw/main/templates"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to print colored messages
print_header() {
    echo -e "${BLUE}=======================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=======================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to download file from templates directory or use local
download_or_copy_template() {
    local template_name="$1"
    local destination="$2"
    
    # First try to copy from local templates directory
    if [ -f "${SCRIPT_DIR}/../templates/${template_name}" ]; then
        cp "${SCRIPT_DIR}/../templates/${template_name}" "${destination}"
        return 0
    fi
    
    # Try wget
    if command_exists wget; then
        wget -q -O "${destination}" "${REPO_RAW_URL}/${template_name}" 2>/dev/null && return 0
    fi
    
    # Try curl
    if command_exists curl; then
        curl -s -o "${destination}" "${REPO_RAW_URL}/${template_name}" 2>/dev/null && return 0
    fi
    
    return 1
}

# Function to create new project structure
create_new_project() {
    local target_dir="${1:-.}"
    
    print_header "Creating New Documentation Project"
    
    # Create directory structure
    print_info "Creating directory structure..."
    mkdir -p "${target_dir}/chapters"
    mkdir -p "${target_dir}/media"
    mkdir -p "${target_dir}/out"
    mkdir -p "${target_dir}/out/build"
    mkdir -p "${target_dir}/.vscode"
    mkdir -p "${target_dir}/.vscode/schemas"
    print_success "Directories created"
    
    # Copy or download configuration files
    print_info "Setting up configuration..."
    
    # Metadata only (defaults.yaml is built into Docker image)
    if download_or_copy_template "metadata.yaml.template" "${target_dir}/metadata.yaml"; then
        print_success "Created metadata.yaml"
    else
        print_error "Failed to create metadata.yaml, creating minimal version"
        create_minimal_metadata "${target_dir}/metadata.yaml"
    fi
    
    # Example chapters
    print_info "Creating example chapters..."
    
    if download_or_copy_template "01-introduction.md.template" "${target_dir}/chapters/01-introduction.md"; then
        print_success "Created chapters/01-introduction.md"
    else
        create_minimal_intro "${target_dir}/chapters/01-introduction.md"
    fi
    
    if download_or_copy_template "02-example-content.md.template" "${target_dir}/chapters/02-example-content.md"; then
        print_success "Created chapters/02-example-content.md"
    else
        create_minimal_example "${target_dir}/chapters/02-example-content.md"
    fi
    
    # Build script
    print_info "Creating build script..."
    if download_or_copy_template "build-pdf.sh.template" "${target_dir}/build-pdf.sh"; then
        chmod +x "${target_dir}/build-pdf.sh"
        if [ -n "${VERSION}" ] && [ "${VERSION}" != "unknown" ]; then
            sed -i "s#IMAGE_TAG=\"\${IMAGE_TAG:-latest}\"#IMAGE_TAG=\"${VERSION}\"#" "${target_dir}/build-pdf.sh" || true
        fi
        print_success "Created build-pdf.sh"
    else
        create_minimal_build_script "${target_dir}/build-pdf.sh"
    fi

    # Build helper script
    print_info "Creating build helper script..."
    if download_or_copy_template "buildPDF.template" "${target_dir}/buildPDF"; then
        chmod +x "${target_dir}/buildPDF"
        print_success "Created buildPDF"
    fi
    
    # Help file
    print_info "Creating help documentation..."
    if download_or_copy_template "Help.md.template" "${target_dir}/Help.md"; then
        if [ -n "${VERSION}" ] && [ "${VERSION}" != "unknown" ]; then
            sed -i "s#\${IMAGE_TAG}#${VERSION}#g" "${target_dir}/Help.md" || true
        fi
        print_success "Created Help.md"
    else
        create_minimal_help "${target_dir}/Help.md"
    fi

    print_info "Adding pandoc-schema for .yaml files..."
    if download_or_copy_template "pandoc-metadata.json.template" "${target_dir}/.vscode/schemas/pandoc-metadata.json"; then
        print_success "Created schema template"
    fi

    if download_or_copy_template "settings.json.template" "${target_dir}/.vscode/settings.json"; then
        print_success "Created vscode-settings"
    fi
    
    # Create .gitignore
    create_gitignore "${target_dir}/.gitignore"
    
    echo ""
    print_success "Project structure created successfully!"
    echo ""
    print_header "Next Steps"
    echo "1. Edit your documentation in the chapters/ directory"
    echo "2. Customize document settings in metadata.yaml"
    echo "3. Run ./build-pdf.sh to generate your PDF"
    echo "4. Check Help.md for detailed documentation"
    echo ""
    echo "Note: Pandoc configuration (defaults.yaml) is built into the Docker image."
    echo "      You only need to edit metadata.yaml for document customization."
    echo ""
}

create_minimal_metadata() {
    cat > "$1" << 'EOF'
title: "Project Documentation"
author: "Your Name"
date: ""
lang: en-US
documentclass: scrartcl
mainfont: "Liberation Serif"
sansfont: "Liberation Sans"
monofont: "Liberation Mono"
papersize: a4
fontsize: 11pt
linestretch: 1.15
linkcolor: blue
urlcolor: blue
toc-title: "Table of Contents"
numbersections: true
linestretch: 1.15
linkcolor: blue
urlcolor: blue
listings: true
EOF
    print_success "Created minimal metadata.yaml"
}

create_minimal_intro() {
    cat > "$1" << 'EOF'
# Introduction

Welcome to your documentation project.

## Getting Started

This template provides a professional documentation system using Pandoc and LaTeX.

## Features

- Easy to write: Use Markdown syntax
- Professional output: LaTeX-based PDF generation
- Code highlighting: Support for multiple programming languages
- Customizable: Easily adjust styling and layout

Edit the files in the `chapters/` directory to build your documentation.
EOF
    print_success "Created minimal introduction chapter"
}

create_minimal_example() {
    cat > "$1" << 'EOF'
# Example Content

## Code Example

```python
def hello_world():
    print("Hello, World!")
```

## Table

| Column 1 | Column 2 |
|----------|----------|
| Data 1   | Data 2   |

## List

- First item
- Second item
- Third item
EOF
    print_success "Created minimal example chapter"
}

create_minimal_build_script() {
        cat > "$1" << 'EOF'
#!/bin/bash
set -e
IMAGE_NAME="pandoc-documentation-creator"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_NAME="${OUTPUT_NAME:-documentation}"

echo "Building PDF..."

docker run --rm \
    -v "${PROJECT_DIR}:/data" \
    --entrypoint=/bin/sh \
    -e OUTPUT_NAME="${OUTPUT_NAME}" \
    "${IMAGE_NAME}" \
    -c "set -e
COMMON_ARGS='-halt-on-error'
mkdir -p /data/out/build
pandoc --defaults=/usr/local/share/pandoc/defaults.yaml \\\n+  --metadata-file=/data/metadata.yaml \\\n+  /data/chapters/*.md \\\n+  --to=latex \\\n+  --output /data/out/build/${OUTPUT_NAME}.tex \\\n+  --standalone \\\n+  --verbose \\\n+  --biblatex \\\n+  > /data/out/build/pandoc.log 2>&1
cd /data/out/build
pdflatex $COMMON_ARGS ${OUTPUT_NAME}.tex
bibtex ${OUTPUT_NAME}
pdflatex $COMMON_ARGS ${OUTPUT_NAME}.tex
pdflatex $COMMON_ARGS ${OUTPUT_NAME}.tex
mv -f /data/out/build/${OUTPUT_NAME}.pdf /data/out/${OUTPUT_NAME}.pdf"

echo "Done! Output: out/${OUTPUT_NAME}.pdf"
EOF
    chmod +x "$1"
    print_success "Created minimal build script"
}

create_minimal_help() {
    cat > "$1" << 'EOF'
# Help

## Quick Start

1. Write markdown files in `chapters/` directory
2. Run `./build-pdf.sh` to generate PDF
3. Find output in `out/documentation.pdf`

## Configuration

Edit `metadata.yaml` to customize document properties.
EOF
    print_success "Created minimal help file"
}

create_gitignore() {
    cat > "$1" << 'EOF'
# Output directory
out/*.pdf
out/build/

# Temporary files
*.aux
*.log
*.out
*.toc
*.lot
*.lof

# Diagram cache
plantuml-images/
mermaid-images/

# OS files
.DS_Store
Thumbs.db
EOF
}

pull_with_spinner() {
    local image="$1"
    local pid
    local spin="|/-\\"
    local i=0

    docker pull "$image" >/dev/null 2>&1 &
    pid=$!

    printf "Pulling Docker image "
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\rPulling Docker image %s" "${spin:$i:1}"
        sleep 0.1
    done
    wait "$pid"
    return $?
}

# Function to check/pull Docker image
check_docker_image() {
    print_header "Checking Docker Image"
    
    # Check Docker
    if ! command_exists docker; then
        print_error "Docker is not installed"
        exit 1
    fi
    
    # Try to pull the latest image
    print_info "Pulling latest Docker image..."
    if pull_with_spinner "${IMAGE_REGISTRY}:latest"; then
        print_success "Docker image pulled successfully"
    else
        print_error "Failed to pull Docker image"
        print_info "Checking for local image..."
        if ! docker image inspect "${IMAGE_REGISTRY}:latest" >/dev/null 2>&1; then
            print_error "No local image found either"
            exit 1
        fi
        print_info "Using local image"
    fi
    
        # Get version from Docker image
        IMAGE_VERSION=$(docker inspect --format='{{index .Config.Labels "org.opencontainers.image.version"}}' "${IMAGE_REGISTRY}:latest" 2>/dev/null || echo "unknown")
        
        if [ "$IMAGE_VERSION" != "unknown" ] && [ -n "$IMAGE_VERSION" ]; then
            VERSION="$IMAGE_VERSION"
            print_info "Using image version: ${VERSION}"
        else
            print_info "Could not determine image version, using default: ${VERSION}"
        fi
    
    # Set the full image name with version if available
    if [ -n "${VERSION}" ] && [ "${VERSION}" != "unknown" ]; then
        IMAGE_NAME="${IMAGE_REGISTRY}:${VERSION}"
    else
        IMAGE_NAME="${IMAGE_REGISTRY}:latest"
    fi
    print_info "Selected image: ${IMAGE_NAME}"
}

# Main script logic
print_header "Pandoc Documentation Creator"

# Check/pull Docker image
check_docker_image

echo ""
print_info "Version: ${VERSION}"

echo ""

# Create new project structure
create_new_project "."

echo ""
print_header "Setup Complete!"
echo "Your documentation project is ready."
echo ""
echo "Next steps:"
echo "  1. Edit files in the chapters/ directory"
echo "  2. Customize metadata.yaml"
echo "  3. Run ./build-pdf.sh to generate your PDF"
echo ""

# Remove the init script
rm -rf init.sh
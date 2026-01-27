# Quick Start Guide

## Bootstrap Your Documentation Project

You don't need to clone the entire repository! Just download the init script and you're ready to go.

### Using wget

```bash
# Download init.sh
wget https://gitlab.com/woofi4/public/pandoc-documentation-creator/-/raw/main/init.sh

# Make it executable
chmod +x init.sh

# Build the Docker image
./init.sh build

# Create a new documentation project
./init.sh new

# Build your PDF
./build-pdf.sh
```

### Using curl

```bash
# Download init.sh
curl -O https://gitlab.com/woofi4/public/pandoc-documentation-creator/-/raw/main/init.sh

# Make it executable
chmod +x init.sh

# Build the Docker image
./init.sh build

# Create a new documentation project
./init.sh new

# Build your PDF
./build-pdf.sh
```

## One-Liner (wget)

```bash
wget -O init.sh https://gitlab.com/woofi4/public/pandoc-documentation-creator/-/raw/main/init.sh && chmod +x init.sh && ./init.sh build
```

## One-Liner (curl)

```bash
curl -o init.sh https://gitlab.com/woofi4/public/pandoc-documentation-creator/-/raw/main/init.sh && chmod +x init.sh && ./init.sh build
```

## What This Does

1. **Downloads** the init.sh script from GitLab
2. **Builds** the Docker image with all dependencies
3. **Creates** a complete project structure when you run `./init.sh new`
4. **Generates** professional PDFs from your markdown

## Repository

Full source: https://gitlab.com/woofi4/public/pandoc-documentation-creator

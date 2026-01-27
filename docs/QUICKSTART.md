# Quick Start Guide

## Bootstrap Your Documentation Project

You don't need to clone the entire repository! Just run one command and you're ready to go.

## One-Liner Setup (wget)

```bash
wget -qO- https://gitlab.com/woofi4/public/pandoc-documentation-creator/-/raw/main/init.sh | bash
```

## One-Liner Setup (curl)

```bash
curl -fsSL https://gitlab.com/woofi4/public/pandoc-documentation-creator/-/raw/main/init.sh | bash
```

## What This Does

1. **Downloads** the init.sh script
2. **Builds** the Docker image with all dependencies
3. **Creates** a complete project structure in your current directory
4. **Sets up** everything you need to generate professional PDFs

## After Setup

```bash
# Edit your documentation
vim chapters/01-introduction.md

# Build your PDF
./build-pdf.sh
```

## Repository

Full source: https://gitlab.com/woofi4/public/pandoc-documentation-creator

## Manual Installation (Optional)

If you prefer to download and inspect the script first:

```bash
# Download
wget https://gitlab.com/woofi4/public/pandoc-documentation-creator/-/raw/main/init.sh

# Review the script
cat init.sh

# Make executable and run
chmod +x init.sh
./init.sh
```

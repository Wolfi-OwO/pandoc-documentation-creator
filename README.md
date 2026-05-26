# Pandoc Documentation Creator

[![pipeline](https://gitlab.com/woofi4/public/pandoc-documentation-creator/badges/main/pipeline.svg)](https://gitlab.com/woofi4/public/pandoc-documentation-creator/-/pipelines)
[![latest-release](https://gitlab.com/woofi4/public/pandoc-documentation-creator/-/badges/release.svg)](https://gitlab.com/woofi4/public/pandoc-documentation-creator/-/releases/permalink/latest)

**Maintainer:** Phillip Kofler (<koflerphillip@outlook.com>)

A complete Docker-based documentation system using Pandoc, LaTeX, and professional templates.

## Quick Start

### Bootstrap with wget (Recommended)

```bash
# Download and run init.sh
wget https://gitlab.com/woofi4/public/pandoc-documentation-creator/-/raw/main/init.sh
chmod +x init.sh
./init.sh build
```

Or with curl:

```bash
# Download and run init.sh
curl -O https://gitlab.com/woofi4/public/pandoc-documentation-creator/-/raw/main/init.sh
chmod +x init.sh
./init.sh build
```

### From Cloned Repository

If you've already cloned the repository:

```bash
git clone https://gitlab.com/woofi4/public/pandoc-documentation-creator.git
cd pandoc-documentation-creator
./init.sh build
```

### 1. Build the Docker Image

```bash
./init.sh build
```

### 2. Create a New Documentation Project

```bash
./init.sh new
```

This creates a complete project structure:

```text
your-project/
├── chapters/          # Your markdown documentation (Be careful default, can be overwritten!)
├── media/             # Images and diagrams
├── out/               # Generated PDFs
│   ├── build/         # Build logs and LaTeX artifacts
│   └── xxx.pdf/       # Output PDF
├── metadata.yaml      # Document metadata (title, author, etc.)
├── build-pdf.sh       # Build script
├── buildPDF           # Build helper run inside Docker
└── Help.md            # Comprehensive help
```

Note: Pandoc configuration (defaults.yaml) is built into the Docker image.
You only need to edit metadata.yaml for document customization.

### 3. Write Your Documentation

Edit the markdown files in `chapters/`:

```markdown
# My Chapter

This is **bold** and this is *italic*.

## Code Example

```python
def hello():
    print("Hello, World!")
```

### 4. Build Your PDF

```bash
./build-pdf.sh
```

The Docker container executes buildPDF to run Pandoc, pdflatex, and bibtex in sequence.

Find your PDF in `out/documentation.pdf`!

## Project Structure

```text
pandoc-documentation-creator/
├── Dockerfile              # Docker image definition
├── init.sh                # Initialization and setup script
├── build-pdf.sh           # PDF build script (for examples)
├── build-pdf-local.sh     # Local build variant
├── buildPDF               # Build helper run inside Docker
├── core/                  # LaTeX templates and headers
│   ├── custom-template.tex
│   ├── header.tex
│   └── listings-languages.tex
├── docker/                # Docker-specific files
│   ├── Dockerfile
│   ├── eisvogel.latex
│   └──  plantuml
├── templates/             # Project templates
│   ├── Help.md.template
│   ├── defaults.yaml.template
│   ├── metadata.yaml.template
│   ├── 01-introduction.md.template
│   ├── 02-example-content.md.template
│   └── buildPDF.template
├── example/               # Example documentation
│   ├── deckblatt.md
│   └── documentation.md
├── extensions/            # Pandoc extensions
│   ├── extensions.yaml
│   └── metadata.yaml
└── styles/               # Syntax highlighting themes
    └── code/
        └── vscode-light.theme
```

## Configuration

### Metadata (.pandoc/metadata.yaml)

Customize your document:

```yaml
title: "My Documentation"
author: "Your Name"
date: "2026"
lang: "de-AT"
documentclass: scrartcl
```

### Defaults (.pandoc/defaults.yaml)

Configure Pandoc behavior:

```yaml
from: markdown
to: pdf
table-of-contents: true
number-sections: true
pdf-engine: xelatex
```

## Usage Examples

### Basic Build

```bash
docker run --rm \
  -v $(pwd):/data \
  --entrypoint=/bin/sh \
  -e OUTPUT_NAME="documentation" \
  -e INPUT_GLOB="/data/chapters/*.md" \
  pandoc-documentation-creator \
  -c "/data/buildPDF"
```

### Custom Template

```bash
docker run --rm \
  -v $(pwd):/data \
  --entrypoint=/bin/sh \
  -e OUTPUT_NAME="doc" \
  -e INPUT_GLOB="/data/chapters/*.md" \
  -e PANDOC_EXTRA_ARGS="--template=/usr/local/share/pandoc/templates/custom-template.tex" \
  pandoc-documentation-creator \
  -c "/data/buildPDF"
```

### With Table of Contents

```bash
docker run --rm \
  -v $(pwd):/data \
  --entrypoint=/bin/sh \
  -e OUTPUT_NAME="doc" \
  -e INPUT_GLOB="/data/chapters/*.md" \
  -e PANDOC_EXTRA_ARGS="--toc --toc-depth=3" \
  pandoc-documentation-creator \
  -c "/data/buildPDF"
```

## Inputs & Bibliography

Builds require explicit inputs. Provide one of:

- `INPUT_FILES`: space-separated list of markdown files.
- `INPUT_GLOB`: glob like `/data/chapters/*.md`.
- `INPUT_DIR`: a directory containing `.md` files.

The default syntax highlighting theme is **VSCode Light**.

Bibliographies are supported via `references.bib` and `@key` citations in your markdown or `metadata.yaml`:

```yaml
bibliography: references.bib
```

You can override or point to a different file using `BIBLIOGRAPHY`, for example:

```bash
-e BIBLIOGRAPHY="/data/references.bib"
```

## Features in Detail

### Code Highlighting

Supports multiple languages with VSCode Light theme:

- Python, JavaScript, TypeScript, Java, C#, C++
- Bash, PowerShell, SQL
- JSON, YAML, XML, HTML, CSS
- Dockerfile, Makefile
- And many more...

### Diagrams

#### PlantUML

```plantuml
@startuml
Alice -> Bob: Hello
Bob -> Alice: Hi!
@enduml
```

#### Mermaid

```mermaid
graph TD
    A[Start] --> B[Process]
    B --> C[End]
```

### SVG Images (Auto-Converted)

LaTeX/PDF output can’t include `.svg` images directly. During the build, referenced SVGs are automatically rasterized using **Inkscape** (to PNG by default).

You can control the export via environment variables:

- `SVG_EXPORT_FORMAT`: `png` (default) or `jpg`
- `SVG_EXPORT_DPI`: export resolution (default: `300`)
- `SVG_EXPORT_JPG_QUALITY`: JPG quality (default: `92`)

### Typography

- Professional KOMA-Script document classes
- Liberation fonts (Serif, Sans, Mono)
- Customizable spacing and margins
- Beautiful code boxes with line numbers

## Requirements

- Docker
- Bash (for init and build scripts)
- wget or curl (for downloading templates)

## Advanced Usage

### Creating Projects in Specific Directories

```bash
./init.sh new /path/to/my-project
cd /path/to/my-project
./build-pdf.sh
```

### Customizing Templates

1. Copy templates from `templates/` directory
2. Modify as needed
3. Reference in your `.pandoc/defaults.yaml`

### Adding Custom Filters

Add to `metadata.yaml`:

```yaml
# Document metadata is configured here
# Pandoc defaults.yaml is built into the Docker image
```

## Docker Image Details

The image includes:

- Pandoc 3.7 with LaTeX
- Python 3 with pandoc filters
- NodeMermaid CLI.js with
- PlantUML with Java runtime
- Chromium for Mermaid rendering
- Comprehensive TeX packages
- VSCode Light syntax theme
- Custom templates and filters

## Troubleshooting

### Docker Build Fails

```bash
# Clear Docker cache
docker system prune -a

# Rebuild
./init.sh build
```

### PDF Generation Fails

1. Check markdown syntax
2. Verify file paths in configuration
3. Check Docker container logs
4. Ensure all referenced files exist

### Missing Fonts

The image includes Liberation fonts. To use custom fonts:

1. Mount font directory: `-v /path/to/fonts:/usr/share/fonts/custom`
2. Update font cache in container
3. Reference fonts in metadata

## Contributing

Contributions welcome! Areas for improvement:

- Additional syntax themes
- More templates
- Additional LaTeX packages
- Documentation improvements
- Bug fixes

## License

See [LICENCE](LICENCE) file for details.

## Credits

Built with:

- [Pandoc](https://pandoc.org/)
- [TeX Live](https://www.tug.org/texlive/)
- [KOMA-Script](https://www.ctan.org/pkg/koma-script)
- [PlantUML](https://plantuml.com/)
- [Mermaid](https://mermaid-js.github.io/)

## Support

- Check Help.md for detailed documentation (created with `./init.sh new`)
- Review example files in `examples/`
- See Pandoc documentation: <https://pandoc.org/MANUAL.html>

---

**Happy documenting!**

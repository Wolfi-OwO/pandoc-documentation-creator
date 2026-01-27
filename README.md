# Pandoc Documentation Creator

A complete Docker-based documentation system using Pandoc, LaTeX, and professional templates.

## Features

- 🐳 **Docker-based**: No local dependencies needed
- 📝 **Markdown**: Write in simple Markdown syntax
- 🎨 **Professional output**: Beautiful PDF generation with LaTeX
- 💻 **Code highlighting**: VSCode Light theme syntax highlighting
- 📊 **Diagrams**: PlantUML and Mermaid support
- ⚙️ **Configurable**: Easy customization through YAML files
- 🚀 **Ready to use**: Complete templates and examples included

## Quick Start

### 1. Build the Docker Image

```bash
./init.sh build
```

### 2. Create a New Documentation Project

```bash
./init.sh new
```

This creates a complete project structure:

```
your-project/
├── chapters/           # Your markdown documentation
├── media/             # Images and diagrams
├── output/            # Generated PDFs
├── .pandoc/           # Pandoc configuration
│   ├── defaults.yaml
│   └── metadata.yaml
├── build-pdf.sh       # Build script
└── Help.md           # Comprehensive help
```

### 3. Write Your Documentation

Edit the markdown files in `chapters/`:

```markdown
# My Chapter

This is **bold** and this is *italic*.

## Code Example

\`\`\`python
def hello():
    print("Hello, World!")
\`\`\`
```

### 4. Build Your PDF

```bash
./build-pdf.sh
```

Find your PDF in `output/documentation.pdf`!

## Project Structure

```
pandoc-documentation-creator/
├── Dockerfile              # Docker image definition
├── init.sh                # Initialization and setup script
├── build-pdf.sh           # PDF build script (for examples)
├── build-pdf-local.sh     # Local build variant
├── core/                  # LaTeX templates and headers
│   ├── custom-template.tex
│   ├── header.tex
│   └── listings-languages.tex
├── docker/                # Docker-specific files
│   ├── Dockerfile
│   ├── eisvogel.latex
│   ├── mmdc-wrapper.sh
│   ├── plantuml
│   └── tof-box.lua
├── templates/             # Project templates
│   ├── Help.md.template
│   ├── defaults.yaml.template
│   ├── metadata.yaml.template
│   ├── 01-introduction.md.template
│   ├── 02-example-content.md.template
│   └── build-pdf.sh.template
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
lang: "en-US"
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
docker run --rm -v $(pwd):/data pandoc-documentation-creator \
  --defaults=/data/.pandoc/defaults.yaml \
  /data/chapters/*.md \
  -o /data/output/documentation.pdf
```

### Custom Template

```bash
docker run --rm -v $(pwd):/data pandoc-documentation-creator \
  --template=custom-template.tex \
  chapters/*.md \
  -o output/doc.pdf
```

### With Table of Contents

```bash
docker run --rm -v $(pwd):/data pandoc-documentation-creator \
  --toc \
  --toc-depth=3 \
  chapters/*.md \
  -o output/doc.pdf
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

\`\`\`plantuml
@startuml
Alice -> Bob: Hello
Bob -> Alice: Hi!
@enduml
\`\`\`

#### Mermaid

\`\`\`mermaid
graph TD
    A[Start] --> B[Process]
    B --> C[End]
\`\`\`

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

Add to `.pandoc/defaults.yaml`:

```yaml
filters:
  - pandoc-plantuml
  - mermaid-filter
  - /path/to/your/custom-filter.lua
```

## Docker Image Details

The image includes:

- Pandoc 3.7 with LaTeX
- Python 3 with pandoc filters
- Node.js with Mermaid CLI
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
- Review example files in `example/`
- See Pandoc documentation: https://pandoc.org/MANUAL.html

---

**Happy documenting! 📚**

```bash
docker run --rm -v $(pwd):/data pandoc-documentation-creator:latest \
  my-doc.md \
  --defaults=/usr/local/share/pandoc/extensions/extensions.yaml \
  -o /data/output/my-doc.pdf
  --template=custom-template.tex \

### Mit Custom Template

```bash
docker run --rm -v $(pwd):/data -v $(pwd)/core:/templates \
  pandoc-documentation-creator:latest \
  my-doc.md \
  --template=/templates/custom-template.tex \
  -o /data/output/my-doc.pdf
```

  --template=/templates/custom-template.tex \

MIT License - siehe LICENCE

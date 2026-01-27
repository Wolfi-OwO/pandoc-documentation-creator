# Pandoc Documentation Creator

Vollstaendiges CI/CD-Projekt fuer automatisierte PDF-Dokumentationserstellung mit Pandoc, Docker und GitLab CI/CD.

## Features

- Pandoc 3.7 fuer Markdown-zu-PDF-Konvertierung
- Eigenes LaTeX-Template (custom-template.tex)
- Code Highlighting mit Listings
- PlantUML Support fuer Diagramme
- Docker fuer konsistente Build-Umgebung
- GitLab CI/CD fuer automatische Registry-Pushes
- Einfache Nutzung mit init.sh und build-pdf.sh

## Quick Start

### 1. Initialisierung

```bash
./init.sh
```

Dies baut das Docker-Image und zeigt Beispiel-Verwendung.

### 2. Beispiel bauen

```bash
./build-pdf.sh
```

Dies erstellt `output/documentation.pdf` aus den Beispiel-Dateien.

### 3. Eigene Dokumentation erstellen

```bash
docker run --rm -v $(pwd):/data pandoc-documentation-creator:latest \
  my-doc.md \
  --template=custom-template.tex \
  --listings \
  --pdf-engine=xelatex \
  --toc \
  --number-sections \
  -o /data/output/my-doc.pdf
```

## Projektstruktur

```
pandoc-documentation-creator/
|-- docker/               Docker-spezifische Dateien
|   |-- eisvogel.latex    Eisvogel Template
|   |-- plantuml          PlantUML Wrapper-Skript
|   |-- tof-box.lua       Lua Filter
|   `-- code-printout.tex LaTeX Codedruck-Template
|
|-- extensions/           Pandoc Extensions
|   |-- extensions.yaml   Pandoc Defaults
|   `-- metadata.yaml     Metadata Defaults
|
|-- core/                 Optionale Custom Templates
|   |-- custom-template.tex
|   `-- header.tex
|
|-- documentation/        Projekt-Dokumentation
|
|-- example/              Beispiel-Dokumente
|   |-- deckblatt.md
|   `-- 00-example.md
|
|-- output/               Generierte PDFs
|
|-- init.sh               Initialisierung und Docker-Build
|-- build-pdf.sh          PDF-Build-Skript
|-- Dockerfile            Docker-Image Definition
`-- .gitlab-ci.yml        CI/CD Pipeline
```

## Docker Image manuell bauen

```bash
docker build -t pandoc-documentation-creator:1.0.0 .
```

## CI/CD Pipeline

Das Projekt ist fuer GitLab CI/CD vorbereitet. Bei jedem Git-Tag wird automatisch:

1. Docker-Image gebaut
2. Zu GitLab Container Registry gepusht
3. Mit Version und latest getaggt

```bash
# Tag erstellen
git tag v1.0.0
git push origin v1.0.0
```

## Erweiterte Verwendung

### Mit PlantUML-Diagrammen

```markdown
```plantuml
@startuml
- Pandoc 3.7 fuer Markdown-zu-PDF-Konvertierung
- Eigenes LaTeX-Template (custom-template.tex)
- Code Highlighting mit Listings (Dark Modern VS Code Style)

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

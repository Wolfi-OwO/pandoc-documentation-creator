FROM pandoc/latex:3.7

# Build arguments for OCI labels
ARG VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

# Metadata labels (passed via build args)
LABEL org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.source="${VCS_URL}" \
      org.opencontainers.image.title="Pandoc Documentation Creator" \
      org.opencontainers.image.description="Professional documentation generator using Pandoc and LaTeX"

ENV PLANTUML_VERSION=1.2025.4

# Install system dependencies and fonts
RUN apk add --no-cache \
    python3 \
    py3-pip \
    openjdk21-jre \
    graphviz \
    fontconfig \
    freetype \
    ttf-dejavu \
    ttf-liberation \
    font-noto \
    zip \
    unzip \
    patch \
    make \
    nodejs \
    npm \
    chromium \
    chromium-chromedriver

# Update font cache
RUN fc-cache -fv

# Install mermaid-cli globally
RUN npm install -g @mermaid-js/mermaid-cli

# Install mermaid-filter globally
RUN npm install --global mermaid-filter

# Set puppeteer to use system chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Copy puppeteer config
COPY docker/.puppeteer.json /root/.puppeteer.json

# Replace all mmdc binaries with our wrapper that adds --no-sandbox
COPY docker/scripts/mmdc-wrapper.sh /usr/local/bin/mmdc-wrapper
RUN chmod +x /usr/local/bin/mmdc-wrapper && \
    mv /usr/local/bin/mmdc /usr/local/bin/mmdc-original && \
    ln -sf /usr/local/bin/mmdc-wrapper /usr/local/bin/mmdc && \
    find /usr/local/lib/node_modules -name mmdc -type f 2>/dev/null | while read mmdc_path; do \
        if [ -x "$mmdc_path" ]; then \
            mv "$mmdc_path" "${mmdc_path}-original" && \
            ln -sf /usr/local/bin/mmdc-wrapper "$mmdc_path"; \
        fi; \
    done && \
    find /usr/local/lib/node_modules -path "*/.bin/mmdc" 2>/dev/null | while read mmdc_link; do \
        rm -f "$mmdc_link" && \
        ln -sf /usr/local/bin/mmdc-wrapper "$mmdc_link"; \
    done

# Install pandoc filters
RUN pip3 install --break-system-packages --no-cache-dir \
    pandoc-plantuml-filter \
    pandoc-shortcaption \
    pandoc-mermaid-filter

# Download PlantUML
RUN mkdir -p /opt/plantuml && \
    wget -nv -O /opt/plantuml/plantuml.jar \
    https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar

# Copy PlantUML wrapper script
COPY docker/scripts/plantuml /usr/bin/plantuml
RUN chmod a+x /usr/bin/plantuml

# Install required TeX packages (in smaller groups to avoid tlmgr crashes)
RUN tlmgr update --self

# Core packages
RUN tlmgr install \
    microtype listings fvextra xcolor geometry titlesec

# Koma-Script and page layout
RUN tlmgr install \
    koma-script fancyhdr booktabs multirow colortbl

# Math and special formatting
RUN tlmgr install \
    mathtools amsmath enumitem footmisc adjustbox mdframed needspace

# Fonts - includes lm (Latin Modern) and source fonts
RUN tlmgr install \
    lm lm-math \
    merriweather fontaxes mweights sourcesanspro sourcecodepro \
    fontawesome5 ly1 fontspec

# Page and document setup
RUN tlmgr install \
    titling pagecolor collectbox footnotebackref zref sectsty \
    truncate tocloft wallpaper morefloats etoolbox

# Text formatting and links
RUN tlmgr install \
    ulem upquote csquotes float hyperref iftex xkeyval xpatch \
    caption bidi scrhack

# Advanced packages
RUN tlmgr install \
    siunitx threeparttable makecell bbold cleveref forloop lipsum \
    courier pdfpages lineno hardwrap catchfile pdflscape pdftexcmds

# Create directories
RUN mkdir -p /usr/local/share/pandoc/templates/ && \
    mkdir -p /usr/local/share/pandoc/filters/

ENV LAST_UPDATE=2026-01-27-vscode-light-theme

# Copy custom template and theme
COPY pandoc/templates/custom-template.tex /usr/local/share/pandoc/templates/custom-template.tex
COPY pandoc/templates/header.tex /usr/local/share/pandoc/templates/header.tex
COPY pandoc/defaults.yaml /usr/local/share/pandoc/defaults.yaml
COPY pandoc/styles/ /usr/local/share/pandoc/templates/styles/

# Copy extensions
COPY pandoc/extensions/ /usr/local/share/pandoc/extensions/

# Copy templates for project initialization
COPY templates/ /usr/local/share/pandoc/project-templates/

# Working directory
WORKDIR /data

# Entrypoint
ENTRYPOINT ["/usr/local/bin/pandoc"]

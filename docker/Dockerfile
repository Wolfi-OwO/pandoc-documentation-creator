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

# Install system dependencies and fonts in one layer
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
    curl \
    nodejs \
    npm \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Install mermaid-cli and configure Chromium for headless rendering
RUN npm install -g @mermaid-js/mermaid-cli && \
    npm cache clean --force

# Configure Puppeteer to use system Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    CHROME_BIN=/usr/bin/chromium-browser \
    PUPPETEER_ARGS="--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage --disable-gpu --single-process --no-zygote"

# Install pandoc filters and cleanup pip cache
RUN pip3 install --break-system-packages --no-cache-dir \
    pandoc-plantuml-filter \
    pandoc-shortcaption \
    pandoc-mermaid-filter && \
    rm -rf /root/.cache/pip
# Download PlantUML and setup wrapper
COPY docker/scripts/plantuml /usr/bin/plantuml
RUN mkdir -p /opt/plantuml && \
    wget -nv -O /opt/plantuml/plantuml.jar \
    https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar && \
    chmod a+x /usr/bin/plantuml

# Install all TeX packages in optimized groups (combined to reduce layers)
RUN tlmgr update --self && \
    tlmgr install \
        microtype listings fvextra xcolor geometry titlesec \
        koma-script fancyhdr booktabs multirow colortbl \
        mathtools amsmath enumitem footmisc adjustbox mdframed needspace \
        lm lm-math merriweather fontaxes mweights sourcesanspro sourcecodepro \
        fontawesome5 ly1 fontspec \
        titling pagecolor collectbox footnotebackref zref sectsty \
        truncate tocloft wallpaper morefloats etoolbox \
        ulem upquote csquotes float hyperref iftex xkeyval xpatch \
        caption bidi scrhack \
        siunitx threeparttable makecell bbold cleveref forloop lipsum \
        courier pdfpages lineno hardwrap catchfile pdflscape pdftexcmds && \
    rm -rf /tmp/*

# Update font cache after all fonts are installed
RUN fc-cache -fv

# Create directories
RUN mkdir -p /usr/local/share/pandoc/templates/ \
             /usr/local/share/pandoc/filters/

# Copy all pandoc files in fewer layers
COPY pandoc/templates/custom-template.tex /usr/local/share/pandoc/templates/
COPY pandoc/templates/header.tex /usr/local/share/pandoc/templates/
COPY pandoc/defaults.yaml /usr/local/share/pandoc/
COPY pandoc/styles/ /usr/local/share/pandoc/templates/styles/
COPY pandoc/extensions/ /usr/local/share/pandoc/extensions/
COPY templates/ /usr/local/share/pandoc/project-templates/

# Working directory
WORKDIR /data

# Entrypoint
ENTRYPOINT ["/usr/local/bin/pandoc"]

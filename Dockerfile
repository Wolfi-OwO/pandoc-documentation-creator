FROM pandoc/latex:3.7

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
ENV PUPPETEER_ARGS="--no-sandbox --disable-setuid-sandbox"

# Copy puppeteer and mermaid config
COPY .puppeteer.json /root/.puppeteer.json
COPY docker/mmdc-wrapper.sh /usr/bin/mmdc-wrapper
RUN chmod +x /usr/bin/mmdc-wrapper
ENV PUPPETEER_CFG=/root/.puppeteer.json
ENV MERMAID_BIN=/usr/bin/mmdc-wrapper
ENV MERMAID_BIN=/usr/bin/mmdc-wrapper

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
COPY docker/plantuml /usr/bin/plantuml
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
COPY core/custom-template.tex /usr/local/share/pandoc/templates/custom-template.tex
COPY core/header.tex /usr/local/share/pandoc/templates/header.tex
COPY core/defaults.yaml /usr/local/share/pandoc/defaults.yaml
COPY styles/ /usr/local/share/pandoc/templates/styles/

# Copy Lua filters
COPY docker/tof-box.lua /usr/local/share/pandoc/filters/tof-box.lua

# Copy extensions
COPY extensions/ /usr/local/share/pandoc/extensions/

# Copy templates for project initialization
COPY templates/ /usr/local/share/pandoc/project-templates/

# Working directory
WORKDIR /data

# Entrypoint
ENTRYPOINT ["/usr/local/bin/pandoc"]

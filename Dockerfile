FROM pandoc/latex:3.7

ENV PLANTUML_VERSION=1.2025.4

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    openjdk21-jre \
    graphviz \
    fontconfig \
    freetype \
    ttf-dejavu \
    zip \
    unzip \
    patch \
    make \
    nodejs \
    npm

# Install pandoc filters
RUN pip3 install --break-system-packages --no-cache-dir \
    pandoc-plantuml-filter \
    pandoc-shortcaption

# Download PlantUML
RUN mkdir -p /opt/plantuml && \
    wget -nv -O /opt/plantuml/plantuml.jar \
    https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar

# Copy PlantUML wrapper script
COPY docker/plantuml /usr/bin/plantuml
RUN chmod a+x /usr/bin/plantuml

# Install required TeX packages (sequential to avoid tlmgr locking)
RUN tlmgr update --self && \
        tlmgr install \
            microtype listings fvextra xcolor geometry titlesec koma-script \
            fancyhdr booktabs multirow colortbl adjustbox \
            mathtools amsmath enumitem footmisc \
            merriweather fontaxes mweights mdframed needspace sourcesanspro \
            sourcecodepro titling ly1 pagecolor collectbox footnotebackref \
            zref fontawesome5 sectsty truncate tocloft wallpaper morefloats \
            etoolbox fontspec ulem upquote csquotes float hyperref iftex xkeyval xpatch \
            caption bidi scrhack \
            siunitx threeparttable makecell bbold cleveref forloop lipsum courier \
            pdfpages lineno hardwrap catchfile pdflscape pdftexcmds

# Create directories
RUN mkdir -p /usr/local/share/pandoc/templates/ && \
    mkdir -p /usr/local/share/pandoc/filters/

ENV LAST_UPDATE=2026-01-26-light-theme

# Copy custom template
COPY core/custom-template.tex /usr/local/share/pandoc/templates/custom-template.tex
COPY core/header.tex /usr/local/share/pandoc/templates/header.tex
COPY styles/ /usr/local/share/pandoc/templates/styles/

# Copy Lua filters
COPY docker/tof-box.lua /usr/local/share/pandoc/filters/tof-box.lua

# Copy extensions
COPY extensions/ /usr/local/share/pandoc/extensions/

# Working directory
WORKDIR /data

# Entrypoint
ENTRYPOINT ["/usr/local/bin/pandoc"]

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
    curl

# Install pandoc filters and cleanup pip cache
RUN pip3 install --break-system-packages --no-cache-dir \
    pandoc-plantuml-filter \
    pandoc-shortcaption && \
    rm -rf /root/.cache/pip

# Copy and setup custom Kroki filter
COPY docker/scripts/pandoc-kroki-filter.py /usr/local/bin/pandoc-kroki-filter
RUN chmod +x /usr/local/bin/pandoc-kroki-filter


# Download PlantUML and setup wrapper
COPY docker/scripts/plantuml /usr/bin/plantuml
RUN mkdir -p /opt/plantuml && \
    wget -nv -O /opt/plantuml/plantuml.jar \
    https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar && \
    chmod a+x /usr/bin/plantuml

# Install all TeX packages in optimized groups
RUN set -e; \
        tlmgr option repository https://mirror.ctan.org/systems/texlive/tlnet; \
        for i in 1 2 3; do \
            if tlmgr update --self && \
                 tlmgr install \
                 microtype listings fvextra xcolor geometry titlesec \
                 koma-script fancyhdr booktabs multirow colortbl \
                 mathtools amsmath enumitem footmisc adjustbox mdframed needspace \
                 lm lm-math merriweather fontaxes mweights sourcesanspro sourcecodepro \
                 fontawesome5 ly1 fontspec breqn \
                 titling pagecolor collectbox footnotebackref zref sectsty \
                 truncate tocloft wallpaper morefloats etoolbox \
                 ulem upquote csquotes float hyperref iftex xkeyval xpatch \
                 caption bidi scrhack \
                 siunitx threeparttable makecell bbold cleveref forloop lipsum \
                 courier pdfpages lineno hardwrap catchfile pdflscape pdftexcmds \
                 svg transparent; then \
                success=1; \
                break; \
            fi; \
            sleep 5; \
        done; \
        [ -n "$success" ]; \
        rm -rf /tmp/*

# Update font cache after all fonts are installed
RUN fc-cache -fv

# Create directories
RUN mkdir -p /usr/local/share/pandoc/templates/ \
    /usr/local/share/pandoc/filters/ \
    /usr/local/share/pandoc/styles/ \
    /usr/local/share/examples/

# Copy all pandoc files
COPY pandoc/ /usr/local/share/pandoc/
RUN chmod +x /usr/local/share/pandoc/filters/*.lua

# Copy examples
COPY examples/ /usr/local/share/examples/

# Copy build script
COPY buildPDF /data/buildPDF
RUN chmod +x /data/buildPDF

# Working directory
WORKDIR /data

# Entrypoint
ENTRYPOINT ["/usr/local/bin/pandoc"]
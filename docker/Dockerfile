FROM pandoc/latex:3.9

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

LABEL org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.revision="${VCS_REF}" \
    org.opencontainers.image.source="${VCS_URL}" \
    org.opencontainers.image.title="Pandoc Documentation Creator" \
    org.opencontainers.image.description="Professional documentation generator using Pandoc and LaTeX"

ENV PLANTUML_VERSION=1.2025.4

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
    wget

RUN pip3 install --break-system-packages --no-cache-dir \
    pandoc-plantuml-filter \
    pandoc-shortcaption && \
    rm -rf /root/.cache/pip

COPY docker/scripts/pandoc-kroki-filter.py /usr/local/bin/pandoc-kroki-filter
RUN chmod +x /usr/local/bin/pandoc-kroki-filter

COPY docker/scripts/plantuml /usr/bin/plantuml
RUN mkdir -p /opt/plantuml && \
    wget -nv -O /opt/plantuml/plantuml.jar \
    https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar && \
    chmod a+x /usr/bin/plantuml

RUN set -e; \
    tlmgr option repository https://mirror.ctan.org/systems/texlive/tlnet; \
    for i in 1 2 3; do \
        if tlmgr update --self && \
           tlmgr install \
             microtype listings fvextra xcolor geometry titlesec \
             koma-script fancyhdr booktabs multirow colortbl \
             mathtools amsmath enumitem footmisc adjustbox mdframed needspace \
             lm lm-math merriweather fontaxes mweights sourcesans sourcecodepro \
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

RUN fc-cache -fv

RUN mkdir -p /usr/local/share/pandoc/templates/ \
    /usr/local/share/pandoc/filters/ \
    /usr/local/share/pandoc/styles/ \
    /usr/local/share/examples/

COPY pandoc/ /usr/local/share/pandoc/
RUN chmod +x /usr/local/share/pandoc/filters/*.lua

COPY examples/ /usr/local/share/examples/

COPY buildPDF /data/buildPDF
RUN chmod +x /data/buildPDF

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/pandoc"]
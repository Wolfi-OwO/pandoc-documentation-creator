FROM pandoc/latex:3.7

ENV PLANTUML_VERSION=1.2025.4
ENV REVEALJS_VERSION=5.1.0
ENV EISVOGEL_VERSION=3.2.1

# python3 py3-pip                 ... for pandoc plantuml filter
# openjdk21-jre graphviz          ... for plantuml
# fontconfig freetype ttf-dejavu  ... for plantuml as well
# make                            ... for the thesis project
RUN apk add --no-cache python3 py3-pip py3-psutil openjdk21-jre graphviz fontconfig freetype ttf-dejavu make patch zip nodejs npm

# install pandoc-plantuml-filter and other packages via pip3
RUN pip3 install --break-system-packages pandoc-plantuml-filter pandoc-shortcaption

# download specified version of plantuml
RUN mkdir -p /opt/plantuml && \
    wget -nv -O /opt/plantuml/plantuml.jar https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar

# download and extract specified version of reveal.js
RUN mkdir -p /opt && \
    wget -nv -O /opt/reveal.js.zip https://github.com/hakimel/reveal.js/archive/refs/tags/${REVEALJS_VERSION}.zip && \
    unzip /opt/reveal.js.zip -d /opt && \
    rm /opt/reveal.js.zip && \
    mv /opt/reveal.js-${REVEALJS_VERSION} /opt/reveal.js

# pandoc filter requires the existence of such a script
ADD plantuml /usr/bin/plantuml
RUN chmod a+x /usr/bin/plantuml

# add additional tex packages for Eisvogel template
# taken from https://github.com/rstropek/pandoc-latex/blob/master/Dockerfile
RUN tlmgr update --self && \
    tlmgr install \
    merriweather \
    fontaxes \
    mweights \
    mdframed \
    needspace \
    sourcesanspro \
    sourcecodepro \
    titling \
    ly1 \
    pagecolor \
    adjustbox \
    collectbox \
    titlesec \
    fvextra \
    pdftexcmds \
    footnotebackref \
    zref \
    fontawesome5 \
    footmisc \
    sectsty \
    truncate \
    tocloft \
    wallpaper \
    morefloats \
    siunitx \
    threeparttable \
    makecell \
    bbold \
    cleveref \
    multirow \
    forloop \
    lipsum \
    courier \
    koma-script \
    mathtools \
    pdfpages \
    lineno \
    hardwrap \
    catchfile \
    pdflscape \
    tcolorbox \
    environ \
    pgf \

# create template directory first
RUN mkdir -p /usr/local/share/pandoc/templates/

ADD eisvogel_improvements.patch /opt/eisvogel/eisvogel_improvements.patch

# download and integrate eisvogel template
RUN mkdir -p /opt/eisvogel && \
    echo "${EISVOGEL_VERSION}" >/opt/eisvogel/version && \
    wget -nv -O /tmp/eisvogel.zip https://github.com/Wandmalfarbe/pandoc-latex-template/releases/download/v${EISVOGEL_VERSION}/Eisvogel.zip && \
    unzip -j /tmp/eisvogel.zip Eisvogel-${EISVOGEL_VERSION}/eisvogel.latex -d /opt/eisvogel && \
    mv /opt/eisvogel/eisvogel.latex /opt/eisvogel/eisvogel.tex && \
    patch -d /opt/eisvogel </opt/eisvogel/eisvogel_improvements.patch && \
    mkdir -p /root/.local/share/pandoc/templates && \
    cp /opt/eisvogel/eisvogel.tex /usr/local/share/pandoc/templates/eisvogel.tex


ADD code-printout.tex /usr/local/share/pandoc/templates/code-printout.tex

# install solution remover globally
RUN npm install -g solution-remove@latest

# add generate assignment script
ADD generateAssignment.sh /usr/bin/generateAssignment.sh
RUN chmod a+x /usr/bin/generateAssignment.sh

# add additional template for development
ADD eisvogel.latex /usr/local/share/pandoc/templates/eisvogel.latex

# add lua filter
ADD tof-box.lua /usr/local/share/pandoc/filters/

# automatically add revealjs-url as variable to pandoc
ENTRYPOINT ["/usr/local/bin/pandoc", "-V", "revealjs-url:/opt/reveal.js"]

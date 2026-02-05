## Pandoc Documentation Creator - Release ${CI_COMMIT_TAG}

### Docker Image

- **Documentation Creator:** `${CI_REGISTRY_IMAGE}:${CI_COMMIT_TAG}`
- **Documentation Creator (latest):** `${CI_REGISTRY_IMAGE}:latest`

### Usage

Pull and run the Documentation Creator image:

```bash
docker pull ${CI_REGISTRY_IMAGE}:${CI_COMMIT_TAG}

docker run --rm \
-v "${PROJECT_DIR}:/data" \
--entrypoint=/bin/sh \
"${IMAGE_NAME}" \
-c "pandoc --defaults=/usr/local/share/pandoc/defaults.yaml --metadata-file=/data/metadata.yaml /data/chapters/*.md --to=latex --output /data/out/build/documentation.tex --standalone --verbose --biblatex --top-level-division=chapter > /data/out/build/pandoc.log 2>&1 && cd /data/out/build && pdflatex -halt-on-error documentation.tex && bibtex documentation && pdflatex -halt-on-error documentation.tex && pdflatex -halt-on-error documentation.tex && mv -f /data/out/build/documentation.pdf /data/out/documentation.pdf"

```

### Test Artifacts

See the attached PDF files generated during CI testing.

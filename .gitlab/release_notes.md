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
-c "pandoc --defaults=/usr/local/share/pandoc/defaults.yaml --metadata-file=/data/metadata.yaml /data/chapters/*.md -o /data/output/documentation.pdf"

```

### Test Artifacts

See the attached PDF files generated during CI testing.

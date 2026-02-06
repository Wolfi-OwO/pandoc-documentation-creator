## Pandoc Documentation Creator - Release ${CI_COMMIT_TAG#v}

### Docker Image

- **Documentation Creator:** `${CI_REGISTRY_IMAGE}:${CI_COMMIT_TAG#v}`
- **Documentation Creator (latest):** `${CI_REGISTRY_IMAGE}:latest`

### Usage

Pull and run the Documentation Creator image:

```bash
docker pull ${CI_REGISTRY_IMAGE}:${CI_COMMIT_TAG#v}

docker run --rm \
-v "${PROJECT_DIR}:/data" \
--entrypoint=/bin/sh \
"${CI_REGISTRY_IMAGE}:${CI_COMMIT_TAG#v}" \
-c "/data/buildPDF"

```

### Test Artifacts

See the attached PDF files generated during CI testing.

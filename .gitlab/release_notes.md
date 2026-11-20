## Pandoc Documentation Creator - Release ${TAG_NO_V}

### Docker Image

- **Documentation Creator:** `${CI_REGISTRY_IMAGE}:${TAG_NO_V}`
- **Documentation Creator (latest):** `${CI_REGISTRY_IMAGE}:latest`

### Setup Project

Pull and run the Documentation Creator image:

```bash
wget https://gitlab.com/WoofiOwO/pandoc-documentation-creator/-/raw/v${TAG_NO_V}/init.sh

chmod +x init.sh

./init.sh build
```

### Usage

Pull and run the Documentation Creator image:

```bash
docker pull ${CI_REGISTRY_IMAGE}:${TAG_NO_V}

docker run --rm \
-v "${PROJECT_DIR}:/data" \
--entrypoint=/bin/sh \
"${CI_REGISTRY_IMAGE}:${TAG_NO_V}" \
-c "/data/buildPDF"

```

### Test Artifacts

See the attached PDF files generated during CI testing.

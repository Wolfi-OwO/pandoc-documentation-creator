#!/bin/sh
# Wrapper for mmdc to add puppeteer config with no-sandbox flag
# Suppress verbose output that breaks JSON parsing
exec /usr/local/bin/mmdc-original "$@" -p /root/.puppeteer.json -q 2>&1 | grep -v "Generating" | grep -v "Done" || true

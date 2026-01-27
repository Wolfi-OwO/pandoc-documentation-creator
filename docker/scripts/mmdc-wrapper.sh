#!/bin/sh
# Wrapper for mmdc to add puppeteer config with timeout and no-sandbox flag
# Increase timeout for slower systems, especially on first run
timeout 60 /usr/local/bin/mmdc-original "$@" -p /root/.puppeteer.json -q 2>&1 | grep -v "Generating" | grep -v "Done" | grep -v "^$" || true

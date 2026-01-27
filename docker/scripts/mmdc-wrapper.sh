#!/bin/sh
# Wrapper for mmdc to add puppeteer config and suppress non-JSON output
/usr/local/bin/mmdc-original "$@" -p /root/.puppeteer.json 2>&1 | grep -v "Generating" | grep -v "Done" || true

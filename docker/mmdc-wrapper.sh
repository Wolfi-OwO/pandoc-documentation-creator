#!/bin/sh
# Wrapper for mmdc to suppress non-JSON output
/usr/local/bin/mmdc "$@" -p /root/.puppeteer.json -q 2>&1 | grep -v "Generating" | grep -v "Done" || true
exit ${PIPESTATUS[0]}

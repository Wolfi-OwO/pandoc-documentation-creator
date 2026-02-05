#!/usr/bin/env python3

import hashlib
import json
import sys
from pathlib import Path


SEVERITY_MAP = {
    "error": "critical",
    "warning": "major",
    "info": "minor",
    "style": "info",
}


def _fingerprint(text: str) -> str:
    return hashlib.md5(text.encode("utf-8"), usedforsecurity=False).hexdigest()


def _load_comments(payload):
    if isinstance(payload, dict) and "comments" in payload:
        return payload["comments"]
    if isinstance(payload, list):
        return payload
    return []


def convert(shellcheck_json):
    issues = []
    for comment in _load_comments(shellcheck_json):
        path = comment.get("file")
        if not path:
            continue

        line = int(comment.get("line") or 1)
        end_line = int(comment.get("endLine") or line)
        code = comment.get("code")
        level = (comment.get("level") or "warning").lower()
        message = comment.get("message") or "ShellCheck issue"

        severity = SEVERITY_MAP.get(level, "minor")
        category = "Style" if level == "style" else "Bug Risk"

        fingerprint_source = f"{path}:{line}:{end_line}:{code}:{message}"

        issues.append(
            {
                "type": "issue",
                "check_name": f"ShellCheck {code}" if code else "ShellCheck",
                "description": message,
                "categories": [category],
                "location": {
                    "path": path,
                    "lines": {"begin": line, "end": end_line},
                },
                "severity": severity,
                "fingerprint": _fingerprint(fingerprint_source),
            }
        )

    return issues


def main():
    if len(sys.argv) != 3:
        print("Usage: shellcheck-to-codeclimate.py <input.json> <output.json>")
        return 2

    input_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])

    with input_path.open("r", encoding="utf-8") as handle:
        payload = json.load(handle)

    issues = convert(payload)

    with output_path.open("w", encoding="utf-8") as handle:
        json.dump(issues, handle, ensure_ascii=False)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
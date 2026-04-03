#!/usr/bin/env bash

set -euo pipefail

DOC_PATH="examples/advanced/documentation.md"
LUA_PATH="pandoc/filters/code-caption.lua"
TEX_PATH="pandoc/templates/listings-languages.tex"

for required in "$DOC_PATH" "$LUA_PATH" "$TEX_PATH"; do
    if [ ! -f "$required" ]; then
        echo "Missing required file: $required"
        exit 1
    fi
done

mapfile -t table_ids < <(
    awk '
        /^# Tables/ {in_table=1; next}
        in_table && /^#/ {exit}
        in_table && /`code-[^`]+`/ {
            line=$0
            while (match(line, /`code-[^`]+`/)) {
                id=substr(line, RSTART+1, RLENGTH-2)
                print id
                line=substr(line, RSTART+RLENGTH)
            }
        }
    ' "$DOC_PATH" | sort -u
)

if [ ${#table_ids[@]} -eq 0 ]; then
    echo "No code example IDs found in the tables section."
    exit 1
fi

declare -A code_lang
while IFS=$'\t' read -r id lang; do
    if [ -n "$id" ]; then
        code_lang["$id"]="$lang"
    fi
done < <(
    awk '
        /{#code-/ {
            id=""
            lang=""
            if (match($0, /\{#(code-[^ \t}]+)[^}]*\}/, m)) { id=m[1] }
            if (match($0, /^```([A-Za-z0-9_+-]+)/, m2)) { lang=tolower(m2[1]) }
            if (lang == "") {
                if (match($0, /\.[A-Za-z0-9_+-]+/, m3)) { lang=tolower(substr(m3[0], 2)) }
            }
            if (id != "") print id "\t" lang
        }
    ' "$DOC_PATH"
)

declare -A style_map
while IFS=$'\t' read -r lang style; do
    if [ -n "$lang" ]; then
        style_map["$lang"]="$style"
    fi
done < <(
    awk '
        /local language_definitions = \{/ {in_map=1; next}
        in_map && /^[[:space:]]*}/ {in_map=0}
        in_map {
            if (match($0, /([A-Za-z0-9_]+)[[:space:]]*=[[:space:]]*\{[^}]*style[[:space:]]*=[[:space:]]*"([^"]+)"/, m)) {
                print tolower(m[1]) "\t" m[2]
            }
        }
    ' "$LUA_PATH"
)

declare -A alias_map
while IFS=$'\t' read -r alias target; do
    if [ -n "$alias" ]; then
        alias_map["$alias"]="$target"
    fi
done < <(
    awk '
        /local alias_map = \{/ {in_alias=1; next}
        in_alias && /^[[:space:]]*}/ {in_alias=0}
        in_alias {
            if (match($0, /\["([^"]+)"\][[:space:]]*=[[:space:]]*"([^"]+)"/, m)) {
                print tolower(m[1]) "\t" tolower(m[2])
            } else if (match($0, /([A-Za-z0-9_]+)[[:space:]]*=[[:space:]]*"([^"]+)"/, m2)) {
                print tolower(m2[1]) "\t" tolower(m2[2])
            }
        }
    ' "$LUA_PATH"
)

declare -A styles
while IFS= read -r style; do
    if [ -n "$style" ]; then
        styles["$style"]=1
    fi
done < <(
    awk '
        /\\lstdefinestyle\{/ {
            if (match($0, /\\lstdefinestyle\{([^}]+)\}/, m)) {
                print m[1]
            }
        }
    ' "$TEX_PATH"
)

fail=0
for id in "${table_ids[@]}"; do
    lang="${code_lang[$id]-}"
    if [ -z "$lang" ]; then
        echo "Missing code block for table id: $id"
        fail=1
        continue
    fi

    if [ -n "${alias_map[$lang]-}" ]; then
        lang="${alias_map[$lang]}"
    fi

    style="${style_map[$lang]-}"
    if [ -z "$style" ]; then
        echo "No style map entry for language '$lang' (id $id)"
        fail=1
        continue
    fi

    if [ -z "${styles[$style]-}" ]; then
        echo "Style '$style' missing in listings-languages.tex (language '$lang', id $id)"
        fail=1
    fi
done

if [ $fail -ne 0 ]; then
    exit 1
fi

echo "Language mappings verified for ${#table_ids[@]} table entries."

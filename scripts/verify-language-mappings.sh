#!/bin/sh

set -eu

DOC_PATH="examples/advanced/documentation.md"
LUA_PATH="pandoc/filters/code-caption.lua"
TEX_PATH="pandoc/templates/listings-languages.tex"

for required in "$DOC_PATH" "$LUA_PATH" "$TEX_PATH"; do
    if [ ! -f "$required" ]; then
        echo "Missing required file: $required"
        exit 1
    fi
done

TMP_DIR="$(mktemp -d)"
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

TABLE_IDS="${TMP_DIR}/table_ids.txt"
CODE_LANGS="${TMP_DIR}/code_langs.tsv"
STYLE_MAP="${TMP_DIR}/style_map.tsv"
ALIAS_MAP="${TMP_DIR}/alias_map.tsv"
STYLES="${TMP_DIR}/styles.txt"

awk '
    /^# Tables/ {in_table=1; next}
    in_table && /^#/ {exit}
    in_table && /`code-[^`][^`]*`/ {
        line=$0
        while (match(line, /`code-[^`][^`]*`/)) {
            id=substr(line, RSTART+1, RLENGTH-2)
            print id
            line=substr(line, RSTART+RLENGTH)
        }
    }
' "$DOC_PATH" | sort -u > "$TABLE_IDS"

if [ ! -s "$TABLE_IDS" ]; then
    echo "No code example IDs found in the tables section."
    exit 1
fi

awk '
    /^[[:space:]]*```/ {
        line=$0
        sub(/^[[:space:]]*/, "", line)
        if (line !~ /#code-/) {
            next
        }
        id=line
        sub(/.*#code-/, "code-", id)
        sub(/[^A-Za-z0-9_-].*$/, "", id)

        lang=line
        sub(/^```/, "", lang)
        sub(/[[:space:]{].*$/, "", lang)
        if (lang == "") {
            if (match(line, /\.[A-Za-z0-9_-][A-Za-z0-9_-]*/)) {
                lang=substr(line, RSTART+1, RLENGTH-1)
            }
        }

        if (id != "") print id "\t" tolower(lang)
    }
' "$DOC_PATH" > "$CODE_LANGS"

awk '
    /local language_definitions = \{/ {in_map=1; next}
    in_map && /^[[:space:]]*}/ {in_map=0}
    in_map {
        line=$0
        if (line ~ /style[[:space:]]*=[[:space:]]*"/) {
            key=line
            sub(/=.*/, "", key)
            gsub(/[[:space:]]*/, "", key)

            style=line
            sub(/.*style[[:space:]]*=[[:space:]]*"/, "", style)
            sub(/".*/, "", style)

            if (key != "" && style != "") {
                print tolower(key) "\t" style
            }
        }
    }
' "$LUA_PATH" > "$STYLE_MAP"

awk '
    /local alias_map = \{/ {in_alias=1; next}
    in_alias && /^[[:space:]]*}/ {in_alias=0}
    in_alias {
        line=$0
        if (line ~ /\["[^"]+"\][[:space:]]*=[[:space:]]*"/) {
            alias=line
            sub(/.*\["/, "", alias)
            sub(/"\].*/, "", alias)

            target=line
            sub(/.*=[[:space:]]*"/, "", target)
            sub(/".*/, "", target)

            if (alias != "" && target != "") {
                print tolower(alias) "\t" tolower(target)
            }
        } else if (line ~ /[A-Za-z0-9_][A-Za-z0-9_]*[[:space:]]*=[[:space:]]*"/) {
            alias=line
            sub(/=.*/, "", alias)
            gsub(/[[:space:]]*/, "", alias)

            target=line
            sub(/.*=[[:space:]]*"/, "", target)
            sub(/".*/, "", target)

            if (alias != "" && target != "") {
                print tolower(alias) "\t" tolower(target)
            }
        }
    }
' "$LUA_PATH" > "$ALIAS_MAP"

awk '
    {
        needle="\\lstdefinestyle{"
        pos=index($0, needle)
        if (pos > 0) {
            line=substr($0, pos + length(needle))
            end=index(line, "}")
            if (end > 1) {
                print substr(line, 1, end - 1)
            }
        }
    }
' "$TEX_PATH" > "$STYLES"

missing=0
while IFS= read -r id; do
    lang="$(awk -F '\t' -v key="$id" '$1==key {print $2; exit}' "$CODE_LANGS")"
    if [ -z "$lang" ]; then
        echo "Missing code block for table id: $id"
        missing=1
        continue
    fi

    alias="$(awk -F '\t' -v key="$lang" '$1==key {print $2; exit}' "$ALIAS_MAP")"
    if [ -n "$alias" ]; then
        lang="$alias"
    fi

    style="$(awk -F '\t' -v key="$lang" '$1==key {print $2; exit}' "$STYLE_MAP")"
    if [ -z "$style" ]; then
        echo "No style map entry for language '$lang' (id $id)"
        missing=1
        continue
    fi

    if ! grep -qx "$style" "$STYLES"; then
        echo "Style '$style' missing in listings-languages.tex (language '$lang', id $id)"
        missing=1
    fi
done < "$TABLE_IDS"

if [ "$missing" -ne 0 ]; then
    exit 1
fi

COUNT="$(wc -l < "$TABLE_IDS" | tr -d ' ')"
echo "Language mappings verified for ${COUNT} table entries."

#!/bin/sh

TYPE=$1

# options to override and their defaults
GA_TEMPLATE=${GA_TEMPLATE:-"eisvogel.tex"}
GA_LISTINGS_NO_PAGE_BREAK=${GA_LISTINGS_NO_PAGE_BREAK:-"true"}
GA_LISTINGS_DISABLE_LINE_NUMBERS=${GA_LISTINGS_DISABLE_LINE_NUMBERS:-"true"}
GA_LISTINGS_DEFAULT_LANGUAGE=${GA_LISTINGS_DEFAULT_LANGUAGE:-"java"}
GA_LANG=${GA_LANG:-"de-DE"}
GA_OUTPUT_DIR=${GA_OUTPUT_DIR:-"_pdfs"}
GA_DEPARTMENT=${GA_DEPARTMENT:-"HTL Villach - Abteilung Informatik"}

if [ "$TYPE" == "Blatt" ]; then
  shift
  BLATT=$1
  TITLE="Blatt $BLATT"
  FILENAME=${PREFIX}blatt$(printf "%02d" $BLATT)
else
  TITLE="$TYPE"
  shift
  FILENAME=${PREFIX}$1
fi

shift

SEARCHPATH="."
for EXAMPLE in "$@"; do
  if [ -d "$EXAMPLE" ]; then
    MARKDOWNS="$MARKDOWNS $EXAMPLE/README.md"
    SEARCHPATH="$SEARCHPATH:$EXAMPLE"    
  elif [ -f "$EXAMPLE" ]; then
    MARKDOWNS="$MARKDOWNS $EXAMPLE"
    SEARCHPATH="$SEARCHPATH:$(dirname $EXAMPLE)"
  else
    echo "$EXAMPLE neither file nor folder"
    exit 1;
  fi
done

if [ "$#" -ne 1 ]; then
  NUMBERING_ARGS="-N --number-offset=2"
fi
pandoc --variable header-center="$TITLE" \
       --variable footer-left="$YEAR" \
       --variable header-left="$GA_DEPARTMENT" \
       --variable header-right="$SUBJECT" \
       --variable listings-no-page-break="$GA_LISTINGS_NO_PAGE_BREAK" \
       --variable listings-disable-line-numbers="$GA_LISTINGS_DISABLE_LINE_NUMBERS" \
       --variable listings-default-language="$GA_LISTINGS_DEFAULT_LANGUAGE" \
       --variable colorlinks="true" \
       --variable lang="$GA_LANG" \
       --filter pandoc-plantuml \
       --lua-filter tof-box.lua \
       --template="$GA_TEMPLATE" $NUMBERING_ARGS \
       --listings \
       --resource-path=$SEARCHPATH \
       $MARKDOWNS \
       -o "$GA_OUTPUT_DIR/$FILENAME.pdf"

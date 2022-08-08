#!/bin/bash
set -e

if [[ $# -lt 2 ]]; then
    echo "Missing arguments"
    exit -1
fi

RELEASE_DIR="$(realpath "$1")"
shift
mkdir -p "$RELEASE_DIR"

while [[ $# -gt 0 ]]; do
    INPUT="$1"
    shift

    (
        set -e

        if [[ $INPUT == *.zip ]]; then
            INAME=$(basename -s .zip -- "$INPUT")
        elif [[ $INPUT == *.tar.xz ]]; then
            INAME=$(basename -s .tar.xz -- "$INPUT")
        else
            echo "Unknown input file type: $INPUT"
            exit 1
        fi

        TAGNAME="$(cut -d- -f2 <<<"$INAME")"

        if [[ $TAGNAME == N ]]; then
            TAGNAME="master"
        elif [[ $TAGNAME == n* ]]; then
            TAGNAME="$(sed -re 's/([0-9]+\.[0-9]+).*/\1/' <<<"$TAGNAME")"
        fi

        if [[ "$INAME" =~ -[0-9]+-g ]]; then
            ONAME="ffmpeg-$TAGNAME-latest-$(cut -d- -f5- <<<"$INAME")"
        else
            ONAME="ffmpeg-$TAGNAME-latest-$(cut -d- -f3- <<<"$INAME")"
        fi

        if [[ $INPUT == *.zip ]]; then
            cp $INPUT "$RELEASE_DIR/$ONAME.zip"
        elif [[ $INPUT == *.tar.xz ]]; then
            cp $INPUT "$RELEASE_DIR/$ONAME.tar.xz"
        fi
    ) &

    while [[ $(jobs | wc -l) -gt 3 ]]; do
        wait %1
    done
done

while [[ $(jobs | wc -l) -gt 0 ]]; do
    wait %1
done


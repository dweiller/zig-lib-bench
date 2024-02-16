#!/bin/sh

if [ $# -lt 4 ]; then
    echo "usage: memcpy-dist PRELOAD_LIB GNUPLOT_SCRIPT OUTPUT args..."
    exit 1
fi

PRELOAD_LIB="$1"
shift

GNUPLOT_SCRIPT="$1"
shift

OUTPUT="$1"
shift

LD_PRELOAD="$PRELOAD_LIB" "$@"

if [ $? -ne 0 ]; then
    echo "error running \"LD_PRELOAD=$PRELOAD_LIB $@\""
    exit 1
fi

gnuplot "$GNUPLOT_SCRIPT" > "${OUTPUT}.svg"

mv memcpy-hist.tsv "${OUTPUT}.tsv"

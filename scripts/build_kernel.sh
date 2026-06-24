#!/usr/bin/env bash

set -euo pipefail

ARCHITECTURE="x86_64"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --architecture|-a)
            # if [[ -z "${2:-}" ]]; then
            #    echo "Expected to get a value for $1 got nothing"
            #    exit 1
            # fi
            # ARCHITECTURE="$2"
            # echo "DEBUG: Set ARCHITECTURE to $ARCHITECTURE"
            # shift 2
            shift 2
            ;;
        *)
            echo "ERROR: Unknown argument: $1"
            exit 1
            ;;
    esac
done


if [[ "$ARCHITECTURE" != "x86_64" && "$ARCHITECTURE" != "aarch64" ]]; then
	echo "ERROR: Invalid ARCHITECTURE, only available options are 'x86_64' and 'aarch64'."
	exit 1
fi

zig build -Darchitecture=$ARCHITECTURE

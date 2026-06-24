#!/usr/bin/env bash

set -euo pipefail

ARCHITECTURE="x86_64"
MEMORY="1024"

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
            ;;
        --memory|-m)
            if [[ -z "${2:-}" ]]; then
                echo "Expected to get a value for $1 got nothing"
                exit 1
            fi
            MEMORY="$2"
            echo "DEBUG: Set MEMORY to $MEMORY"
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

if [[ ! -f "octos-$ARCHITECTURE.iso" ]]; then
    echo "ERROR: The ISO does not exist. Have you built it?"
    exit 1
fi

if [[ "$ARCHITECTURE" == "x86_64" ]]; then
	qemu-system-$ARCHITECTURE \
        -M q35 \
        -drive if=pflash,unit=0,format=raw,file=edk2-ovmf-bins/ovmf-code-x86_64.fd,readonly=on \
        -serial stdio \
	    -cdrom octos-$ARCHITECTURE.iso
elif [[ "$ARCHITECTURE" == "aarch64" ]]; then
    :
fi

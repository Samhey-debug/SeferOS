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

mkdir -p iso/boot/limine/
mkdir -p iso/EFI/BOOT/
cp -v zig-out/bin-$ARCHITECTURE/kernel iso/boot/
cp -v limine.conf iso/boot/limine/
cp -v limine-binary/limine-uefi-cd.bin iso/boot/limine/
cp -v limine-binary/BOOTX64.EFI iso/EFI/BOOT

xorriso \
    -as mkisofs \
    -R \
    -r \
    -J \
    -hfsplus \
    -apm-block-size 2048 \
    --efi-boot boot/limine/limine-uefi-cd.bin \
    -efi-boot-part \
    --efi-boot-image \
    --protective-msdos-label iso \
    -o octos-$ARCHITECTURE.iso
./limine bios-install octos-$ARCHITECTURE.iso

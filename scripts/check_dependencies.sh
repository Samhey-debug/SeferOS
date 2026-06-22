#!/usr/bin/env bash

set -euo pipefail

if [[ ! -d "edk2-ovmf-bins" && ! -d "limine-binary" ]]; then
	exit 1
fi

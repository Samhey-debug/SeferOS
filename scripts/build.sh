#!/usr/bin/env bash

set -euo pipefail
trap 'echo "ERROR: Build failed at line $LINENO"' ERR

ARCHITECTURE="x86_64"
CLEAN=0
REINSTALL=0
SKIP_ISO=0
SKIP_DEPENDENCY_CHECK=0

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
        --clean|-c)
            CLEAN=1
            echo "DEBUG: Set CLEAN to $CLEAN"
            shift
            ;;
        --reinstall|-r)
            REINSTALL=1
            echo "DEBUG: Set REINSTALL to $REINSTALL"
            shift
            ;;
        --skip-iso|-si)
            SKIP_ISO=1
            echo "DEBUG: Set SKIP_ISO to $SKIP_ISO"
            shift
            ;;
        --skip-dependency-check|-sdp)
            SKIP_DEPENDENCY_CHECK=1
            echo "DEBUG: Set SKIP_DEPENDENCY_CHECK to $SKIP_DEPENDENCY_CHECK"
            shift
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

if [[ "$CLEAN" == "1" ]]; then
    echo "[1/5] Cleaning..."
    ./scripts/clean.sh &> /dev/null
    REINSTALL=1
    echo "DEBUG: Set REINSTALL to $REINSTALL"
else
	echo "[1/5] Step 1 (cleaning) skipped"
fi

if [[ $REINSTALL -eq 0 && $SKIP_DEPENDENCY_CHECK -ne 1 ]]; then
	echo "[2/5] Checking dependencies..."
	if ! ./scripts/check_dependencies.sh; then
	    REINSTALL=1
	    echo "DEBUG: Set REINSTALL to $REINSTALL"
	fi
else
	echo "[2/5] Step 2 (checking dependencies) skipped"
fi

if [[ "$REINSTALL" == "1" ]]; then
	echo "[3/5] Installing..."
	./scripts/install.sh &> /dev/null
else
	echo "[3/5] Step 3 (installation) skipped"
fi

echo "[4/5] Building the kernel..."
./scripts/build_kernel.sh -a "$ARCHITECTURE"

if [[ "$SKIP_ISO" != "1" ]]; then
    echo "[5/5] Building the ISO..."
    ./scripts/build_iso.sh -a "$ARCHITECTURE" &> /dev/null
else
	echo "[5/5] Step 5 (building the ISO) skipped"
fi

echo "Done!"

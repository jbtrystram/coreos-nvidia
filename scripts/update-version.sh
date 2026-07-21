#!/bin/bash
set -euo pipefail

# Usage: scripts/update-version.sh --stream <version> --driver <version>
# Updates Fedora stream and NVIDIA driver version across all config files.

STREAM=""
DRIVER=""

usage() {
    echo "Usage: $0 --stream <version> --driver <version>"
    echo "  --stream  Fedora stream version (e.g. 44)"
    echo "  --driver  NVIDIA driver version (e.g. 595.71.05)"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --stream) STREAM="$2"; shift 2 ;;
        --driver) DRIVER="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

# Validate arguments
if [[ -z "$STREAM" || -z "$DRIVER" ]]; then
    echo "Error: Both --stream and --driver are required"
    usage
fi

# Resolve script location so the script can be run from any directory
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BUILD_ARGS_CONF="$REPO_ROOT/build-args.conf"
README="$REPO_ROOT/README.md"

# Read current values for summary
CURRENT_STREAM=$(grep "^STREAM=" "$BUILD_ARGS_CONF" | cut -d= -f2)
CURRENT_DRIVER=$(grep "^DRIVER_VERSION=" "$BUILD_ARGS_CONF" | cut -d= -f2)

echo "Updating versions:"
echo "  Fedora stream: ${CURRENT_STREAM} -> ${STREAM}"
echo "  NVIDIA driver: ${CURRENT_DRIVER} -> ${DRIVER}"
echo ""

# Update build-args.conf
sed -i "s/^STREAM=.*/STREAM=${STREAM}/" "$BUILD_ARGS_CONF"
sed -i "s/^DRIVER_VERSION=.*/DRIVER_VERSION=${DRIVER}/" "$BUILD_ARGS_CONF"
echo "Updated $BUILD_ARGS_CONF"


# Update README.md
sed -i "s/^ARG STREAM=.*/ARG STREAM=${STREAM}/" "$README"
sed -i "s/^ARG VERSION=.*/ARG VERSION=${DRIVER}/" "$README"
echo "Updated $README"

echo ""
echo "Done. Fedora ${STREAM} with NVIDIA driver ${DRIVER}."

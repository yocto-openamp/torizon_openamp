#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_DIR="$ROOT_DIR/sources"
DOWNLOADS_DIR="$ROOT_DIR/downloads"
BUILD_DIR="$ROOT_DIR/build"

mkdir -p "$SOURCES_DIR" "$DOWNLOADS_DIR" "$BUILD_DIR"

cd "$SOURCES_DIR"

if [ ! -d rpmsg-lite ]; then
  echo "Cloning RPMsg-Lite into $SOURCES_DIR/rpmsg-lite"
  git clone --depth 1 https://github.com/NXPmicro/rpmsg-lite.git
fi

if [ ! -d mcux-sdk ]; then
  echo "Cloning MCUX SDK into $SOURCES_DIR/mcux-sdk"
  git clone --depth 1 https://github.com/nxp-mcuxpresso/mcux-sdk.git
fi

cat > "$ROOT_DIR/docs/README_build_notes.md" <<'EOF'
# Build notes

Suggested layout:
- sources/rpmsg-lite : RPMsg-Lite middleware source
- sources/mcux-sdk : MCUXpresso SDK source
- build : build output directory
- downloads : archive/download staging area

Typical bootstrap:
./run_0_bootstrap.sh
EOF

echo "Bootstrap complete."
echo "Sources available at:"
echo "  $SOURCES_DIR/rpmsg-lite"
echo "  $SOURCES_DIR/mcux-sdk"

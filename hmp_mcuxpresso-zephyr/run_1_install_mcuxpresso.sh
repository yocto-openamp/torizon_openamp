#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_DIR="$ROOT_DIR/sources"
DOWNLOADS_DIR="$ROOT_DIR/downloads"
BUILD_DIR="$ROOT_DIR/build"
MCUX_SDK_DIR="$SOURCES_DIR/mcux-sdk"
CMSIS_CORE_DIR="$MCUX_SDK_DIR/core/CMSIS/Core/Include"

mkdir -p "$SOURCES_DIR" "$DOWNLOADS_DIR" "$BUILD_DIR"
mkdir -p "$ROOT_DIR/docs"

cd "$SOURCES_DIR"

if [ ! -d rpmsg-lite ]; then
  echo "Cloning RPMsg-Lite into $SOURCES_DIR/rpmsg-lite"
  git clone --depth 1 https://github.com/NXPmicro/rpmsg-lite.git
fi

if [ ! -d mcux-sdk ]; then
  echo "Cloning MCUX SDK into $SOURCES_DIR/mcux-sdk"
  git clone --depth 1 https://github.com/nxp-mcuxpresso/mcux-sdk.git
fi

if [ ! -d "$CMSIS_CORE_DIR" ]; then
  echo "CMSIS Core headers not found at $CMSIS_CORE_DIR"
  echo "Cloning CMSIS_5 (MCUX_2.16.000) into sources/mcux-sdk/core/CMSIS"
  mkdir -p "$MCUX_SDK_DIR/core"
  if [ -d "$MCUX_SDK_DIR/core/CMSIS/.git" ]; then
    echo "Existing CMSIS git directory found but expected Core/Include is missing."
    echo "Please verify checkout at $MCUX_SDK_DIR/core/CMSIS"
    exit 1
  fi
  git clone --depth 1 --branch MCUX_2.16.000 \
    https://github.com/nxp-mcuxpresso/CMSIS_5.git \
    "$MCUX_SDK_DIR/core/CMSIS"
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
echo "  $MCUX_SDK_DIR/core/CMSIS"

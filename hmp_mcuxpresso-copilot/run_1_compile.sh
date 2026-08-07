#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_DIR="$ROOT_DIR/sources"
BUILD_DIR="$ROOT_DIR/build"
RPMSGLITE_SRC="$SOURCES_DIR/rpmsg-lite"
RPMSGLITE_BUILD_DIR="$BUILD_DIR/rpmsg-lite"

mkdir -p "$BUILD_DIR"

if [ ! -d "$RPMSGLITE_SRC" ]; then
  echo "RPMsg-Lite source not found at $RPMSGLITE_SRC"
  echo "Run bootstrap first: bash scripts/bootstrap_rpmsg_lite.sh"
  exit 1
fi

if ! command -v cmake >/dev/null 2>&1; then
  echo "cmake not found in PATH"
  exit 1
fi

if command -v ninja >/dev/null 2>&1; then
  GENERATOR="-G Ninja"
else
  GENERATOR=""
fi

echo "Configuring RPMsg-Lite build in $RPMSGLITE_BUILD_DIR"
cmake -S "$RPMSGLITE_SRC" -B "$RPMSGLITE_BUILD_DIR" -DCMAKE_BUILD_TYPE=Release $GENERATOR

echo "Building RPMsg-Lite"
cmake --build "$RPMSGLITE_BUILD_DIR" --parallel

echo "Build finished. Artifacts are in $RPMSGLITE_BUILD_DIR"

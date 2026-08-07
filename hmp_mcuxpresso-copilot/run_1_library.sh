#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_DIR="$ROOT_DIR/sources"
BUILD_DIR="$ROOT_DIR/build"
RPMSGLITE_SRC="$SOURCES_DIR/rpmsg-lite"
RPMSGLITE_BUILD_DIR="$BUILD_DIR/rpmsg-lite"
ZEPHYR_SDK_DIR="${ZEPHYR_SDK_DIR:-$HOME/zephyr-sdk-1.0.1}"
RPMSGLITE_ENV="${RPMSGLITE_ENV:-bm}"
RPMSGLITE_PLATFORM="${RPMSGLITE_PLATFORM:-imx8mp_m7}"
RPMSGLITE_CONFIG_DIR="${RPMSGLITE_CONFIG_DIR:-$RPMSGLITE_SRC/template_application}"

mkdir -p "$BUILD_DIR"

if [ ! -d "$RPMSGLITE_SRC" ]; then
  echo "RPMsg-Lite source not found at $RPMSGLITE_SRC"
  echo "Run bootstrap first: bash scripts/bootstrap_rpmsg_lite.sh"
  exit 1
fi

if [ ! -d "$ZEPHYR_SDK_DIR" ]; then
  echo "Zephyr SDK not found at $ZEPHYR_SDK_DIR"
  echo "Set ZEPHYR_SDK_DIR if your SDK is installed elsewhere."
  exit 1
fi

TOOLCHAIN_BIN_DIR="$ZEPHYR_SDK_DIR/gnu/arm-zephyr-eabi/bin"
CC="$TOOLCHAIN_BIN_DIR/arm-zephyr-eabi-gcc"
AR="$TOOLCHAIN_BIN_DIR/arm-zephyr-eabi-ar"

if [ ! -x "$CC" ]; then
  echo "Cross compiler not found: $CC"
  exit 1
fi

if [ ! -x "$AR" ]; then
  echo "Archiver not found: $AR"
  exit 1
fi

PLATFORM_INCLUDE_DIR="$RPMSGLITE_SRC/lib/include/platform/$RPMSGLITE_PLATFORM"
ENV_INCLUDE_DIR="$RPMSGLITE_SRC/lib/include/environment/$RPMSGLITE_ENV"
ENV_SOURCE_FILE="$RPMSGLITE_SRC/lib/rpmsg_lite/porting/environment/rpmsg_env_${RPMSGLITE_ENV}.c"

if [ ! -d "$PLATFORM_INCLUDE_DIR" ]; then
  echo "Platform include directory not found: $PLATFORM_INCLUDE_DIR"
  echo "Set RPMSGLITE_PLATFORM to a valid platform directory under lib/include/platform."
  exit 1
fi

if [ ! -d "$ENV_INCLUDE_DIR" ]; then
  echo "Environment include directory not found: $ENV_INCLUDE_DIR"
  echo "Set RPMSGLITE_ENV to a valid environment directory under lib/include/environment."
  exit 1
fi

if [ ! -f "$ENV_SOURCE_FILE" ]; then
  echo "Environment source file not found: $ENV_SOURCE_FILE"
  exit 1
fi

if [ ! -f "$RPMSGLITE_CONFIG_DIR/rpmsg_config.h" ]; then
  echo "rpmsg_config.h not found in $RPMSGLITE_CONFIG_DIR"
  echo "Set RPMSGLITE_CONFIG_DIR to a directory containing rpmsg_config.h."
  exit 1
fi

mkdir -p "$RPMSGLITE_BUILD_DIR"
rm -f "$RPMSGLITE_BUILD_DIR"/*.o "$RPMSGLITE_BUILD_DIR"/librpmsg-lite.a

COMMON_INCLUDES=(
  -I"$RPMSGLITE_SRC/lib/include"
  -I"$ENV_INCLUDE_DIR"
  -I"$PLATFORM_INCLUDE_DIR"
  -I"$RPMSGLITE_CONFIG_DIR"
)

CFLAGS=(
  -Os
  -ffunction-sections
  -fdata-sections
  -mcpu=cortex-m7
  -mthumb
)

SOURCES=(
  "$RPMSGLITE_SRC/lib/common/llist.c"
  "$RPMSGLITE_SRC/lib/virtio/virtqueue.c"
  "$RPMSGLITE_SRC/lib/rpmsg_lite/rpmsg_lite.c"
  "$RPMSGLITE_SRC/lib/rpmsg_lite/rpmsg_ns.c"
  "$RPMSGLITE_SRC/lib/rpmsg_lite/rpmsg_queue.c"
  "$ENV_SOURCE_FILE"
)

echo "Compiling RPMsg-Lite sources with $CC"
for src in "${SOURCES[@]}"; do
  obj="$RPMSGLITE_BUILD_DIR/$(basename "${src%.c}").o"
  "$CC" "${CFLAGS[@]}" "${COMMON_INCLUDES[@]}" -c "$src" -o "$obj"
done

echo "Creating static library"
"$AR" rcs "$RPMSGLITE_BUILD_DIR/librpmsg-lite.a" "$RPMSGLITE_BUILD_DIR"/*.o

echo "Build finished. Artifact: $RPMSGLITE_BUILD_DIR/librpmsg-lite.a"

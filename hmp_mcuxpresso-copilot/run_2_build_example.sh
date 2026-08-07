#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_DIR="$ROOT_DIR/sources"
MCUX_SDK_DIR="$SOURCES_DIR/mcux-sdk"
BUILD_DIR="$ROOT_DIR/build/mcux-example-minimal-cm7"

ZEPHYR_SDK_DIR="${ZEPHYR_SDK_DIR:-$HOME/zephyr-sdk-1.0.1}"
TOOLCHAIN_BIN_DIR="$ZEPHYR_SDK_DIR/gnu/arm-zephyr-eabi/bin"

CC="$TOOLCHAIN_BIN_DIR/arm-zephyr-eabi-gcc"
OBJCOPY="$TOOLCHAIN_BIN_DIR/arm-zephyr-eabi-objcopy"
SIZE="$TOOLCHAIN_BIN_DIR/arm-zephyr-eabi-size"

DEVICE="MIMX8ML8"
CPU_DEFINE="CPU_MIMX8ML8DVNLZ"

DEVICE_DIR="$MCUX_SDK_DIR/devices/$DEVICE"
CMSIS_CORE_DIR="$MCUX_SDK_DIR/core/CMSIS/Core/Include"

STARTUP_FILE="$DEVICE_DIR/gcc/startup_${DEVICE}_cm7.S"
SYSTEM_FILE="$DEVICE_DIR/system_${DEVICE}_cm7.c"
LINKER_SCRIPT="$DEVICE_DIR/gcc/${DEVICE}xxxxx_cm7_ram.ld"

MAIN_C="$BUILD_DIR/main.c"
OUT_ELF="$BUILD_DIR/minimal_${DEVICE}_cm7.elf"
OUT_BIN="$BUILD_DIR/minimal_${DEVICE}_cm7.bin"
OUT_MAP="$BUILD_DIR/minimal_${DEVICE}_cm7.map"

if [ ! -d "$MCUX_SDK_DIR" ]; then
  echo "MCUX SDK not found at $MCUX_SDK_DIR"
  exit 1
fi

if [ ! -d "$ZEPHYR_SDK_DIR" ]; then
  echo "Zephyr SDK not found at $ZEPHYR_SDK_DIR"
  echo "Set ZEPHYR_SDK_DIR if your SDK is installed elsewhere."
  exit 1
fi

if [ ! -x "$CC" ]; then
  echo "Cross compiler not found: $CC"
  exit 1
fi

if [ ! -x "$OBJCOPY" ]; then
  echo "objcopy not found: $OBJCOPY"
  exit 1
fi

if [ ! -x "$SIZE" ]; then
  echo "size tool not found: $SIZE"
  exit 1
fi

if [ ! -d "$CMSIS_CORE_DIR" ]; then
  echo "CMSIS Core headers not found at $CMSIS_CORE_DIR"
  echo "Run bootstrap first: ./run_0_bootstrap.sh"
  exit 1
fi

for f in "$STARTUP_FILE" "$SYSTEM_FILE" "$LINKER_SCRIPT" "$DEVICE_DIR/fsl_device_registers.h"; do
  if [ ! -f "$f" ]; then
    echo "Required file not found: $f"
    exit 1
  fi
done

mkdir -p "$BUILD_DIR"

cat > "$MAIN_C" <<'EOF'
#include "fsl_device_registers.h"

int main(void)
{
    SystemCoreClockUpdate();

    for (;;)
    {
        __asm volatile("nop");
    }
}
EOF

CFLAGS=(
  -mcpu=cortex-m7
  -mthumb
  -O2
  -ffunction-sections
  -fdata-sections
  -D"$CPU_DEFINE"
  -I"$DEVICE_DIR"
  -I"$CMSIS_CORE_DIR"
)

ASFLAGS=(
  "${CFLAGS[@]}"
  -D__START=main
)

echo "Compiling minimal CM7 example sources"
"$CC" "${CFLAGS[@]}" -c "$MAIN_C" -o "$BUILD_DIR/main.o"
"$CC" "${CFLAGS[@]}" -c "$SYSTEM_FILE" -o "$BUILD_DIR/system_${DEVICE}_cm7.o"
"$CC" "${ASFLAGS[@]}" -c "$STARTUP_FILE" -o "$BUILD_DIR/startup_${DEVICE}_cm7.o"

echo "Linking ELF"
"$CC" \
  "$BUILD_DIR/main.o" \
  "$BUILD_DIR/system_${DEVICE}_cm7.o" \
  "$BUILD_DIR/startup_${DEVICE}_cm7.o" \
  -T "$LINKER_SCRIPT" \
  -Wl,--gc-sections \
  -Wl,-Map="$OUT_MAP" \
  -nostartfiles \
  -o "$OUT_ELF"

echo "Generating BIN"
"$OBJCOPY" -O binary "$OUT_ELF" "$OUT_BIN"

echo "Size report"
"$SIZE" "$OUT_ELF"

echo "Build finished."
echo "  ELF: $OUT_ELF"
echo "  BIN: $OUT_BIN"
echo "  MAP: $OUT_MAP"
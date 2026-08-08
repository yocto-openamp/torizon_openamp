#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

. .venv/bin/activate

SDK_VERSION="$(<zephyr/SDK_VERSION)"
ZEPHYR_SDK_INSTALL_DIR="$HOME/zephyr-sdk-$SDK_VERSION"
export ZEPHYR_SDK_INSTALL_DIR

west build --pristine \
	--board imx8mp_evk/mimx8ml8/m7 \
	--build-dir build \
	zephyr/samples/subsys/ipc/openamp_rsc_table \
	-- \
	-DCONF_FILE="$PROJECT_DIR/prj_verdin_imx8mp.conf" \
	-DDTC_OVERLAY_FILE="$PROJECT_DIR/prj_verdin_imx8mp.overlay"

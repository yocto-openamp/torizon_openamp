#!/usr/bin/env bash
set -euo pipefail

. .venv/bin/activate

export ZEPHYR_SDK_INSTALL_DIR="${ZEPHYR_SDK_INSTALL_DIR:-$HOME/zephyr-sdk-1.0.1}"

west build --pristine \
	--board imx8mp_evk/mimx8ml8/m7 \
	--build-dir build \
	zephyr/samples/subsys/ipc/openamp_rsc_table \
	-- \
	-DCONF_FILE=prj_verdin_imx8mp.conf \
	-DDTC_OVERLAY_FILE=prj_verdin_imx8mp.overlay

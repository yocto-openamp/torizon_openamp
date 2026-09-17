# OpenAmp - Build zephyr application

## Zephyr workspace

Prepare the Zephyr workspace and SDK as described in [Yocto - Prepare build environment](README_yocto_20_prepare_build_environment.md). The firmware build must produce an ELF suitable for the i.MX8M Plus M7 remoteproc loader.

```bash
export ZEPHYR_TOP=$HOME
source "$ZEPHYR_TOP/zephyr/.venv/bin/activate"
cd "$ZEPHYR_TOP/zephyr/zephyrproject"
west update
west zephyr-export
```

## MCUXpresso OpenAMP examples

The NXP demo binaries are not built from a C source recipe in this repository. The matching source is in the [MCUXpresso SDK examples](https://github.com/nxp-mcuxpresso/mcuxsdk-examples):

```text
multicore_examples/rpmsg_lite_str_echo_rtos/remote
multicore_examples/rpmsg_lite_pingpong_rtos_linux/remote
_boards/evkmimx8mp/multicore_examples/
```

Build the matching `EVK-MIMX8MP` example using its board README, then copy the resulting ELF into `/lib/firmware` with the names used by the Torizon image. The prebuilt NXP bundle contains binaries plus license and metadata; it does not contain the full application source.

## Build a Zephyr application

For a Zephyr application, build from the application directory with the board and configuration selected by that application:

```bash
cd path/to/zephyr/application
west build -b verdin_imx8mp samples/basic/blinky
```

The resulting firmware is typically `build/zephyr/zephyr.elf`. Copy it to the target only after confirming that the target device tree exposes an M7 remoteproc instance and that the firmware's resource table and reserved-memory layout match the Linux configuration.

# Agent

## Hardware used

- [Toradex Verdin i.MX 8M Plus](https://www.toradex.com/de/computer-on-modules/verdin-arm-family/nxp-imx-8m-plus)
- [Toradex Mallow carrier board](https://www.toradex.com/products/carrier-board/mallow-carrier-board)
- [torizon/meta-toradex-torizon](https://github.com/torizon/meta-toradex-torizon)

## Goal

- The A53 cpu run yocto torizon (from this repo)

- The M7 cpu should run Zephyr.

The goal ist to find zephyr sources for the M7 and build them.

Examples to be compiled:

- https://docs.zephyrproject.org/latest/samples/subsys/ipc/rpmsg_service/README.html
- https://github.com/zephyrproject-rtos/zephyr/tree/main/samples/subsys/ipc/rpmsg_service

- https://docs.zephyrproject.org/latest/samples/subsys/ipc/openamp_rsc_table/README.html
- https://github.com/zephyrproject-rtos/zephyr/tree/main/samples/subsys/ipc/openamp_rsc_table

## Expected Artifacts

Please write these documents:

- README_0_environment_setup.md
- README_1_get_sources-and-build.md
- README_2_run_examples.md

The documents should be written for a developer who wants to build the binaries and run them on the Toradex Verdin i.MX 8M Plus.

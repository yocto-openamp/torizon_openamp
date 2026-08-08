# Agent.md

## Context

On linux, the kernel module is loaded: `modprobe rpmsg-client-sample`.
This is the source: hmp_mcuxpresso-zephyr/src/main.c / common.h.
The source was copied from https://github.com/torvalds/linux/blob/master/samples/rpmsg/rpmsg_client_sample.c / https://github.com/nxp-mcuxpresso/rpmsg-lite/blob/main/zephyr/samples/rpmsglite_pingpong/src/main.c
.

It is expected to get the output from hmp_mcuxpresso-zephyr/sources/rpmsg-lite/zephyr/samples/rpmsglite_pingpong/README.rst.

## Task

Build elf file for: hmp_mcuxpresso-zephyr/sources/rpmsg-lite/zephyr/samples/rpmsglite_pingpong/remote/src/main.c

Linux: Master (or Application)
M7: Remote

Linux: RPMsg driver/client
M7: RPMsg endpoint/service

M7 overlay template: hmp_mcuxpresso-zephyr/sources/rpmsg-lite/zephyr/samples/rpmsglite_pingpong/remote/boards

## Target

M7 core of the toradex Verdin iMX8M Plus

* See: hmp_mcuxpresso-zephyr/prj_verdin_imx8mp.conf

## Infrastructure

* Zephyr: hmp_mcuxpresso-zephyr/zephyr
* Zephyr SDK: ~/zephyr-sdk-1.0.1/
* Zephyr West: ~/torizon_openamp/hmp_mcuxpresso-zephyr/.venv/bin/west
* Python: ~/torizon_openamp/hmp_mcuxpresso-zephyr/.venv/bin/python

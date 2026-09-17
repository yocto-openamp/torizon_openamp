# OpenAmp - Design

## Architecture

OpenAMP on this platform connects Linux on the Cortex-A53 with firmware on the Cortex-M7 through the Linux `remoteproc` and RPMsg frameworks.

The Linux-side support comes from the Toradex NXP kernel and BSP metadata rather than a separate OpenAMP layer. The relevant kernel features are:

```text
CONFIG_REMOTEPROC
CONFIG_REMOTEPROC_CDEV
CONFIG_IMX_REMOTEPROC
CONFIG_RPMSG_VIRTIO
CONFIG_RPMSG_CHAR
CONFIG_RPMSG_CTRL
```

The implementation uses the i.MX remoteproc driver together with reserved memory, virtio vrings, a resource table, and the RPMsg transport. Linux can then load an M7 ELF from `/lib/firmware` and start it through `/sys/class/remoteproc/remoteproc0/`.

Relevant Linux components include:

```text
imx_rproc.c
imx_rpmsg.c
imx_rpmsg_tty.c
rpmsg_char.c
rpmsg_ctrl.c
```

The RPMsg examples use either the ping-pong channel or the virtual TTY channel. For background, see the [Linux remoteproc documentation](https://docs.kernel.org/staging/remoteproc.html) and [ST's Linux RPMsg overview](https://wiki.st.com/stm32mpu/wiki/Linux_RPMsg_framework_overview).

## Firmware choices

The Torizon image includes NXP demo firmware such as:

```text
/lib/firmware/imx8mp_m7_TCM_hello_world.elf
/lib/firmware/imx8mp_m7_TCM_low_power_wakeword.elf
/lib/firmware/imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf
/lib/firmware/imx8mp_m7_TCM_rpmsg_lite_str_echo_rtos.elf
/lib/firmware/imx8mp_m7_TCM_sai_low_power_audio.elf
```

The prebuilt demos originate from NXP's demo bundle. Rebuildable source is available in the [MCUXpresso SDK examples](https://github.com/nxp-mcuxpresso/mcuxsdk-examples), especially `rpmsg_lite_pingpong_rtos_linux` and `rpmsg_lite_str_echo_rtos`.

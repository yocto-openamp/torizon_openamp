

verdin-imx8mp_hmp_overlay.dtbo

yocto-workdir/build-torizon/tmp/work-shared/verdin-imx8mp/kernel-source/arch/arm64/boot/dts/freescale/imx8mp-evk-rpmsg.dts


```bash
reserved-memory {
    vdev0vring0: vdev0vring0@55000000 { ... };
    vdev0vring1: vdev0vring1@55008000 { ... };
    vdevbuffer: vdevbuffer@55400000 { ... };
    rsc_table: rsc-table@550ff000 { ... };
};

imx8mp-cm7 {
    compatible = "fsl,imx8mn-cm7";
    rsc-da = <0x55000000>;
    mbox-names = "tx", "rx", "rxdb";
    mboxes = <&mu 0 1
              &mu 1 1
              &mu 3 1>;
    memory-region = <&vdevbuffer>, <&vdev0vring0>, <&vdev0vring1>, <&rsc_table>;
    status = "okay";
};
```


## Sample application

`/dev/rpmsg*`

### M7

https://github.com/zephyrproject-rtos/zephyr/blob/main/samples/subsys/ipc/rpmsg_service/README.rst

https://docs.zephyrproject.org/latest/samples/subsys/ipc/ipc_service/rpmsg_lite/README.html

> It is a better fit than the NXP-style pingpong demo because it uses the generic RPMsg path rather than the board-specific helpers described in README_2026-06-06b_imx-m7-demos.md.

### Linux

https://github.com/torvalds/linux/blob/master/samples/rpmsg/rpmsg_client_sample.c

### Run

```
Suggested first test
M7 sends “ping”
Linux receives it and replies “pong”
M7 prints the echoed response
```
hmp_mcuxpresso-zephyr/sources/rpmsg-lite/zephyr/samples/rpmsglite_pingpong/remote/src/main.c

hmp_mcuxpresso-zephyr/prj_verdin_imx8mp.conf


```bash
cd hmp_mcuxpresso-zephyr

sudo su
./run_3_start-root.sh
```

```text
[30527.503757] remoteproc remoteproc0: stopped remote processor imx-rproc
[30527.504413] remoteproc remoteproc0: powering up imx-rproc
[30527.507138] remoteproc remoteproc0: Booting fw image rpmsg_lite_sample.elf, size 1076980
[30528.018590] rproc-virtio rproc-virtio.2.auto: assigned reserved memory node vdevbuffer@55400000
[30528.128591] imx-rproc imx8mp-cm7: imx_rproc_kick: failed (0, err:-62)
[30528.135058] virtio_rpmsg_bus virtio0: rpmsg host is online
[30528.135143] rproc-virtio rproc-virtio.2.auto: registered virtio0 (type 7)
[30528.135153] remoteproc remoteproc0: remote processor imx-rproc is now up
```

```bash
ls  -1 /dev/re* /dev/rpmsg* /sys/bus/rpmsg/devices/
/dev/remoteproc0
/dev/rpmsg_ctrl0

/sys/bus/rpmsg/devices/:
virtio0.rpmsg_ctrl.0.0
virtio0.rpmsg_ns.53.53
```

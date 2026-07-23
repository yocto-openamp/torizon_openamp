# Run imx-m7-demos

https://developer.toradex.com/software/hmp/hmp-nxp/how-to-use-remoteproc

## check

```bash
torizon$ ls /sys/class/remoteproc/remoteproc0/
torizon$ cat /sys/class/remoteproc/remoteproc0/state
offline
torizon# echo stop > /sys/class/remoteproc/remoteproc0/state 
torizon$ cat /sys/class/remoteproc/remoteproc0/state 
```

## sample applications

```bash
torizon$ ls -l /lib/firmware/*.elf
/lib/firmware/imx8mp_m7_TCM_hello_world.elf
/lib/firmware/imx8mp_m7_TCM_low_power_wakeword.elf
/lib/firmware/imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf
/lib/firmware/imx8mp_m7_TCM_rpmsg_lite_str_echo_rtos.elf
/lib/firmware/imx8mp_m7_TCM_sai_low_power_audio.elf
```

## remoteproc

```bash
torizon# echo imx8mp_m7_TCM_hello_world.elf > /sys/class/remoteproc/remoteproc0/firmware
torizon$ echo start > /sys/class/remoteproc/remoteproc0/state
```

See: https://github.com/nxp-mcuxpresso/mcuxsdk-examples/tree/release/25.06.00-pvw2/multicore_examples/rpmsg_lite_pingpong
See: https://github.com/nxp-mcuxpresso/mcuxsdk-examples/tree/release/25.06.00-pvw2/multicore_examples/rpmsg_lite_pingpong/readme.md

```bash
torizon# modprobe imx_rpmsg_pingpong
torizon# echo imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf > /sys/class/remoteproc/remoteproc0/firmware
torizon# echo start > /sys/class/remoteproc/remoteproc0/state
# dmesg
# [  260.591014] remoteproc remoteproc0: powering up imx-rproc
# [  260.598545] remoteproc remoteproc0: Booting fw image imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf, size 63376
# [  261.111026] rproc-virtio rproc-virtio.2.auto: assigned reserved memory node vdevbuffer@55400000
# [  261.112189] virtio_rpmsg_bus virtio0: rpmsg host is online
# [  261.112278] rproc-virtio rproc-virtio.2.auto: registered virtio0 (type 7)
# [  261.112288] remoteproc remoteproc0: remote processor imx-rproc is now up
# [  262.113133] virtio_rpmsg_bus virtio0: creating channel rpmsg-openamp-demo-channel addr 0x1e
# [  262.113355] imx_rpmsg_pingpong virtio0.rpmsg-openamp-demo-channel.-1.30: new channel: 0x400 -> 0x1e!
# [  262.118598] get 1 (src: 0x1e)
...
# [  262.285124] get 101 (src: 0x1e)
# [  262.285148] imx_rpmsg_pingpong virtio0.rpmsg-openamp-demo-channel.-1.30: goodbye!
```

Output to UART
```bash
RPMSG Ping-Pong FreeRTOS RTOS API Demo...
RPMSG Share Base Addr is 0x55000000
Link is up!
Nameservice announce sent.
Waiting for ping...
Sending pong...
Waiting for ping...
...
Sending pong...
Ping pong done, deinitializing...
Looping forever...
```


See: https://github.com/EmcraftSystems/imx8m-som-rtos-demos/tree/master/multicore_examples/rpmsg_lite_str_echo_rtos
See: https://github.com/nxp-mcuxpresso/mcuxsdk-examples/blob/main/_boards/evkmimx8mm/multicore_examples/rpmsg_lite_str_echo_rtos/remote/example_board_readme.md

```bash
torizon# modprobe imx_rpmsg_tty
torizon# echo imx8mp_m7_TCM_rpmsg_lite_str_echo_rtos.elf > /sys/class/remoteproc/remoteproc0/firmware
torizon# echo start > /sys/class/remoteproc/remoteproc0/state
# dmesg
# [ 1960.662697] remoteproc remoteproc0: powering up imx-rproc
# [ 1960.663043] remoteproc remoteproc0: Booting fw image imx8mp_m7_TCM_rpmsg_lite_str_echo_rtos.elf, size 58460
# [ 1961.175069] rproc-virtio rproc-virtio.2.auto: assigned reserved memory node vdevbuffer@55400000
# [ 1961.176493] virtio_rpmsg_bus virtio0: rpmsg host is online
# [ 1961.176538] rproc-virtio rproc-virtio.2.auto: registered virtio0 (type 7)
# [ 1961.176547] remoteproc remoteproc0: remote processor imx-rproc is now up
# [ 1961.177007] virtio_rpmsg_bus virtio0: creating channel rpmsg-virtual-tty-channel-1 addr 0x1e
# [ 1961.178024] imx_rpmsg_tty virtio0.rpmsg-virtual-tty-channel-1.-1.30: new channel: 0x400 -> 0x1e!
# [ 1961.181593] Install rpmsg tty driver!
# [ 1961.186736] rpmsg_tty_cb68 65 6c 6c 6f 20 77 6f 72 6c 64 21              hello world!
# UART
# RPMSG String Echo FreeRTOS RTOS API Demo...

# Nameservice sent, ready for incoming messages...
# Get Message From Master Side : "hello world!" [len : 12]
torizon# echo test > /dev/ttyRPMSG30
# dmesg
# [ 1831.095617] rpmsg_tty_cb74 65 73 74                                      test
# [ 1831.098338] rpmsg_tty_cb0d 0a                                            ..
# UART
# Get Message From Master Side : "test" [len : 4]
# Get New Line From Master Side
```

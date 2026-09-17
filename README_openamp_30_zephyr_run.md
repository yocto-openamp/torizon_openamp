# OpenAmp - Run application

## Inspect remoteproc

On the Torizon target:

```bash
ls /sys/class/remoteproc/remoteproc0/
cat /sys/class/remoteproc/remoteproc0/state
```

Copy a firmware ELF to `/lib/firmware`, select it, and start the M7:

```bash
scp build/zephyr/zephyr.elf torizon@<module-ip>:/lib/firmware/zephyr.elf
ssh torizon@<module-ip>
echo zephyr.elf | sudo tee /sys/class/remoteproc/remoteproc0/firmware
echo start | sudo tee /sys/class/remoteproc/remoteproc0/state
cat /sys/class/remoteproc/remoteproc0/state
dmesg | tail -20
```

Stop it with:

```bash
echo stop | sudo tee /sys/class/remoteproc/remoteproc0/state
```

## Run the NXP RPMsg demos

The image contains several prebuilt M7 ELF files. For the ping-pong demo:

```bash
sudo modprobe imx_rpmsg_pingpong
echo imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf | \
	sudo tee /sys/class/remoteproc/remoteproc0/firmware
echo start | sudo tee /sys/class/remoteproc/remoteproc0/state
```

Expected Linux output includes `virtio_rpmsg_bus: rpmsg host is online`, followed by the ping-pong channel and messages such as `get 1` and `get 101`. The M7 UART reports `RPMSG Ping-Pong FreeRTOS RTOS API Demo...` and repeated `Sending pong...` messages.

For the virtual TTY demo:

```bash
sudo modprobe imx_rpmsg_tty
echo imx8mp_m7_TCM_rpmsg_lite_str_echo_rtos.elf | \
	sudo tee /sys/class/remoteproc/remoteproc0/firmware
echo start | sudo tee /sys/class/remoteproc/remoteproc0/state
echo test | sudo tee /dev/ttyRPMSG30
```

The M7 UART reports that the nameservice is ready and echoes the received message.

## UART connections

Use a 1.8 V USB-UART adapter. On the Mallow X11 header, UART3 is the A53/Linux/U-Boot console and UART4 is typically the M7 debug console. A Wi-Fi/Bluetooth module may claim UART4; in that case disable its Linux device-tree ownership or move the M7 console to another available UART.

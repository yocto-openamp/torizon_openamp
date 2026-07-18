I’m checking the active network interface names and IPs on this board first so I can give you the exact `netconsole` command shape for your setup rather than a generic example.

Ran terminal command:  ip -br a

Ran terminal command:  lsmod | grep netconsole || true
modinfo netconsole 2>/dev/null | sed -n '1,40p' || true

The target side is on `ethernet0` with `192.168.1.222`. Next I’m checking whether `netconsole` is built in or needs a module load, so I can give you the exact bring-up sequence and fallback if the module is missing.

Ran terminal command:  zgrep -E 'CONFIG_NETCONSOLE|CONFIG_NETPOLL|CONFIG_NETCONSOLE_DYNAMIC' /proc/config.gz 2>/dev/null || grep -E 'CONFIG_NETCONSOLE|CONFIG_NETPOLL|CONFIG_NETCONSOLE_DYNAMIC' /boot/config-$(uname -r) 2>/dev/null || true

On your current kernel, you cannot use `netconsole` yet. I checked the running config and it has:

```text
# CONFIG_NETCONSOLE is not set
```

So the immediate answer is: `netconsole` is not available in this Toradex kernel build. You would need a kernel with at least `CONFIG_NETPOLL=y` and `CONFIG_NETCONSOLE=y`. `CONFIG_NETCONSOLE_DYNAMIC=y` is optional but useful.

For your target, the relevant network details are already clear:

- Interface: `ethernet0`
- Target IP: `192.168.1.222`

If you rebuild or switch to a kernel with netconsole enabled, this is the setup.

**Host side**
Pick the Linux PC on the same subnet that will receive logs. Suppose its IP is `192.168.1.10`.

Find the host MAC on the interface connected to the board:

```sh
ip -br a
ip link show <host-iface>
```

Listen for UDP logs on the host. `socat` is the most reliable:

```sh
sudo socat -u UDP-RECV:6666 -
```

If you only have `nc`, use the variant supported by your distro, for example:

```sh
nc -u -l 6666
```

**Target side**
Load `netconsole` before reproducing the freeze. Replace the host MAC with the real MAC of your PC:

```sh
# octoprobe4
sudo modprobe netconsole netconsole=6665@192.168.1.222/ethernet0,6666@6666@192.168.1.204/00:d8:61:60:ae:71

# Testmessage
echo "<6>NETCONSOLE_TEST: hello from $(hostname) at $(date -Iseconds)" | sudo tee /dev/kmsg >/dev/null
```

Then verify it is active:

```sh
dmesg | tail
```

Now reproduce your failure:

```sh
echo imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf > /sys/class/remoteproc/remoteproc0/firmware
echo start > /sys/class/remoteproc/remoteproc0/state
```

If the kernel still manages to emit anything before or during the freeze, it should appear on the host listener.

**If built into the kernel instead of a module**
You can also pass it on the kernel command line:

```text
netconsole=6665@192.168.1.222/ethernet0,6666@192.168.1.10/aa:bb:cc:dd:ee:ff
```

That is better for very early crashes, but for your case, a module is usually enough because Linux is already fully booted before you start `remoteproc`.

**What you need to change first**
Because your current kernel lacks netconsole support, you have two practical options:

1. Boot a Toradex/custom kernel that has `CONFIG_NETCONSOLE=y` or `m`.
2. Use another crash-capture path instead, such as UART or `pstore`, if rebuilding the kernel is not convenient.

If you want, I can give you the exact kernel config fragment you need for Torizon/Toradex, or help you set up `pstore/ramoops` as the next-best fallback when `netconsole` is unavailable.

Completed: *Test with stable Toradex kernel* (4/4)

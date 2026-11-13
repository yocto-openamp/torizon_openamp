# Hardware - Two SHT40 sensors

Both sensors share Verdin I2C_1 on the Mallow carrier board:

| Signal | Mallow connector | Verdin SODIMM |
| - | - | - |
| I2C_1_SDA | X10-10 | 12 |
| I2C_1_SCL | X10-11 | 14 |
| GND | X10-9 | - |

Connect both SDA lines in parallel and both SCL lines in parallel, with a
common ground. The sensors must have distinct **7-bit addresses**, `0x44`
and `0x45`. SHT40 addresses are factory fixed: use the appropriate variants
(for example SHT40-AD1B at `0x44` and SHT40-BD1B at `0x45`). Software cannot
change two `0x44` sensors into this pair.

## Electrical requirements

The [Mallow V1.1 datasheet](https://docs.toradex.com/113873-mallow-carrier-board-datasheet.pdf)
specifies **1.8 V logic** for I2C_1 at X10. Use a 1.8 V sensor supply and
SDA/SCL pull-ups to 1.8 V, accounting for pull-ups already present on the bus.
Do not connect breakout-board pull-ups to 3.3 V or 5 V directly to X10;
use a suitable bidirectional I2C level shifter if the sensor board requires
a different bus voltage. Check the exact sensor board's supply requirements.

## Yocto integration

The productxy layer builds and enables
`verdin-imx8mp_sht40_overlay.dtbo` in both the Easy Installer overlay list and
the U-Boot distro boot configuration. It adds two `sensirion,sht4x` devices
under `&i2c4`, which is **Verdin I2C_1**, not `&i2c1`.
The existing pin mux and bus speed are retained. HMP and the SPI_1 M7
handoff overlays remain enabled.

The kernel fragment selects `CONFIG_SENSORS_SHT4x=m`, and the image explicitly
includes `kernel-module-sht4x`. Device-tree matching loads the driver
automatically; no userspace I2C device creation is needed.

Build in the [configured Yocto environment](README_yocto_40_build.md):

```bash
bitbake torizon-docker
```

Deploy the rebuilt image and reboot.

## Read temperature and humidity

With the current Verdin device tree, `&i2c4` is Linux adapter **i2c-3**.
Read each sensor by address rather than relying on unstable `hwmonN` indices:

```bash
set -eu
for address in 0044 0045; do
    device="/sys/bus/i2c/devices/3-$address"
    found=0
    for hwmon in "$device"/hwmon/hwmon*; do
        [ -d "$hwmon" ] || continue
        found=1
        printf 'Sensor 0x%s (%s)\n' "${address#00}" "$(cat "$hwmon/name")"
        printf 'Temperature [milli-degrees C]: '
        cat "$hwmon/temp1_input"
        printf 'Relative humidity [milli-percent RH]: '
        cat "$hwmon/humidity1_input"
    done
    if [ "$found" -eq 0 ]; then
        printf 'No hwmon device for %s; check wiring and dmesg.\n' "$device" >&2
        exit 1
    fi
done
```

Divide both readings by 1000: `23500` means 23.5 degrees C, and `45600`
means 45.6% RH. The driver caches measurements for at least two seconds.

If a sensor does not appear, inspect `dmesg | grep -iE 'sht4|i2c'` and
`ls /sys/bus/i2c/devices/`. Verify the overlay was loaded and the driver
is available with `sudo modprobe sht4x`. Probe errors can indicate a missing
sensor, wrong address, wiring or voltage problems. Avoid raw I2C commands
against sensors while the kernel driver owns them.

**Individual raw readings**

```bash
# Sensor 0x44
cat /sys/bus/i2c/devices/3-0044/hwmon/hwmon*/temp1_input
cat /sys/bus/i2c/devices/3-0044/hwmon/hwmon*/humidity1_input

# Sensor 0x45
cat /sys/bus/i2c/devices/3-0045/hwmon/hwmon*/temp1_input
cat /sys/bus/i2c/devices/3-0045/hwmon/hwmon*/humidity1_input
```

Raw values are scaled by 1000: 23500 = 23.5 °C, 45600 = 45.6 %RH. Allow at least 2 seconds between measurements.

**If the sensors are unavailable**

```bash
sudo modprobe sht4x
sudo dmesg | grep -iE 'sht4|i2c'
ls /sys/bus/i2c/devices/3-004*
```

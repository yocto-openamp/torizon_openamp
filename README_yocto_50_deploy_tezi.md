# Yocto - Deploy - Tezi Installer

## Prepare the image

The image to install is:

```text
yocto-workdir/build-torizon/deploy/images/verdin-imx8mp/torizon-docker-verdin-imx8mp-Tezi.tar
```

## USB recovery mode

1. Power off the Verdin module.
2. Connect Ethernet and the PC to the Mallow USB-C recovery connector X8.
3. Connect X16 pin 1 (GND) to pin 2 (`CTRL_RECOVERY_MICO`).
4. Power on, then run the Toradex recovery script on the host.

```bash
mkdir -p /tmp/torizon
cd /tmp/torizon
wget https://tezi.toradex.com/artifactory/tezi-oe-prod-frankfurt/scarthgap-7.x.y/release/12/verdin-imx8mp/tezi/tezi-run/oedeploy/Verdin-iMX8MP_ToradexEasyInstaller_7.6.1+build.12.zip
unzip Verd*.zip
cd Verd*
./recovery-linux.sh
```

Disconnect the recovery jumper after the module enters recovery mode. Open the installer with `gvncviewer 192.168.11.1`, select the Torizon OS image feed, and choose **Install**, **Yes**, and **I Accept**.

## Connect with SSH

After installation and reboot:

```bash
ssh-copy-id torizon@verdin-imx8mp-08910183.local
ssh torizon@verdin-imx8mp-08910183.local
uname -a
systemctl is-system-running
```

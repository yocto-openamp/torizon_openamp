# Hardware - Bring up

In this document:

* Run Easy Installer
* Flash a Yocto image

## Links

* [Mallow](https://developer.toradex.com/hardware/verdin-som-family/carrier-boards/mallow-carrier-board/)
* [Connectors](https://www.toradex.com/products/carrier-board/mallow-carrier-board#features)
* https://docs.toradex.com/113763-mallow-v1.1-assembly-drawing.zip
* https://developer.toradex.com/easy-installer/toradex-easy-installer/download-tezi

* 0063 Verdin iMX8M Plus Quad 4GB IT, V1.1C, S/N 08910183

* X9 2xUSB-A: Plug a USB keyboard/mouse into the Mallow Carrier Board's USB 3.x Host (X9) connector(s).
* X8 USB-C: Plug a USB Type-C to Type-A cable into the DRP (X8) connector to enter Recovery Mode and load the Toradex Easy Installer.
* SW2: Reset button
* SW1: Power button

## ETH

00:14:2D:87:F5:67
192.168.1.170

* VSCode 'Torizon IDE Extension'
* verdin-imx8mp-08910183
* connect, torizon/torizon
* ssh torizon@verdin-imx8mp-08910183.local

## USB Recovery Mode

### Server: Server image to be installed

See also [TEZI Server](tezi-server/tezi_server_README.md)

```bash
cd yocto-workdir
uv run https://raw.githubusercontent.com/yocto-openamp/torizon_openamp/main/tezi-server/tezi_server.py
```

### Mallow: Boot into Recovery Mode

* Power off
* Connect ETH
* Connect PC with Mallow-USB-C
* Connect X16 pin 1 (GND) with pin 2 (CTRL_RECOVERY_MICO)
	* https://docs.toradex.com/117250-mallow_carrier_board_recovery_mode.mp4
	* [Mallow loading TEZI](https://developer.toradex.com/easy-installer/toradex-easy-installer/loading-toradex-easy-installer/?module=verdin_imx8mp&carrier=mallow#3-loading-tezi)
* Power on (or SW2/RST)
* Disconnect X16 pin 1 (GND) from pin 2 (CTRL_RECOVERY_MICO)

### PC: Toradex Easy Installer

```bash
lsusb
# ID 1fc9:0146 NXP Semiconductors SE Blank 865

mkdir -p /tmp/torizon
cd /tmp/torizon
wget https://tezi.toradex.com/artifactory/tezi-oe-prod-frankfurt/scarthgap-7.x.y/release/12/verdin-imx8mp/tezi/tezi-run/oedeploy/Verdin-iMX8MP_ToradexEasyInstaller_7.6.1+build.12.zip
unzip Verd*.zip
cd Verd*
./recovery-linux.sh
```

Use `gvncviewer 192.168.11.1` to open the installer. On the VNC display, select Torizon OS, then choose Install, Yes, and I Accept.

### Connect with SSH

```bash
ssh-copy-id torizon@verdin-imx8mp-08910183.local
# Password: torizon
```

To allow passwordless root SSH access:

```bash
ssh torizon@verdin-imx8mp-08910183.local
sudo cp -r ~torizon/.ssh ~root
ssh root@verdin-imx8mp-08910183.local
```

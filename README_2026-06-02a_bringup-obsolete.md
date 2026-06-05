# Bringup 2026-06-02

## Links

* [Mallow](https://developer.toradex.com/hardware/verdin-som-family/carrier-boards/mallow-carrier-board/)
* [Connectors](https://www.toradex.com/products/carrier-board/mallow-carrier-board#features)
* https://docs.toradex.com/113763-mallow-v1.1-assembly-drawing.zip

* X9 2xUSB-A: Plug a USB keyboard/mouse into the Mallow Carrier Board's USB 3.x Host (X9) connector(s).

* X8 USB-C: Plug a USB Type-C to Type-A cable into the DRP (X8) connector to enter Recovery Mode and load the Toradex Easy Installer.
* SW2: Reset button
* SW1: Power button

## ETH

00:14:2D:87:F5:67
192.168.1.170

## Connect HDMI

* Toradex Easy Install 5.7.3 -> 7.6.1
* 0063 Verdin iMX8M Plus Quad 4GB IT, V1.1C, S/N 08910183

-> Torizon OS Easy Pairing 7.7.9

## First login into 'Torizon OS Easy Pairing 7.7.9'

* VSCode 'Torizon IDE Extension'
* verdin-imx8mp-08910183
* commect, torizon/torizon

* ssh torizon@verdin-imx8mp-08910183.local

## USB Recovery Mode

```bash
$ sudo apt  install uuu
$ uuu -lsusb
uuu (Universal Update Utility) for nxp imx chips -- lib1.5.201

Connected Known USB Devices
	Path	 Chip	 Pro	 Vid	 Pid	 BcdVersion	 Serial_no
	====================================================================
	3:7	 MX865	 SDPS:	 0x1FC9	0x0146	 0x0002	 120D28005D669B2A
```

* Power off
* Connect USB C to the PC
* Connect X16 pin1(GND) with pin2(CTRL_RECOVERY_MICO)
  * https://docs.toradex.com/117250-mallow_carrier_board_recovery_mode.mp4
  * [mallow loading-tezi ](https://developer.toradex.com/easy-installer/toradex-easy-installer/loading-toradex-easy-installer/?module=verdin_imx8mp&carrier=mallow#3-loading-tezi)

```text
usb 3-7: new high-speed USB device number 31 using xhci_hcd
usb 3-7: New USB device found, idVendor=1fc9, idProduct=0146, bcdDevice= 0.02
usb 3-7: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 3-7: Product: SE Blank 865  
usb 3-7: Manufacturer: NXP       SemiConductor Inc 
hid-generic 0003:1FC9:0146.000E: hiddev1,hidraw5: USB HID v1.10 Device [NXP       SemiConductor Inc  SE Blank 865  ] on usb-0000:00:14.0-7/input0
```

### Install Toradex Easy Installer

https://developer.toradex.com/easy-installer/toradex-easy-installer/download-tezi

```bash
$ wget https://tezi.toradex.com/artifactory/tezi-oe-prod-frankfurt/scarthgap-7.x.y/release/12/verdin-imx8mp/tezi/tezi-run/oedeploy/Verdin-iMX8MP_ToradexEasyInstaller_7.6.1+build.12.zip
$ unzip *zip
$ cd Verd*
$ sudo su
root@maerki-ideapad-320:/tmp/torizon/Verdin-iMX8MP_ToradexEasyInstaller_7.6.1+build.12# ./recovery-linux.sh 
Downloading Toradex Easy Installer...
uuu (Universal Update Utility) for nxp imx chips -- libuuu_1.5.233-0-g79ce7d2
Success 1    Failure 0                                                
3:7-08910183 7/ 7 [Done                                  ] FB: done                                                               
3:7-120D2800 1/ 1 [=================100%=================] SDPS: boot -f ../imx-boot-recoverytezi                                 
Successfully downloaded Toradex Easy Installer.
```


* Remove: X16 pin1(GND) with pin2(CTRL_RECOVERY_MICO)
* Powercycle

```bash
scp octoprobe@octoprobe4.local:/home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir/build-torizon/deploy/images/verdin-imx8mp/torizon-docker-verdin-imx8mp-Tezi.tar /media/maerki/torizon/

$ cd yocto-workdir/build-torizon/deploy/images/verdin-imx8mp/
$ python3 -m http.server 8080


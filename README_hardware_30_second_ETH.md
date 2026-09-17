# Hardware - Second ETH

This page documents how to connect a ETH adapter to M.2.

The yocto-image described in this repo provides this configuration

Internet (dhcp) ==IPv4v6==> ETH on Mallow Carrier Board - ETH on M.2 (192.168.50.1, dhcp) ==IPv4==> Other computers (will get IP von dhcp and have access to the internet)

## Links

[Delock 95272](https://www.delock.de/produkt/95272/merkmale.html) is an M.2 2242 B+M card using Intel I225-V with a 2.5 GbE RJ45 port.

## Collected information

[Toradex: Second ETH](https://developer.toradex.com/software/linux-resources/connectivity/network-on-toradex-computer-on-modules/?utm_source=chatgpt.com#second-ethernet-on-toradex-carrier-boards)

The i.MX 8M Plus has a second Gigabit Ethernet controller exposed as RGMII. Toradex documents using that interface with an external Ethernet PHY on the carrier board.

The Mallow carrier board does not provide that second PHY/RJ45 interface. Its X17 connector is M.2 Key B with one PCIe lane, so a PCIe Ethernet adapter can be used instead.


## Ethernet bringup

Connect the Delock 95272 to X17 and inspect the PCIe and network devices:

```bash
lspci -nn
# 00:00.0 PCI bridge [0604]: Synopsys, Inc. DWC_usb3 / PCIe bridge [16c3:abcd] (rev 01)
# 01:00.0 Ethernet controller [0200]: Intel Corporation Ethernet Controller I225-V [8086:15f3] (rev 03)

lspci -k
# Kernel driver in use: igc

ip -br link
# ethernet0        UP  00:14:2d:87:f5:67
# enp1s0           UP  88:c9:b3:b5:2f:9e
```

Check both interfaces with `ethtool ethernet0` and `ethtool enp1s0`. The onboard interface is `ethernet0`; the PCIe adapter is `enp1s0`. Both should report an active link when connected.

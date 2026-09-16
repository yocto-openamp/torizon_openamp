# Second ETH

## Collected info

[Toradex, Second ETH](https://developer.toradex.com/software/linux-resources/connectivity/network-on-toradex-computer-on-modules/?utm_source=chatgpt.com#second-ethernet-on-toradex-carrier-boards)

The i.MX 8M Plus has a second Gigabit Ethernet controller exposed as RGMII. Toradex specifically documents using that interface with an external Ethernet PHY on the carrier board.

**Mallow does not provide that second PHY/RJ45 interface.**

The key fact is that Mallow's X17 is M.2 Key B with one PCIe lane, and Toradex confirms it can be used for PCIe/NVMe devices.

Don't search for a "one-notch M-key Ethernet card." Search for:

*M.2 B+M key PCIe x1 Ethernet I225* or *M.2 B key 2.5GbE I225*

## Links

* https://community.toradex.com/t/mallow-carrier-board-and-pcie-m-2-key-b/20530

## Cards

### Ableconn M2NW108BM — Intel I225, 2.5 GbE

https://ableconn.com/products_2.php?gid=172

2.5GbE

M.2 B+M-key card, PCIe ×1, with an RJ45 connector, based on the Intel I225. The manufacturer explicitly says it works in M.2 B-Key or M-Key sockets.

Risk: Single Print

### Ableconn/Lycom NW-107BM — 1 GbE

https://www.lycom.com.tw/NW-107BM.htm

M.2 B-M key, PCIe ×1 Ethernet module

### IOCrest IO-M2F225-GLAN — Intel I225, 2.5 GbE

M.2 B-Key/M-Key → 2.5G Ethernet, using Intel I225

### Advantech PCM-34R1TP-AE

https://www.integral-system.fr/products/1-port-gigabit-ethernet-intel-174-i225-2-5gb-s-ieee-1588-tsn-1x-rj45-b-m-key-3042-pciex1-pcm-34r1tp-ae

https://www.integral-system.fr/media/product/file/09196237-E1E4-4EEA-8DFB-8951616485BE.pdf

CHF77


### Delock M.2 Key B+M 2.5GbE Ethernet

https://www.digitec.ch/de/s1/product/delock-konverter-m2-key-bm-stecker-zu-1-x-rj45-25-gigabit-lan-port-horizontal-pcie-20-netzwerkkarte-32987734

CHF 42.59

**too long!**

### Ebay 2.5G M.2 B+M Key PCIE NVME Ethernet Card 2500M RJ45 LAN Card Intel I225 Chipset

https://www.ebay.com/itm/316249066533

USD 30

### DfRobot FIT1005

**Stock: 0** (Mouser&Digikey), (1 left https://www.dfrobot.com/search-fit1005.html)

https://www.mouser.ch/en/ProductDetail/DFRobot/FIT1005?qs=jcD%2FCkGBYeOGKfJ9FwXBAA%3D%3D

Ethernet Modules M.2 (B+M Key) to 2.5G Ethernet

CHF 20

### https://de.aliexpress.com/item/1005009824703376.html

CHF 45

M.2 B+M I226-T2 Industrial Grade 2.5G Gigabit Ethernet Card PCIE Dual Electrical Port Network Card

**probably too long**

### https://de.aliexpress.com/item/1005006567773303.html

CHF 25

M.2 to Dual Port 2.5G Ethernet NIC Network Card M.2 22*80mm Size B Key and M Key 2500 Mbps RTL8125B Chipset

**too long**

### [Delock 95272](https://www.delock.de/produkt/95272/merkmale.html)

https://www.delock.de/files/110284.download

Intel i225V
M.2 2242 B+M Stecker

2.5GB

CHF40 https://www.conrad.ch/de/p/delock-95272-m-2-controller-rj45-seriell-3379284.html

CHF47 https://www.digitec.ch/de/s1/product/delock-konverter-m2-key-bm-1-x-rj45-25-gigabit-lan-netzwerkkarte-31701823
==> SELECTED

CHF81 https://www.reichelt.com/ch/de/shop/produkt/netzwerkkarte_m_2_2_5_gigabit_ethernet_1x_rj45-335262

### [Delock 95274](https://www.delock.de/produkt/95274/merkmale.html)

https://www.digitec.ch/de/s1/product/delock-m2-key-bm-1-x-rj45-netzwerkkarte-42616779

Delock M.2 Key B+M 1 x RJ45

10GB

**too long**

### https://www.delock.de/produkt/62851/merkmale.html

M.2 2242, Realtek RTL8111

1G


## ETH bringup

Connect `Delock 95272`

```bash
$ lspci -nn
00:00.0 PCI bridge [0604]: Synopsys, Inc. DWC_usb3 / PCIe bridge [16c3:abcd] (rev 01)
01:00.0 Ethernet controller [0200]: Intel Corporation Ethernet Controller I225-V [8086:15f3] (rev 03)
$ lspci -k
00:00.0 PCI bridge: Synopsys, Inc. DWC_usb3 / PCIe bridge (rev 01)
	Kernel driver in use: pcieport
01:00.0 Ethernet controller: Intel Corporation Ethernet Controller I225-V (rev 03)
	Subsystem: Intel Corporation Ethernet Controller I225-V
	Kernel driver in use: igc
$ lsmod | grep igc
...nothing...
$ ip link
3: ethernet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 00:14:2d:87:f5:67 brd ff:ff:ff:ff:ff:ff
    altname end0
6: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 88:c9:b3:b5:2f:9e brd ff:ff:ff:ff:ff:ff
$ ip -br link
ethernet0        UP             00:14:2d:87:f5:67 <BROADCAST,MULTICAST,UP,LOWER_UP> 
enp1s0           UP             88:c9:b3:b5:2f:9e <BROADCAST,MULTICAST,UP,LOWER_UP> 

$ sudo ethtool ethernet0
Settings for ethernet0:
	Supported ports: [ TP	 MII ]
	Supported link modes:   10baseT/Full
	                        100baseT/Full
	                        1000baseT/Full
	Supported pause frame use: Symmetric Receive-only
	Supports auto-negotiation: Yes
	Supported FEC modes: Not reported
	Advertised link modes:  10baseT/Full
	                        100baseT/Full
	                        1000baseT/Full
	Advertised pause frame use: Symmetric Receive-only
	Advertised auto-negotiation: Yes
	Advertised FEC modes: Not reported
	Link partner advertised link modes:  10baseT/Half 10baseT/Full
	                                     100baseT/Half 100baseT/Full
	                                     1000baseT/Full
	Link partner advertised pause frame use: Symmetric
	Link partner advertised auto-negotiation: Yes
	Link partner advertised FEC modes: Not reported
	Speed: 1000Mb/s
	Duplex: Full
	Auto-negotiation: on
	master-slave cfg: preferred slave
	master-slave status: slave
	Port: Twisted Pair
	PHYAD: 7
	Transceiver: external
	MDI-X: on (auto)
	Supports Wake-on: ug
	Wake-on: d
        Current message level: 0x0000003f (63)
                               drv probe link timer ifdown ifup
	Link detected: yes
$ sudo ethtool enp1s0
Settings for enp1s0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
	                        1000baseT/Full
	                        2500baseT/Full
	Supported pause frame use: Symmetric
	Supports auto-negotiation: Yes
	Supported FEC modes: Not reported
	Advertised link modes:  10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
	                        1000baseT/Full
	                        2500baseT/Full
	Advertised pause frame use: Symmetric
	Advertised auto-negotiation: Yes
	Advertised FEC modes: Not reported
	Speed: 1000Mb/s
	Duplex: Full
	Auto-negotiation: on
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	MDI-X: off (auto)
	Supports Wake-on: pumbg
	Wake-on: g
        Current message level: 0x00000007 (7)
                               drv probe link
	Link detected: yes

$ ip addr
3: ethernet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:14:2d:87:f5:67 brd ff:ff:ff:ff:ff:ff
    altname end0
    inet 192.168.1.222/24 brd 192.168.1.255 scope global dynamic noprefixroute ethernet0
       valid_lft 86297sec preferred_lft 86297sec
    inet6 2a02:aa15:4101:b400::a1f7/128 scope global dynamic noprefixroute 
       valid_lft 506517sec preferred_lft 506517sec
    inet6 fe80::f01c:b482:cb8b:41cd/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
6: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 88:c9:b3:b5:2f:9e brd ff:ff:ff:ff:ff:ff
    inet 192.168.50.1/24 brd 192.168.50.255 scope global noprefixroute enp1s0
       valid_lft forever preferred_lft forever
$ sudo systemctl status dnsmasq
○ dnsmasq.service
     Loaded: masked (Reason: Unit dnsmasq.service is masked.)
     Active: inactive (dead)

$ nmcli connection show --active
NAME         UUID                                  TYPE      DEVICE    
dhcp-server  cfc1f14b-b017-466a-b011-ba2a06b30ee6  ethernet  enp1s0    
network0     958cc5e3-1bbf-3d64-beeb-020d4414e254  ethernet  ethernet0 
lo           6854b740-d66e-47fb-aa18-335881cd00ee  loopback  lo       
$ nmcli device status
DEVICE     TYPE      STATE                   CONNECTION  
enp1s0     ethernet  connected               dhcp-server 
ethernet0  ethernet  connected               network0    
lo         loopback  connected (externally)  lo          
$ nmcli device show enp1s0
GENERAL.DEVICE:                         enp1s0
GENERAL.TYPE:                           ethernet
GENERAL.HWADDR:                         88:C9:B3:B5:2F:9E
GENERAL.MTU:                            1500
GENERAL.STATE:                          100 (connected)
GENERAL.CONNECTION:                     dhcp-server
GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/3
WIRED-PROPERTIES.CARRIER:               on
IP4.ADDRESS[1]:                         192.168.50.1/24
IP4.GATEWAY:                            --
IP4.ROUTE[1]:                           dst = 192.168.50.0/24, nh = 0.0.0.0, mt = 101
IP6.GATEWAY:                            --
```

## Measure throughput Mallow vs Dell Inspiron 5550

```bash
# Malllow
$ iperf3 -s

# Notebook
$ sudo ethtool enp0s31f6
1000baseT/Full

iperf3 -c 192.168.50.1
955MBits/s
```

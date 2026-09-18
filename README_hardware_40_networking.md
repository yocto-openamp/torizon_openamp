# Hardware - Networking

This chapter demonstrates some variants how networking may be set up.


## Variant 'Office Network'

```
           Internet

              ^
              |RJ45
              v

Office Network: Router (DHCP server)

              ^
              |
    -------------------------
    |RJ45                   |RJ45
    v                       V

Developer Notebook       Toradex
```

* Pro: Simple
* Con: Need access to router to find out Toradex IP


## Variant 'Developer Subnet'

```
           Internet

              ^
              |RJ45/WLAN
              v

       (dhcp client)
       Developer Notebook
       (dhcp server)

              ^
              |RJ45
              v

           Toradex
```

* Pro: Works everywhere
* Pro/Con: Toradex computer is only visible from the Developer Notebook
* Pro: Name resultion `verdin-imx8mp-08910183.local` works.


### Configuration

As root, `enp0s` is the USB to RJ45 dongle.

**Create a named connection on `enp0s`**

```bash
nmcli connection add type ethernet con-name "ToradexNet" ifname enp0s ipv4.method shared
nmcli connection up ToradexNet
```

**List all leases**

As root
```bash
ls -l /var/lib/NetworkManager/dnsmasq-en*.leases
```

```bash
sudo cat /var/lib/NetworkManager/dnsmasq-enp0s31f6.leases
1789724647 00:14:2d:87:f5:67 10.42.0.170 verdin-imx8mp-08910183 01:00:14:2d:87:f5:67
```

**Debugging**

```bash
# List interfaces
nmcli device status
# Show details about ToradexNet
nmcli connection show ToradexNet
# This is how to connect to a Toradex board
ssh torizon@verdin-imx8mp-08910183.local
```

* TODO: How to display see dhcp table?

## Variant 'Boot into Recovery Mode'

```
           Internet

              ^
              |RJ45/WLAN
              v

       (dhcp client)
       Developer Notebook
       (dhcp server)

              ^
              |USB
              v

            (USB-C)
           Toradex
```

NXP's uuu (Universal Update Utility) will provide RNDIS.

See [Hardware - bring up](README_hardware_20_bring_up.md)

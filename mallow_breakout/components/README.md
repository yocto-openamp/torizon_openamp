# Components for breakout board

## References

* [Toradex Verdin i.MX 8M Plus](https://www.toradex.com/de/computer-on-modules/verdin-arm-family/nxp-imx-8m-plus)

  * Table 17: SoC Pins Mapping

* [Toradex Mallow carrier board](https://www.toradex.com/products/carrier-board/mallow-carrier-board)

  * [Datasheet](https://docs.toradex.com/113873-mallow-carrier-board-datasheet.pdf)
  * [Developer](https://developer.toradex.com/hardware/verdin-som-family/carrier-boards/mallow-carrier-board)
  * [Assembly Drawings](https://docs.toradex.com/113763-mallow-v1.1-assembly-drawing.zip)
  * [3D Step](https://docs.toradex.com/113766-mallow-v1.1-3d-step-model.zip)
  * [3D PDF](https://docs.toradex.com/113767-mallow-v1.1-3d-pdf-model.zip)


## Pin Mapping

* https://pinout.torizon.io/#/pinout


| Mallow / Name | SODIMM | iMX8M Plus Ball Name | iMX8M Plus ALTx | Comment |
| - | - | - | - | - |
| X10-21 / GPIO_1 | 206 | GPIO1_IO00 | GPIO1_IO00 | |
| X10-22 / GPIO_2 | 208 | GPIO1_IO01 | GPIO1_IO01 | |
| X10-23 / GPIO_3 | 210 | GPIO1_IO05 | GPIO1_IO05 | |
| X10-24 / GPIO_4 | 212 | GPIO1_IO06 | GPIO1_IO06 | |
| X16-1 / GND | | | | |
| X16-2 / CTRL_RECOVERY_MICO | 246 | | | | 


Pin 206 (GPIO1_IO00) is not dedicated to either the Cortex-A53 or the Cortex-M7. It is a SoC GPIO peripheral (GPIO1_IO00) that can be controlled by either the Cortex-A53 cluster or the Cortex-M7, depending on how your software configures ownership and the IOMUX.

The GPIO controllers are shared peripherals, not hardwired to a specific CPU. Therefore:

If Linux is running on the A53, Linux can configure and drive GPIO1_IO00.
If firmware is running on the M7, the M7 can also access GPIO1_IO00.
Both cores must not control the same GPIO simultaneously. Ownership must be coordinated (typically by device tree on Linux and by ensuring the M7 firmware only uses peripherals reserved for it). 

Zephyr Device Tree entry:
```
&pinctrl {
    pinctrl_gpio1_io0: gpio1io0grp {
        fsl,pins = <
            MX8MP_IOMUXC_GPIO1_IO00__GPIO1_IO00 0x1c4
        >;
    };
};
```

SODIMM pin 212:
```
&pinctrl {
    pinctrl_gpio212: gpio212grp {
        fsl,pins = <
            MX8MP_IOMUXC_GPIO1_IO06__GPIO1_IO06 0x184
        >;
    };
};
```

# experiment_torizon_openamp

Experiments with NXP i.MX 8M Plus Computer on Module, zephyr and openamp

* [Install environment and build yocto](README_environment.md)
* [Deploy to the board, Tezi Installer](README_deploy.md)
* [Bringung of the board](README_2026-06-05a_bringup.md)
* [Run the toradex provided open amp demos](README_2026-06-06b_imx-m7-demos.md)
* [A yocto layer for a productxy - assessment](README_add_layer_productxy.md)
* [A yocto layer for a productxy - git](https://github.com/hmaerki/experiment_torizon_openamp_productxy)

## References

* [Toradex Verdin i.MX 8M Plus](https://www.toradex.com/de/computer-on-modules/verdin-arm-family/nxp-imx-8m-plus)
* [Toradex Mallow carrier board](https://www.toradex.com/products/carrier-board/mallow-carrier-board)

  * [Datasheet](https://docs.toradex.com/113873-mallow-carrier-board-datasheet.pdf)

* [torizon/meta-toradex-torizon](https://github.com/torizon/meta-toradex-torizon)

## BOM

| CHF | Distributor/Link | Product | Notes |
| -: | :-: | - | - |
| 249 | [toradex](https://www.toradex.com/de/computer-on-modules/verdin-arm-family/nxp-imx-8m-plus) | 00631102 Verdin iMX8M Plus Quad 4GB IT V1.1C | - |
| 83 | [toradex](https://www.toradex.com/de/products/carrier-board/mallow-carrier-board) | 01611102 Mallow Carrier Board V1.1C | - |
| 11 | [toradex](https://www.toradex.com/de/accessories/verdin-industrial-heatsink) | 23111100 Verdin Industrial Heatsink Type 1 V1.1A | - |
| 25+29 | toradex | Freight+MWST | - |
| 29 | [distrelec](https://ftdichip.com/products/ttl-232rg-vreg1v8-we/) | TTL-232RG-VREG1V8-WE USB-TTL SERIAL CABLE | 1.7V !!! |
| 26 | [distrelec](https://www.st.com/en/evaluation-tools/nucleo-f722ze.html) | NUCLEO-F722ZE STM32 Nucleo-144 development board | [STM32F722ZET6](https://www.st.com/resource/en/datasheet/stm32f722ic.pdf) 216 MHz |


## Repositories involved

* https://github.com/hmaerki/experiment_torizon_openamp @ Verdin-nxp-imx-8m-plus

  Yocto

  Board bringup: [README_2026-06-05a_bringup.md](https://github.com/hmaerki/experiment_torizon_openamp/blob/Verdin-nxp-imx-8m-plus/README_2026-06-05a_bringup.md)

  Build instructions: [README_environment.md](https://github.com/hmaerki/experiment_torizon_openamp/blob/Verdin-nxp-imx-8m-plus/README_environment.md)

  Add productxy layer: [README_add_layer_productxy.md](https://github.com/hmaerki/experiment_torizon_openamp/blob/Verdin-nxp-imx-8m-plus/README_add_layer_productxy.md)
  
  Deploy and start: [README_deploy.md](https://github.com/hmaerki/experiment_torizon_openamp/blob/Verdin-nxp-imx-8m-plus/README_deploy.md)

  OpenAmp demos: [README_2026-06-06b_imx-m7-demos.md](https://github.com/hmaerki/experiment_torizon_openamp/blob/Verdin-nxp-imx-8m-plus/README_2026-06-06b_imx-m7-demos.md)

* https://github.com/hmaerki/experiment_torizon_openamp_productxy

  A Yocto layer which makes experiment_torizon_openamp to a product by adding software and yocto configuration.

* https://github.com/hmaerki/experiment_zephyr_isr_on_M7

  NUCLEO-F722ZE: Measure interrupt handling time

* https://github.com/hmaerki/response_time_analyzer

  Measure response time on two gpio using a RP2 and micropython.

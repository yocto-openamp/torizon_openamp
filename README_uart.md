# UART

## Toradex Cable recommendation

* https://developer.toradex.com/hardware/verdin-som-family/carrier-boards/mallow-carrier-board/

* https://ftdichip.com/products/ttl-232rg-vreg1v8-we/

* https://www.distrelec.ch/de/ttl-232rg-vreg1v8-we-ftdi-ttl-232rg-vreg1v8-we/p/30401774
* https://media.distrelec.com/Web/Downloads/_t/ds/TTL-232RG-VREG1V8-WE_eng_tds.pdf

## chatgpt

On the **Mallow Carrier Board** with a **Verdin iMX8M Plus**, Toradex exposes **two debug UARTs** on connector **X11**:

* **UART3** → primary serial console (A53/Linux/U-Boot)
* **UART4** → secondary serial console (typically used for M7 debug output) ([Toradex Documentation][1])

### A53 (Linux/U-Boot) console

The Cortex-A53 console is connected to **UART3** on the Mallow debug header X11.

| X11 Pin | Signal    |
| ------- | --------- |
| 1       | GND       |
| 3       | UART3_RXD |
| 4       | UART3_TXD |

Connect a **1.8 V USB-UART adapter** (not 3.3 V!) such as the FTDI 1.8 V cable recommended by Toradex. Open the terminal at **115200 8N1**. You'll see:

* U-Boot output
* Linux kernel boot log
* Linux login prompt (if enabled) ([Toradex Documentation][1])

---

### M7 console

By default Toradex SDK examples and Zephyr use **UART4** as the M7 debug console. ([Zephyr Project Documentation][2])

The Mallow X11 header also exposes UART4:

| X11 Pin   | Signal        |
| --------- | ------------- |
| GND       | Common ground |
| UART4_RXD | M7 console RX |
| UART4_TXD | M7 console TX |

(Refer to the X11 pinout in the Mallow datasheet for exact pin numbers.) ([Toradex Documentation][1])

In MCUXpresso SDK examples, the M7 console is usually initialized via:

```c
BOARD_InitDebugConsole();
```

and routed to UART4.

---

### Important caveat: Wi-Fi/Bluetooth modules

If your Verdin iMX8M Plus variant includes **Wi-Fi/Bluetooth**, UART4 is shared with the Bluetooth interface. In Linux, Bluetooth normally claims UART4, preventing external M7 console access. Toradex support notes that to use UART4 externally for the M7, you must remove UART4/Bluetooth references from the Linux device tree. ([Toradex Community][3])

---

### Alternative: Move M7 console to UART1

If UART4 is unavailable, Zephyr and MCUXpresso applications can be modified to use another UART (for example UART1). The Zephyr documentation specifically mentions changing the console device from UART4 to UART1. ([Zephyr Project Documentation][2])

You would then:

1. Route UART1 to an available Verdin connector/header.
2. Disable Linux ownership of that UART.
3. Configure your M7 firmware to use UART1 for the debug console.

---

### Typical setup

Many developers end up using:

* **UART3** → Linux/U-Boot console (A53)
* **UART4** → M7 printf/debug console

with **two separate USB-UART adapters**, both operating at **1.8 V logic levels**. ([Toradex Documentation][1])

If you tell me:

1. whether you're using **Toradex BSP Linux**, **Torizon**, or **Yocto**,
2. whether your module has **Wi-Fi/Bluetooth**, and
3. whether the M7 firmware is **MCUXpresso SDK** or **Zephyr**,

I can show the exact device-tree and firmware changes needed to get simultaneous A53 and M7 consoles working.

[1]: https://docs.toradex.com/113122-mallow-carrier-board-datasheet.pdf?utm_source=chatgpt.com "Mallow Carrier Board"
[2]: https://docs.zephyrproject.org/latest/boards/toradex/verdin_imx8mp/doc/index.html?utm_source=chatgpt.com "Verdin iMX8M Plus SoM — Zephyr Project Documentation"
[3]: https://community.toradex.com/t/cortex-m-jtag-debugging-verdin-mallow/30168?utm_source=chatgpt.com "Cortex-M JTAG Debugging (Verdin/Mallow) - Technical Support - Toradex Community"

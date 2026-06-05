## Wrong - TI
yocto-workdir/layers/meta-ti/meta-ti-bsp/recipes-bsp/zephyr-fw/zephyr-openamp-rsc-table-fw.bb
SUMMARY = "Precompiled Zephyr OpenAMP example firmware for TI K3 devices"

find . -name zephyr_openamp_rsc_table.elf
-> not found

## NXP

yocto-workdir/layers/meta-freescale/recipes-fsl/mcore-demos/imx-m7-demos_2.16.000.bb.

I’m locating the OpenAMP firmware recipes that actually match `verdin-imx8mp`, then I’ll trace which one provides a runnable Zephyr-style remoteproc example for this board.

Read [](file:///home/octoprobe/work_beampilot/experiment_torizon_openamp)

Searched for files matching `experiment_torizon_openamp` · `**/*openamp*.bb*`, no matches

Searched for files matching `experiment_torizon_openamp` · `**/*zephyr*.bb*`, no matches

Read memory

The direct file search missed the deep Yocto tree, so I’m switching to `rg` in the workspace to find the actual BSP recipe that targets `imx8mp` and OpenAMP/remoteproc firmware.

Ran terminal command:  rg -n --glob '*.bb' --glob '*.bbappend' 'openamp|remoteproc|rpmsg|m4|cm7|zephyr' yocto-workdir/layers | head -n 300

Ran terminal command:  rg -n '^(MACHINE|DISTRO|IMAGE) ?=' yocto-workdir/build-torizon/conf/*.conf yocto-workdir/build-torizon/conf/*/*.conf

I found a broad candidate set; the next step is narrowing that to recipes that are both present in your layers and named for NXP `imx8mp` or Cortex-M firmware rather than TI K3.

Read [](file:///home/octoprobe/.vscode-server/data/User/workspaceStorage/28172d5fed45869310b55f78e3ca390d-1/GitHub.copilot-chat/chat-session-resources/93c8221a-2e03-43ae-816d-128708483005/call_EGUOJJdGwt1kMcoUidDM9kI8__vscode-1780651129501/content.txt#1-1), lines 1 to 260

The TI layer only gives K3 examples. I’m now checking the NXP/Freescale layers for the matching M7/OpenAMP firmware recipe family that fits `verdin-imx8mp`.

Ran terminal command:  rg -n --glob '*.bb' --glob '*.bbappend' 'imx8mp|verdin-imx8mp|openamp|remoteproc|rpmsg|m7|cm7|multicore|freertos|zephyr' yocto-workdir/layers/meta-freescale yocto-workdir/layers/meta-toradex-* yocto-workdir/layers/openembedded-core/meta yocto-workdir/layers/meta-openembedded | head -n 400

Ran terminal command:  find yocto-workdir/build-torizon/conf -maxdepth 2 -type f | sort

I have the relevant layer 

Created 3 todos

set now. Next I’m extracting the precise NXP candidate recipes and the active `MACHINE` so I can point you to the right `.bb` instead of another incompatible example.

Read [](file:///home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir/build-torizon/conf/local.conf)

Read [](file:///home/octoprobe/.vscode-server/data/User/workspaceStorage/28172d5fed45869310b55f78e3ca390d-1/GitHub.copilot-chat/chat-session-resources/93c8221a-2e03-43ae-816d-128708483005/call_279DJbboBPBOSPfhXUkN38lx__vscode-1780651129504/content.txt#1-1), lines 1 to 220

Read [](file:///home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir/build-torizon/conf/auto.conf)

The build is definitely `MACHINE ?= "verdin-imx8mp"`. I’m now narrowing to the NXP recipe names that deploy Cortex-M firmware for `imx8mp`, because that is the layer family your board can actually use.

Ran terminal command:  rg -n --glob '*.bb' --glob '*.bbappend' 'imx.*firmware|firmware.*imx|cm7|m7|remoteproc|openamp|rpmsg|multicore' yocto-workdir/layers/meta-freescale yocto-workdir/layers/meta-toradex-nxp yocto-workdir/layers/meta-toradex-bsp-common yocto-workdir/layers/meta-toradex-demos | head -n 400

Ran terminal command:  find yocto-workdir/layers -path '*recipes-*' \( -name '*imx*firmware*.bb' -o -name '*firmware-imx*.bb' -o -name '*cm7*.bb' -o -name '*m7*.bb' -o -name '*openamp*.bb' -o -name '*rpmsg*.bb' -o -name '*remoteproc*.bb' -o -name '*multicore*.bb' \) | sort | head -n 300

I found the likely match: `imx-m7-demos`. I’m reading that recipe and nearby metadata now to verify it actually provides OpenAMP/RPMsg demo firmware for `imx8mp`.

Ran terminal command:  rg -n 'imx-m7-demos|mcore-demos|rpmsg|openamp' yocto-workdir/layers/meta-freescale yocto-workdir/layers/meta-toradex-* yocto-workdir/build-torizon/tmp/work yocto-workdir/build-torizon/tmp/deploy -g '*' | head -n 300

Read [](file:///home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir/layers/meta-freescale/recipes-fsl/mcore-demos/imx-m7-demos_24.12.00.bb)

Read [](file:///home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir/layers/meta-freescale/recipes-fsl/mcore-demos/imx-m7-demos_2.16.000.bb)

Starting: *Verify compatibility with verdin-imx8mp* (3/4)

The candidate recipe is explicitly compatible with `mx8mp-nxp-bsp`. I’m checking the Toradex machine configuration now to confirm `verdin-imx8mp` inherits that override and to inspect what firmware files the recipe actually deploys.

Ran terminal command:  rg -n 'mx8mp-nxp-bsp|MACHINEOVERRIDES|verdin-imx8mp' yocto-workdir/layers/meta-toradex-* yocto-workdir/layers/meta-freescale yocto-workdir/build-torizon/conf | head -n 200

Searched for files matching `experiment_torizon_openamp` · `yocto-workdir/layers/**/*verdin-imx8mp*.conf`, no matches

Read [](file:///home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir/layers/meta-freescale/recipes-fsl/mcore-demos/imx-mcore-demos.inc)

I confirmed the recipe installs firmware into firmware and is designed for `imx8mp` M7 demos. One more check remains: whether Toradex’s `verdin-imx8mp` machine inherits the `mx8mp-nxp-bsp` override that makes this recipe selectable.

Read [](file:///home/octoprobe/.vscode-server/data/User/workspaceStorage/28172d5fed45869310b55f78e3ca390d-1/GitHub.copilot-chat/chat-session-resources/93c8221a-2e03-43ae-816d-128708483005/call_ke1e2yvdlOPDoZrYAPECIumo__vscode-1780651129516/content.txt#1-1), lines 1 to 220

I have the override chain. I’m reading the exact extender lines for i.MX8MP so I can confirm `verdin-imx8mp` inherits `mx8mp-nxp-bsp`, which is the key compatibility gate on the recipe.

Read [](file:///home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir/layers/meta-freescale/conf/machine/include/imx-base.inc#190-190), lines 190 to 240

The Freescale side is clear: any machine with `mx8mp` plus `use-nxp-bsp` gets the `mx8mp-nxp-bsp` compatibility override. I’m pulling the Toradex machine include now to confirm `verdin-imx8mp` lands in that path.

Ran terminal command:  find yocto-workdir/layers/meta-toradex-* -path '*machine*' -name 'verdin-imx8mp.conf' -o -name '*imx8mp*.inc' | sort

Ran terminal command:  bitbake-layers show-recipes imx-m7-demos 2>/dev/null | head -n 50

Updated todo list

`imx-m7-demos` may simply need the Yocto environment sourced before BitBake can resolve it. I’m checking the machine file and then asking BitBake again from inside the configured build environment.

Ran terminal command:  cd /home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir && . ./setup-environment build-torizon >/dev/null && bitbake-layers show-recipes imx-m7-demos | head -n 50

Read [](file:///home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir/layers/meta-toradex-nxp/conf/machine/verdin-imx8mp.conf)

The machine file confirms the match: `verdin-imx8mp` sets `mx8mp` and `IMX_DEFAULT_BSP = "nxp"`, so recipes gated on `mx8mp-nxp-bsp` are valid here. I’m doing one final BitBake/source check and a content search for RPMsg/OpenAMP demo naming.

Ran terminal command:  cd /home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir && . ./setup-environment build-torizon >/dev/null && bitbake -e imx-m7-demos | rg '^(PN|PV|COMPATIBLE_MACHINE|SRC_URI|S=|WORKDIR=)' | sed -n '1,40p'

Ran terminal command:  rg -n 'rpmsg_lite|str_echo|pingpong|tty_rpmsg|openamp' yocto-workdir/layers/meta-freescale yocto-workdir/layers/meta-toradex-* yocto-workdir/build-torizon/tmp -g '*' | head -n 200

The metadata path is settled; the remaining uncertainty is just demo naming. I’m rerunning that search with absolute paths so I can tell you whether the NXP recipe carries the expected RPMsg/OpenAMP examples or is only a generic demo bundle.

Ran terminal command:  rg -n 'rpmsg_lite|str_echo|pingpong|tty_rpmsg|openamp' /home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir/layers/meta-freescale /home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir/layers/meta-toradex-* /home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir/build-torizon/tmp -g '*' | head -n 200

Ran terminal command:  cd /home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir && . ./setup-environment build-torizon >/dev/null && bitbake -e imx-m7-demos > /tmp/imx-m7-demos.env && rg '^(PN|PV|COMPATIBLE_MACHINE|SRC_URI|S=|WORKDIR=)' /tmp/imx-m7-demos.env | sed -n '1,40p'

I already have enough to identify the right recipe family. I’m doing one last file-level search in the Yocto caches to see whether the bundled NXP demo names are visible locally for `imx8mp-m7`.

Ran terminal command:  find /home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir -iname '*imx8mp*m7*demo*' -o -iname '*mcore*demos*' | head -n 100

Ran terminal command:  find /home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir/build-torizon/tmp/deploy -path '*mcore-demos*' -o -iname '*.elf' | head -n 200

Starting: *Inspect imx-m7-demos recipe for OpenAMP* (4/4)

I’m avoiding the terminal pager noise now and using direct file indexing to see whether any M-core demo payloads or built firmware files already exist in the workspace.

Searched for files matching `experiment_torizon_openamp` · `yocto-workdir/**/*mcore*`, no matches

Searched for files matching `experiment_torizon_openamp` · `yocto-workdir/**/*.elf`, no matches

Searched for files matching `experiment_torizon_openamp` · `yocto-workdir/**/imx-m7-demos*`, no matches

For Verdin iMX8MP, the matching existing recipe is yocto-workdir/layers/meta-freescale/recipes-fsl/mcore-demos/imx-m7-demos_2.16.000.bb. That is the one you want, not the TI Zephyr recipe.

Why this is the match:
verdin-imx8mp.conf sets MACHINEOVERRIDES with mx8mp and verdin-imx8mp.conf sets IMX_DEFAULT_BSP = "nxp".
imx-base.inc expands that to mx8mp-nxp-bsp.
imx-m7-demos_2.16.000.bb declares COMPATIBLE_MACHINE including mx8mp-nxp-bsp.
imx-mcore-demos.inc maps mx8mp-nxp-bsp to SOC = imx8mp, imx-mcore-demos.inc maps it to MCORE_TYPE = m7, and imx-mcore-demos.inc installs the resulting firmware into /lib/firmware.

One important caveat: this is an NXP M7 demo bundle, not a Zephyr-specific recipe. The newer imx-m7-demos_24.12.00.bb is only for mx95, so for your board the usable one is the 2.16.000 recipe.

If you want, I can do one of these next:
1. Find the exact firmware filename inside the imx-m7-demos payload that corresponds to the RPMsg/OpenAMP echo example for iMX8MP.
2. Show how to add imx-m7-demos to your image or install it with BitBake.
3. Create a custom bb recipe for a real Zephyr-built OpenAMP ELF if you specifically need Zephyr rather than the NXP demo bundle.

Completed: *Inspect imx-m7-demos recipe for OpenAMP* (4/4)


##################################################################

For iMX8MP, the RPMsg/OpenAMP echo example is NXP M7 demo:

rpmsg_lite_str_echo_rtos (remote CM7 side)
Channel name on Linux side: rpmsg-openamp-demo-channel, confirmed in imx_rpmsg_tty.c:214 and imx_rpmsg_pingpong.c:72
Matching iMX8MP RPMsg DT is present at:

imx8mp-evk-rpmsg.dts:114
Upstream NXP firmware filenames for this board/example are:

imx8mp_m7_DDR_rpmsg_lite_str_echo_rtos.bin
imx8mp_m7_DDR_rpmsg_lite_pingpong_rtos_linux_remote.bin
And the recipe family to get these M7 demos is:

imx-m7-demos_2.16.000.bb
Quick next step to verify locally:

```sh
cd /home/octoprobe/work_beampilot/experiment_torizon_openamp/yocto-workdir
MACHINE=verdin-imx8mp DISTRO=torizon source ./setup-environment build-torizon
bitbake imx-m7-demos
find build-torizon/tmp -type f | grep -E 'imx8mp_m7_DDR_(rpmsg_lite_str_echo_rtos|rpmsg_lite_pingpong_rtos_linux_remote)\.bin'
```

If you want, I can now give you the exact remoteproc load/start commands for these binaries on Verdin iMX8MP.

##################################################################

I’ll give you the concrete on-target command sequence to load the iMX8MP RPMsg/OpenAMP echo firmware and verify traffic over RPMsg TTY.

1. Copy firmware to the target (Torizon Linux side) into /lib/firmware  
Use the M7 echo binary name:
- imx8mp_m7_DDR_rpmsg_lite_str_echo_rtos.bin

2. Run this on the target to stop, load, and start remoteproc

~~~bash
set -e

# Pick first remoteproc (adjust if your CM7 is a different index)
RP=/sys/class/remoteproc/remoteproc0

# Inspect current state
cat $RP/name || true
cat $RP/state || true

# Stop if running
echo stop > $RP/state 2>/dev/null || true

# Select firmware and start
echo imx8mp_m7_DDR_rpmsg_lite_str_echo_rtos.bin > $RP/firmware
echo start > $RP/state

# Verify
cat $RP/state
dmesg | tail -n 80
~~~

3. Check RPMsg TTY endpoint and send test strings

~~~bash
# Load tty bridge module if not already loaded
modprobe imx_rpmsg_tty 2>/dev/null || true

# Find RPMsg tty node
ls -l /dev/ttyRPMSG* || true

# Example: choose first RPMsg tty
TTY=$(ls /dev/ttyRPMSG* 2>/dev/null | head -n1)
echo "Using $TTY"

# Read in one terminal:
cat "$TTY"

# Write in another terminal:
echo "hello from A53" > "$TTY"
echo "second line" > "$TTY"
~~~

4. If remoteproc index is not 0, discover it first

~~~bash
for d in /sys/class/remoteproc/remoteproc*; do
  echo "---- $d ----"
  cat $d/name 2>/dev/null || true
  cat $d/state 2>/dev/null || true
done
~~~

Notes:
- Your kernel already exposes the OpenAMP demo RPMsg channel support (rpmsg-openamp-demo-channel), so this is the correct Linux side path.
- If firmware start fails, share the last 80 lines of dmesg and I can pinpoint the exact mismatch (resource table, memory carveout, or firmware name).

1. If you want, I can now give you the host-side BitBake command sequence to ensure this firmware is built and installed into the image automatically.
2. I can also prepare a short section for your README with this exact runbook.

Completed: *Extract firmware filename from DTS files* (4/4)


##################################################################

$ sudo modprobe rpmsg_char
$ sudo modprobe rpmsg_ctrl
$ sudo lsmod
Module                  Size  Used by
rpmsg_ctrl             12288  0
rpmsg_char             20480  1 rpmsg_ctrl

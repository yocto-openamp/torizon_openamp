# README 0: Environment Setup

This document prepares a Linux host for Zephyr development targeting the Cortex-M7 on the Toradex Verdin i.MX 8M Plus.

This document covers only environment setup:

- Host packages
- Python virtual environment
- `west`
- Zephyr SDK prerequisites
- Optional debug tools
- Board-specific constraints that matter before the first build

Source checkout and the actual build steps belong in `README_1_get_sources-and-build.md`.
Running the firmware on the module belongs in `README_2_run_examples.md`.

## Scope and Assumptions

Hardware:

- Toradex Verdin i.MX 8M Plus
- Toradex Mallow carrier board

Software target:

- Linux on the A53 cores
- Zephyr on the Cortex-M7 core

Important Zephyr board targets for this SoM:

- `verdin_imx8mp/mimx8ml8/m7`
- `verdin_imx8mp/mimx8ml8/m7/ddr`

The `m7` target uses ITCM.
The `m7/ddr` target uses DDR.

| Feature             | ITCM (Instruction Tightly Coupled Memory)          | DDR (External DRAM)                            |
| ------------------- | -------------------------------------------------- | ---------------------------------------------- |
| Location            | On-chip memory, directly attached to CPU           | External system memory                         |
| Speed               | Very fast, deterministic latency                   | Slower, higher latency                         |
| Size                | Usually small (tens or hundreds of KB)             | Much larger (MBs to GBs)                       |
| Cache effects       | Often uncached/direct access                       | May be cached                                  |
| Typical use         | Critical code, interrupt handlers, real-time tasks | Large buffers, shared memory, application data |
| OpenAMP suitability | Usually not ideal for shared memory                | Common choice for RPMsg/OpenAMP shared memory  |


Lets start with ITCM according to the working examples `imx8mp_m7_TCM_hello_world.elf`.

## 1. Host Operating System

Use a recent Debian or Ubuntu host.

The Zephyr getting started guide currently documents Ubuntu 24.04 LTS and later, but the package list below also works well on recent Debian-based systems.

Update the package index first:

```bash
sudo apt update
```

## 2. Install Host Dependencies

Install the core Zephyr build dependencies:

```bash
sudo apt install --no-install-recommends \
	git cmake ninja-build gperf ccache dfu-util device-tree-compiler \
	wget xz-utils file make gcc gcc-multilib g++-multilib \
	python3-dev python3-venv python3-pip python3-tk \
	libsdl2-dev libmagic1
```

Notes:

- On `aarch64` Linux hosts, `gcc-multilib` and `g++-multilib` may be unavailable. If that happens, omit those two packages.
- `device-tree-compiler` is required by normal Zephyr builds.
- `ninja-build` and `cmake` are required for essentially all Zephyr sample builds.

Verify the main tools:

```bash
cmake --version
ninja --version
python3 --version
dtc --version
git --version
```

## 3. Create a Dedicated Zephyr Workspace

Keep the Zephyr source tree separate from this repository.

Example:

```bash
mkdir -p ~/zephyrproject
python3 -m venv ~/zephyrproject/.venv
source ~/zephyrproject/.venv/bin/activate
python -m pip install --upgrade pip
pip install west
```

From this point on, activate the virtual environment in every shell you use for Zephyr work:

```bash
source ~/zephyrproject/.venv/bin/activate
```

Quick verification:

```bash
west --version
python --version
```

## 4. Prepare for Zephyr SDK Installation

The compiler toolchain should come from the Zephyr SDK.

There are two workable approaches:

1. Install the SDK later from inside the Zephyr workspace with `west sdk install`.
2. Install the SDK manually from the Zephyr SDK release archive.

For this document set, prefer option 1, because it stays close to current upstream Zephyr setup.

That means the SDK installation itself will happen after the source checkout in `README_1_get_sources-and-build.md`.

Still, it is useful to understand the two environment variables that matter if the SDK is installed in a non-default location:

```bash
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_SDK_INSTALL_DIR=$HOME/zephyr-sdk-<version>
```

Do not set these yet unless you actually install the SDK manually outside the default path.

## 5. Optional Debug and Inspection Tools

For build-only work they are not required, but they help a lot once firmware needs to be loaded or debugged:

```bash
sudo apt install --no-install-recommends minicom picocom gdb-multiarch
```

What they are useful for:

- `minicom` or `picocom`: serial console for M7 log output
- `gdb-multiarch`: low-level inspection and debug sessions

If you plan to use a J-Link probe later, install SEGGER tools separately from SEGGER.

## 6. Board-Specific Constraints to Know Up Front

Before building anything, keep these constraints in mind:

### The M7 is not standalone-booting on this board

The Verdin i.MX 8M Plus does not provide dedicated flash for the M7 Zephyr image.
The A53 side has to load and start the Cortex-M7 firmware.

In practice that means:

- build on the host
- copy the firmware to the Linux side or load it from U-Boot
- start the M7 from the A53 side

### Choose ITCM vs DDR intentionally

Zephyr exposes two relevant board targets:

- `verdin_imx8mp/mimx8ml8/m7`
- `verdin_imx8mp/mimx8ml8/m7/ddr`

For the OpenAMP and RPMsg samples listed in [agent.md](agent.md), expect the DDR variant to be the more relevant target.

### UART4 is the default M7 console

Upstream Zephyr configures UART4 as the default console on this board.

That matters because Wi-Fi/Bluetooth variants can also use UART4.
If your module uses Wi-Fi/Bluetooth and you need that functionality at the same time, you may need to move the Zephyr console to another UART later.

### Linux must not fight with the M7 for peripherals

Toradex and Zephyr both call this out: peripherals assigned to the M7 should not be claimed by Linux at the same time.

This is especially important later when testing:

- UARTs
- shared memory / RPMsg path
- GPIOs used directly by the M7

## 7. Recommended Working Convention

Use this repository only for notes, Yocto integration, and target-side experiments.
Keep the upstream Zephyr checkout in a separate directory.

A practical split is:

- this repository: experiment notes and deployment flow
- `~/zephyrproject`: upstream Zephyr workspace

This avoids mixing Yocto-generated content with the Zephyr source tree.

## 8. Ready-State Checklist

You are ready for `README_1_get_sources-and-build.md` when all of the following work:

```bash
source ~/zephyrproject/.venv/bin/activate
west --version
cmake --version
ninja --version
python --version
dtc --version
```

And you know which build target you want to start with:

- `verdin_imx8mp/mimx8ml8/m7`
- `verdin_imx8mp/mimx8ml8/m7/ddr`

## References

- Zephyr getting started guide: https://docs.zephyrproject.org/latest/develop/getting_started/index.html
- Zephyr board documentation for Verdin i.MX 8M Plus: https://docs.zephyrproject.org/latest/boards/toradex/verdin_imx8mp/doc/index.html
- Toradex HMP overview: https://developer.toradex.com/software/hmp/hmp-overview
- Toradex NXP HMP SDK/toolchain page: https://developer.toradex.com/software/hmp/hmp-nxp/setting-up-sdk-toolchain-nxp

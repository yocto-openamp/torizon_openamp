I’m checking the current `remoteproc` state and any existing notes first so I can anchor the diagnosis on the live sysfs state before suggesting recovery steps.

Read [](file:///sys/class/remoteproc/remoteproc0)

Read memory

I found `remoteproc0` still present, so the next check is whether the processor stayed `offline`, whether the firmware name latched, and whether the firmware file actually exists where the kernel loader expects it.

Ran terminal command:  set -u
for f in /sys/class/remoteproc/remoteproc0/name /sys/class/remoteproc/remoteproc0/state /sys/class/remoteproc/remoteproc0/firmware /sys/class/remoteproc/remoteproc0/recovery; do
  printf '== %s ==\n' "$f"
  cat "$f" 2>&1 || true
  printf '\n'
done
printf '== firmware candidates ==\n'
find /lib/firmware /usr/lib/firmware -maxdepth 2 -type f 2>/dev/null | grep 'imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote\.elf' || true

`remoteproc0` is still `offline` and the firmware attribute never latched your ELF name, so I’m narrowing this to either a privileged write problem or a hang inside the write path before the attribute is updated.

Ran terminal command:  id
printf '\n== permissions ==\n'
ls -l /sys/class/remoteproc/remoteproc0/firmware /sys/class/remoteproc/remoteproc0/state
printf '\n== exact firmware file ==\n'
find /lib/firmware /usr/lib/firmware -type f 2>/dev/null | grep -F '/imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf' || true
printf '\n== recent dmesg remoteproc ==\n'
sudo -n dmesg | grep -iE 'remoteproc|imx-rproc|rpmsg|m7|mu|resource table' | tail -n 80

The last probe likely stalled on `sudo`, so I’m repeating it without privilege escalation to separate shell-access issues from the kernel behavior itself.

Ran terminal command:  whoami || true
id || true
printf '\n== permissions ==\n'
ls -l /sys/class/remoteproc/remoteproc0/firmware /sys/class/remoteproc/remoteproc0/state || true
printf '\n== exact firmware file ==\n'
find /lib/firmware /usr/lib/firmware -type f 2>/dev/null | grep -F '/imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf' || true
printf '\n== dmesg readable ==\n'
dmesg 2>&1 | tail -n 5 || true

Starting: *Filter recent kernel log lines for remoteproc messages* (4/4)

The live state is consistent: `remoteproc0` exists, is `offline`, and the firmware attribute still shows its default placeholder. The remaining useful checks are the exact file path and whether a privileged sysfs write hangs even before `state=start`.

I’m testing the exact privileged path now: first whether `sudo -n` is available, then the firmware write using `tee`, which is the correct way to write to sysfs under sudo.

Ran terminal command:  printf '== sudo -n ==\n'
sudo -n true
printf 'sudo_rc=%s\n' "$?"
printf '\n== firmware file ==\n'
find /lib/firmware /usr/lib/firmware -type f 2>/dev/null | grep -F 'imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf' || true
Completed with input:  printf '== sudo -n ==\n'
sudo -n true
printf 'sudo_rc=%s\n' "$?"
printf '\n== firmware file ==\n'
find /lib/firmware /usr/lib/firmware -type f 2>/dev/null | grep -F 'imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf' || true

`sudo` needs an interactive password here, so I can’t reproduce the privileged write directly from this session. I’m still checking whether the ELF is in the firmware search path, because if it is not, the write should fail quickly rather than freeze.

Ran terminal command:  find /lib/firmware /usr/lib/firmware -type f 2>/dev/null | grep -F 'imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf' || true

I’m running the same write pattern unprivileged to see whether the shell behavior itself matches what you saw or whether your original reproduction must have been from a root context.

Ran terminal command:  timeout 5 sh -c 'echo imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf > /sys/class/remoteproc/remoteproc0/firmware'; printf 'firmware_write_rc=%s\n' "$?"
timeout 5 sh -c 'echo start > /sys/class/remoteproc/remoteproc0/state'; printf 'start_write_rc=%s\n' "$?"
printf 'state='; cat /sys/class/remoteproc/remoteproc0/state

The unprivileged `state` write fails normally with `Permission denied`; I’m isolating the `firmware` write now because that’s the one that may actually be blocking in your case.

Ran terminal command:  timeout 5 sh -c 'echo imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf > /sys/class/remoteproc/remoteproc0/firmware'
printf 'firmware_write_rc=%s\n' "$?"
printf 'firmware='; cat /sys/class/remoteproc/remoteproc0/firmware

The isolated `firmware` write behaved abnormally even without root, which points away from a simple `Permission denied` path and toward the kernel blocking in the sysfs handler. I’m checking the node metadata and a non-writing read path next.

Ran terminal command:  ls -l /sys/class/remoteproc/remoteproc0/firmware
printf 'read='; cat /sys/class/remoteproc/remoteproc0/firmware
printf '\nstate='; cat /sys/class/remoteproc/remoteproc0/state

I’ve got enough to say this is not a normal userspace permission failure. The remaining discriminator is the platform/kernel version, because there are board-specific i.MX8MP remoteproc regressions in some BSPs.

Ran terminal command:  uname -a
printf '\n== os-release ==\n'
cat /etc/os-release
printf '\n== model ==\n'
cat /sys/firmware/devicetree/base/model 2>/dev/null | tr '\0' '\n'
printf '\n== compatible ==\n'
tr '\0' '\n' < /sys/firmware/devicetree/base/compatible 2>/dev/null | head -n 20

Added 1 todo

The shell in this environment is returning partial output unpredictably, so I’m switching to one-line probes to avoid losing the key version strings.

Ran terminal command:  uname -r

Ran terminal command:  cat /sys/firmware/devicetree/base/model 2>/dev/null | tr '\0' '\n'

Ran terminal command:  tr '\0' '\n' < /sys/firmware/devicetree/base/compatible 2>/dev/null | head -n 10

This is a Verdin iMX8MP on a Toradex 6.6.138-7.6.1-devel kernel, which is enough to focus on the Toradex/NXP remoteproc path rather than generic Linux behavior. I’m checking the backing DT node so I can tell whether `remoteproc0` is actually the M7 instance you intend to start.

Ran terminal command:  readlink -f /sys/class/remoteproc/remoteproc0/device
readlink -f /sys/class/remoteproc/remoteproc0/device/of_node
basename "$(readlink -f /sys/class/remoteproc/remoteproc0/device/of_node)"
ls /sys/class/remoteproc/remoteproc0/device 2>/dev/null | head

`remoteproc0` is the CM7 node, so the target is correct. The next useful check is whether the device tree advertises the expected memory regions and mailboxes for RPMsg startup.

Ran terminal command:  for f in status firmware-name memory-region mboxes mbox-names rsc-da; do
  p="/sys/firmware/devicetree/base/imx8mp-cm7/$f"
  if [ -e "$p" ]; then
    printf '== %s ==\n' "$f"
    if [ "$f" = memory-region ] || [ "$f" = mboxes ]; then
      od -An -tx4 "$p" 2>/dev/null || true
    else
      tr '\0' '\n' < "$p" 2>/dev/null || cat "$p" 2>/dev/null || true
    fi
    printf '\n'
  fi
done

The CM7 node is wired for RPMsg mailboxes and multiple reserved-memory regions, so this is not a simple “M7 disabled in DT” case. I’m resolving those memory regions now, because a bad carveout or resource-table address is a common way to hard-lock this path.

Ran terminal command:  for n in /sys/firmware/devicetree/base/reserved-memory/*; do
  [ -d "$n" ] || continue
  if [ -f "$n/phandle" ]; then
    ph=$(od -An -tx4 "$n/phandle" | tr -d ' \n')
    reg=$(od -An -tx4 "$n/reg" 2>/dev/null | tr -s ' ' | sed 's/^ //')
    printf '%s phandle=%s reg=%s\n' "$(basename "$n")" "$ph" "$reg"
  fi
done | grep -E '35010000|36010000|37010000|38010000|39010000|vdev|m7|rsc|vring|rpmsg'

The carveouts are present and named as expected for RPMsg, but the raw values coming back through sysfs need one more decode pass to confirm the resource-table address cleanly.

Ran terminal command:  printf 'rsc-da raw: '
od -An -tx4 /sys/firmware/devicetree/base/imx8mp-cm7/rsc-da 2>/dev/null || true
printf 'firmware attr: '
cat /sys/class/remoteproc/remoteproc0/firmware
printf 'state attr: '
cat /sys/class/remoteproc/remoteproc0/state

Starting: *Check firmware file presence and permissions* (5/6)

The fact that the hang appears on the `firmware` write matters: on upstream remoteproc that path should only update a string, not boot the M7. I’m checking whether this kernel ships the matching source or headers so I can tell if Toradex carried a different handler here.

Ran terminal command:  krel=$(uname -r)
for d in /usr/src /lib/modules/$krel/source /lib/modules/$krel/build; do
  [ -e "$d" ] && echo "$d"
done
if [ -r "/lib/modules/$krel/build/drivers/remoteproc/remoteproc_sysfs.c" ]; then
  sed -n '1,220p' "/lib/modules/$krel/build/drivers/remoteproc/remoteproc_sysfs.c"
fi
Completed with input:  krel=$(uname -r)
for d in /usr/src /lib/modules/$krel/source /lib/modules/$krel/build; do
  [ -e "$d" ] && echo "$d"
done
if [ -r "/lib/modules/$krel/build/drivers/remoteproc/remoteproc_sysfs.c" ]; then
  sed -n '1,220p' "/lib/modules/$krel/build/drivers/remoteproc/remoteproc_sysfs.c"
fi

Local kernel sources are not obviously available from the module build tree, so I’m falling back to package-level clues and then I’ll consolidate the diagnosis and the exact recovery/debug steps.

Ran terminal command:  ls /usr/src | head -n 40
printf '\n== remoteproc modules ==\n'
find /lib/modules/$(uname -r) -type f | grep -E 'remoteproc|imx_rproc|imx.*rpmsg' | head -n 40

What I could verify on the board:

- remoteproc0 is the CM7 instance on the Verdin i.MX8MP.
- Its state is still offline.
- The firmware attribute still shows the default placeholder, not your ELF name.
- The ELF exists in the firmware search path.
- The CM7 device-tree node has the expected RPMsg mailboxes and reserved-memory carveouts.

The important part is this: if the board really freezes on the firmware write itself, that is not normal remoteproc behavior. On the normal Linux remoteproc path, writing the firmware name should only update a string. The ELF is not parsed and the M7 is not started until you write start to the state node. So a freeze during the firmware write points much more strongly to a BSP/kernel bug or a bad remoteproc sysfs path on this Toradex 6.6.138-7.6.1-devel build than to a problem in the ELF itself.

There is also one correctness issue in the command form: if you are not already root, use sudo tee, not sudo echo with shell redirection. The safe form is:

sudo sh -c 'printf "%s" imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf > /sys/class/remoteproc/remoteproc0/firmware'
cat /sys/class/remoteproc/remoteproc0/firmware
sudo sh -c 'printf "%s" start > /sys/class/remoteproc/remoteproc0/state'
cat /sys/class/remoteproc/remoteproc0/state

The key discriminator is the middle cat. If the board freezes before that cat returns the ELF name, the problem is in the kernel remoteproc firmware-store path, not in loading or starting the M7 firmware.

Without UART, the best next diagnostics are:

1. Try the same sequence on a stable Toradex kernel, not the current devel build.
This matters because you are on 7.6.1-devel, and a remoteproc regression there is more plausible than an ELF-specific failure during the firmware-name write.

2. Enable netconsole before reproducing.
If the kernel hard-locks before dmesg flushes locally, netconsole is the best replacement for UART.

3. Trace remoteproc just before reproducing.
Run:
mount -t debugfs none /sys/kernel/debug
grep remoteproc /sys/kernel/debug/tracing/available_events
echo 1 > /sys/kernel/debug/tracing/events/remoteproc/enable
cat /sys/kernel/debug/tracing/trace_pipe
Then reproduce in a second session.

4. Check whether the freeze is only with your chosen ELF name.
As a control, try writing a short dummy name to the firmware node, then read the attribute back. If that also freezes, the handler itself is broken.

My working conclusion is: this does not look like a bad rpmsg_lite image yet, because your hang appears to happen before the start path. It looks like a kernel/BSP issue in the remoteproc sysfs handler on this Toradex devel kernel.

If you want, I can give you one exact netconsole setup for a second Linux host, or a minimal step-by-step matrix to prove whether this is a devel-kernel regression versus a CM7 firmware issue.

Completed: *Check firmware file presence and permissions* (5/6)

=============

The clarification changes the fault boundary: the firmware name write is fine, so I’m checking the ELF layout itself now to see whether `start` is booting the M7 into an unsafe memory map or a malformed resource table.

Ran terminal command:  fw=/lib/firmware/imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf
printf '== file ==\n'
ls -l "$fw"
printf '\n== file type ==\n'
file "$fw" || true
printf '\n== sections of interest ==\n'
readelf -S "$fw" 2>/dev/null | grep -E 'resource|text|data|bss|interrupt|vector|boot' || true
printf '\n== program headers ==\n'
readelf -l "$fw" 2>/dev/null || true
printf '\n== symbols of interest ==\n'
nm -n "$fw" 2>/dev/null | grep -E 'resource|rpmsg|vector|Reset|boot|start' | head -n 60 || true

The root shell is available here, so I can inspect the M7 image directly. I’m pulling the ELF header and load map next; that should tell us whether `start` is jumping into TCM or into an address range that can hang the SoC.

Ran terminal command:  fw=/lib/firmware/imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf
readelf -h "$fw"
Completed with input:  fw=/lib/firmware/imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf
readelf -h "$fw"

Ran terminal command:  fw=/lib/firmware/imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf
objdump -h "$fw"
Completed with input:  fw=/lib/firmware/imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf
objdump -h "$fw"

Ran terminal command:  fw=/lib/firmware/imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf
objdump -x "$fw" | sed -n '/Program Header:/,/Sections:/p'

The board image does not ship `readelf` or `objdump`, so I’m switching to lightweight probes that are already present: `strings`, `od`, and current kernel state.

Ran terminal command:  command -v llvm-readelf || true
command -v arm-none-eabi-readelf || true
command -v eu-readelf || true
command -v strings || true
command -v hexdump || true
command -v od || true
printf '\n== remoteproc state ==\n'
cat /sys/class/remoteproc/remoteproc0/state
printf '\n== firmware ==\n'
cat /sys/class/remoteproc/remoteproc0/firmware
printf '\n== recent remoteproc dmesg ==\n'
dmesg | grep -iE 'remoteproc|imx-rproc|rpmsg|m7|mu|resource' | tail -n 80

The shell is flaky with multi-step probes, but the key boundary is unchanged: the firmware attribute is accepted, and the lockup happens only when the kernel releases reset and the M7 begins executing. That shifts the likely cause from sysfs to the firmware or platform integration at boot.

Ran terminal command:  strings /lib/firmware/imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.elf | grep -iE 'resource|rsc|vring|vdev|rpmsg|MIMX8ML8|MIMX8MP|TCM|DDR' | head -n 80

Ran terminal command:  dmesg | tail -n 120

Ran terminal command:  cat /proc/iomem | grep -iE 'rsc|vring|vdev|m7|remoteproc|5540|5500|80000000'

The firmware image does contain RPMsg and `.resource_table` content, and the kernel log has no earlier remoteproc errors. I’m checking remoteproc debugfs next; if it exposes the parsed firmware state, that will narrow this to either a boot-time M7 crash or a host-side remoteproc setup issue.

Ran terminal command:  mount -t debugfs none /sys/kernel/debug 2>/dev/null || true
printf '== debugfs remoteproc ==\n'
find /sys/kernel/debug -maxdepth 3 -path '*/remoteproc*' -o -path '*/imx_rproc*' 2>/dev/null | sort
printf '\n== class attrs ==\n'
for f in /sys/class/remoteproc/remoteproc0/*; do [ -f "$f" ] && printf '%s=' "$f" && cat "$f" 2>/dev/null && printf '\n'; done

Created 4 todos

That clarification changes the diagnosis materially.

Because the firmware name write succeeds and the attribute reads back correctly, the host-side sysfs path is fine. The freeze happens only on:

```sh
echo start > /sys/class/remoteproc/remoteproc0/state
```

That means Linux is getting as far as attempting to boot the CM7, and the system hangs only once the M7 is released from reset and begins executing the ELF. In practice, that usually means the firmware is doing something unsafe very early, or the host and firmware disagree on memory/peripheral ownership.

What I verified on the board:

- `remoteproc0` is the CM7 instance.
- The firmware file exists in firmware.
- The ELF contains RPMsg and `.resource_table` related content.
- The CM7 device tree has RPMsg carveouts and mailboxes configured.
- There are no prior remoteproc errors in the kernel log before booting.

So the likely fault is now one of these, in order:

1. The M7 firmware is booting and touching a bad address immediately.
This is the most likely reason for a hard freeze with no `dmesg` output.

2. The firmware’s RPMsg resource table or shared-memory addresses do not match Linux’s reserved-memory layout.
On your board, Linux is configured for these RPMsg carveouts:
- vring0 at `0x55000000`
- vring1 at `0x55008000`
- resource table at `0x550ff000`
- vdev buffer at `0x55400000`

If the firmware was built with different addresses, the M7 can scribble over memory and hang the SoC right after `start`.

3. The CM7 firmware initializes or reconfigures a peripheral Linux already owns.
Common examples are clocks, MU, DDR-related init, UART, Ethernet, or pinmux.

4. The ELF is structurally loadable but wrong for this exact BSP.
For example, wrong linker script, wrong memory target, or a startup file that assumes a different memory map.

A few concrete points:

- The string `startup_MIMX8ML8_cm7.S.obj` inside the ELF is not automatically wrong. NXP uses `MIMX8ML8` naming for i.MX8M Plus SDK parts, so that alone is not the problem.
- Since the freeze is on `start`, I would not focus on sysfs anymore. I would focus on the CM7 firmware build configuration and its early startup code.

What to check in the M7 firmware source right now:

1. In `rsc_table.c`, verify the resource-table and RPMsg addresses match Linux exactly:
- `0x55000000`
- `0x55008000`
- `0x550ff000`
- `0x55400000`

2. In the linker script, verify all load/run addresses are valid for the `TCM` variant you are booting.

3. In board/system init, remove or disable anything that touches clocks, DDR setup, pinmux, or peripherals Linux is already using.

4. If this is an MCUXpresso example, compare it against the exact Toradex/NXP example known to work on Verdin iMX8MP Linux-remoteproc, not just any i.MX8MP rpmsg-lite example.

The fastest discriminator is this:

- Boot a known-good Toradex or NXP CM7 demo ELF for Verdin iMX8MP remoteproc.
- If that also freezes on `start`, suspect the Toradex `6.6.138-7.6.1-devel` kernel/BSP.
- If that works, your current ELF or its build configuration is the issue.

Without UART, the best next debug path is netconsole, because this kind of failure often happens too early for logs to reach persistent buffers. If you want, I can give you the exact netconsole commands for your host/target pair, or a short checklist to verify the resource-table values in your CM7 source before you rebuild.

Starting: *Test with stable Toradex kernel* (4/4)

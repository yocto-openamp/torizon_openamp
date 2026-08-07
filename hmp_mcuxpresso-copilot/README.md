# hmp_mcuxpresso-copilot

This directory is prepared for downloading and building an NXP RPMsg-Lite / MCUX-based sample for the i.MX 8M Plus M7 target.

## Directory layout

- sources/ : cloned source trees
  - sources/rpmsg-lite
  - sources/mcux-sdk
- build/ : build output
- downloads/ : download staging area
- docs/ : notes and build documentation
- scripts/ : helper scripts

## Bootstrap

Run:

```bash
cd hmp_mcuxpresso-copilot
bash run_0_bootstrap.sh
```

This will clone the public RPMsg-Lite and MCUX SDK repositories into the prepared structure.

## Run as root

```bash
cd hmp_mcuxpresso-copilot

mkdir -p /root/firmware
echo /root/firmware > /sys/module/firmware_class/parameters/path
cp build/mcux-example-minimal-cm7/rpmsg_lite_sample_MIMX8ML8_cm7.elf /root/firmware
echo stop > /sys/class/remoteproc/remoteproc0/state
echo rpmsg_lite_sample_MIMX8ML8_cm7.elf > /sys/class/remoteproc/remoteproc0/firmware
echo start > /sys/class/remoteproc/remoteproc0/state
```
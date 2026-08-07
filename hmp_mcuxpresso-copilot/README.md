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
bash scripts/bootstrap_rpmsg_lite.sh
```

This will clone the public RPMsg-Lite and MCUX SDK repositories into the prepared structure.

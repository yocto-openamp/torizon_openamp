# Connect to the yocto image

* https://developer.toradex.com/software/hmp/hmp-nxp/how-to-use-remoteproc/
* https://github.com/zephyrproject-rtos/zephyr/discussions/80011


Change password from `torizon` to `t`: `ssh torizon@verdin-imx8mp-08910183.local`

## Applications tested

See: recipes-images/images/torizon-docker.bbappend

`uvx --python 3.13.13 mpremote --help`

`docker run hello-world`

`openocd` v0.12.0+dev-00150-g91bd43134-dirty (2026-06-02-13:44)

`cmake`

Missing: gcc, jinja, g++

### VSCode

Add to `~/.ssh/config`:

```text
Host torzion@torizon@verdin-imx8mp-08910183.local
  HostName torizon@verdin-imx8mp-08910183.local
  User torzion
  ForwardAgent true
  ForwardX11 true
  ForwardX11Trusted no
```

### Git & Zephyr

~/gits/experiment_zephyr_isr_on_M7

Follow: https://github.com/hmaerki/experiment_zephyr_isr_on_M7/blob/main/zephyr_app/README.md
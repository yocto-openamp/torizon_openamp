# Yocto - Build

## Preparation: git email

Make sure git email is configure. Examples:

```bash
git config --global user.email "email@example.com"
git config --global user.name "Your Name"

git config --global user.email "buhtig.hans.maerki@ergoinfo.ch"
git config --global user.name "Hans Maerki"
```

## Initialize the yocto-workdir

The productxy manifest uses the same Torizon crops container as the standard workspace. Initialize it with the productxy manifest:

```bash
mkdir ./yocto-workdir
cd ./yocto-workdir
repo init \
	-u https://github.com/yocto-openamp/torizon_openamp_manifest.git \
	-b scarthgap-7.x.y \
	-m torizon/productxy.xml
repo sync --no-clone-bundle
```

The target is `MACHINE=verdin-imx8mp`, distribution `torizon`, image `torizon-docker`.

## Build the productxy image

Start the container:

Important: `cd torizon_openamp` - do not enter `yocto-workdir`!

```bash
docker run --rm -it \
  --name=crops \
  -v "$(pwd)/yocto-workdir:/workdir/torizon" \
  --workdir=/workdir/torizon \
  -e MACHINE=verdin-imx8mp \
  -e IMAGE=torizon-docker \
  torizon/crops:scarthgap-7.x.y
```

Start the build:

```bash
source setup-environment

# Verify if all layers selected
bitbake-layers show-layers | grep meta-productxy
bitbake-layers show-appends | grep torizon-docker

time bitbake torizon-docker
```

After about 1.5h: The Easy Installer image is written below `build-torizon/deploy/images/verdin-imx8mp/`.

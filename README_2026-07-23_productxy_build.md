# How to build productxy from scratch

Start with README_environment.md untils step `### 3b) Create workspace and initialize manifest`.

## Create workspace and initialize manifest

```bash
mkdir -p ./yocto-workdir
cd ./yocto-workdir

git config --global user.email "email@example.com"
git config --global user.name "Your Name"

repo init \
  -u https://github.com/yocto-openamp/torizon_openamp_manifest.git \
  -b scarthgap-7.x.y \
  -m torizon/productxy.xml

repo sync --no-clone-bundle
```


## Build

cd into repo directory

```bash
docker run --rm -it \
  --name=crops \
  -v "$(pwd)/yocto-workdir:/workdir/torizon" \
  --workdir=/workdir/torizon \
  -e MACHINE=verdin-imx8mp \
  -e IMAGE=torizon-docker \
  torizon/crops:scarthgap-7.x.y
```

```bash
startup-tdx.sh
```

or

```bash
source setup-environment

time bitbake torizon-docker
```

---
name: torizon-docker
description: torizon-docker Is a yocto image build using a docker container
---

## Preparation

As local user:

```bash
cd ./yocto-workdir

repo init \
  -u https://github.com/yocto-openamp/torizon_openamp_manifest.git \
  -b scarthgap-7.x.y \
  -m torizon/productxy.xml

repo sync --no-clone-bundle
```

## Build - in docker container

```bash
docker run --rm -it \
  --name=crops \
  -v "$(pwd)/yocto-workdir:/workdir/torizon" \
  --workdir=/workdir/torizon \
  -e MACHINE=verdin-imx8mp \
  -e IMAGE=torizon-docker \
  torizon/crops:scarthgap-7.x.y
```

Run bitbake within container:

```bash
source setup-environment

bitbake torizon-docker
```

## Reuse existing container

```bash
docker exec -u pokyuser crops bash -lc '...comand...'
```

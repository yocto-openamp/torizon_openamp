# Implement a layer productxy

**Only has to be done once to create the layer**

```bash
docker run --rm -it \
  --name=crops \
  -v "$(pwd)/yocto-workdir:/workdir/torizon" \
  --workdir=/workdir/torizon \
  -e MACHINE=verdin-imx8mp \
  -e IMAGE=torizon-docker \
  torizon/crops:scarthgap-7.x.y
```

Follow [meta-layers](https://developer.toradex.com/linux-bsp/os-development/build-yocto/custom-meta-layers-recipes-and-images-in-yocto-project-hello-world-examples):

```bash
source setup-environment
bitbake-layers create-layer ../layers/meta-productxy
# /workdir/torizon/layers/meta-productxy
vi conf/bblayers.conf
or persistent:
vi yocto-workdir/layers/meta-toradex-torizon/conf/template/bblayers.conf
  ...Add to end of file:

  ${OEROOT}/layers/meta-productxy \


# Variant: Create new meta-productxy
$ cd yocto-workdir/layers/meta-productxy
$ git init
$ git add .
$ git commit -m "Initial Commit" -m "Add meta-productxy from template"
git branch -M main
git remote add origin https://github.com/hmaerki/experiment_torizon_openamp_productxy.git
git push -u origin main

# Variant: checkout existing meta-productxy
$ cd yocto-workdir/layers
$ rm -r meta-productxy
$ git clone https://github.com/hmaerki/experiment_torizon_openamp_productxy meta-productxy
```

## Build

```bash
startup-tdx.sh
```

or

```bash
time bitbake torizon-docker
```

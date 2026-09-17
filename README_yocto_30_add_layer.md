# Yocto - How the productxy layer was added

SKIP THIS DOCUMENT!

The layer only has to be created once. This is how it was created.

Start the Torizon build container:

```bash
docker run --rm -it \
	--name=crops \
	-v "$(pwd)/yocto-workdir:/workdir/torizon" \
	--workdir=/workdir/torizon \
	-e MACHINE=verdin-imx8mp \
	-e IMAGE=torizon-docker \
	torizon/crops:scarthgap-7.x.y
```

Create the layer and add it to the build configuration:

```bash
source setup-environment
bitbake-layers create-layer ../layers/meta-productxy
vi conf/bblayers.conf
```

Add this entry to `BBLAYERS`:

```text
${OEROOT}/layers/meta-productxy \\
```

For a persistent template configuration, also update `yocto-workdir/layers/meta-toradex-torizon/conf/template/bblayers.conf`.

## Publish or check out the layer

```bash
cd yocto-workdir/layers/meta-productxy
git init
git add .
git commit -m "Initial Commit" -m "Add meta-productxy from template"
git branch -M main
git remote add origin https://github.com/hmaerki/experiment_torizon_openamp_productxy.git
git push -u origin main
```

To use the existing repository instead:

```bash
cd yocto-workdir/layers
rm -r meta-productxy
git clone https://github.com/hmaerki/experiment_torizon_openamp_productxy meta-productxy
```

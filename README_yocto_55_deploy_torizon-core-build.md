# Yocto - Deploy - TorizonCoreBuilder

## Links

* [TorizonCore Builder](https://github.com/torizon/torizoncore-builder/)
* [Command reference](https://developer.toradex.com/torizon/os-customization/torizoncore-builder-tool-commands-manual/)

## Update the target via SSH

```bash
docker run --rm -i \
	-v "$(pwd):/workdir:ro" \
	-v tcb-storage:/storage \
	torizon/torizoncore-builder:latest \
	images --remove-storage unpack \
	yocto-workdir/build-torizon/deploy/images/verdin-imx8mp/torizon-docker-verdin-imx8mp-Tezi.tar
```

```bash
docker run --rm -i \
	-v tcb-storage:/storage \
	--net=host \
	-v /var/run/docker.sock:/var/run/docker.sock \
	torizon/torizoncore-builder:latest deploy \
	--remote-host verdin-imx8mp-08910183 \
	--remote-username torizon \
	--remote-password 'torizon' \
	--reboot base
```

## Push to Torizon Cloud

Download `credentials.zip` from the Torizon Cloud dashboard. The writable `/deploy` mount is required because `platform push` creates `/deploy/tuf-repo` during signing:

```bash
rm -rf tuf
mkdir -p tuf
docker run --rm -i \
	--user "$(id -u):$(id -g)" \
	-v "$(pwd):/workdir:ro" \
	-v "$(pwd)/tuf:/deploy" \
	-v tcb-storage:/storage \
	torizon/torizoncore-builder:latest platform push \
	--credentials credentials.zip \
	--package-name maerki_demo \
	--package-version v0.1.2 base
```

If signing reports `RepoAlreadyInitialized`, remove the existing `tuf` directory before retrying.


## Push to Torizon Cloud


```bash
rm -rf tuf-lockbox
mkdir -p tuf-lockbox
docker run --rm -i \
	--user "$(id -u):$(id -g)" \
	-v "$(pwd):/workdir:ro" \
	-v "$(pwd)/tuf-lockbox:/tuf-lockbox" \
	-v tcb-storage:/storage \
    torizon/torizoncore-builder:latest platform lockbox \
    --credentials credentials.zip \
    --output-directory /tuf-lockbox/update \
    lockbox_maerki_demo_v0-1-5
```

Format a USB stick to `fat32`.
Label the filesystem: `torizon-update`.

```bash
sudo cp -r tuf-lockbox/update/ /media/maerki/torizon-update/
sync
eject
```

1. Boot Verdin iMX8M Plus
          ↓
2. Wait for Torizon OS to finish booting
          ↓
3. Insert USB stick
          ↓
4. USB automatically mounts
          ↓
5. aktualizr detects /media/<label>/update
          ↓
6. Lockbox is validated
          ↓
7. Update is installed
          ↓
8. Board reboots if required

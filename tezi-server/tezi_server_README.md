# tezi_server.py

## Links

- https://developer.toradex.com/easy-installer/toradex-easy-installer/toradex-easy-installer-detailed-manual/
- https://tezi.toradex.com/image_list.json
- https://developer.toradex.com/torizon/os-customization/torizoncore-builder-tool-commands-manual/

## Purpose

This server exposes Toradex Easy Installer feed data directly from generated Tezi tar archives.

It serves:

- A dynamic image list at /image_list.json
- Files inside Tezi tar archives through URL paths
- A local override file toradexlinux.png from this folder

In Toradex Easy Installer:
- Click `Feeds (f)`
- Enter `http://octoprobe4.local:8000`. Replace `octoprobe4.local` with the adequate server name or ip address.
- Now 'our' Tezi.tar files should appear.

## Startup Assumptions

The image search root is:

- yocto-workdir/build-torizon/deploy/images/

## Endpoints

### Root redirect

Request:

- GET /
- HEAD /
- GET with empty path variant handled as root

Behavior:

- Responds with 301 redirect
- Location points to http://<Host>/image_list.json

Reason:

- Some clients provide a URL without trailing slash and require an explicit redirect target.

### Image list

Request:

- GET /image_list.json

Response:

- JSON object with:
	- config_format: 1
	- images: dynamically discovered image paths

Image list generation:

- Scans yocto-workdir/build-torizon/deploy/images/*/*.tar
- Keeps only tar files ending with -Tezi.tar
- Emits each entry as:
	- <relative tar path>/image.json

Example entry:

- verdin-imx8mp/torizon-docker-verdin-imx8mp-Tezi_7.x.y-build/image.json

### Tar member access

Request shape:

- /<relative_tar_path>/<member_name>

Example:

- /verdin-imx8mp/torizon-docker-verdin-imx8mp-Tezi_7.6.1+build.12.tar/image.json

Behavior:

- Resolves tar file under the images root
- Opens tar with Python tarfile module
- Finds member by suffix match on /<member_name>
- Streams member bytes as HTTP response

Special handling:

- If member_name is toradexlinux.png, serves local file tezi-server/resources/toradexlinux.png
- If member_name is image.json:
	- Rewrites "name": "Torizon OS" to include current Host header
	- Removes license line for LA_OPT_NXP_SW.html

## Error Handling

- 404 when tar file does not exist
- 404 when requested tar member is missing or not a regular file
- 500 for tar read/parsing failures

## Run

From repository root:

```bash
python3 tezi-server/tezi_server.py

# or

uv run https://raw.githubusercontent.com/yocto-openamp/torizon_openamp/main/tezi-server/tezi_server.py
```

## Quick Checks

```bash
curl -i http://octoprobe4.local:8000/
curl -s http://octoprobe4.local:8000/image_list.json | jq .
curl -I http://octoprobe4.local:8000/image_list.json
```

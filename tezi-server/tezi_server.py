#!/usr/bin/env python3

import http.server
import json
import pathlib
import sys
import tarfile
import urllib.parse

PORT = 8000
BIND = ""
PROTOCOL = "HTTP/1.0"

DIRECTORY_TEZI_IMAGES = "build-torizon/deploy/images/"
DIRECTORY_YOCTO_WORKDIR = "yocto-workdir"

ENDPOINT_IMAGE_LIST_JSON = "image_list.json"
ENDPOINT_TORADEXLINUX_PNG = "toradexlinux.png"
ENDPOINT_IMAGE_JSON = "image.json"


def get_tezi_files(directory_tezi_images: pathlib.Path) -> list[str]:
    return [
        f"{t.relative_to(directory_tezi_images)}"
        for t in directory_tezi_images.glob("*/*.tar")
        if t.name.endswith("-Tezi.tar")
    ]


def make_image_list(directory_tezi_images: pathlib.Path) -> dict[str, str | int | list]:
    return {
        "config_format": 1,
        "images": [f + "/image.json" for f in get_tezi_files(directory_tezi_images)],
    }


class TeziRequestHandler(http.server.SimpleHTTPRequestHandler):
    directory_tezi_images: pathlib.Path

    def _send_image_list(self, include_body: bool) -> None:
        body = (
            json.dumps(make_image_list(self.directory_tezi_images), indent=2) + "\n"
        ).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        if include_body:
            self.wfile.write(body)

    def _redirect_root(self, path: str) -> bool:
        """
        It seems like that the Toradex Easy Installer allows to configure
        a feed like 'http://octoprobe4.local:8000' (not the missing '/').
        This screws up Toradex Easy Installer.
        However when we send a redirect to http://octoprobe4.local:8000/image_list.json
        """
        if path not in ("", "/"):
            return False
        self.send_response(301)
        location = f"http://{self.headers.get('Host', '')}/{ENDPOINT_IMAGE_LIST_JSON}"
        self.send_header("Location", location)
        self.send_header("Content-Length", "0")
        self.end_headers()
        return True

    def _do_get_image_list(self, path: str) -> bool:
        if path == "/" + ENDPOINT_IMAGE_LIST_JSON:
            self._send_image_list(include_body=True)
            return True
        return False

    def _do_get_file(self, path: str) -> bool:
        path = path.removeprefix("/")
        parts = path.rpartition("/")
        if len(parts) != 3:
            return False

        relative_tar, _, tar_member = parts
        # Example relative_tar: 'verdin-imx8mp/torizon-docker-verdin-imx8mp-Tezi.tar'
        # Example tar_member: 'image.json'
        filename_tar = self.directory_tezi_images / relative_tar
        if not filename_tar.is_file():
            self.send_error(404, f"Tar file not found: {filename_tar}")
            return True

        member_name = urllib.parse.unquote(tar_member)

        if member_name == ENDPOINT_TORADEXLINUX_PNG:
            filename_png = (
                self.directory_tezi_images / "resources" / ENDPOINT_TORADEXLINUX_PNG
            )
            content_png = filename_png.read_bytes()
            self.send_response(200)
            self.send_header("Content-Type", self.guess_type(member_name))
            self.send_header("Content-Length", str(len(content_png)))
            self.end_headers()
            self.wfile.write(content_png)
            return True

        try:
            with tarfile.open(filename_tar, "r:*") as tf:
                for member in tf.getmembers():
                    if not member.path.endswith("/" + member_name):
                        continue

                    if not member.isfile():
                        self.send_error(
                            404,
                            f"Requested member is not a file: {member_name} / {filename_tar}",
                        )
                        return True

                    extracted = tf.extractfile(member)
                    if extracted is None:
                        self.send_error(
                            404,
                            f"File not found in tar: {member_name} / {filename_tar}",
                        )
                        return True

                    content = extracted.read()
                    if member_name == ENDPOINT_IMAGE_JSON:
                        host = self.headers.get("Host", "")
                        content = content.replace(
                            b'"name": "Torizon OS",',
                            f'"name": "Torizon OS ({host})",'.encode("ascii"),
                        )
                        content = content.replace(
                            b'"license": "LA_OPT_NXP_SW.html",',
                            b"",
                        )
                    self.send_response(200)
                    self.send_header("Content-Type", self.guess_type(member_name))
                    self.send_header("Content-Length", str(len(content)))
                    self.end_headers()
                    self.wfile.write(content)
                    return True

                self.send_error(
                    500, f"Failed to read tar file: {member_name} {filename_tar}"
                )

        except (tarfile.TarError, OSError):
            self.send_error(
                500, f"Failed to read tar file: {member_name} {filename_tar}"
            )

        return True

    def do_GET(self) -> None:
        path = urllib.parse.urlsplit(self.path).path
        if self._redirect_root(path=path):
            return
        if self._do_get_image_list(path=path):
            return
        if self._do_get_file(path=path):
            return
        super().do_GET()

    def do_HEAD(self) -> None:
        path = urllib.parse.urlsplit(self.path).path
        if self._redirect_root(path=path):
            return
        super().do_HEAD()


def main() -> None:
    cwd = pathlib.Path.cwd()
    cwd_absolute = cwd.resolve().absolute()

    if cwd.name != DIRECTORY_YOCTO_WORKDIR:
        print(
            f"ERROR: This program is expected to be started in the directory '{DIRECTORY_YOCTO_WORKDIR}' but not '{cwd_absolute.name}'!"
        )
        sys.exit(1)
    assert cwd_absolute.is_dir()

    directory_tezi_images = cwd_absolute / DIRECTORY_TEZI_IMAGES

    handler_class = TeziRequestHandler
    # protocol_version is a class attribute used by the handler.
    handler_class.protocol_version = PROTOCOL
    handler_class.directory_tezi_images = directory_tezi_images

    print(f"Start server on port:{PORT}, directory:{directory_tezi_images}")
    print(
        f"Current tarfiles: {get_tezi_files(directory_tezi_images=directory_tezi_images)}"
    )

    with http.server.ThreadingHTTPServer((BIND, PORT), handler_class) as server:
        server.serve_forever()


if __name__ == "__main__":
    main()

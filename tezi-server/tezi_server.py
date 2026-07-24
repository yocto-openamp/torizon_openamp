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
ENDPOINT_IMAGE_JSON = "image.json"

ENDPOINT_TORADEXLINUX_PNG = "toradexlinux.png"
# xxd -p -c 16 tezi-server/resources/toradexlinux.png | sed 's/../\\x&/g; s/^/    b"/; s/$/"/'
TORADEXLINUX_PNG_BYTES = (
    b"\x89\x50\x4e\x47\x0d\x0a\x1a\x0a\x00\x00\x00\x0d\x49\x48\x44\x52"
    b"\x00\x00\x00\x28\x00\x00\x00\x28\x08\x06\x00\x00\x00\x8c\xfe\xb8"
    b"\x6d\x00\x00\x00\x01\x73\x52\x47\x42\x01\xd9\xc9\x2c\x7f\x00\x00"
    b"\x00\x04\x67\x41\x4d\x41\x00\x00\xb1\x8f\x0b\xfc\x61\x05\x00\x00"
    b"\x00\x20\x63\x48\x52\x4d\x00\x00\x7a\x26\x00\x00\x80\x84\x00\x00"
    b"\xfa\x00\x00\x00\x80\xe8\x00\x00\x75\x30\x00\x00\xea\x60\x00\x00"
    b"\x3a\x98\x00\x00\x17\x70\x9c\xba\x51\x3c\x00\x00\x00\x3b\x49\x44"
    b"\x41\x54\x58\xc3\xed\xce\x41\x0d\x00\x30\x08\x04\xb0\x63\xfe\xb5"
    b"\xe0\x8f\xd7\x66\x83\x25\xad\x82\xd6\x74\x6e\x16\x3b\x59\x4e\x50"
    b"\x50\x50\x50\x50\x50\x50\x50\x50\x50\x50\x50\x50\x50\x50\x50\x50"
    b"\x50\x50\x50\x50\x50\xf0\xd7\xe0\x03\xa5\x21\x02\xf6\xfe\x88\xd6"
    b"\x79\x00\x00\x00\x00\x49\x45\x4e\x44\xae\x42\x60\x82"
)


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
            if False:
                filename_png = (
                    self.directory_tezi_images / "resources" / ENDPOINT_TORADEXLINUX_PNG
                )
                content_png = filename_png.read_bytes()
            else:
                content_png = TORADEXLINUX_PNG_BYTES
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

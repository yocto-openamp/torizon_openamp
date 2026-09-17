# Yocto - Prepare build environment

## Host prerequisites

The build environment targets Linux, preferably Ubuntu 22.04. Install the required tools:

```bash
sudo apt update
sudo apt install -y git curl wget unzip xz-utils file build-essential \
	cmake ninja-build gperf ccache dfu-util device-tree-compiler \
	python3 python3-pip python3-venv python3-setuptools python3-wheel udev
```

Install Docker and allow the current user to run it without `sudo`:

```bash
sudo apt install -y ca-certificates gnupg docker-ce docker-ce-cli \
	containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER"
newgrp docker
docker run --rm hello-world
```

## Install `repo`

Use `sudo apt install repo`.

As fallback you may:

```bash
mkdir -p ~/bin
curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
export PATH=~/bin:$PATH
echo 'export PATH=~/bin:$PATH' >> ~/.bashrc
```


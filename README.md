# LichUI - Builder

## System Requirements

### System and recomendations

Debian-based Linux system. Currently, this project has been tested and is working correctly on Ubuntu 24.04 and Debian 13.

It also works on Arch Linux, but it should be noted that you will need to install the necessary dependencies on Arch, in addition to making the necessary adjustments:

Install clang18

```bash
yay -S clang18
```

Add patch in ~/.zshrc or ~/.bashrc

```bash
export PATH="/usr/lib/llvm18/bin:$PATH"
```

```bash
source ~/.zshrc
```

### font for terminal aesthetics

```bash
https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
```

### Basic Dependencies

```bash
sudo apt update && sudo apt upgrade -y
```

```bash
sudo apt install -y \
    git npm attr unzip tar g++ gcc xxd \
    python3 python3-pip python3-venv openjdk-21-jdk \
    cmake ninja-build clang ccache build-essential \
    pkg-config libssl-dev zlib1g-dev liblz4-dev \
    liblzma-dev libzstd-dev libfuse3-dev libudev-dev \
    libgtest-dev libprotobuf-dev lz4 libbrotli-dev \
    protobuf-compiler perl liblld-dev zip libusb-1.0-0-dev \
    git-lfs zipalign p7zip-full cpio webp
```

## How to Start ?

### Clone the repository

Use the following command to clone the repository and all its necessary submodules:

```bash
git clone --recurse-submodules https://github.com/MrDemonc/LichUI_Builder.git -b sixteen && cd LichUI_Builder
```

### How to build

Build tools:

```bash
source ./build.sh tools
```

Build rom:

```bash
source ./build.sh a54x
run make_rom
```

Clear dir work

```bash
source ./build.sh clear
```

### Where is the built rom ?

The rom and manifest will be in "/out/target/$TARGET/"

### Crédits

This project was inspired by the UN1CA project by developer @Salvogiangri. Several of the smali scripts and patches have been used and modified for this project. Many thanks and credits to @Salvogiangri and the UN1CA development team.

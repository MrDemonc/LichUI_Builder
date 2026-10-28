# LichUI - Builder

LichUI Builder is an automated build toolchain and patching framework for building the LichUI custom ROM based on Samsung One UI ports.

Currently supported target:
- **Samsung Galaxy A54 5G (`a54x` / SM-A546E)** (ported from Galaxy S23 FE `SM-S711B`)

---

## System Requirements & Recommendations

- **Operating System**: Debian-based Linux distribution (tested on Ubuntu 24.04 and Debian 13) or Arch Linux.
- **Disk Space**: 70–100 GB of free space recommended.
- **RAM**: 16 GB or 8 GB + Swap.

### Arch Linux Adjustments

```bash
yay -S clang18
export PATH="/usr/lib/llvm18/bin:$PATH"
```

### Basic Dependencies (Debian / Ubuntu)

```bash
sudo apt update && sudo apt upgrade -y
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

### Font for Terminal Aesthetics (Optional)

```bash
https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
```

---

## Quick Start

### 1. Clone Repository with Submodules

```bash
git clone --recurse-submodules https://github.com/MrDemonc/LichUI_Builder.git -b sixteen && cd LichUI_Builder
```

### 2. Follow the Build Guide

Building requires downloading and preparing the target stock firmware (`A546EXXUFEYI4`) before running the build scripts. Please refer to:

👉 **[BUILD_GUIDE.md](BUILD_GUIDE.md)** for detailed firmware placement, tools compilation, and build execution commands.

---

## Credits

This project was inspired by the UN1CA project by developer [@Salvogiangri](https://github.com/Salvogiangri). Several smali scripts, tools, and patches have been used and modified for this project. Many thanks and credits to @Salvogiangri and the UN1CA development team.

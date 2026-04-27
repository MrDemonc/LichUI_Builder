#!/bin/bash
source "$dir_work/scripts/utils/common.sh"

# Download and Extract firmware
run make_firmware

# Apply patches
run apply_patches
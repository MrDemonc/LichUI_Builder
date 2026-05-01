#!/bin/bash
source "$dir_scr/utils/common.sh"
source "$dir_work/platform/core/config/version.sh

# Download and Extract firmware
run make_firmware

# Apply bluetooth patch
run patch_bluetooth

# Apply floating feature patch
run floating_feature

# Apply patches
run apply_patches

# Apply smali patches
run apktool
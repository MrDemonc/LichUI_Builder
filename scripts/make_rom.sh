#!/bin/bash
set -e
source "$dir_scr/utils/common.sh"
source "$dir_work/platform/core/config/version.sh"

failure() {
    echo ""
    log_error "LichUI for $TARGET build failed"
    exit 1
}
trap failure ERR

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

# Create rom zip
run flashable_zip

# Get manifest
run get_manifest

log_success "LichUI for $TARGET built successfully"
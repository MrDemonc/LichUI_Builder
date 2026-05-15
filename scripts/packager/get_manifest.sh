#!/usr/bin/env bash

# Source utilities
source "$dir_scr/utils/build_utils.sh" || exit 1

# Setup firmware variables (SOURCE_DIR, TARGET_DIR)
setup_firmware_vars

# Load target config explicitly to get BOOTLOADER and other vars
if [ -f "$dir_work/target/$TARGET/config.sh" ]; then
    source "$dir_work/target/$TARGET/config.sh"
fi

if [ -f "$dir_work/platform/core/config/version.sh" ]; then
    source "$dir_work/platform/core/config/version.sh"
    ROM_VERSION="$LICH_VERSION"
fi

# Variables
OUT_DIR="${OUT_DIR:-$dir_work/out/target/$TARGET}"
ROM_IS_OFFICIAL="${ROM_IS_OFFICIAL:-$OFFICIAL_ROM}"
DEBUG="${DEBUG:-false}"

# Find the generated zip file
ZIP_FILE=$(ls -t "$OUT_DIR"/LichUI_${ROM_VERSION}_*_${TARGET}*.zip 2>/dev/null | head -n 1)

if [[ -z "$ZIP_FILE" ]] || [[ ! -f "$ZIP_FILE" ]]; then
    log_error "Zip file not found in $OUT_DIR"
    exit 1
fi

ZIP_FILE_NAME=$(basename "$ZIP_FILE")

log_info "Getting necessary information for manifest..."

ZIP_SIZE=$(stat -c%s "$ZIP_FILE")
ZIP_MD5=$(md5sum "$ZIP_FILE" | cut -d' ' -f1)

# Security patch from source system
SECURITY_PATCH=$(get_prop system "ro.build.version.security_patch" | tr -d '-')

if [[ -z "$SECURITY_PATCH" ]]; then 
    log_error "Could not get the security patch from build.prop"
    exit 1
fi

log_info "Generating manifest.txt..."

MANIFEST_FILE="$OUT_DIR/manifest.txt"
cat > "$MANIFEST_FILE" << EOF
{
  "response": [
    {
      "builddate": $(date +%Y%m%d),
      "md5": "$ZIP_MD5",
      "patch": $SECURITY_PATCH,
      "size": $ZIP_SIZE,
      "bl": "${BOOTLOADER:-unknown}",
      "url": "https://pixeldrain.com/api/file/[id]?download",
      "version": "$ROM_VERSION"
    }
  ]
}
EOF

log_success "manifest.txt generated successfully in $MANIFEST_FILE"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "${dir_work}/out/flags/.common" ]; then
    log_warning "common patches has already been completed previously. Skiping..."
    exit 0
fi

set_prop "$SOURCE_FIRMWARE" system "$SCRIPT_DIR/system.prop"
set_prop "$TARGET_FIRMWARE" vendor "$SCRIPT_DIR/vendor.prop"

log_success "Process completed successfully"
touch "${dir_work}/out/flags/.common"
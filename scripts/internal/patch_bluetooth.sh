#!/bin/bash

source "$dir_scr/utils/utils.sh"
setup_firmware_vars

log_info "Starting Bluetooth patch process..."

BT_FLAG="$dir_work/out/flags/.bt_patched"
if [ -f "$BT_FLAG" ]; then
    log_success "Bluetooth is already patched. Skipping."
    exit 0
fi

# Detect APEX directory (handle system/system or system/)
APEX_DIR="$FW_DIR/$SOURCE_DIR/system/system/apex"
if [ ! -d "$APEX_DIR" ]; then
    APEX_DIR="$FW_DIR/$SOURCE_DIR/system/apex"
fi

BT_APEX=$(find "$APEX_DIR" -name "com.android.bt*.apex" 2>/dev/null | head -n 1)

if [ -z "$BT_APEX" ] || [ ! -f "$BT_APEX" ]; then
    log_error "Bluetooth APEX not found in $APEX_DIR (SOURCE_DIR: $SOURCE_DIR)"
    exit 1
fi


log_info "Processing APEX: $(basename "$BT_APEX")"

TEMP_WORK="$dir_work/out/bt_patch"
mkdir -p "$TEMP_WORK/mnt"

cleanup() {
    if mountpoint -q "$TEMP_WORK/mnt"; then
        sudo umount "$TEMP_WORK/mnt" 2>/dev/null || true
    fi
    rm -rf "$TEMP_WORK"
}
trap cleanup EXIT

if ! unzip -o -qq "$BT_APEX" "apex_payload.img" -d "$TEMP_WORK"; then
    log_error "Failed to extract apex_payload.img"
    exit 1
fi

PAYLOAD="$TEMP_WORK/apex_payload.img"
if [ ! -f "$PAYLOAD" ]; then
    log_error "apex_payload.img not found after extraction"
    exit 1
fi

if ! sudo mount -o ro,loop "$PAYLOAD" "$TEMP_WORK/mnt"; then
    log_error "Could not mount apex_payload.img (Sudo might be required)"
    exit 1
fi

ORIGINAL_LIB="$TEMP_WORK/mnt/lib64/libbluetooth_jni.so"
PATCH_LIB="$TEMP_WORK/libbluetooth_jni_patched.so"

if [ ! -f "$ORIGINAL_LIB" ]; then
    log_error "libbluetooth_jni.so not found inside APEX"
    exit 1
fi

cp "$ORIGINAL_LIB" "$PATCH_LIB"

sudo umount "$TEMP_WORK/mnt"

FROM_HEX="00122a0140395f01086b00020054"
TO_HEX="00122a0140395f01086bde030014"

if ! hex_patch "$PATCH_LIB" "$FROM_HEX" "$TO_HEX"; then
    log_error "Failed to apply hex patch to Bluetooth library"
    exit 1
fi

if ! add system "$PATCH_LIB" "/lib64/libbluetooth_jni.so"; then
    log_error "Failed to inject patched Bluetooth library into firmware"
    exit 1
fi

# Cleanup handled by trap EXIT

mkdir -p "$(dirname "$BT_FLAG")"
touch "$BT_FLAG"

log_success "Bluetooth fix completed successfully"


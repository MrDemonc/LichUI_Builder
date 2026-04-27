#!/bin/bash

if [ -f "${dir_work}/out/flags/.mics" ]; then
    log_success "Mics is already applied"
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CURRENT_DATE=$(date +%Y%m%d)
source "$dir_work/platform/core/configs/version.sh"

set_prop "$SOURCE_FIRMWARE" system "$SCRIPT_DIR/system.prop"
set_prop "$TARGET_FIRMWARE" vendor "$SCRIPT_DIR/vendor.prop"

# Fix nfc
delete_items "$SOURCE_FIRMWARE/system/system/lib64" "libstatslog_nfc.so"
delete_items "$SOURCE_FIRMWARE/system/system/etc" "nfc_key"
delete_items "$SOURCE_FIRMWARE/system/system/priv-app" "NfcNci"
copy_items "$dir_work/target/$TARGET/patches/mics/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "libnfc_nci_jni.so"
copy_items "$dir_work/target/$TARGET/patches/mics/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "libnfc_prop_extn.so"
copy_items "$dir_work/target/$TARGET/patches/mics/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "libnfc_vendor_extn.so"
copy_items "$dir_work/target/$TARGET/patches/mics/system/priv-app" "$SOURCE_FIRMWARE/system/system/priv-app" "NfcNci"
copy_items "$dir_work/target/$TARGET/patches/mics/system/etc" "$SOURCE_FIRMWARE/system/system/etc" "nfc_key"

# Fix SoundBooster
delete_items "$SOURCE_FIRMWARE/system/system/lib64" "lib_SoundBooster_ver2000.so"
delete_items "$SOURCE_FIRMWARE/system/system/lib64" "libsamsungSoundbooster_plus_legacy.so"
delete_items "$SOURCE_FIRMWARE/system/system/lib" "lib_SoundBooster_ver2000.so"
delete_items "$SOURCE_FIRMWARE/system/system/lib" "libsamsungSoundbooster_plus_legacy.so"
delete_items "$SOURCE_FIRMWARE/system/system/etc" "stage_policy.conf"
copy_items "$TARGET_FIRMWARE/system/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "lib_SoundBooster_ver1100.so"
copy_items "$TARGET_FIRMWARE/system/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "libsamsungSoundbooster_plus_legacy.so"
copy_items "$TARGET_FIRMWARE/system/system/lib" "$SOURCE_FIRMWARE/system/system/lib" "lib_SoundBooster_ver1100.so"
copy_items "$TARGET_FIRMWARE/system/system/lib" "$SOURCE_FIRMWARE/system/system/lib" "libsamsungSoundbooster_plus_legacy.so"
copy_items "$TARGET_FIRMWARE/system/system/etc" "$SOURCE_FIRMWARE/system/system/etc" "stage_policy.conf"

# Add target apex
delete_items "$SOURCE_FIRMWARE/system/system/system_ext/apex" "com.android.vndk.v31.apex"
copy_items "$dir_work/target/$TARGET/patches/mics/system/system_ext/apex" "$SOURCE_FIRMWARE/system/system/system_ext/apex" "com.android.vndk.v33.apex"

# Fix Selinux
delete_items "$SOURCE_FIRMWARE/system/system/system_ext/etc/selinux/mapping" "*"
delete_items "$SOURCE_FIRMWARE/system/system/system_ext/etc/selinux" "system_ext_seapp_contexts"
copy_items "$dir_work/target/$TARGET/patches/mics/system/system_ext/etc/selinux" "$SOURCE_FIRMWARE/system/system/system_ext/etc/selinux" "system_ext_seapp_contexts"
copy_items "$dir_work/target/$TARGET/patches/mics/system/system_ext/etc/selinux/mapping" "$SOURCE_FIRMWARE/system/system/system_ext/etc/selinux/mapping" "*"
delete_items "$TARGET_FIRMWARE/vendor/etc/selinux" "vendor_sepolicy.cil"
copy_items "$dir_work/target/$TARGET/patches/mics/vendor/etc/selinux" "$TARGET_FIRMWARE/vendor/etc/selinux" "vendor_sepolicy.cil"

# Fix esim
delete_items "$SOURCE_FIRMWARE/system/system/etc/permissions" "privapp-permissions-com.samsung.euicc.xml"

delete_work "/system/lib64/lib_SoundBooster_ver2000.so" '$SOURCE_FIRMWARE/system'
delete_work "/system/lib/lib_SoundBooster_ver2000.so" '$SOURCE_FIRMWARE/system'
add_work "/system/lib64/lib_SoundBooster_ver1100.so" '$SOURCE_FIRMWARE/system'
add_work "/system/lib/lib_SoundBooster_ver1100.so" '$SOURCE_FIRMWARE/system'

add_work "/system/system_ext/apex/com.android.vndk.v33.apex" '$SOURCE_FIRMWARE/system'
delete_work "/system/system_ext/apex/com.android.vndk.v31.apex" '$SOURCE_FIRMWARE/system'
delete_work "/system/priv-app/NfcNci/oat" '$SOURCE_FIRMWARE/system'

add_work "/system/lib64/libnfc_nci_jni.so" '$SOURCE_FIRMWARE/system'
add_work "/system/lib64/libnfc_prop_extn.so" '$SOURCE_FIRMWARE/system'
add_work "/system/lib64/libnfc_vendor_extn.so" '$SOURCE_FIRMWARE/system'
add_work "/system/system_ext/apex/com.android.vndk.v33.apex" '$SOURCE_FIRMWARE/system'

log_success "Process completed successfully"
touch "${dir_work}/out/flags/.mics"
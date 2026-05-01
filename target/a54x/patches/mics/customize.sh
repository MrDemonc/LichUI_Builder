#!/bin/bash

readonly CURRENT_DATE=$(date +%Y%m%d)

setprop system "system.prop"
setprop vendor "vendor.prop"

# Fix nfc
delete system "lib64/libstatslog_nfc.so"
add system "system/lib64/libnfc_nci_jni.so" "lib64/libnfc_nci_jni.so"
add system "system/lib64/libnfc_prop_extn.so" "lib64/libnfc_prop_extn.so"
add system "system/lib64/libnfc_vendor_extn.so" "lib64/libnfc_vendor_extn.so"
add system "system/priv-app/NfcNci" "priv-app/NfcNci"
add system "system/etc/nfc_key" "etc/nfc_key"

# Fix SoundBooster
delete system "lib64/lib_SoundBooster_ver2000.so"
delete system "lib/lib_SoundBooster_ver2000.so"
add system "$FW_DIR/$TARGET_DIR/system/system/lib64/libsamsungSoundbooster_plus_legacy.so" "lib64/libsamsungSoundbooster_plus_legacy.so"
add system "$FW_DIR/$TARGET_DIR/system/system/lib64/lib_SoundBooster_ver1100.so" "lib64/lib_SoundBooster_ver1100.so"
add system "$FW_DIR/$TARGET_DIR/system/system/lib/libsamsungSoundbooster_plus_legacy.so" "lib/libsamsungSoundbooster_plus_legacy.so"
add system "$FW_DIR/$TARGET_DIR/system/system/lib/lib_SoundBooster_ver1100.so" "lib/lib_SoundBooster_ver1100.so"
add system "$FW_DIR/$TARGET_DIR/system/system/etc/stage_policy.conf" "etc/stage_policy.conf"

# Add target apex
delete system "system_ext/apex/com.android.vndk.v31.apex"
add system "$FW_DIR/$TARGET_DIR/system/system/system_ext/apex/com.android.vndk.v33.apex" "system_ext/apex/com.android.vndk.v33.apex"

# Fix Selinux
delete system "system_ext/etc/selinux/mapping" "*"
add system "system/system_ext/etc/selinux/system_ext_seapp_contexts" "system_ext/etc/selinux/system_ext_seapp_contexts"
add system "$FW_DIR/$TARGET_DIR/system/system/system_ext/etc/selinux/mapping" "system_ext/etc/selinux/mapping" "*"
add vendor "vendor/etc/selinux/vendor_sepolicy.cil" "etc/selinux/vendor_sepolicy.cil"

# Remove esim
delete system "etc/permissions/privapp-permissions-com.samsung.euicc.xml"
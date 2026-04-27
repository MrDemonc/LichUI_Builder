#!/bin/bash

if [ -f "${dir_work}/out/flags/.stock_blobs" ]; then
    log_success "Stock_blobs is already applied"
    exit 0
fi

delete_items "$SOURCE_FIRMWARE/product/priv-app" "HotwordEnrollmentOKGoogleEx4CORTEXM55"
delete_items "$SOURCE_FIRMWARE/product/priv-app" "HotwordEnrollmentXGoogleEx4CORTEXM55"
copy_items "$TARGET_FIRMWARE/product/priv-app" "$SOURCE_FIRMWARE/product/priv-app" "HotwordEnrollmentOKGoogleEx4CORTEXM4"
copy_items "$TARGET_FIRMWARE/product/priv-app" "$SOURCE_FIRMWARE/product/priv-app" "HotwordEnrollmentXGoogleEx4CORTEXM4"

delete_items "$SOURCE_FIRMWARE/system/system/etc/vintf" "compatibility_matrix.device.xml"
copy_items "$TARGET_FIRMWARE/system/system/etc/vintf" "$SOURCE_FIRMWARE/system/system/etc/vintf" "compatibility_matrix.device.xml"

delete_items "$SOURCE_FIRMWARE/system/system/etc/permissions" "com.sec.feature.cover.flip.xml"
delete_items "$SOURCE_FIRMWARE/system/system/etc/permissions" "com.sec.feature.pocketmode_level6.xml"
delete_items "$SOURCE_FIRMWARE/system/system/etc/permissions" "com.sec.feature.sensorhub_level29.xml"
delete_items "$SOURCE_FIRMWARE/system/system/etc/permissions" "com.sec.feature.wirelesscharger_authentication.xml"
copy_items "$TARGET_FIRMWARE/system/system/etc/permissions" "$SOURCE_FIRMWARE/system/system/etc/permissions" "com.sec.feature.pocketsensitivitymode_level4.xml"
copy_items "$TARGET_FIRMWARE/system/system/etc/permissions" "$SOURCE_FIRMWARE/system/system/etc/permissions" "com.sec.feature.sensorhub_level100.xml"

sed -i "s|<version>31</version>|<version>${VNDK}</version>|g" "$FW_DIR/$SOURCE_MODEL/system/system/system_ext/etc/vintf/manifest.xml"


delete_work "/product/priv-app/HotwordEnrollmentOKGoogleEx4CORTEXM55" '$SOURCE_FIRMWARE/product' true
delete_work "/product/priv-app/HotwordEnrollmentXGoogleEx4CORTEXM55" '$SOURCE_FIRMWARE/product' true
delete_work "/system/etc/permissions/com.sec.feature.cover.flip.xml" '$SOURCE_FIRMWARE/system'
delete_work "/system/etc/permissions/com.sec.feature.sensorhub_level29.xml" '$SOURCE_FIRMWARE/system'

add_work "/product/priv-app/HotwordEnrollmentOKGoogleEx4CORTEXM4" '$SOURCE_FIRMWARE/product'
add_work "/product/priv-app/HotwordEnrollmentOKGoogleEx4CORTEXM4/HotwordEnrollmentOKGoogleEx4CORTEXM4.apk" '$SOURCE_FIRMWARE/product'
add_work "/product/priv-app/HotwordEnrollmentOKGoogleEx4CORTEXM4/oat" '$SOURCE_FIRMWARE/product'
add_work "/product/priv-app/HotwordEnrollmentOKGoogleEx4CORTEXM4/oat/arm64" '$SOURCE_FIRMWARE/product'
add_work "/product/priv-app/HotwordEnrollmentOKGoogleEx4CORTEXM4/oat/arm64/HotwordEnrollmentOKGoogleEx4CORTEXM4.odex" '$SOURCE_FIRMWARE/product'
add_work "/product/priv-app/HotwordEnrollmentOKGoogleEx4CORTEXM4/oat/arm64/HotwordEnrollmentOKGoogleEx4CORTEXM4.vdex" '$SOURCE_FIRMWARE/product'
add_work "/product/priv-app/HotwordEnrollmentXGoogleEx4CORTEXM4" '$SOURCE_FIRMWARE/product'
add_work "/product/priv-app/HotwordEnrollmentXGoogleEx4CORTEXM4/HotwordEnrollmentXGoogleEx4CORTEXM4.apk" '$SOURCE_FIRMWARE/product'
add_work "/product/priv-app/HotwordEnrollmentXGoogleEx4CORTEXM4/oat" '$SOURCE_FIRMWARE/product'
add_work "/product/priv-app/HotwordEnrollmentXGoogleEx4CORTEXM4/oat/arm64" '$SOURCE_FIRMWARE/product'
add_work "/product/priv-app/HotwordEnrollmentXGoogleEx4CORTEXM4/oat/arm64/HotwordEnrollmentXGoogleEx4CORTEXM4.odex" '$SOURCE_FIRMWARE/product'
add_work "/product/priv-app/HotwordEnrollmentXGoogleEx4CORTEXM4/oat/arm64/HotwordEnrollmentXGoogleEx4CORTEXM4.vdex" '$SOURCE_FIRMWARE/product'
add_work "/system/etc/permissions/com.sec.feature.sensorhub_level100.xml" '$SOURCE_FIRMWARE/system'

log_success "Process completed successfully"
touch "${dir_work}/out/flags/.stock_blobs"

#!/bin/bash

# Product
delete product "priv-app/HotwordEnrollmentOKGoogleEx4CORTEXM55"
delete product "priv-app/HotwordEnrollmentXGoogleEx4CORTEXM55"
add product "$FW_DIR/$TARGET_DIR/product/priv-app/HotwordEnrollmentOKGoogleEx4CORTEXM4" "priv-app/HotwordEnrollmentOKGoogleEx4CORTEXM4"
add product "$FW_DIR/$TARGET_DIR/product/priv-app/HotwordEnrollmentXGoogleEx4CORTEXM4" "priv-app/HotwordEnrollmentXGoogleEx4CORTEXM4"

# System
delete system "etc/permissions/com.sec.feature.cover.flip.xml"
delete system "etc/permissions/com.sec.feature.pocketmode_level6.xml"
delete system "etc/permissions/com.sec.feature.sensorhub_level29.xml"
delete system "etc/permissions/com.sec.feature.wirelesscharger_authentication.xml"
add system "$FW_DIR/$TARGET_DIR/system/system/etc/vintf/compatibility_matrix.device.xml" "etc/vintf/compatibility_matrix.device.xml"
add system "$FW_DIR/$TARGET_DIR/system/system/etc/permissions/com.sec.feature.pocketsensitivitymode_level4.xml" "etc/permissions/com.sec.feature.pocketsensitivitymode_level4.xml"
add system "$FW_DIR/$TARGET_DIR/system/system/etc/permissions/com.sec.feature.sensorhub_level100.xml" "etc/permissions/com.sec.feature.sensorhub_level100.xml"

sed -i "s|<version>31</version>|<version>${SOURCE_VNDK}</version>|g" "$FW_DIR/$SOURCE_DIR/system/system/system_ext/etc/vintf/manifest.xml"


#!/bin/bash

update_config "SEC_FLOATING_FEATURE_COMMON_CONFIG_AI_VERSION" "20253"
update_config "SEC_FLOATING_FEATURE_FRAMEWORK_SUPPORT_PERSONALIZED_DATA_CORE" "TRUE"
update_config "SEC_FLOATING_FEATURE_FRAMEWORK_SUPPORT_AI_BRIEF_FOR_UT" "TRUE"

delete system "priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk"
delete system "priv-app/SamsungSmartSuggestions/oat"

add system "system/etc/default-permissions/default-permissions-com.samsung.android.app.moments.xml" "etc/default-permissions/default-permissions-com.samsung.android.app.moments.xml"
add system "system/etc/permissions/privapp-permissions-com.samsung.android.app.moments.xml" "etc/permissions/privapp-permissions-com.samsung.android.app.moments.xml"
add system "system/etc/sysconfig/moments.xml" "etc/sysconfig/moments.xml"
add system "system/priv-app/Moments" "priv-app/Moments"

log_warning "Downloading SamsungSmartSuggestions APK..."

download_file "$(get_galaxy_store_url "com.samsung.android.smartsuggestions")" \
    "$FW_DIR/$SOURCE_DIR/system/system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk"

set_metadata system "priv-app/SamsungSmartSuggestions"
set_metadata system "priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk"


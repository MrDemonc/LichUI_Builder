#!/bin/bash

if [ -f "${dir_work}/out/flags/.now_brief" ]; then
    log_success "Now_brief is already applied"
    exit 0
fi

delete_items "$SOURCE_FIRMWARE/system/system/priv-app/SamsungSmartSuggestions" "SamsungSmartSuggestions.apk"
delete_items "$SOURCE_FIRMWARE/system/system/priv-app/SamsungSmartSuggestions" "oat"
copy_items "$dir_work/platform/customization/mods/now_brief/system/etc/default-permissions" "$SOURCE_FIRMWARE/system/system/etc/default-permissions" "default-permissions-com.samsung.android.app.moments.xml"
copy_items "$dir_work/platform/customization/mods/now_brief/system/etc/permissions" "$SOURCE_FIRMWARE/system/system/etc/permissions" "privapp-permissions-com.samsung.android.app.moments.xml"
copy_items "$dir_work/platform/customization/mods/now_brief/system/etc/sysconfig" "$SOURCE_FIRMWARE/system/system/etc/sysconfig" "moments.xml"
copy_items "$dir_work/platform/customization/mods/now_brief/system/priv-app" "$SOURCE_FIRMWARE/system/system/priv-app" "Moments"

update_config "SEC_FLOATING_FEATURE_COMMON_CONFIG_AI_VERSION" "20253"
update_config "SEC_FLOATING_FEATURE_FRAMEWORK_SUPPORT_PERSONALIZED_DATA_CORE" "TRUE"
update_config "SEC_FLOATING_FEATURE_FRAMEWORK_SUPPORT_AI_BRIEF_FOR_UT" "TRUE"

log_warning "Downloading SamsungSmartSuggestions APK..."

DOWNLOAD_FILE "$(GET_GALAXY_STORE_DOWNLOAD_URL "com.samsung.android.smartsuggestions")" \
    "$dir_work/out/firmware/$SOURCE_FIRMWARE/system/system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk"


add_work "/system/priv-app/Moments" '$SOURCE_FIRMWARE/system'
add_work "/system/priv-app/Moments/Moments.apk" '$SOURCE_FIRMWARE/system'
add_work "/system/etc/permissions/privapp-permissions-com.samsung.android.app.moments.xml" '$SOURCE_FIRMWARE/system'
add_work "/system/etc/default-permissions/default-permissions-com.samsung.android.app.moments.xml" '$SOURCE_FIRMWARE/system'
add_work "/system/etc/sysconfig/moments.xml" '$SOURCE_FIRMWARE/system'

log_success "Process completed successfully"
touch "${dir_work}/out/flags/.now_brief"
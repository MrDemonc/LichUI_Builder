#!/bin/bash

if [ -f "${dir_work}/out/flags/.lich_apps" ]; then
    log_success "Lich_apps is already applied"
    exit 0
fi

copy_items "$dir_work/platform/customization/mods/lich_apps/system/priv-app" "$SOURCE_FIRMWARE/system/system/priv-app" "Updater"
copy_items "$dir_work/platform/customization/mods/lich_apps/system/etc/permissions" "$SOURCE_FIRMWARE/system/system/etc/permissions" "privapp-permissions-com.lich.updater.xml"
copy_items "$dir_work/platform/customization/mods/lich_apps/system/etc/default-permissions" "$SOURCE_FIRMWARE/system/system/etc/default-permissions" "default-permissions-com.lich.updater.xml"

add_work "/system/priv-app/Updater" '$SOURCE_FIRMWARE/system'
add_work "/system/priv-app/Updater/Updater.apk" '$SOURCE_FIRMWARE/system'
add_work "/system/etc/permissions/privapp-permissions-com.lich.updater.xml" '$SOURCE_FIRMWARE/system'
add_work "/system/etc/default-permissions/default-permissions-com.lich.updater.xml" '$SOURCE_FIRMWARE/system'

log_success "Process completed successfully"
touch "${dir_work}/out/flags/.lich_apps"

# Disable
# copy_items "$dir_work/platform/customization/mods/lich_apps/system/priv-app" "$SOURCE_FIRMWARE/system/system/priv-app" "Lich"
# copy_items "$dir_work/platform/customization/mods/lich_apps/system/etc/permissions" "$SOURCE_FIRMWARE/system/system/etc/permissions" "privapp-permissions-com.lichui.settings.xml"
# copy_items "$dir_work/platform/customization/mods/lich_apps/system/etc/default-permissions" "$SOURCE_FIRMWARE/system/system/etc/default-permissions" "default-permissions-com.lichui.settings.xml"
# add_work "/system/priv-app/Lich" '$SOURCE_FIRMWARE/system'
# add_work "/system/priv-app/Lich/Lich.apk" '$SOURCE_FIRMWARE/system'
# add_work "/system/etc/permissions/privapp-permissions-com.lichui.settings.xml" '$SOURCE_FIRMWARE/system'
# add_work "/system/etc/default-permissions/default-permissions-com.lichui.settings.xml" '$SOURCE_FIRMWARE/system'
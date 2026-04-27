#!/bin/bash

if [ -f "${dir_work}/out/flags/.applock" ]; then
    log_success "AppLock is already applied"
    exit 0
fi

copy_items "$dir_work/platform/customization/mods/applock/system/priv-app" "$SOURCE_FIRMWARE/system/system/priv-app" "AppLock"
copy_items "$dir_work/platform/customization/mods/applock/system/etc/permissions" "$SOURCE_FIRMWARE/system/system/etc/permissions" "privapp-permissions-com.samsung.android.applock.xml"

add_work "/system/etc/permissions/privapp-permissions-com.samsung.android.applock.xml" '$SOURCE_FIRMWARE/system'
add_work "/system/priv-app/AppLock" '$SOURCE_FIRMWARE/system'
add_work "/system/priv-app/AppLock/AppLock.apk" '$SOURCE_FIRMWARE/system'

log_success "Process completed successfully"
touch "${dir_work}/out/flags/.applock"
#!/bin/bash

copy_items "$dir_work/platform/customization/mods/applock/system/priv-app" "$SOURCE_FIRMWARE/system/system/priv-app" "AppLock"
copy_items "$dir_work/platform/customization/mods/applock/system/etc/permissions" "$SOURCE_FIRMWARE/system/system/etc/permissions" "privapp-permissions-com.samsung.android.applock.xml"

add system "system/etc/permissions/privapp-permissions-com.samsung.android.applock.xml"
add system "system/priv-app/AppLock" "priv-app/AppLock"
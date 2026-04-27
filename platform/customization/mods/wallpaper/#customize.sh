#!/bin/bash

if [ -f "${dir_work}/out/flags/.wallpaper" ]; then
    log_success "Wallpaper is already applied"
    exit 0
fi

delete_items "$SOURCE_FIRMWARE/system/system/priv-app/wallpaper-res" "wallpaper-res.apk"

cat "$dir_work/platform/customization/mods/wallpaper/system/priv-app/wallpaper-res/wallpaper-res.apk."* \
    > "$FW_DIR/$SOURCE_FIRMWARE/system/system/priv-app/wallpaper-res/wallpaper-res.apk"

log_success "Process completed successfully"
touch "${dir_work}/out/flags/.wallpaper"
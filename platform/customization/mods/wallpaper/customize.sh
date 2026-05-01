#!/bin/bash

delete system "priv-app/wallpaper-res/wallpaper-res.apk"

cat "system/priv-app/wallpaper-res/wallpaper-res.apk."* \
    > "$FW_DIR/$SOURCE_DIR/system/system/priv-app/wallpaper-res/wallpaper-res.apk"

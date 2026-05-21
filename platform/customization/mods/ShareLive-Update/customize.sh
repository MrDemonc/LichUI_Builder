#!/bin/bash

delete system "priv-app/ShareLive/oat"
delete system "priv-app/ShareLive/ShareLive.apk"

log_warning "Downloading ShareLive APK..."

download_file "$(get_galaxy_store_url "com.samsung.android.app.sharelive")" \
    "$FW_DIR/$SOURCE_DIR/system/system/priv-app/ShareLive/ShareLive.apk"

set_metadata system "priv-app/ShareLive"
set_metadata system "priv-app/ShareLive/ShareLive.apk"

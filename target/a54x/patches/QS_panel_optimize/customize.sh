#!/bin/bash

# QS Dowload Throttle V1.1 by SIYNTE
# https://t.me/galaxyA54developer/108751/283309
[ -f "$FW_DIR/$SOURCE_DIR/system/system/etc/init/qs_download_throttle.rc" ] && rm -f "$FW_DIR/$SOURCE_DIR/system/system/etc/init/qs_download_throttle.rc"
{
    echo "on post-fs-data"
    echo "    exec_background -- /system/bin/cmd settings put global notification_rate_limit 2000"  
    echo "    exec_background -- /system/bin/cmd settings put global notification_live_updates 0"
    echo "    exec_background -- /system/bin/cmd setprop persist.sysui.notification_throttle true"
    echo "    exec_background -- /system/bin/cmd setprop persist.sysui.qs_partial_invalidation true"
    echo ""
    echo "on property:sys.boot_completed=1"
    echo "    exec_background -- /system/bin/cmd settings put global notification_rate_limit 1200"
} >> "$FW_DIR/$SOURCE_DIR/system/system/etc/init/qs_download_throttle.rc"

set_metadata "system" "/etc/init/qs_download_throttle.rc"

log_success "Process completed successfully"
touch "${dir_work}/out/flags/.qs_panel"
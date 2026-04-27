#!/bin/bash

if [ -f "${dir_work}/out/flags/.ssrm" ]; then
    log_success "SSRM is already applied"
    exit 0
fi

delete_items "$SOURCE_FIRMWARE/system/system/priv-app/SamsungDeviceHealthManagerService" "SamsungDeviceHealthManagerService.apk"
copy_items "$dir_work/target/$TARGET/patches/ssrm/system/priv-app/SamsungDeviceHealthManagerService" "$SOURCE_FIRMWARE/system/system/priv-app/SamsungDeviceHealthManagerService" "SamsungDeviceHealthManagerService.apk"

log_success "Process completed successfully"
touch "${dir_work}/out/flags/.ssrm"
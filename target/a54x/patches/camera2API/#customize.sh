#!/bin/bash

# Credit TBM13 for: https://github.com/TBM13/Samsung-Camera-Experiments.git

if [ -f "${dir_work}/out/flags/.2API" ]; then
    log_success "Camera2API is already patched"
    exit 0
fi

sudo sed -i '/<\/resources>/i \
\
\t<!-- Lich add features -->\n\t<local name="CAMERA_SUPPORT_PICTURE_FORMAT" value="true"/>' "$dir_work/out/firmware/$SOURCE_FIRMWARE/system/system/cameradata/camera-feature.xml"

HEX_PATCH "$dir_work/target/$TARGET/patches/camera2API/vendor/lib64/hw/camera.s5e8835.so" "28008052291c007201200039080000f9" "13000014291c007201200039080000f9"

HEX_PATCH "$dir_work/target/$TARGET/patches/camera2API/vendor/lib64/hw/camera.s5e8835.so" "ff8301d1fd7b02a9fd830091f85f03a9f65704a9f44f05a957d03bd5d6f6ffb0" "1f7d00a91f0900f9c0035fd66100805228008052ecffff1757d03bd5d6f6ffb0"

delete_items "$TARGET_FIRMWARE/vendor/lib64/hw" "camera.s5e8835.so"
copy_items "$dir_work/target/$TARGET/patches/camera2API/vendor/lib64/hw" "$TARGET_FIRMWARE/vendor/lib64/hw" "camera.s5e8835.so"
copy_items "$dir_work/target/$TARGET/patches/camera2API/vendor/etc/permissions" "$TARGET_FIRMWARE/vendor/etc/permissions" "android.hardware.camera.full.xml"
copy_items "$dir_work/target/$TARGET/patches/camera2API/vendor/etc/permissions" "$TARGET_FIRMWARE/vendor/etc/permissions" "android.hardware.camera.manual_postprocessing.xml"
copy_items "$dir_work/target/$TARGET/patches/camera2API/vendor/etc/permissions" "$TARGET_FIRMWARE/vendor/etc/permissions" "android.hardware.camera.manual_sensor.xml"
copy_items "$dir_work/target/$TARGET/patches/camera2API/vendor/etc/permissions" "$TARGET_FIRMWARE/vendor/etc/permissions" "android.hardware.camera.raw.xml"

add_work "/vendor/etc/permissions/android.hardware.camera.full.xml" '$TARGET_FIRMWARE/vendor'
add_work "/vendor/etc/permissions/android.hardware.camera.manual_postprocessing.xml" '$TARGET_FIRMWARE/vendor'
add_work "/vendor/etc/permissions/android.hardware.camera.manual_sensor.xml" '$TARGET_FIRMWARE/vendor'
add_work "/vendor/etc/permissions/android.hardware.camera.raw.xml" '$TARGET_FIRMWARE/vendor'

log_success "Process completed successfully"
touch "${dir_work}/out/flags/.2API"






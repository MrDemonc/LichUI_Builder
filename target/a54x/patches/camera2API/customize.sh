#!/bin/bash

add vendor "vendor/etc/permissions/android.hardware.camera.full.xml" "etc/permissions/android.hardware.camera.full.xml"
add vendor "vendor/etc/permissions/android.hardware.camera.manual_postprocessing.xml" "etc/permissions/android.hardware.camera.manual_postprocessing.xml"
add vendor "vendor/etc/permissions/android.hardware.camera.manual_sensor.xml" "etc/permissions/android.hardware.camera.manual_sensor.xml"
add vendor "vendor/etc/permissions/android.hardware.camera.raw.xml" "etc/permissions/android.hardware.camera.raw.xml"

sudo sed -i '/<\/resources>/i \
\
\t<!-- Lich add features -->\n\t<local name="CAMERA_SUPPORT_PICTURE_FORMAT" value="true"/>' "$FW_DIR/$SOURCE_DIR/system/system/cameradata/camera-feature.xml"

hex_patch "$FW_DIR/$TARGET_DIR/vendor/lib64/hw/camera.s5e8835.so" "28008052291c007201200039080000f9" "13000014291c007201200039080000f9"

hex_patch "$FW_DIR/$TARGET_DIR/vendor/lib64/hw/camera.s5e8835.so" "ff8301d1fd7b02a9fd830091f85f03a9f65704a9f44f05a957d03bd5d6f6ffb0" "1f7d00a91f0900f9c0035fd66100805228008052ecffff1757d03bd5d6f6ffb0"

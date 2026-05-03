import re

with open("scripts/flashable_zip.sh", "r") as f:
    data = f.read()

# Logging
data = data.replace("LOGE ", "log_error ")
data = data.replace("LOGW ", "log_warning ")
data = data.replace("LOG ", "log_info ")
data = data.replace("LOG_STEP_IN ", "log_info ")
data = data.replace("LOG_STEP_OUT", 'log_success "Done"')

# Variables
data = data.replace('source "$SRC_DIR/scripts/utils/build_utils.sh"', 'source "$dir_scr/utils/build_utils.sh"')
data = data.replace('SRC_DIR', 'dir_work')
data = data.replace('TARGET_CODENAME', 'TARGET')

# Paths
data = data.replace('SOURCE_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$SOURCE_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$SOURCE_FIRMWARE")"', 'SOURCE_FIRMWARE_PATH="$SOURCE_DIR"')
data = data.replace('TARGET_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$TARGET_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$TARGET_FIRMWARE")"', 'TARGET_FIRMWARE_PATH="$TARGET_DIR"')

# Zip name
data = re.sub(r'ZIP_FILE_NAME="UN1CA_.*?"', 'ZIP_FILE_NAME="LichUI_${ROM_VERSION}_$(date +%Y%m%d)_${TARGET}${ZIP_FILE_SUFFIX}"', data)

# Keys
data = re.sub(r'PRIVATE_KEY_PATH=.*?\n.*?fi\nPRIVATE_KEY_PATH\+=".pk8"\nPUBLIC_KEY_PATH\+=".x509.pem"', 'PRIVATE_KEY_PATH="$dir_work/platform/security/lich-ota.pk8"\nPUBLIC_KEY_PATH="$dir_work/platform/security/lich-ota.x509.pem"', data, flags=re.DOTALL)

# Target super group name
data = data.replace('"$TARGET_SUPER_GROUP_NAME"', '"${TARGET_SUPER_GROUP_NAME:-samsung_dynamic_partitions}"')
data = data.replace('${TARGET_SUPER_GROUP_NAME}', '${TARGET_SUPER_GROUP_NAME:-samsung_dynamic_partitions}')

# Target OS file system
data = data.replace('"$TARGET_OS_FILE_SYSTEM_TYPE"', '"${TARGET_OS_FILE_SYSTEM:-erofs}"')

# Updater-binary
data = data.replace('cp -a "$dir_work/prebuilts/bootable/deprecated-ota/updater"', 'cp -a "$dir_work/prebuilt/update-binary/update-binary"')

# Header
data = data.replace('UN1CA $ROM_VERSION', 'LichUI $ROM_VERSION')
data = data.replace('Coded by salvo_giangri @XDAforums', 'Built with LichUI Builder')

# AVB key
data = data.replace('"$dir_work/security/avb/testkey_rsa4096.pem"', '"$dir_work/external/android-tools/vendor/core/fs_mgr/libfs_avb/tests/data/testkey_rsa4096.pem"')

with open("scripts/flashable_zip.sh", "w") as f:
    f.write(data)


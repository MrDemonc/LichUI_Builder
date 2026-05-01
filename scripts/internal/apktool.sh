#!/bin/bash

if [ -f "${dir_work}/out/flags/.apktool" ]; then
    log_success "Apktool patches are already applied"
    exit 0
fi

source "$dir_work/scripts/utils/apktool_utils.sh"
source "$dir_work/scripts/utils/smali_utils.sh"

# Framework configuration
setup_framework

## Jar files to patch

# services.jar
decompile "services.jar"
smali_patch "services.jar" "0005-Disable-SAK-in-DarManagerService.patch"
#source "$dir_work/platform/customization/patches/aosp_signature/signature.sh"
compile "services.jar"

# framework.jar
#decompile "framework.jar"
#smali_patch "framework.jar"
#compile "framework.jar"

# knoxsdk.jar
#decompile "knoxsdk.jar"
#smali_patch "knoxsdk.jar"
#compile "knoxsdk.jar"

# samsungkeystoreutils.jar
#decompile "samsungkeystoreutils.jar"
#smali_patch "samsungkeystoreutils.jar"
#compile "samsungkeystoreutils.jar"

# Apks to patch

# Systemui.apk
#decompile "SystemUI.apk"
#smali_patch "SystemUI.apk"
#compile "SystemUI.apk"

# SecSettings.apk
#decompile "SecSettings.apk"
#smali_patch "SecSettings.apk"
#cp "$dir_work/platform/customization/patches/common/Apk/SecSettings/res/drawable/lich_logo.png" "$dir_work/out/apktool/working/SecSettings/res/drawable/lich_logo.png"
#compile "SecSettings.apk"

# DAAgent.apk
#decompile "DAAgent.apk"
#smali_patch "DAAgent.apk"
#compile "DAAgent.apk"

# BiometricSetting.apk
#decompile "BiometricSetting.apk"
#smali_patch "BiometricSetting.apk"
#compile "BiometricSetting.apk"

# framework-res__r11sxxx__auto_generated_rro_product.apk
decompile "framework-res__r11sxxx__auto_generated_rro_product.apk"
smali_patch "framework-res__r11sxxx__auto_generated_rro_product.apk"
source "$dir_work/target/$TARGET/product/overlay.sh" > /dev/null
compile "framework-res__r11sxxx__auto_generated_rro_product.apk"

log_success "Process completed successfully"
touch "${dir_work}/out/flags/.apktool"
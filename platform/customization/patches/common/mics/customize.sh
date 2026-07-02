smali_patch "SecSettings.apk" "0001-Real-Model-Version.patch"
smali_patch "SecSettings.apk" "0002-OneUI-minor-version.patch"
smali_patch "SecSettings.apk" "0003-Battery-info.patch"
smali_patch "SecSettings.apk" "0004-Introduce-Lich-Updater.patch"

# Hide United Arab Emirates in About device phone
SMALI_PATCH "SecSettings" \
        "smali_classes5/com/samsung/android/settings/deviceinfo/aboutphone/DeviceInfoHeader.smali" "replace" \
        'initInfoChart()V' \
        'if-eqz v0, :cond_9' \
        'goto :cond_9'

smali_patch "framework.jar" "0001-Introduce-CsFeatureHooks.patch"
smali_patch "SecSettings.apk" "0001-Enable-real-time-network-speed-in-status-bar.patch"
smali_patch "SecSettings.apk" "0002-Enable-quick-switch-to-Secure-Folder-Feature.patch"
smali_patch "SecSettings.apk" "0003-Hide-Remote-Management-Title-In-Settings-App.patch"
smali_patch "SecSettings.apk" "0004-Enable-Power-Off-Lock-Feature.patch"
smali_patch "SystemUI.apk" "0001-Enable-real-time-network-speed-in-status-bar.patch"
smali_patch "SystemUI.apk" "0002-Enable-Smart-View-Tile-Visibility-settings.patch"
smali_patch "SystemUI.apk" "0003-Enable-Power-Off-Lock-Feature.patch"
smali_patch "SystemUI.apk" "0004-Fix-padding-network-speed-icon.patch"

# Enable-Power-Off-Lock-Feature -> framework.jar
SMALI_PATCH "framework" \
    "smali_classes6/com/samsung/android/globalactions/util/SystemPropertiesWrapper.smali" "return" \
    'isBrazilianCountryISO()Z' \
    'true'
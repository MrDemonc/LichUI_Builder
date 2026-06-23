# Bypass SamsungDex Floating Feature
# SUPPORT_DUAL_DESKTOP_MODE, SUPPORT_WIRELESS_DESKTOP_MODE
# SUPPORT_FIXED_ZOOM_DESKTOP_MODE

SMALI_PATCH "SecSettings" \
    "smali_classes5/com/samsung/android/settings/Rune.smali" \
    "return" \
    "supportDesktopMode()Z" \
    "true"
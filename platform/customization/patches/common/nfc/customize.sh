# Change nfc value antpos=1 for antpos=16 in SecSettings

SMALI_PATCH "SecSettings" \
        "smali_classes5/com/samsung/android/settings/nfc/NfcSettings.smali" "replace" \
        'populateViewForOrientation(Lcom/android/settingslib/widget/LayoutPreference;)V' \
        '1' \
        "$ANTPOS"

SMALI_PATCH "SecSettings" \
        "smali_classes5/com/samsung/android/settings/nfc/NfcAntennaGuideDialog.smali" "replace" \
        'onCreate(Landroid/os/Bundle;)V' \
        '1' \
        "$ANTPOS"
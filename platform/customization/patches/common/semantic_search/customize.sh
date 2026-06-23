# Copy raw files
cp -a "$CURRENT_PATCH_DIR/system/priv-app/SecSettingsIntelligence.apk/res/raw/"* "$APKTOOL/working/SecSettingsIntelligence/res/raw/"

SMALI_PATCH "SecSettingsIntelligence" \
    "smali_classes2/com/samsung/android/settings/intelligence/Rune.smali" "replaceall" \
    "const-string v1, \\\"\\\"" \
    "const-string v1, \\\"400\\\""
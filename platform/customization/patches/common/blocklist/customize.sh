delete system "etc/ldu_blocklist.xml"

add system "$CURRENT_PATCH_DIR/system/etc/lich_blocklist.xml" "etc/lich_blocklist.xml"

smali_patch "services.jar" "0001-Allow-custom-PackageBlockListPolicy.patch"

SMALI_PATCH "services" \
    "smali_classes2/com/samsung/android/server/pm/install/PackageBlockListPolicy\$1.smali" 'remove'

# Install Apps from priv-app
SMALI_PATCH "services" \
    "smali_classes2/com/android/server/pm/InstallPackageHelper.smali" "replace" \
    'processParseResult(Lcom/android/server/pm/ParallelPackageParser$ParseResult;)V' \
    'sget-boolean v2, Lcom/samsung/android/rune/PMRune;->PM_ALLOWED_SYSTEM_PRELOAD_APPS:Z' \
    'goto :cond_0'
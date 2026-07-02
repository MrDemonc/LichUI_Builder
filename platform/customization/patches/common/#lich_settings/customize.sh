# SecSettings
smali_patch "SecSettings.apk" "0001-Add-Lich-Settings.patch"
cp -a "$CURRENT_PATCH_DIR/system/priv-app/SecSettings.apk/res/drawable/lich_logo.png" "$APKTOOL/working/SecSettings/res/drawable/lich_logo.png"
# Services
smali_patch "services.jar" "0001-Allow-Disable-ScreenShot-Detection.patch"
smali_patch "services.jar" "0002-Allow-ScreenShot.patch"
smali_patch "services.jar" "0003-Introduce-HideAppListUtils.patch"
smali_patch "services.jar" "0004-Introduce-PlayIntegrityHooks.patch"
# Framework
smali_patch "framework.jar" "0001-Introduce-SamsungPropsHooks.patch"
smali_patch "framework.jar" "0002-FloatingFeatureHook.patch"
smali_patch "framework.jar" "0003-Allow-unlimited-storage-for-google-Photos.patch"
# smali_patch "framework.jar" "0004-Nuke-Knox-Matrix-AI-Privacy.patch"
smali_patch "framework.jar" "0005-Introduce-HideAppListUtils.patch"
smali_patch "framework.jar" "0006-Introduce-PlayIntegrityHooks.patch"
smali_patch "framework.jar" "0007-Introduce-KeyboxImitationHooks.patch"
# Knoxsdk
smali_patch "knoxsdk.jar" "0001-Introduce-SamsungPropsHooks.patch"

# Storage root
SMALI_PATCH "services" \
    "smali/com/android/server/StorageManagerService.smali" "return" \
    "isRootedDevice()Z" \
    "false"

# Introduce-SamsungPropsHooks
SMALI_PATCH "framework" \
    "smali/android/app/Instrumentation.smali" "replace" \
    'newApplication(Ljava/lang/Class;Landroid/content/Context;)Landroid/app/Application;' \
    'invoke-virtual {p0, p1}, Landroid/app/Application;->attach(Landroid/content/Context;)V' \
    '    invoke-virtual {p0, p1}, Landroid/app/Application;->attach(Landroid/content/Context;)V\n\n    invoke-static {p1}, Lio/lichlabs/lich/SamsungPropsHooks;->init(Landroid/content/Context;)V\n\n    invoke-static {p1}, Lio/lichlabs/lich/PlayIntegrityHooks;->setProps(Landroid/content/Context;)V'

SMALI_PATCH "framework" \
    "smali/android/app/Instrumentation.smali" "replace" \
    'newApplication(Ljava/lang/ClassLoader;Ljava/lang/String;Landroid/content/Context;)Landroid/app/Application;' \
    'invoke-virtual {p0, p3}, Landroid/app/Application;->attach(Landroid/content/Context;)V' \
    '    invoke-virtual {p0, p3}, Landroid/app/Application;->attach(Landroid/content/Context;)V\n\n    invoke-static {p3}, Lio/lichlabs/lich/SamsungPropsHooks;->init(Landroid/content/Context;)V\n\n    invoke-static {p3}, Lio/lichlabs/lich/PlayIntegrityHooks;->setProps(Landroid/content/Context;)V'

# Nuke-Knox-Matrix-AI-Privacy.patch
#rm -rf "$APKTOOL/working/framework/smali_classes6/com/samsung/android/kmxservice/ai/privacy/PermissionData$1.smali"
#rm -rf "$APKTOOL/working/framework/smali_classes6/com/samsung/android/kmxservice/ai/privacy/PermissionData.smali"
#rm -rf "$APKTOOL/working/framework/smali_classes6/com/samsung/android/kmxservice/ai/privacy/PermissionDataController$1.smali"
#rm -rf "$APKTOOL/working/framework/smali_classes6/com/samsung/android/kmxservice/ai/privacy/PermissionDataController$2.smali"
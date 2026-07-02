smali_patch "SamsungSmartSuggestions.apk" "0001-Now-Brief.patch"
smali_patch "SamsungSmartSuggestions.apk" "0001-NowNudge.patch"

# NowNudge
#SMALI_PATCH "SamsungSmartSuggestions" \
#        "smali_classes13/com/samsung/android/smartsuggestions/featureconfig/rune/Rune.smali" \
#        "return" \
#        "public final getSUPPORT_NOW_NUDGE()Z" \
#        "true"

#SMALI_PATCH "SamsungSmartSuggestions" \
#        "smali_classes13/com/samsung/android/smartsuggestions/service/screenintelligence/setting/NowNudgesSettingHelper.smali" \
#        "return" \
#        "private final internalNowNudgesSwitchOn(Landroid/content/Context;)Z" \
#        "true"
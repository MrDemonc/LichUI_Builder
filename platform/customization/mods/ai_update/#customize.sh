#!/bin/bash

if [ -f "${dir_work}/out/flags/.ai_update" ]; then
    log_success "Ai_update is already applied"
    exit 0
fi

# Update AI
update_config "SEC_FLOATING_FEATURE_COMMON_CONFIG_AI_VERSION" "20261"

# SketchBook
if [ -d "$dir_work/out/firmware/$SOURCE_FIRMWARE/system/system/app/SketchBook" ];then
    :
else
    mkdir -p "$dir_work/out/firmware/$SOURCE_FIRMWARE/system/system/app/SketchBook"
    cat "$dir_work/platform/customization/mods/ai_update/system/app/SketchBook/SketchBook.apk."* \
    > "$FW_DIR/$SOURCE_FIRMWARE/system/system/app/SketchBook/SketchBook.apk"
fi

# Languaje Offline
update_config "SEC_FLOATING_FEATURE_GENAI_SUPPORT_OFFLINE_LANGUAGEMODEL" "TRUE"
copy_items "$dir_work/platform/customization/mods/ai_update/system/priv-app" "$SOURCE_FIRMWARE/system/system/priv-app" "OfflineLanguageModel_stub"

# Audio Eraser
# update_config "SEC_FLOATING_FEATURE_AUDIO_CONFIG_MULTISOURCE_SEPARATOR" "{FastScanning_6, SourceSeparator_4, Version_1.3.0}"
# update_config "SEC_FLOATING_FEATURE_MMFW_CONFIG_MEDIA_CONTEXT_ANALYZER_CORE" "GPU"
# update_config "SEC_FLOATING_FEATURE_MMFW_SUPPORT_MEDIA_CONTEXT_ANALYZER" "TRUE"

# copy_items "$dir_work/platform/customization/mods/ai_update/system/etc" "$SOURCE_FIRMWARE/system/system/etc" "audio_ae_intervals.conf"
# copy_items "$dir_work/platform/customization/mods/ai_update/system/etc" "$SOURCE_FIRMWARE/system/system/etc" "fastScanner.tflite"
# copy_items "$dir_work/platform/customization/mods/ai_update/system/etc" "$SOURCE_FIRMWARE/system/system/etc" "mss_v0.23.0_VMWO_2_fp32.sorione"
copy_items "$dir_work/platform/customization/mods/ai_update/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "libaplayer.so"
# copy_items "$dir_work/platform/customization/mods/ai_update/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "libC2paDps.camera.samsung.so"
# copy_items "$dir_work/platform/customization/mods/ai_update/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "libmediacontextanalyzer.so"
# copy_items "$dir_work/platform/customization/mods/ai_update/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "libmediasndk.so"
# copy_items "$dir_work/platform/customization/mods/ai_update/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "libmultisourceseparator.so"
# copy_items "$dir_work/platform/customization/mods/ai_update/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "libsbs.so"
# copy_items "$dir_work/platform/customization/mods/ai_update/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "libtensorflowlite_gpu_delegate.so"
# copy_items "$dir_work/platform/customization/mods/ai_update/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "libveframework.videoeditor.samsung.so"
# copy_items "$dir_work/platform/customization/mods/ai_update/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "libvideo-highlight-arm64-v8a.so"
# copy_items "$dir_work/platform/customization/mods/ai_update/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "libvoice_booster.so"


# add_work "/system/etc/audio_ae_intervals.conf" '$SOURCE_FIRMWARE/system'
# add_work "/system/etc/fastScanner.tflite" '$SOURCE_FIRMWARE/system'
# add_work "/system/etc/mss_v0.23.0_VMWO_2_fp32.sorione" '$SOURCE_FIRMWARE/system'
add_work "/system/lib64/libaplayer.so" '$SOURCE_FIRMWARE/system'
# add_work "/system/lib64/libC2paDps.camera.samsung.so" '$SOURCE_FIRMWARE/system'
# add_work "/system/lib64/libmediacontextanalyzer.so" '$SOURCE_FIRMWARE/system'
# add_work "/system/lib64/libmediasndk.so" '$SOURCE_FIRMWARE/system'
# add_work "/system/lib64/libmultisourceseparator.so" '$SOURCE_FIRMWARE/system'
# add_work "/system/lib64/libsbs.so" '$SOURCE_FIRMWARE/system'
# add_work "/system/lib64/libtensorflowlite_gpu_delegate.so" '$SOURCE_FIRMWARE/system'
# add_work "/system/lib64/libveframework.videoeditor.samsung.so" '$SOURCE_FIRMWARE/system'
# add_work "/system/lib64/libvideo-highlight-arm64-v8a.so" '$SOURCE_FIRMWARE/system'
# add_work "/system/lib64/libvoice_booster.so" '$SOURCE_FIRMWARE/system'
add_work "/system/priv-app/OfflineLanguageModel_stub" '$SOURCE_FIRMWARE/system'
add_work "/system/priv-app/OfflineLanguageModel_stub/OfflineLanguageModel_stub.apk" '$SOURCE_FIRMWARE/system'
add_work "/system/app/SketchBook" '$SOURCE_FIRMWARE/system'
add_work "/system/app/SketchBook/SketchBook.apk" '$SOURCE_FIRMWARE/system'

log_success "Process completed successfully"
touch "${dir_work}/out/flags/.ai_update"
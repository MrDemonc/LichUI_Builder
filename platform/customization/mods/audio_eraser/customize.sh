#!/bin/bash

update_config "SEC_FLOATING_FEATURE_AUDIO_CONFIG_MULTISOURCE_SEPARATOR" "{FastScanning_6, SourceSeparator_4, Version_1.3.0}"
update_config "SEC_FLOATING_FEATURE_MMFW_CONFIG_MEDIA_CONTEXT_ANALYZER_CORE" "GPU"
update_config "SEC_FLOATING_FEATURE_MMFW_SUPPORT_MEDIA_CONTEXT_ANALYZER" "TRUE"

if [ -d "$FW_DIR/$SOURCE_DIR/system/system/etc/mediacontextanalyzer" ]; then
    :
else
    mkdir -p "$FW_DIR/$SOURCE_DIR/system/system/etc/mediacontextanalyzer"
    set_metadata system "etc/mediacontextanalyzer"
fi

cat "system/etc/mediacontextanalyzer/human-pet-pose_SR-V200.tflite."* \
    > "$FW_DIR/$SOURCE_DIR/system/system/etc/mediacontextanalyzer/human-pet-pose_SR-V200.tflite"
set_metadata system "etc/mediacontextanalyzer/human-pet-pose_SR-V200.tflite"

add system "system/etc/audio_ae_intervals.conf" "etc/audio_ae_intervals.conf" 
add system "system/etc/fastScanner.tflite" "etc/fastScanner.tflite"
add system "system/etc/mss_v0.23.0_VMWO_2_fp32.sorione" "etc/mss_v0.23.0_VMWO_2_fp32.sorione"
add system "system/etc/public.libraries-audio.samsung.txt" "etc/public.libraries-audio.samsung.txt"

add system "system/lib64/libmediasndk.mediacore.samsung.so" "lib64/libmediasndk.mediacore.samsung.so"
add system "system/lib64/libmediasndk.so" "lib64/libmediasndk.so"
add system "system/lib64/libmultisourceseparator.audio.samsung.so" "lib64/libmultisourceseparator.audio.samsung.so"
add system "system/lib64/libmultisourceseparator.so" "lib64/libmultisourceseparator.so"
add system "system/lib64/libsbs.so" "lib64/libsbs.so"
add system "system/lib64/libtensorflowlite_gpu_delegate.so" "lib64/libtensorflowlite_gpu_delegate.so"
add system "system/lib64/libveframework.videoeditor.samsung.so" "lib64/libveframework.videoeditor.samsung.so"
add system "system/lib64/libcontextanalyzer_jni.media.samsung.so" "lib64/libcontextanalyzer_jni.media.samsung.so"
add system "system/lib64/libmediacontextanalyzer.so" "lib64/libmediacontextanalyzer.so"
add system "system/lib64/libvideo-highlight-arm64-v8a.so" "lib64/libvideo-highlight-arm64-v8a.so"
add system "system/lib64/libaplayer.so" "lib64/libaplayer.so"
add system "system/lib64/android.media.audio.eraser.types-V1-ndk.so" "lib64/android.media.audio.eraser.types-V1-ndk.so"
add system "system/lib64/libC2paDps.camera.samsung.so" "lib64/libC2paDps.camera.samsung.so"
add system "system/lib64/libaudiocoreaaudiorecorder.so" "lib64/libaudiocoreaaudiorecorder.so"
add system "system/lib64/libvoice_booster.so" "lib64/libvoice_booster.so"

add system "system/etc/mediacontextanalyzer/Detection.tflite" "etc/mediacontextanalyzer/Detection.tflite"
add system "system/etc/mediacontextanalyzer/human-pet-det_SR-V131.tflite" "etc/mediacontextanalyzer/human-pet-det_SR-V131.tflite"
add system "system/etc/mediacontextanalyzer/keyword-classification_SR-V031.tflite" "etc/mediacontextanalyzer/keyword-classification_SR-V031.tflite"
add system "system/etc/mediacontextanalyzer/Keyword.tflite" "etc/mediacontextanalyzer/Keyword.tflite"
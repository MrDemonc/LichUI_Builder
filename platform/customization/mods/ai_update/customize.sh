#!/bin/bash

# Update AI Version
update_config "SEC_FLOATING_FEATURE_COMMON_CONFIG_AI_VERSION" "20261"

# Offline Language Support
update_config "SEC_FLOATING_FEATURE_GENAI_SUPPORT_OFFLINE_LANGUAGEMODEL" "TRUE"
add system "system/priv-app/OfflineLanguageModel_stub" "priv-app/OfflineLanguageModel_stub"

# SketchBook
local sb_check="$FW_DIR/$SOURCE_DIR/system/system/app/SketchBook"
[ ! -d "$sb_check" ] && sb_check="$FW_DIR/$SOURCE_DIR/system/app/SketchBook"

if [ -d "$sb_check" ]; then
    log_info "SketchBook already present in system ... replace"
    delete system "app/SketchBook"
    add system "system/app/SketchBook" "app/SketchBook"
    else
    log info "Add SketchBook"
    add system "system/app/SketchBook" "app/SketchBook"
fi

# VisionModel-Stub
local sb_check="$FW_DIR/$SOURCE_DIR/system/system/app/VisionModel-Stub"
[ ! -d "$sb_check" ] && sb_check="$FW_DIR/$SOURCE_DIR/system/app/VisionModel-Stub"

# Floating Features IA
update_config "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_MOTIONPHOTO_AUTO_TRIM_MODE" "TRUE"
update_config "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_MOTIONPHOTO_SOUND_TIMING" "TRUE"
update_config "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_MOTIONPHOTO_SOUND_TYPE" "TRUE"
update_config "SEC_FLOATING_FEATURE_MMFW_SUPPORT_VIDEOSERACH" "TRUE"
update_config "SEC_FLOATING_FEATURE_MMFW_SUPPORT_VIDEO_SEARCH" "TRUE"
update_config "SEC_FLOATING_FEATURE_MSCH_SUPPORT_NLSEARCH" "TRUE"
update_config "SEC_FLOATING_FEATURE_COMMON_SUPPORT_HIGH_PERFORMANCE_MODE" "TRUE"
update_config "SEC_FLOATING_FEATURE_MMFW_SUPPORT_AI_SOUND_ERASER" "TRUE"
update_config "SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_RAY_TRACING" "TRUE"


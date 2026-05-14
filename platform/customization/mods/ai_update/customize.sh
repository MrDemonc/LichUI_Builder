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
    log_info "SketchBook already present in system"
else
    add system "system/app/SketchBook" "app/SketchBook"
fi

# VisionModel-Stub
local sb_check="$FW_DIR/$SOURCE_DIR/system/system/app/VisionModel-Stub"
[ ! -d "$sb_check" ] && sb_check="$FW_DIR/$SOURCE_DIR/system/app/VisionModel-Stub"


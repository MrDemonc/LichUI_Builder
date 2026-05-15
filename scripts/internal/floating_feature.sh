#!/bin/bash

source "$dir_scr/utils/utils.sh"

log_info "Starting Floating Feature update process..."

# Persistence Check
FF_FLAG="$dir_work/out/flags/.ff_patched"
if [ -f "$FF_FLAG" ]; then
    log_success "Floating Features are already updated. Skipping."
    exit 0
fi

# Config locations
FF_PATCH_DIR="$dir_work/target/$TARGET/patches/floating_Feature"
FF_CONFIG_FILE="$FF_PATCH_DIR/ff.sh"

if [ ! -f "$FF_CONFIG_FILE" ]; then
    log_error "Configuration file not found: $FF_CONFIG_FILE"
    exit 1
fi

# Source the configuration file to get variables (like FEATURES_TO_DELETE)
source "$FF_CONFIG_FILE"

# 1. Handle deletions
if [ -n "$FEATURES_TO_DELETE" ]; then
    for feature in "${FEATURES_TO_DELETE[@]}"; do
        update_config "$feature" "delete"
    done
fi

# 2. Handle updates/additions from ff.sh
# We read the file line by line to support the KEY=VALUE format
while IFS='=' read -r key value || [[ -n "$key" ]]; do
    # Skip comments, empty lines, and the special FEATURES_TO_DELETE array
    [[ -z "$key" || "$key" =~ ^[[:space:]]*# || "$key" == "FEATURES_TO_DELETE" ]] && continue
    
    # Strip spaces and quotes
    key=$(echo "$key" | tr -d '[:space:]')
    value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
    
    # Only process keys starting with SEC_FLOATING_FEATURE
    if [[ "$key" =~ ^SEC_FLOATING_FEATURE_ ]]; then
        update_config "$key" "$value"
    fi
done < "$FF_CONFIG_FILE"

# Create flag
mkdir -p "$(dirname "$FF_FLAG")"
touch "$FF_FLAG"

log_success "Floating features update process completed successfully"

#!/bin/bash
# ---------------------------------------------------------
# Patching Engine (Magisk-style) with Persistence
# ---------------------------------------------------------

# Load core utilities (Auto-loads common and logs)
SOURCE_DIR_LOCAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SOURCE_DIR_LOCAL/utils/utils.sh"


# Ensure environment is strictly managed
set -e

# Persistent state file
STATE_FILE="$dir_work/out/.applied_patches"
mkdir -p "$(dirname "$STATE_FILE")"
touch "$STATE_FILE"

# Target and Platform patch locations
PATCH_DIRS=(
    "$dir_work/target/$TARGET/patches"
    "$dir_work/platform/customization"
)

log_info "Initializing Patching Engine..."

# Loop through patch directories
for BASE_DIR in "${PATCH_DIRS[@]}"; do
    if [ ! -d "$BASE_DIR" ]; then
        continue
    fi

    log_info "Scanning for patches in: $BASE_DIR"
    
    # Recursively find customize.sh scripts
    while IFS= read -r script_path; do
        script_name=$(basename "$script_path")
        script_dir=$(dirname "$script_path")
        
        # Create a unique ID for this patch (relative path)
        patch_id="${script_path#$dir_work/}"

        # Skip if filename starts with #
        if [[ "$script_name" == "#"* ]]; then
            log "  [Skipped] (Disabled) $script_dir"
            continue
        fi

        # Check if already applied successfully in a previous run
        if grep -Fxq "$patch_id" "$STATE_FILE"; then
            log "  [Skipped] (Already Applied) $(basename "$script_dir")"
            continue
        fi

        # Enter patch directory context
        pushd "$script_dir" > /dev/null
        
        # Clear previous module variables to avoid leakage
        unset name author id version versionCode description
        
        # Load module.prop variables (Magisk compatibility)
        if [ -f "module.prop" ]; then
            while IFS='=' read -r key value || [ -n "$key" ]; do
                [[ "$key" =~ ^#.* ]] && continue
                [ -z "$key" ] && continue
                
                # Strip carriage return and leading/trailing spaces
                clean_key=$(echo "$key" | tr -d '\r[[:space:]]')
                clean_value=$(echo "$value" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
                
                export "$clean_key"="$clean_value"
            done < "module.prop"
        fi


        # Show personalized info
        display_name="${name:-$(basename "$script_dir")}"
        if [ -n "$author" ]; then
            log_info "Patching: $display_name by $author"
        else
            log_info "Patching: $display_name"
        fi

        # Execute customization script
        if ! source "./$script_name"; then
            log_error "Patch execution failed at: $script_path"
            exit 1
        fi

        popd > /dev/null
        
        # Save success state
        echo "$patch_id" >> "$STATE_FILE"
        log_success "Customization applied successfully"
        
    done < <(find "$BASE_DIR" -type f \( -name "customize.sh" -o -name "#customize.sh" \))
done

log_success "Patching process completed."

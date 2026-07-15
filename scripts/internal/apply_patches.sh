#!/bin/bash

source "$dir_scr/utils/utils.sh"
source "$dir_work/platform/core/config/version.sh"

set -e

# Persistent state file
STATE_FILE="$dir_work/out/flags/.applied_patches"
mkdir -p "$(dirname "$STATE_FILE")"
touch "$STATE_FILE"

# Target and Platform patch locations
PATCH_DIRS=(
    "$dir_work/target/$TARGET/patches"
    "$dir_work/target/$TARGET/mods"
    "$dir_work/platform/customization/mods"
)

log_info "Initializing Patching Engine..."

# Arrays to categorize patches
ACTIVE_PATCHES=()
APPLIED_PATCHES=()
DISABLED_PATCHES=()

# 1. SCAN AND CATEGORIZE EVERYTHING
for BASE_DIR in "${PATCH_DIRS[@]}"; do
    if [ ! -d "$BASE_DIR" ]; then continue; fi
    
    while IFS= read -r script_path; do
        script_name=$(basename "$script_path")
        script_dir=$(dirname "$script_path")
        patch_id="${script_path#$dir_work/}"

        if [[ "$script_name" == "#"* ]]; then
            DISABLED_PATCHES+=("$script_path")
        elif grep -Fxq "$patch_id" "$STATE_FILE"; then
            APPLIED_PATCHES+=("$script_path")
        else
            ACTIVE_PATCHES+=("$script_path")
        fi
    done < <(find "$BASE_DIR" -type f \( -name "customize.sh" -o -name "#customize.sh" \))
done

# 2. EXECUTE ACTIVE PATCHES
if [ ${#ACTIVE_PATCHES[@]} -gt 0 ]; then
    for script_path in "${ACTIVE_PATCHES[@]}"; do
        script_name=$(basename "$script_path")
        script_dir=$(dirname "$script_path")
        patch_id="${script_path#$dir_work/}"

        pushd "$script_dir" > /dev/null
        
        # Load module.prop
        unset name author id version versionCode description
        if [ -f "module.prop" ]; then
            while IFS='=' read -r key value || [ -n "$key" ]; do
                [[ "$key" =~ ^#.* ]] && continue
                [ -z "$key" ] && continue
                clean_key=$(echo "$key" | tr -d '\r[[:space:]]')
                clean_value=$(echo "$value" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
                export "$clean_key"="$clean_value"
            done < "module.prop"
        fi

        display_name="${name:-$(basename "$script_dir")}"
        if [ -n "$author" ]; then
            echo -e "\n\033[1;36m[I]\033[0m \033[1;37mPatching:\033[0m \033[1;35m$display_name\033[0m \033[1;34m(by $author)\033[0m\n"
        else
            echo -e "\n\033[1;36m[I]\033[0m \033[1;37mPatching:\033[0m \033[1;35m$display_name\033[0m\n"
        fi




        # Function to run the script in a local scope
        run_patch_script() {
            source "$1"
        }

        if ! run_patch_script "./$script_name"; then
            log_error "Patch execution failed at: $script_path"
            exit 1
        fi


        popd > /dev/null
        echo "$patch_id" >> "$STATE_FILE"
        log_success "Customization applied successfully"
    done
else
    log_info "No new patches to apply."
fi

# 3. LIST ALREADY APPLIED
if [ ${#APPLIED_PATCHES[@]} -gt 0 ]; then
    echo -e "\n\033[1;33m[W] Patches already applied:\033[0m"
    for script_path in "${APPLIED_PATCHES[@]}"; do
        rel_path="${script_path%/*}"
        rel_path="${rel_path#$dir_work/}"
        patch_name=$(basename "$(dirname "$script_path")")
        echo -e "\033[1;33m[Skipped]\033[0m \033[1;37m(Applied) $patch_name -> $rel_path\033[0m"
    done
fi

# 4. LIST DISABLED
if [ ${#DISABLED_PATCHES[@]} -gt 0 ]; then
    echo -e "\n\033[1;33m[W] Patches disabled:\033[0m"
    for script_path in "${DISABLED_PATCHES[@]}"; do
        rel_path="${script_path%/*}"
        rel_path="${rel_path#$dir_work/}"
        # For disabled patches, the folder might have the # or the script. 
        # We show the folder name cleaned of #
        patch_name=$(basename "$(dirname "$script_path")" | tr -d '#')
        echo -e "\033[1;33m[Skipped]\033[0m \033[1;37m(Disabled) $patch_name -> $rel_path\033[0m"
    done
fi

echo " "
log_success "Patching process completed."

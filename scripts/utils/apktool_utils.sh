#!/bin/bash

# Load project utilities
source "$dir_work/scripts/utils/utils.sh"

# ========================================================
# Variables and Paths
# ========================================================

readonly PORT_ROM="$FW_DIR/$SOURCE_DIR"
readonly SYSTEM_DIR="${PORT_ROM}/system/system"
readonly FRAMEWORK="${SYSTEM_DIR}/framework"
readonly PRODUCT_DIR="${PORT_ROM}/product"
readonly PRODUCT_OVERLAY="${PRODUCT_DIR}/overlay"
readonly APKTOOL="${dir_work}/out/apktool"
readonly DECOMPILE_DIR="${APKTOOL}/working"
readonly PRIV_APP="${SYSTEM_DIR}/priv-app"
readonly APP="${SYSTEM_DIR}/app"
readonly SYSTEM_UI="${SYSTEM_DIR}/system_ext/priv-app"

readonly FRAMEWORK_DIR="${dir_work}/tools/framework"
readonly FRAMEWORK_RES="${FRAMEWORK}/framework-res.apk"
readonly FRAMEWORK_TAG="$(get_prop "$FW_DIR/$SOURCE_DIR/system/system/build.prop" "ro.system.build.version.incremental")"

COPY_LIST=(
    "$APP/DAAgent:DAAgent.apk"
    "$PRIV_APP/BiometricSetting:BiometricSetting.apk"
    "$PRIV_APP/SecSettings:SecSettings.apk"
    "$PRIV_APP/SecSettingsIntelligence:SecSettingsIntelligence.apk"
    "$PRODUCT_OVERLAY:framework-res__r11sxxx__auto_generated_rro_product.apk"
    "$SYSTEM_UI/SystemUI:SystemUI.apk"
    "$FRAMEWORK:services.jar"
    "$FRAMEWORK:framework.jar"
    "$FRAMEWORK:knoxsdk.jar"
    "$FRAMEWORK:samsungkeystoreutils.jar"
)

# ========================================================
# Internal Helpers
# ========================================================

_ensure_apktool_dir() {
    if [ ! -d "$APKTOOL" ]; then
        mkdir -p "$APKTOOL"
    fi
}

# check_and_copy_file <filename>
# Searches for the filename in COPY_LIST and copies it to the APKTOOL directory if missing.
check_and_copy_file() {
    local target_filename="$1"
    _ensure_apktool_dir

    if [ -f "$APKTOOL/$target_filename" ] || [ -d "$APKTOOL/$target_filename" ]; then
        return 0
    fi

    for item in "${COPY_LIST[@]}"; do
        if [[ "$item" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        local src_path="${item%:*}"
        local entry_filename="${item#*:}"

        if [ "$entry_filename" = "$target_filename" ]; then
            if [ ! -d "$src_path" ]; then
                log_error "Source directory not found: $src_path"
                return 1
            fi
            if [ ! -f "$src_path/$entry_filename" ] && [ ! -d "$src_path/$entry_filename" ]; then
                log_error "File/directory not found: $src_path/$entry_filename"
                return 1
            fi

            if [ -f "$src_path/$entry_filename" ]; then
                cp "$src_path/$entry_filename" "$APKTOOL/"
            elif [ -d "$src_path/$entry_filename" ]; then
                cp -r "$src_path/$entry_filename" "$APKTOOL/"
            fi
            return 0
        fi
    done

    log_error "File $target_filename not found in COPY_LIST. Cannot copy automatically."
    return 1
}

# ========================================================
# Public Functions
# ========================================================

setup_framework() {
    if [ -f "$FRAMEWORK_RES" ]; then
        "$dir_work/tools/bin/apktool" if --quiet -p "$FRAMEWORK_DIR" -t "$FRAMEWORK_TAG" "$FRAMEWORK_RES" || return 1
        return 0
    else
        log_error "Not found framework-res.apk at $FRAMEWORK_RES."
        return 1
    fi
}

decompile() {
    local input_name="$1"
    if [ -z "$input_name" ]; then
        log_error "Usage: decompile <apk|jar>"
        return 1
    fi

    # Ensure file is available in APKTOOL dir
    check_and_copy_file "$input_name" || return 1

    local input_file="$APKTOOL/$input_name"
    local base_name
    base_name="$(basename "$input_file" .apk)"
    base_name="${base_name%.jar}"
    local output_dir="$DECOMPILE_DIR/$base_name"

    if [ -d "$output_dir" ]; then
        rm -rf "$output_dir"
    fi

    log_warning "Decompiling $input_name"

    if ! "$dir_work/tools/bin/apktool" d --quiet --no-debug-info -j "$(( $(nproc) - 1 ))" -o "$output_dir" -p "$FRAMEWORK_DIR" -t "$FRAMEWORK_TAG" "$input_file"; then
        log_error "Failed to decompile $input_name"
        return 1
    fi
}

smali_patch() {
    local input_name="$1"
    local specific_patch="$2"
    if [ -z "$input_name" ]; then
        log_error "Usage: smali_patch <apk|jar> [patch_name]"
        return 1
    fi

    local base_name
    base_name="$(basename "$input_name" .apk)"
    base_name="${base_name%.jar}"
    local target_dir="$DECOMPILE_DIR/$base_name"

    if [ ! -d "$target_dir" ]; then
        log_error "Decompiled directory not found: $target_dir"
        log_error "Run 'decompile $input_name' first"
        return 1
    fi

    local patches_root="$dir_work/platform/customization/patches"

    local applied_any=false

    # If CURRENT_PATCH_DIR is set (called from a customize.sh), look for patch files there
    if [ -n "$CURRENT_PATCH_DIR" ]; then
        local search_dir="$CURRENT_PATCH_DIR/system"
        if [ -d "$search_dir" ]; then
            local patch_files=()
            if [ -n "$specific_patch" ]; then
                local pf=$(find "$search_dir" -path "*/$input_name/$specific_patch" -type f 2>/dev/null | head -1)
                [ -n "$pf" ] && patch_files+=("$pf")
            else
                while IFS= read -r -d '' pf; do
                    patch_files+=("$pf")
                done < <(find "$search_dir" -name "*.patch" -type f -print0 2>/dev/null)
            fi

            if [ ${#patch_files[@]} -gt 0 ]; then
                applied_any=true
                (
                    cd "$target_dir" || exit 1
                    for patch_file in "${patch_files[@]}"; do
                        [ ! -f "$patch_file" ] && continue
                        [[ "$(basename "$patch_file")" == "#"* ]] && continue
                        log_warning "- Applying patch: $(basename "$patch_file") -> $input_name"
                        if patch -p1 --dry-run < "$patch_file" >/dev/null 2>&1; then
                            if ! patch -p1 --no-backup-if-mismatch < "$patch_file" >/dev/null 2>&1; then
                                log_error "Error applying patch $(basename "$patch_file")"
                                exit 1
                            fi
                        else
                            log_error "Patch $(basename "$patch_file") is not compatible"
                            exit 1
                        fi
                    done
                ) || return 1
            fi
        fi
    else
        # Fallback: search across all patch folders for backward compatibility
        local variant="${PATCH_SMALI:-essi}"
        local patch_type="Jar"
        [[ "$input_name" == *.apk ]] && patch_type="Apk"

        local candidate_dirs=(
            "$patches_root/common/$patch_type"
            "$patches_root/$variant/$patch_type"
        )

        for variant_dir in "${candidate_dirs[@]}"; do
            [ ! -d "$variant_dir" ] && continue

            local patch_dir="$variant_dir/$base_name"
            [ ! -d "$patch_dir" ] && continue

            if [ -n "$specific_patch" ] && [ ! -f "$patch_dir/$specific_patch" ]; then
                continue
            fi

            applied_any=true

            (
                cd "$target_dir" || exit 1
                local patch_list=()
                if [ -n "$specific_patch" ]; then
                    patch_list=("$patch_dir/$specific_patch")
                else
                    patch_list=("$patch_dir"/*.patch)
                fi

                for patch_file in "${patch_list[@]}"; do
                    [ ! -f "$patch_file" ] && continue
                    [[ "$(basename "$patch_file")" == "#"* ]] && continue
                    log_warning "- Applying patch: $(basename "$patch_file") -> $input_name"
                    if patch -p1 --dry-run < "$patch_file" >/dev/null 2>&1; then
                        if ! patch -p1 --no-backup-if-mismatch < "$patch_file" >/dev/null 2>&1; then
                            log_error "Error applying patch $(basename "$patch_file")"
                            exit 1
                        fi
                    else
                        log_error "Patch $(basename "$patch_file") is not compatible"
                        exit 1
                    fi
                done
            ) || return 1
        done
    fi

    return 0
}

compile() {
    local input_name="$1"
    if [ -z "$input_name" ]; then
        log_error "Usage: compile <apk|jar>"
        return 1
    fi

    local base_name
    base_name="$(basename "$input_name" .apk)"
    base_name="${base_name%.jar}"
    local module_dir="$DECOMPILE_DIR/$base_name"

    if [ ! -d "$module_dir" ]; then
        log_error "Decompiled directory not found: $module_dir"
        log_error "Run 'decompile $input_name' first"
        return 1
    fi

    local BUILD_OUTPUT_DIR="$dir_work/out/apktool/temp"
    local BUILD_SIGNED_DIR="$dir_work/out/apktool/build"
    mkdir -p "$BUILD_OUTPUT_DIR"
    mkdir -p "$BUILD_SIGNED_DIR"

    log_warning "Building $input_name"

    mkdir -p "$module_dir/build/apk"
    if [ -d "$module_dir/original/META-INF" ]; then
        cp -a "$module_dir/original/META-INF" "$module_dir/build/apk/META-INF"
    fi

    "$dir_work/tools/bin/apktool" b --quiet -j "$(( $(nproc) - 1 ))" -p "$FRAMEWORK_DIR" "$module_dir" || return 1

    local built_file="$BUILD_OUTPUT_DIR/$input_name"
    mkdir -p "$(dirname "$built_file")"
    
    if [ -f "$module_dir/dist/$input_name" ]; then
        mv -f "$module_dir/dist/$input_name" "$built_file"
    else
        local first_out
        first_out="$(find "$module_dir/dist" -maxdepth 1 -type f | head -n1)"
        [ -n "$first_out" ] && mv -f "$first_out" "$built_file"
    fi

    rm -rf "$module_dir/build" "$module_dir/dist"

    local signed_file="$BUILD_SIGNED_DIR/$input_name"

    if [[ "$input_name" == *.apk ]]; then
        local cert_prefix="aosp_platform"
        [ "$OFFICIAL_ROM" = "true" ] && cert_prefix="lich-ota"

        log_warning "Signing $input_name"
        local temp_signed="${signed_file%.apk}-tmp.apk"
        "$dir_work/tools/bin/signapk" \
            "$dir_work/platform/security/${cert_prefix}.x509.pem" \
            "$dir_work/platform/security/${cert_prefix}.pk8" \
            "$built_file" \
            "$temp_signed" || return 1

        mv -f "$temp_signed" "$signed_file"
    else
        log_warning "Zipaligning $input_name"
        local temp_aligned="${signed_file}-tmp"
        "$dir_work/tools/bin/zipalign" -p 4 "$built_file" "$temp_aligned" || return 1
        mv -f "$temp_aligned" "$signed_file"
    fi

    local dest_dir_out="$(dirname "$signed_file")"
    rm -rf "$dest_dir_out/oat"
    rm -f "$dest_dir_out/$input_name.prof" "$dest_dir_out/$input_name.bprof"

    for item in "${COPY_LIST[@]}"; do
        [[ "$item" =~ ^[[:space:]]*# ]] && continue
        
        local src_dir="${item%:*}"
        local original_filename="${item#*:}"
        
        if [ "$original_filename" = "$input_name" ]; then
            log_success "Restored $input_name"
            cp "$signed_file" "$src_dir/$original_filename" || return 1
            break
        fi
    done
}

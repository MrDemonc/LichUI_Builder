#!/bin/bash

if [ -f "$(dirname "$BASH_SOURCE")/log.sh" ]; then
    source "$(dirname "$BASH_SOURCE")/log.sh"
else
    # Fallback if sourced from main dir
    source "$dir_scr/utils/log.sh"
fi

# Default Path Setup
export FW_DIR="${FW_DIR:-$dir_work/out/firmware}"

# ---------------------------------------------------------
# Environment Setup: Detect model names
# ---------------------------------------------------------
setup_firmware_vars() {
    # Expected: target/a54x/config.sh sets TARGET_FIRMWARE and SOURCE_FIRMWARE
    # Example: SOURCE_FIRMWARE="SM-S711B/EUX"
    
    if [ -z "$SOURCE_FIRMWARE" ]; then
        # Load from target if available
        [ -f "$dir_work/target/$TARGET/config.sh" ] && source "$dir_work/target/$TARGET/config.sh"
    fi

    if [ -n "$SOURCE_FIRMWARE" ]; then
        export SOURCE_DIR=$(echo "$SOURCE_FIRMWARE" | cut -d'/' -f1,2 | tr '/' '_')
    fi
    
    if [ -n "$TARGET_FIRMWARE" ]; then
        export TARGET_DIR=$(echo "$TARGET_FIRMWARE" | cut -d'/' -f1,2 | tr '/' '_')
    fi
}

# ---------------------------------------------------------
# Run sub-scripts: run <script_name>
# ---------------------------------------------------------
run() {
    local script="$1"
    [ -z "$script" ] && { log_error "Usage: run <script_name>"; return 1; }

    # Try script name directly or inside internal folder
    local target_script=""
    if [ -f "$dir_scr/internal/${script}.sh" ]; then
        target_script="$dir_scr/internal/${script}.sh"
    elif [ -f "$dir_scr/${script}.sh" ]; then
        target_script="$dir_scr/${script}.sh"
    elif [ -f "$script" ]; then
        target_script="$script"
    fi

    if [ -n "$target_script" ]; then
        bash "$target_script"
    else
        log_error "Script not found: $script"
        return 1
    fi
}

# ---------------------------------------------------------
# Metadata Helpers
# ---------------------------------------------------------
sort_metadata() {
    local partition="$1"
    local fw_name=""
    if [[ "$partition" == "system" ]] || [[ "$partition" == "product" ]]; then
        fw_name="$SOURCE_DIR"
    else
        fw_name="$TARGET_DIR"
    fi
    
    local fs_file="$FW_DIR/$fw_name/fs_config-$partition"
    local fc_file="$FW_DIR/$fw_name/file_context-$partition"
    
    [ -f "$fs_file" ] && sort -u -k1,1 -o "$fs_file" "$fs_file"
    [ -f "$fc_file" ] && sort -u -k1,1 -o "$fc_file" "$fc_file"
}

# ---------------------------------------------------------
# Metadata Engine: add_metadata <partition> <rel_path> <is_dir>
# ---------------------------------------------------------
add_metadata() {
    local partition="$1"
    local rel_path="${2#/}"
    local is_dir="$3"
    
    local fw_name=""
    if [[ "$partition" == "system" ]] || [[ "$partition" == "product" ]]; then
        fw_name="$SOURCE_DIR"
    else
        fw_name="$TARGET_DIR"
    fi
    
    local fs_file="$FW_DIR/$fw_name/fs_config-$partition"
    local fc_file="$FW_DIR/$fw_name/file_context-$partition"
    
    local full_path="$partition/$rel_path"
    full_path="${full_path//\/\//\/}"
    if [[ "$full_path" == "system/system/"* ]]; then
        full_path="${full_path#system/}"
    fi
    
    local fc_path="/$full_path"
    fc_path="${fc_path//\/\//\/}"
    local fc_regex_path=$(echo "$fc_path" | sed -e 's/\./\\./g' -e 's/+/\\+/g' -e 's/\[/\\\[/g' -e 's/\]/\\\]/g' -e 's/\*/\\\*/g')
    
    local uid="0" gid="0" mode="644"
    if [ "$is_dir" = "true" ]; then
        mode="755"
    elif [[ "$full_path" == *"bin/"* ]] || [[ "$full_path" == *.sh ]]; then
        gid="2000"
        mode="755"
    fi
    
    local context="u:object_r:system_file:s0"
    case "$partition" in
        system)
            if [[ "$fc_path" == /system/lib*/*.so ]]; then
                context="u:object_r:system_lib_file:s0"
            elif [[ "$fc_path" == /system/bin/* ]] || [[ "$fc_path" == /system/xbin/* ]]; then
                context="u:object_r:system_file:s0"
            fi
            ;;
        vendor)
            context="u:object_r:vendor_file:s0"
            if [[ "$fc_path" == /vendor/bin/* ]]; then
                context="u:object_r:vendor_configs_file:s0"
            fi
            ;;
        product)
            context="u:object_r:system_file:s0"
            ;;
    esac

    touch "$fs_file" "$fc_file"
    sed -i "\|^$full_path |d" "$fs_file"
    echo "$full_path $uid $gid $mode capabilities=0x0" >> "$fs_file"
    sed -i "\|^$fc_regex_path |d" "$fc_file"
    echo "$fc_regex_path $context" >> "$fc_file"
}

# ---------------------------------------------------------
# add [model] <partition> <src_file_or_dir> <dest_path_in_partition> [pattern]
# ---------------------------------------------------------
add() {
    local partition=""
    local src=""
    local dest=""
    local pattern=""

    # Check if first argument is a model in prebuilt/samsung/devices
    if [ -n "$1" ] && [ -n "$dir_work" ] && [ -d "$dir_work/prebuilt/samsung/devices/$1" ]; then
        partition="$2"
        src="$dir_work/prebuilt/samsung/devices/$1/$3"
        dest="$4"
        pattern="$5"
    else
        partition="$1"
        src="$2"
        dest="$3"
        pattern="$4"
    fi

    if [ -z "$partition" ] || [ -z "$src" ] || [ -z "$dest" ]; then
        log_error "Usage: add [model] <partition> <src> <dest> [pattern]"
        return 1
    fi

    local fw_name=""
    if [[ "$partition" == "system" ]] || [[ "$partition" == "product" ]]; then
        fw_name="$SOURCE_DIR"
    else
        fw_name="$TARGET_DIR"
    fi

    local target_root="$FW_DIR/$fw_name"
    local part_dir="$target_root/$partition"

    if [ "$partition" == "system" ] && [ -d "$target_root/system/system" ]; then
        part_dir="$target_root/system/system"
    fi

    local clean_dest="${dest#/}"
    local target_full_path="$part_dir/$clean_dest"

    # Check existence
    local exists=false
    [ -e "$target_full_path" ] || [ -L "$target_full_path" ] && exists=true

    # 1. Copy/Replace
    if [ -n "$pattern" ] && [ -d "$src" ]; then
        mkdir -p "$target_full_path"
        find "$src" -mindepth 1 -maxdepth 1 -name "$pattern" -exec cp -rf {} "$target_full_path/" \;
    else
        [ "$exists" = "true" ] && rm -rf "$target_full_path"
        mkdir -p "$(dirname "$target_full_path")"
        cp -rf "$src" "$target_full_path"
    fi

    # Auto-Join Logic for split files (e.g. large APKs)
    if [ -d "$target_full_path" ]; then
        find "$target_full_path" -type f \( -name "*.aa" -o -name "*.001" -o -name "*.00" -o -name "*.000" \) | sed 's/\.[^.]*$//' | sort -u | while read -r base_file; do
            log_info "Auto-joining split files for: $(basename "$base_file")"
            cat "${base_file}."* > "${base_file}_joined"
            rm -f "${base_file}."*
            mv -f "${base_file}_joined" "$base_file"
        done
    fi

    # 2. Inject Metadata Recursively
    if [ -d "$target_full_path" ]; then
        log_info "Adding recursive metadata for: $partition/$clean_dest"
        find "$target_full_path" | while read -r item; do
            local rel_to_root="${item#$part_dir/}"
            if [[ "$part_dir" == *"/system/system" ]]; then
                rel_to_root="system/$rel_to_root"
            fi
            local is_d="false"
            [ -d "$item" ] && is_d="true"
            add_metadata "$partition" "$rel_to_root" "$is_d"
        done
    else
        add_metadata "$partition" "$clean_dest" "false"
    fi

    sort_metadata "$partition"

    if [ -n "$pattern" ]; then
        log_success "Added items matching '$pattern' to: $partition/$clean_dest"
    elif [ "$exists" = "true" ]; then
        log_success "Replaced: $partition/$clean_dest"
    else
        log_success "Added: $partition/$clean_dest"
    fi
}

# ---------------------------------------------------------
# set_metadata <partition> <path_in_partition>
# ---------------------------------------------------------
set_metadata() {
    local partition="$1"
    local dest="$2"

    if [ -z "$partition" ] || [ -z "$dest" ]; then
        log_error "Usage: set_metadata <partition> <path_in_partition>"
        return 1
    fi

    local clean_dest="${dest#/}"
    local fw_name=""
    if [[ "$partition" == "system" ]] || [[ "$partition" == "product" ]]; then
        fw_name="$SOURCE_DIR"
    else
        fw_name="$TARGET_DIR"
    fi

    local target_root="$FW_DIR/$fw_name"
    local part_dir="$target_root/$partition"
    if [ "$partition" == "system" ] && [ -d "$target_root/system/system" ]; then
        part_dir="$target_root/system/system"
    fi

    local target_full_path="$part_dir/$clean_dest"
    local is_dir="false"
    [ -d "$target_full_path" ] && is_dir="true"

    add_metadata "$partition" "$clean_dest" "$is_dir"
    sort_metadata "$partition"

    log_success "Metadata set for: $partition/$clean_dest"
}

# ---------------------------------------------------------
# delete <partition> <path_in_partition> [pattern]
# ---------------------------------------------------------
delete() {
    local partition="$1"
    local path="$2"
    local pattern="$3"

    if [ -z "$partition" ] || [ -z "$path" ]; then
        log_error "Usage: delete <partition> <path> [pattern]"
        return 1
    fi

    local fw_name=""
    if [[ "$partition" == "system" ]] || [[ "$partition" == "product" ]]; then
        fw_name="$SOURCE_DIR"
    else
        fw_name="$TARGET_DIR"
    fi

    local target_root="$FW_DIR/$fw_name"
    local part_dir="$target_root/$partition"
    if [ "$partition" == "system" ] && [ -d "$target_root/system/system" ]; then
        part_dir="$target_root/system/system"
    fi

    local clean_path="${path#/}"
    local target_file="$part_dir/$clean_path"

    if [ ! -e "$target_file" ] && [ ! -L "$target_file" ]; then
        log_warning "Not found (Skipped): $clean_path"
        return 0
    fi

    local fs_cfg="$target_root/fs_config-$partition"
    local f_ctx="$target_root/file_context-$partition"

    clean_metadata() {
        local c_path="$1"
        local full_path="$partition/$c_path"
        if [[ "$part_dir" == *"/system/system" ]]; then full_path="system/$c_path"; fi
        
        [ -f "$fs_cfg" ] && sed -i "\|^$full_path |d; \|^$full_path/|d" "$fs_cfg"
        
        local escaped_path=$(echo "/$full_path" | sed -e 's/\./\\./g' -e 's/+/\\+/g' -e 's/\[/\\\[/g' -e 's/\]/\\\]/g' -e 's/\*/\\\*/g')
        [ -f "$f_ctx" ] && sed -i "\|^$escaped_path |d; \|^$escaped_path/|d" "$f_ctx"
    }

    if [ -n "$pattern" ]; then
        if [ -d "$target_file" ]; then
            find "$target_file" -mindepth 1 -maxdepth 1 -name "$pattern" | while read -r item; do
                local rel_to_root="${item#$part_dir/}"
                rm -rf "$item"
                clean_metadata "$rel_to_root"
            done
            log_success "Deleted items matching '$pattern' in: $clean_path"
        else
            log_warning "Target is not a directory, cannot apply pattern: $clean_path"
        fi
    else
        rm -rf "$target_file"
        clean_metadata "$clean_path"
        log_success "Deleted: $clean_path"
    fi
}

# ---------------------------------------------------------
# setprop <partition> [subdir] <file_with_props>
# ---------------------------------------------------------
setprop() {
    local partition="$1"
    local subdir=""
    local input_file=""

    if [ "$#" -eq 3 ]; then
        subdir="$2"
        input_file="$3"
    else
        input_file="$2"
    fi

    if [ -z "$partition" ] || [ -z "$input_file" ]; then
        log_error "Usage: setprop <partition> [subdir] <prop_file>"
        return 1
    fi

    if [ ! -f "$input_file" ]; then
        log_error "Input file not found: $input_file"
        return 1
    fi

    local fw_name=""
    if [[ "$partition" == "system" ]] || [[ "$partition" == "product" ]]; then
        fw_name="$SOURCE_DIR"
    else
        fw_name="$TARGET_DIR"
    fi

    local target_root="$FW_DIR/$fw_name"
    local prop_path=""

    if [ -n "$subdir" ]; then
        prop_path="$target_root/$partition/$subdir/build.prop"
    else
        prop_path="$target_root/$partition/build.prop"
        if [ ! -f "$prop_path" ]; then
            prop_path="$target_root/$partition/etc/build.prop"
            if [ ! -f "$prop_path" ] && [ "$partition" == "system" ]; then
                 prop_path="$target_root/system/system/build.prop"
            fi
        fi
    fi

    if [ ! -f "$prop_path" ]; then
        log_error "build.prop not found in: $prop_path"
        return 1
    fi

    local section=""
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ ^#\ (Add|Change|Clear|Delete) ]]; then
            section="${BASH_REMATCH[1]}"
            continue
        fi
        [[ -z "${line// }" ]] && continue
        [[ "$line" =~ ^# ]] && [[ ! "$line" =~ ^#\ (Add|Change|Clear|Delete) ]] && continue

        case "$section" in
            "Add"|"Change")
                local key="${line%%=*}"
                local value="${line#*=}"
                eval value="\"$value\""
                if grep -q "^$key=" "$prop_path"; then
                    sed -i "s|^$key=.*|$key=$value|" "$prop_path"
                else
                    sed -i '/^# end of file/d' "$prop_path"
                    if ! grep -q "^# Add for LichUI" "$prop_path"; then
                        echo "" >> "$prop_path"
                        echo "# Add for LichUI" >> "$prop_path"
                    fi
                    echo "$key=$value" >> "$prop_path"
                    echo "# end of file" >> "$prop_path"
                fi
                ;;
            "Clear")
                local key="${line%%=*}"
                if grep -q "^$key=" "$prop_path"; then
                    sed -i "s|^$key=.*|$key=|" "$prop_path"
                else
                    echo "$key=" >> "$prop_path"
                fi
                ;;
            "Delete")
                local key="${line// }"
                sed -i "/^$key=/d" "$prop_path"
                ;;
        esac
    done < "$input_file"

    log_success "Patched $partition build.prop"
}

# ---------------------------------------------------------
# hex_patch <target_file> <from_hex> <to_hex>
# ---------------------------------------------------------
hex_patch() {
    local target="$1"
    local from="$2"
    local to="$3"

    if [ -z "$target" ] || [ -z "$from" ] || [ -z "$to" ]; then
        log_error "Usage: hex_patch <file> <from_hex> <to_hex>"
        return 1
    fi

    if [ ! -f "$target" ]; then
        log_error "Hex patch failed: File not found -> $target"
        return 1
    fi

    if ! command -v xxd &> /dev/null; then
        log_error "Hex patch failed: 'xxd' is not installed."
        return 1
    fi

    if xxd -p "$target" | tr -d '\n ' | grep -q "$to"; then
        log_success "File already patched: $(basename "$target")"
        return 0
    fi

    if ! xxd -p "$target" | tr -d '\n ' | grep -q "$from"; then
        log_error "Hex patch failed: Pattern not found in $(basename "$target")"
        return 1
    fi

    log_warning "Applying hex patch to $(basename "$target")..."
    
    local tmp_file="${target}.tmp"
    if xxd -p "$target" | tr -d '\n ' | sed "s/$from/$to/g" | xxd -r -p > "$tmp_file"; then
        mv -f "$tmp_file" "$target"
        log_success "Hex patch applied successfully to $(basename "$target")"
        return 0
    else
        log_error "Hex patch failed for $(basename "$target")"
        rm -f "$tmp_file"
        return 1
    fi
}

# ---------------------------------------------------------
# Helper: check_param <name> <value>
# ---------------------------------------------------------
check_param() {
    local PARAM_NAME="$1"
    local PARAM_VALUE="$2"

    if [ ! "$PARAM_VALUE" ]; then
        log_error "$PARAM_NAME cannot be empty"
        return 1
    fi

    return 0
}

# ---------------------------------------------------------
# get_prop <partition|file> <property>
# ---------------------------------------------------------
get_prop() {
    local source="$1"
    local prop="$2"
    local file=""

    if [[ "$source" == *".prop" ]]; then
        file="$source"
    else
        case "$source" in
            system) file="$FW_DIR/$SOURCE_DIR/system/system/build.prop" ;;
            vendor) file="$FW_DIR/$SOURCE_DIR/vendor/build.prop" ;;
            product) file="$FW_DIR/$SOURCE_DIR/product/build.prop" ;;
            *) file="$source" ;;
        esac
    fi

    if [ ! -f "$file" ]; then return 1; fi
    grep "^$prop=" "$file" | cut -d'=' -f2- | head -n 1
}

# ---------------------------------------------------------
# download_file <url> <output_path>
# ---------------------------------------------------------
download_file() {
    check_param "URL" "$1" || return 1
    check_param "OUTPUT" "$2" || return 1
    
    local url="$1"
    local output="$2"
    
    mkdir -p "$(dirname "$output")"
    log_info "Downloading: $(basename "$output")..."
    curl -L -# -o "$output" "$url"
    return $?
}

# ---------------------------------------------------------
# get_galaxy_store_url <package_name>
# ---------------------------------------------------------
get_galaxy_store_url() {
    check_param "PACKAGE" "$1" || return 1
    local package="$1"
    
    local devices=("SM-S938B" "SM-S901E")
    local sdk=$(get_prop system "ro.build.version.sdk")
    local oneui=$(get_prop system "ro.build.version.oneui")
    
    [ -z "$sdk" ] && sdk="36"
    [ -z "$oneui" ] && oneui="80000"

    local protocol="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>"
    protocol+="<SamsungProtocol networkType=\"0\" openApiVersion=\"$sdk\" deviceModel=\"DEVICE\""
    protocol+=" mcc=\"262\" mnc=\"01\" csc=\"EUX\" version=\"7.7\""
    protocol+=" deviceFeature=\"locale=en_GB||abi32=armeabi-v7a:armeabi||abi64=arm64-v8a||oneUiVersion=$oneui\">"
    protocol+="<request id=\"2303\" numParam=\"2\">"
    protocol+="<param name=\"stduk\">0</param>"
    protocol+="<param name=\"productID\">PRODUCTID</param>"
    protocol+="</request></SamsungProtocol>"

    for device in "${devices[@]}"; do
        local check_url="https://vas.samsungapps.com/stub/stubUpdateCheck.as?appId=$package&versionCode=0&deviceId=$device&mcc=262&mnc=01&csc=EUX&sdkVer=$sdk&oneUiVersion=$oneui&systemId=0"
        local product_id=$(curl -L -s "$check_url" | grep -o -P "(?<=<productId>)[^<]+")
        
        if [ -n "$product_id" ]; then
            local request="${protocol//DEVICE/$device}"
            request="${request//PRODUCTID/$product_id}"
            
            local final_xml=$(curl -L -s "https://uk-odc.samsungapps.com/ods.as" -H "Content-Type: text/plain" -d "$request")
            local download_url=$(grep -o -P "(?<=<value name=\"downLoadURI\">)[^<]+" <<< "$final_xml")
            
            if [ -n "$download_url" ]; then
                echo "${download_url//amp;/}"
                return 0
            fi
        fi
    done

    log_error "Could not find download URL for $package"
    return 1
}

# ---------------------------------------------------------
# update_config <config_key> <value_or_delete>
# ---------------------------------------------------------
update_config() {
    local key="$1"
    local val="$2"
    
    if [ -z "$key" ] || [ -z "$val" ]; then
        log_error "Usage: update_config <key> <val|delete>"
        return 1
    fi

    local ff_file="$FW_DIR/$SOURCE_DIR/system/system/etc/floating_feature.xml"
    if [ ! -f "$ff_file" ]; then
        ff_file="$FW_DIR/$SOURCE_DIR/system/etc/floating_feature.xml"
    fi

    if [ ! -f "$ff_file" ]; then
        log_error "floating_feature.xml not found in $SOURCE_DIR/system"
        return 1
    fi

    local lich_comment="<!-- Added/Modified by LichUI Builder -->"

    if [ "$val" == "delete" ]; then
        if grep -Fq "$key" "$ff_file"; then
            sed -i "/$key/d" "$ff_file"
            log_success "XML: Deleted $key"
        fi
    else
        if grep -Fq "<$key>" "$ff_file"; then
            sed -i "$(sed -n "/<${key}>/=" "$ff_file" | head -n 1) c\    <${key}>${val}</${key}>" "$ff_file"
            log_success "XML: Updated $key -> $val"
        else
            sed -i "/<\/SecFloatingFeatureSet>/d" "$ff_file"
            if ! grep -q "$lich_comment" "$ff_file"; then
                echo "    $lich_comment" >> "$ff_file"
            fi
            echo "    <${key}>${val}</${key}>" >> "$ff_file"
            echo "</SecFloatingFeatureSet>" >> "$ff_file"
            log_success "XML: Added $key -> $val"
        fi
    fi
}

#!/bin/bash
# ---------------------------------------------------------
# LichUI Build Utilities
# ---------------------------------------------------------

# Dependency Chain
# Ensure common.sh is loaded (which also loads logs)
if [ -z "$dir_scr" ]; then
    _UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
    source "$_UTILS_DIR/common.sh"
else
    source "$dir_scr/utils/common.sh"
fi

# Initial configuration (Executed once when sourced)
if type setup_firmware_vars &> /dev/null; then
    setup_firmware_vars
fi
[ -z "$FW_DIR" ] && export FW_DIR="$dir_work/out/firmware"

# ---------------------------------------------------------
# add <partition> <src_file> <dest_path_in_partition>
# ---------------------------------------------------------
add() {
    local partition="$1" # system, vendor, product, etc.
    local src="$2"       # path to source file
    local dest="$3"      # relative path inside partition (e.g. /bin/bash)

    if [ -z "$partition" ] || [ -z "$src" ] || [ -z "$dest" ]; then
        echo -e "${LOG_INDENT}\033[1;31m[E]\033[0m Usage: add <partition> <src> <dest>"
        return 1
    fi

    # Determine which firmware base to use
    local fw_name=""
    if [[ "$partition" == "system" ]] || [[ "$partition" == "product" ]]; then
        fw_name="$SOURCE_DIR"
    else
        fw_name="$TARGET_DIR"
    fi

    if [ -z "$fw_name" ]; then
        echo -e "${LOG_INDENT}\033[1;31m[E]\033[0m Firmware variables (TARGET/SOURCE_DIR) not set."
        return 1
    fi

    local target_root="$FW_DIR/$fw_name"
    local part_dir="$target_root/$partition"

    # Handle system/system subfolder (common in some firmwares)
    if [ "$partition" == "system" ] && [ -d "$target_root/system/system" ]; then
        part_dir="$target_root/system/system"
    fi

    if [ ! -d "$part_dir" ]; then
        echo -e "${LOG_INDENT}\033[1;31m[E]\033[0m Partition directory not found: $part_dir"
        return 1
    fi

    # Clean dest (remove initial /)
    local clean_dest="${dest#/}"
    local target_full_path="$part_dir/$clean_dest"

    # Check if the file already exists in the original firmware
    local exists=false
    if [ -e "$target_full_path" ] || [ -L "$target_full_path" ]; then
        exists=true
    fi

    # 1. Replace or Copy the file
    [ "$exists" = "true" ] && rm -rf "$target_full_path"
    mkdir -p "$(dirname "$target_full_path")"
    cp -rf "$src" "$target_full_path"

    # --- 2. Update Metadata ---
    local meta_path="${partition}/${clean_dest}"
    if [[ "$part_dir" == *"/system/system" ]]; then
        meta_path="system/${clean_dest}"
    fi

    # Update fs_config
    local fs_cfg="$target_root/fs_config-$partition"
    if [ -f "$fs_cfg" ]; then
        if [ "$exists" = "false" ] || ! grep -q "\|^$meta_path " "$fs_cfg"; then
            local mode=644
            [ -x "$src" ] && mode=755
            sed -i "\|^$meta_path |d" "$fs_cfg"
            echo "$meta_path 0 0 $mode capabilities=0x0" >> "$fs_cfg"
            sort -u -o "$fs_cfg" "$fs_cfg"
        fi
    fi

    # Update file_context
    local f_ctx="$target_root/file_context-$partition"
    if [ -f "$f_ctx" ]; then
        local escaped_path=$(echo "$meta_path" | sed -e 's/\./\\./g' -e 's/+/\\+/g' -e 's/\[/\\\[/g' -e 's/\]/\\\]/g' -e 's/\*/\\\*/g')
        if [ "$exists" = "false" ] || ! grep -q "\|^$escaped_path " "$f_ctx"; then
            local context="u:object_r:system_file:s0"
            [[ "$partition" == "vendor" ]] && context="u:object_r:vendor_file:s0"
            sed -i "\|^$escaped_path |d" "$f_ctx"
            echo "$escaped_path $context" >> "$f_ctx"
            sort -u -o "$f_ctx" "$f_ctx"
        fi
    fi

    if [ "$exists" = "true" ]; then
        echo -e "${LOG_INDENT}\033[1;32m[S]\033[0m Replaced $meta_path (Original metadata preserved)"
    else
        echo -e "${LOG_INDENT}\033[1;32m[S]\033[0m Added $src to $meta_path"
    fi
}

# ---------------------------------------------------------
# delete <partition> <path_in_partition>
# ---------------------------------------------------------
delete() {
    local partition="$1"
    local path="$2"

    if [ -z "$partition" ] || [ -z "$path" ]; then
        echo -e "${LOG_INDENT}\033[1;31m[E]\033[0m Usage: delete <partition> <path>"
        return 1
    fi

    # Determine firmware base
    local fw_name=""
    if [[ "$partition" == "system" ]] || [[ "$partition" == "product" ]]; then
        fw_name="$SOURCE_DIR"
    else
        fw_name="$TARGET_DIR"
    fi

    if [ -z "$fw_name" ]; then
        echo -e "${LOG_INDENT}\033[1;31m[E]\033[0m Firmware variables not set."
        return 1
    fi

    local target_root="$FW_DIR/$fw_name"
    local part_dir="$target_root/$partition"

    if [ "$partition" == "system" ] && [ -d "$target_root/system/system" ]; then
        part_dir="$target_root/system/system"
    fi

    local clean_path="${path#/}"
    local target_file="$part_dir/$clean_path"

    # 1. Delete file/directory
    if [ ! -e "$target_file" ] && [ ! -L "$target_file" ]; then
        echo -e "${LOG_INDENT}\033[1;31m[E]\033[0m Path not found in filesystem: $clean_path"
        return 1
    fi

    rm -rf "$target_file"
    echo -e "${LOG_INDENT}\033[1;32m[S]\033[0m Deleted: $clean_path"

    # --- 2. Clean Metadata ---
    local meta_path="${partition}/${clean_path}"
    if [[ "$part_dir" == *"/system/system" ]]; then
        meta_path="system/${clean_path}"
    fi

    local fs_cfg="$target_root/fs_config-$partition"
    if [ -f "$fs_cfg" ]; then
        sed -i "\|^$meta_path|d" "$fs_cfg"
    fi

    local f_ctx="$target_root/file_context-$partition"
    if [ -f "$f_ctx" ]; then
        local escaped_path=$(echo "$meta_path" | sed -e 's/\./\\./g' -e 's/+/\\+/g' -e 's/\[/\\\[/g' -e 's/\]/\\\]/g' -e 's/\*/\\\*/g')
        sed -i "\|^$escaped_path|d" "$f_ctx"
    fi
}

# ---------------------------------------------------------
# setprop <partition> [subdir] <prop_file>
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
        echo -e "${LOG_INDENT}\033[1;31m[E]\033[0m Usage: setprop <partition> [subdir] <prop_file>"
        return 1
    fi

    if [ ! -f "$input_file" ]; then
        echo -e "${LOG_INDENT}\033[1;31m[E]\033[0m Input file not found: $input_file"
        return 1
    fi

    # Determine firmware base
    local fw_name=""
    if [[ "$partition" == "system" ]] || [[ "$partition" == "product" ]]; then
        fw_name="$SOURCE_DIR"
    else
        fw_name="$TARGET_DIR"
    fi

    if [ -z "$fw_name" ]; then
        echo -e "${LOG_INDENT}\033[1;31m[E]\033[0m Firmware variables not set."
        return 1
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
        echo -e "${LOG_INDENT}\033[1;31m[E]\033[0m build.prop not found in: $prop_path"
        return 1
    fi

    local section=""
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ ^#\ (Change|Clear|Delete) ]]; then
            section="${BASH_REMATCH[1]}"
            continue
        fi
        [[ -z "${line// }" ]] && continue
        [[ "$line" =~ ^# ]] && [[ ! "$line" =~ ^#\ (Change|Clear|Delete) ]] && continue

        case "$section" in
            "Change")
                local key="${line%%=*}"
                local value="${line#*=}"
                if grep -q "^$key=" "$prop_path"; then
                    sed -i "s|^$key=.*|$key=$value|" "$prop_path"
                else
                    echo "$key=$value" >> "$prop_path"
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
                sed -i "|^$key=|d" "$prop_path"
                ;;
        esac
    done < "$input_file"

    echo -e "${LOG_INDENT}\033[1;32m[S]\033[0m Patched $partition build.prop"
}

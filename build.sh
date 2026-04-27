#!/bin/bash

# Setup project environment (Bash/Zsh compatible detection)
if [ -n "$BASH_SOURCE" ]; then
    _SCRIPT="${BASH_SOURCE[0]}"
elif [ -n "$ZSH_VERSION" ]; then
    _SCRIPT="${(%):-%x}"
else
    _SCRIPT="$0"
fi
export dir_work="$(cd "$(dirname "$_SCRIPT")" && pwd)"
export dir_scr="$dir_work/scripts"

# Source Core Utilities (Auto-loads common and logs)
source "$dir_scr/utils/utils.sh"



# Timestamp log for build
# Keep only the last 5 logs
log_dir="$dir_work/logs"
mkdir -p "$log_dir"

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="$log_dir/script_$timestamp.log"

ls -t "$log_dir"/script_*.log 2>/dev/null | tail -n +6 | xargs rm -f

exec > >(tee -a "$log_file") 2>&1


# Handle arguments
case "$1" in
    tools)
        log_warning " Building tools..."
        run "$dir_scr/dependencies/build_tools.sh"
        return 0 2>/dev/null || exit 0
        ;;
    clear)
        log_warning " Cleaning build directories..."
        for dir in "firmware" "rom" "apktool" "flags"; do
            if [ -d "$dir_work/out/$dir" ]; then
                log_warning "   cleaning $dir"
                rm -rf "$dir_work/out/$dir"
            fi
        done
        return 0 2>/dev/null || exit 0
        ;;
    *)
        if [ -n "$1" ] && [ -d "$dir_work/target/$1" ]; then
            target="$1"
            config_file="$dir_work/target/$target/config.sh"

            if [ -f "$config_file" ]; then
                log " "
                log_info "Loading configuration for $target..."
                set -a
                source "$config_file"
                set +a

                echo "============================================"
                echo "  TARGET_DEVICE: $target"
                grep -v '^#' "$config_file" | grep '=' | sed 's/^/  /'
                echo "============================================"

                export target
                export TARGET="$target"

                return 0 2>/dev/null || exit 0
            else
                log_error "Configuration file not found in: $config_file"
                return 1 2>/dev/null || exit 1
            fi
        else
            log " "
            log_info "Enter option for build"
            log " "
            log "Use:"
            log "• ./build.sh <target>          >| Build rom for device"
            log "• ./build.sh <target> -i       >| Build only img's"
            log "• ./build.sh clear             >| Clean directories"
            log "• ./build.sh tools             >| Build tools"
            log " "
            log "Target availables:"
            
            targets_list=$(ls -d "$dir_work/target/"*/ 2>/dev/null | xargs -n 1 basename)
            if [ -n "$targets_list" ]; then
                output=""
                count=1
                for t_name in $targets_list; do
                    output+="$count. $t_name  "
                    count=$((count + 1))
                done
                log "$output"
            else
                log_warning "No targets found in target/"
            fi
            return 1 2>/dev/null || exit 1
        fi
        ;;
esac

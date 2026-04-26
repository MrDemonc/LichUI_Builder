#!/bin/bash

source scripts/utils/log.sh

# Timestamp log for build
# Keep only the last 5 logs
log_dir="$PWD/logs"
mkdir -p "$log_dir"

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="$log_dir/script_$timestamp.log"

ls -t "$log_dir"/script_*.log 2>/dev/null | tail -n +6 | xargs rm -f

exec > >(tee -a "$log_file") 2>&1

# Root directory 
find_project_root() {
    local dir="$PWD"

    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.git" ]]; then
            dir_work="$dir"
            dir_scr="$dir_work/scripts"
            return 0
        fi
        dir="${dir%/*}"
    done

    log_error "No found source root directory (.git)."
    return 1
}

if ! find_project_root; then
    return 1 2>/dev/null || exit 1
fi

export dir_work
export dir_scr

# Run function for Scripts
run() {
    local script_path="$1"
    shift

    if [ ! -f "$script_path" ]; then
        if [ -f "$dir_work/$script_path" ]; then
            script_path="$dir_work/$script_path"
        elif [ -f "$dir_work/$script_path.sh" ]; then
            script_path="$dir_work/$script_path.sh"
        fi
    fi

    if [ ! -f "$script_path" ]; then
        log_error "Script not found: $script_path"
        return 1 2>/dev/null || exit 1
    fi

    script_name=$(basename "$script_path")

    echo "-----------------------------------"
    log_warning "Running: $script_name"
    echo "-----------------------------------"

    if [ -x "$script_path" ]; then
        "$script_path" "$@"
    else
        bash "$script_path" "$@"
    fi

    if [ $? -ne 0 ]; then
        echo "-----------------------------------"
        log_error "Failed: $script_name"
        echo "-----------------------------------"
        return 1 2>/dev/null || exit 1
    fi

    echo "-----------------------------------"
    log_success "Completed: $script_name"
    echo "-----------------------------------"
}

if [ -n "$BASH_VERSION" ]; then
    export -f run
fi

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

                # Aquí continuará la lógica de construcción para el target
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

run test

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
    exit 1
fi

export dir_work
export dir_scr

# Run function for Scripts
run() {
    script_name=$(basename "$1")

    echo "-----------------------------------"
    log_warning "Running: $script_name"
    echo "-----------------------------------"

    if [ -x "$1" ]; then
        "$@"
    else
        bash "$@"
    fi

    if [ $? -ne 0 ]; then
        echo "-----------------------------------"
        log_error "Failed: $script_name"
        echo "-----------------------------------"
        exit 1
    fi

    echo "-----------------------------------"
    log_success "Completed: $script_name"
    echo "-----------------------------------"
}

# Handle arguments
case "$1" in
    tools)
        log_warning " Building tools..."
        run "$dir_scr/dependencies/build_tools.sh"
        exit 0
        ;;
    clear)
        log_warning " Cleaning build directories..."
        for dir in "firmware" "rom" "apktool" "flags"; do
            if [ -d "$dir_work/out/$dir" ]; then
                log_warning "   cleaning $dir"
                rm -rf "$dir_work/out/$dir"
            fi
        done
        exit 0
        ;;
    *)
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
        
        targets=($(ls -d "$dir_work/target/"*/ 2>/dev/null | xargs -n 1 basename))
        if [ ${#targets[@]} -gt 0 ]; then
            output=""
            for i in "${!targets[@]}"; do
                output+="$((i+1)). ${targets[$i]}  "
            done
            log "$output"
        else
            log_warning "No targets found in target/"
        fi
        log " "
        exit 1
        ;;
esac


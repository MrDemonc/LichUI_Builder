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
        log_warning " Building tools..."
        run "$dir_scr/dependencies/build_tools.sh"
        exit 0
        ;;
esac


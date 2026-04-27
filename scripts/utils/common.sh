# Load logs (Depends on dir_scr exported by build.sh)
source "$dir_scr/utils/log.sh"


# Run function for Scripts (Breadcrumb style)

# This function handles nested execution and logs the context
run() {
    if [ -z "$1" ]; then
        log_error "Usage: run <script_name> [args]"
        return 1
    fi

    local script_path="$1"
    shift

    # Search for the script in the scripts directory
    if [ ! -f "$script_path" ]; then
        local search_result=$(find "$dir_scr" -maxdepth 3 \( -name "$script_path" -o -name "$script_path.sh" \) -type f -print -quit 2>/dev/null)
        if [ -n "$search_result" ]; then
            script_path="$search_result"
        fi
    fi

    if [ ! -f "$script_path" ]; then
        log_error "Script not found: $script_path"
        return 1
    fi

    local script_name=$(basename "$script_path" .sh)

    # Breadcrumb context logic
    local old_context="$RUN_CONTEXT"
    if [ -z "$RUN_CONTEXT" ]; then
        export RUN_CONTEXT="$script_name"
    else
        export RUN_CONTEXT="$RUN_CONTEXT ❯ $script_name"
    fi

    echo "-----------------------------------"
    log_warning "Running: $script_name"
    echo "-----------------------------------"

    # Execute
    if [ -x "$script_path" ]; then
        "$script_path" "$@"
    else
        bash "$script_path" "$@"
    fi

    local _status=$?
    
    # Restore context
    export RUN_CONTEXT="$old_context"

    if [ $_status -ne 0 ]; then
        echo "-----------------------------------"
        log_error "Failed: $script_name"
        echo "-----------------------------------"
        return $_status
    fi

    echo "-----------------------------------"
    log_success "Completed: $script_name"
    echo "-----------------------------------"
}

# Export function for Bash children
if [ -n "$BASH_VERSION" ]; then
    export -f run
fi

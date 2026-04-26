#Log system

log() {
    printf "\e[33m%s\e[0m\n" "$1"
}

log_warning() {
    echo -e "\033[1;33m[W]\033[0m $1"
}

log_error() {
    echo -e "\033[1;31m[E]\033[0m $1"
}

log_success() {
    echo -e "\033[1;32m[S]\033[0m $1"
}

log_success_compile() {
    echo -e "\033[1;32m$1\033[0m"
}

log_info() {
    echo -e "\033[1;34m[I]\033[0m $1"
}

if [ -n "$BASH_VERSION" ]; then
    export -f log log_warning log_error log_success log_success_compile log_info
fi
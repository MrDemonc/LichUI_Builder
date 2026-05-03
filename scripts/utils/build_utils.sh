# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# [
source "$dir_scr/utils/utils.sh"
# ]

# GET_DISK_USAGE <file>
# Returns the size in bytes of the supplied file.
GET_DISK_USAGE()
{
    check_param "FILE" "$1" || return 1

    local FILE="$1"

    if [ ! -e "$FILE" ]; then
        log_error "File not found: ${FILE//$dir_work\//}"
        return 1
    fi

    local SIZE
    # https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/tools/releasetools/build_image.py#63
    SIZE="$(du -b -k -s "$FILE" | cut -f 1)"

    bc -l <<< "$SIZE * 1024"
}

READ_BYTES_AT()
{
    check_param "FILE" "$1" || return 1
    check_param "OFFSET" "$2" || return 1
    check_param "BYTES" "$3" || return 1

    local FILE="$1"
    local OFFSET="$2"
    local BYTES="$3"

    if [ ! -f "$FILE" ]; then
        log_error "File not found: ${FILE//$dir_work\//}"
        return 1
    fi

    local FILE_SIZE
    FILE_SIZE="$(wc -c "$FILE" | cut -d " " -f 1)"
    if ! [[ "$OFFSET" =~ ^[+-]?[0-9]+$ ]] || [[ "$OFFSET" -gt "$FILE_SIZE" ]]; then
        log_error "Offset value not valid: $OFFSET"
        return 1
    fi
    if ! [[ "$BYTES" =~ ^[+-]?[0-9]+$ ]] || [[ "$BYTES" -gt "$((FILE_SIZE - OFFSET))" ]]; then
        log_error "Bytes value not valid: $BYTES"
        return 1
    fi

    local READ
    local LENGTH
    READ="$(xxd -p -l "$BYTES" -s "$OFFSET" "$FILE")"
    LENGTH="${#READ}"

    while [[ "$LENGTH" -gt 0 ]]; do
        echo -n "${READ:$LENGTH-2:2}"
        LENGTH="$((LENGTH - 2))"
    done
    echo ""
}

IS_SPARSE_IMAGE()
{
    check_param "FILE" "$1" || return 1

    local FILE="$1"

    if [ ! -f "$FILE" ]; then
        log_error "File not found: ${FILE//$dir_work\//}"
        return 1
    fi

    [[ "$(READ_BYTES_AT "$FILE" "0" "4")" == "ed26ff3a" ]]
}

# GET_IMAGE_SIZE <file>
# Returns the size in bytes of the supplied image.
GET_IMAGE_SIZE()
{
    check_param "FILE" "$1" || return 1

    local FILE="$1"

    if [ ! -f "$FILE" ]; then
        log_error "File not found: ${FILE//$dir_work\//}"
        return 1
    fi

    if IS_SPARSE_IMAGE "$FILE"; then
        local BLOCK_SIZE
        local BLOCKS
        BLOCK_SIZE="$(printf "%d" "0x$(READ_BYTES_AT "$FILE" "12" "4")")"
        BLOCKS="$(printf "%d" "0x$(READ_BYTES_AT "$FILE" "16" "4")")"

        bc -l <<< "$BLOCKS * $BLOCK_SIZE"
    else
        GET_DISK_USAGE "$FILE"
    fi
}

# [
DEPENDENCIES=(
    "7z" "awk" "basename" "bc" "brotli" "cat" "clang" "cmake"
    "cp" "cpio" "curl" "cut" "cwebp" "dd" "dirname" "du" "ffmpeg"
    "file" "getfattr" "git" "grep" "head" "java" "ln"
    "lz4" "make" "md5sum" "mkdir" "mount" "mv" "perl" "protoc"
    "python3" "rm" "rsync" "sed" "sha1sum" "sort" "split" "stat"
    "sudo" "tail" "tar" "touch" "tr" "truncate" "umount" "unzip"
    "wc" "whoami" "xargs" "xxd" "zip" "zstd"
)
MISSING=()
for d in "${DEPENDENCIES[@]}"; do
    if ! type "$d" &> /dev/null; then
        MISSING+=("$d")
    fi
done
if [ "${#MISSING[@]}" -ne 0 ]; then
    echo -e '\033[1;31m'"The following dependencies are missing from your system:"'\033[0;31m' >&2
    printf '%s ' "${MISSING[@]}" >&2
    echo -e '\033[0m' >&2
    return 1
fi
unset DEPENDENCIES MISSING
# ]

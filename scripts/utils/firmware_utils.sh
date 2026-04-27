#!/usr/bin/env bash

LOG() {
    echo -e "$@"
}

LOGE() {
    echo -e "\033[0;31m$@\033[0m" >&2
}

LOGW() {
    echo -e "\033[0;33m$@\033[0m" >&2
}

LOG_STEP_IN() {
    echo -e "\033[0;34m$@\033[0m"
}

LOG_STEP_OUT() {
    echo -e "\033[0;34mDone\033[0m"
}

_CHECK_NON_EMPTY_PARAM() {
    local PARAM_NAME="$1"
    local PARAM_VALUE="$2"

    if [ ! "$PARAM_VALUE" ]; then
        LOGE "$PARAM_NAME cannot be empty"
        return 1
    fi

    return 0
}

EVAL() {
    local CMD="$@"
    eval "$CMD" || {
        LOGE "Command failed: $CMD"
        return 1
    }
    return 0
}

COMPARE_SEC_BUILD_VERSION() {
    local STRING1="$1"
    local STRING2="$2"

    STRING1="$(cut -d "/" -f 1 -s <<< "$STRING1")"
    STRING2="$(cut -d "/" -f 1 -s <<< "$STRING2")"

    # Samsung Android OS build version scheme works as follows (eg. A528BXXU1DWA4):
    # - A528B: Model number
    # - XX: Region (XX = EUR_OPEN)
    # - U: Firmware type (U = full update, S = security update)
    # - 1: Rollback protection bit
    # - D: Major OS version (D = 4th OS rollout)
    # - W: Year (W = 2023)
    # - A: Month (A = january)
    # - 4: Incremental version
    local STRING1_MAJOR="${STRING1:${#STRING1}-4:1}"
    local STRING1_YEAR="${STRING1:${#STRING1}-3:1}"
    local STRING1_MONTH="${STRING1:${#STRING1}-2:1}"
    local STRING1_INCREMENTAL="${STRING1:${#STRING1}-1:1}"

    local STRING2_MAJOR="${STRING2:${#STRING2}-4:1}"
    local STRING2_YEAR="${STRING2:${#STRING2}-3:1}"
    local STRING2_MONTH="${STRING2:${#STRING2}-2:1}"
    local STRING2_INCREMENTAL="${STRING2:${#STRING2}-1:1}"

    [[ "$STRING1_MAJOR" > "$STRING2_MAJOR" ]] && return 0
    [[ "$STRING1_MAJOR" < "$STRING2_MAJOR" ]] && return 1
    [[ "$STRING1_YEAR" > "$STRING2_YEAR" ]] && return 0
    [[ "$STRING1_YEAR" < "$STRING2_YEAR" ]] && return 1
    [[ "$STRING1_MONTH" > "$STRING2_MONTH" ]] && return 0
    [[ "$STRING1_MONTH" < "$STRING2_MONTH" ]] && return 1
    [[ "$STRING1_INCREMENTAL" > "$STRING2_INCREMENTAL" ]] && return 0
    [[ "$STRING1_INCREMENTAL" < "$STRING2_INCREMENTAL" ]] && return 1

    return 0
}

GET_LATEST_FIRMWARE() {
    _CHECK_NON_EMPTY_PARAM "MODEL" "$1" || return 1
    _CHECK_NON_EMPTY_PARAM "CSC" "$2" || return 1

    curl -s --retry 5 --retry-delay 5 "https://fota-cloud-dn.ospserver.net/firmware/$2/$1/version.xml" \
        | perl -nE 'say $1 if /<latest[^>]*>(.*?)<\/latest>/'
}

PARSE_FIRMWARE_STRING() {
    local STRING="$1"

    if [ ! "$STRING" ]; then
        LOGE "Firmware value cannot be empty"
        return 1
    fi

    MODEL="$(cut -d "/" -f 1 -s <<< "$STRING")"
    if [ ! "$MODEL" ]; then
        LOGE "No device model value found in \"$STRING\""
        return 1
    fi

    CSC="$(cut -d "/" -f 2 -s <<< "$STRING")"
    if [ ! "$CSC" ]; then
        LOGE "No CSC value found in \"$STRING\""
        return 1
    elif [[ "${#CSC}" != "3" ]]; then
        LOGE "CSC not valid in \"$STRING\": $CSC"
        return 1
    fi

    local THIRD
    THIRD="$(cut -d "/" -f 3 -s <<< "$STRING")"
    if [ ! "$THIRD" ]; then
        LOGE "No IMEI/SN value found in \"$STRING\""
        return 1
    elif [[ "${#THIRD}" == "11" ]] && [[ "$THIRD" == "R"* ]]; then
        SERIAL_NO="$THIRD"
    elif [[ "${#THIRD}" -ge "8" ]] && [[ "${#THIRD}" -le "15" ]] && [[ "$THIRD" =~ ^[+-]?[0-9]+$ ]]; then
        IMEI="$THIRD"
    else
        LOGE "No valid IMEI/SN in \"$STRING\": $THIRD"
        return 1
    fi

    return 0
}

UNSPARSE_IMAGE() {
    _CHECK_NON_EMPTY_PARAM "FILE" "$1"

    local FILE="$1"
    local OUTPUT_PATH="$2"
    local REPLACE=false

    if [ ! -f "$FILE" ]; then
        LOGE "File not found: ${FILE//$SRC_DIR\//}"
        return 1
    fi

    if ! IS_SPARSE_IMAGE "$FILE"; then
        LOGW "Not a Android sparse image: ${FILE//$SRC_DIR\//}"
        return 0
    fi

    if [ ! "$OUTPUT_PATH" ]; then
        OUTPUT_PATH="$(dirname "$FILE")/unsparse_$(basename "$FILE")"
        REPLACE=true
    fi

    LOG "- Unsparsing $(basename "$FILE")..."

    EVAL "simg2img \"$FILE\" \"$OUTPUT_PATH\"" || return 1
    if $REPLACE; then
        mv -f "$OUTPUT_PATH" "$FILE"
    fi

    return 0
}

IS_SPARSE_IMAGE() {
    local FILE="$1"
    [ -f "$FILE" ] && file "$FILE" | grep -q "Android sparse image"
    return $?
}

READ_BYTES_AT() {
    local FILE="$1"
    local OFFSET="$2"
    local LENGTH="$3"

    if [ ! -f "$FILE" ]; then
        LOGE "File not found: ${FILE//$SRC_DIR\//}"
        return 1
    fi

    hexdump -n "$LENGTH" -s "$OFFSET" -e '"%02x"' "$FILE"
    return 0
}

GET_IMAGE_FILE_SYSTEM() {
    # https://android.googlesource.com/platform/external/e2fsprogs/+/refs/tags/android-15.0.0_r1/lib/ext2fs/ext2_fs.h#83
    if [[ "$(READ_BYTES_AT "$1" "1080" "2")" == "ef53" ]]; then
        echo "ext4"
    # https://android.googlesource.com/platform/external/f2fs-tools/+/refs/tags/android-15.0.0_r1/include/f2fs_fs.h#395
    elif [[ "$(READ_BYTES_AT "$1" "1024" "4")" == "f2f52010" ]]; then
        echo "f2fs"
    # https://android.googlesource.com/platform/external/erofs-utils/+/refs/tags/android-15.0.0_r1/include/erofs_fs.h#12
    elif [[ "$(READ_BYTES_AT "$1" "1024" "4")" == "e0f5e1e2" ]]; then
        echo "erofs"
    fi
} 
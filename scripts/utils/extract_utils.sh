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

EXTRACT_FILE_FROM_TAR() {
    _CHECK_NON_EMPTY_PARAM "TAR" "$1" || return 1
    _CHECK_NON_EMPTY_PARAM "FILE" "$2" || return 1

    local TAR="$1"
    local FILE="$2"
    local OUTPUT_PATH="$3"
    local REPLACE=false
    local TAR_FILE
    local TMP_OUTPUT

    if [ ! -f "$TAR" ]; then
        LOGE "File not found: ${TAR//$SRC_DIR\//}"
        return 1
    fi

    TAR_FILE="$(FILE_EXISTS_IN_TAR "$TAR" "$FILE")"
    if [ ! "$TAR_FILE" ]; then
        LOGW "File not found in tar: $FILE"
        return 0
    fi

    TMP_OUTPUT="$(mktemp)"

    if [ ! "$OUTPUT_PATH" ]; then
        OUTPUT_PATH="$FW_DIR/${MODEL}_${CSC}/$(basename "$FILE" .lz4)"
        REPLACE=true
    fi

    LOG "- Extracting $(basename "$FILE")..."

    if [[ "$TAR_FILE" == *".lz4" ]]; then
        EVAL "tar -xf \"$TAR\" \"$TAR_FILE\" -O | lz4 -d > \"$TMP_OUTPUT\"" || { rm -f "$TMP_OUTPUT"; return 1; }
    else
        EVAL "tar -xf \"$TAR\" \"$TAR_FILE\" -O > \"$TMP_OUTPUT\"" || { rm -f "$TMP_OUTPUT"; return 1; }
    fi

    if [ "$TMP_OUTPUT" != "$OUTPUT_PATH" ]; then
        EVAL "mv -f \"$TMP_OUTPUT\" \"$OUTPUT_PATH\"" || { rm -f "$TMP_OUTPUT"; return 1; }
    fi

    return 0
}

FILE_EXISTS_IN_TAR() {
    local TAR="$1"
    local FILE="$2"
    local FOUND

    if [ ! -f "$TAR" ]; then
        LOGE "File not found: ${TAR//$SRC_DIR\//}"
        return 1
    fi

    FOUND="$(tar -tf "$TAR" | grep -x "$FILE$")"
    if [ "$FOUND" ]; then
        echo "$FOUND"
        return 0
    fi

    FOUND="$(tar -tf "$TAR" | grep -x "$FILE.lz4$")"
    if [ "$FOUND" ]; then
        echo "$FOUND"
        return 0
    fi

    FOUND="$(tar -tf "$TAR" | grep -x "$FILE.ext4$")"
    if [ "$FOUND" ]; then
        echo "$FOUND"
        return 0
    fi

    FOUND="$(tar -tf "$TAR" | grep "/$(basename "$FILE")$")"
    if [ "$FOUND" ]; then
        echo "$FOUND"
        return 0
    fi

    FOUND="$(tar -tf "$TAR" | grep "/$(basename "$FILE").lz4$")"
    if [ "$FOUND" ]; then
        echo "$FOUND"
        return 0
    fi

    FOUND="$(tar -tf "$TAR" | grep "/$(basename "$FILE").ext4$")"
    if [ "$FOUND" ]; then
        echo "$FOUND"
        return 0
    fi

    return 1
} 
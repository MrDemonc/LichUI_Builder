#!/bin/bash

source "$dir_work/scripts/utils/common.sh"

export TOOLS_DIR="$dir_work/tools"
export OUT_DIR="$dir_work/out"
export ODIN_DIR="$OUT_DIR/odin"
export FW_DIR="$OUT_DIR/firmware"

mkdir -p "$ODIN_DIR" "$FW_DIR"

# Download and extract firmware
run download
run extract

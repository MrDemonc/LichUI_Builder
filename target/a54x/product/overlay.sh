#!/bin/bash

RRO_DIR="$dir_work/out/apktool/working/framework-res__r11sxxx__auto_generated_rro_product/res/values"
SRC_DIR="$dir_work/target/$TARGET/product/overlay/values"

FILES_TO_REPLACE=(
    "arrays.xml"
    "bools.xml"
    "dimens.xml"
    "integers.xml"
    "public.xml"
    "strings.xml"
)

log_info "- Applying overlay values to framework-res__r11sxxx__auto_generated_rro_product..."

for file in "${FILES_TO_REPLACE[@]}"; do
    if [ -f "$RRO_DIR/$file" ]; then
        rm -f "$RRO_DIR/$file"
    fi
    
    if [ -f "$SRC_DIR/$file" ]; then
        cp -f "$SRC_DIR/$file" "$RRO_DIR/$file"
    fi
done

log_success "- Overlay values applied successfully"

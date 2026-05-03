import re

with open("scripts/flashable_zip.sh", "r") as f:
    data = f.read()

# Define WORK_DIR and assemble partitions before building OS partitions
assembly_code = """
WORK_DIR="$dir_work/out/rom_workspace"
[ -d "$WORK_DIR" ] && rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR/configs"

log_info "- Assembling OS partitions workspace"
# SOURCE partitions
for p in system product; do
    if [ -d "$FW_DIR/$SOURCE_DIR/$p" ]; then
        ln -sf "$FW_DIR/$SOURCE_DIR/$p" "$WORK_DIR/$p"
        ln -sf "$FW_DIR/$SOURCE_DIR/file_context-$p" "$WORK_DIR/configs/file_context-$p"
        ln -sf "$FW_DIR/$SOURCE_DIR/fs_config-$p" "$WORK_DIR/configs/fs_config-$p"
    elif [ -d "$FW_DIR/$SOURCE_DIR/system/$p" ] && [ "$p" == "system" ]; then
        ln -sf "$FW_DIR/$SOURCE_DIR/system/system" "$WORK_DIR/system"
        ln -sf "$FW_DIR/$SOURCE_DIR/file_context-system" "$WORK_DIR/configs/file_context-system"
        ln -sf "$FW_DIR/$SOURCE_DIR/fs_config-system" "$WORK_DIR/configs/fs_config-system"
    fi
done

# TARGET partitions
for d in "$FW_DIR/$TARGET_DIR/"*; do
    if [ -d "$d" ]; then
        p="$(basename "$d")"
        if [[ "$p" != "system" ]] && [[ "$p" != "product" ]] && [[ "$p" != "system_ext" ]]; then
            ln -sf "$d" "$WORK_DIR/$p"
            ln -sf "$FW_DIR/$TARGET_DIR/file_context-$p" "$WORK_DIR/configs/file_context-$p"
            ln -sf "$FW_DIR/$TARGET_DIR/fs_config-$p" "$WORK_DIR/configs/fs_config-$p"
        fi
        if [[ "$p" == "system_ext" ]]; then
            # system_ext usually from TARGET, unless we want from SOURCE? 
            # Prompt says: "ademas se debera crear system y produtc del SOURCE, y las demas imagenes de TARGET excluyendo system y product"
            ln -sf "$d" "$WORK_DIR/$p"
            ln -sf "$FW_DIR/$TARGET_DIR/file_context-$p" "$WORK_DIR/configs/file_context-$p"
            ln -sf "$FW_DIR/$TARGET_DIR/fs_config-$p" "$WORK_DIR/configs/fs_config-$p"
        fi
    fi
done

log_info "- Building OS partitions"
"""

data = data.replace('log_info "- Building OS partitions"', assembly_code)

with open("scripts/flashable_zip.sh", "w") as f:
    f.write(data)


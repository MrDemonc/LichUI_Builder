#!/bin/bash
set -e

source "$dir_work/scripts/utils/apktool_utils.sh"
source "$dir_work/scripts/utils/smali_utils.sh"

if [ -f "${dir_work}/out/flags/.apktool" ]; then
    log_success "Apktool patches are already applied"
    exit 0
fi

PATCHES_ROOT="$dir_work/platform/customization/patches"

# Framework configuration
setup_framework

# ========================================================
# 1. Discover all unique APKs and JARs from patch folders
# ========================================================
declare -A UNIQUE_INPUTS

for variant in "essi" "common"; do
    variant_path="$PATCHES_ROOT/$variant"
    [ ! -d "$variant_path" ] && continue

    while IFS= read -r -d '' patch_dir; do
        patch_name=$(basename "$patch_dir")
        [[ "$patch_name" == "#"* ]] && continue

        system_dir="$patch_dir/system"
        [ ! -d "$system_dir" ] && continue

        while IFS= read -r -d '' apk_dir; do
            input_name=$(basename "$apk_dir")
            UNIQUE_INPUTS["$input_name"]=1
        done < <(find "$system_dir" -type d \( -name "*.apk" -o -name "*.jar" \) -print0 2>/dev/null)
    done < <(find "$variant_path" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
done

# Add framework-res overlay APK (not referenced in patch folders but needed)
UNIQUE_INPUTS["framework-res__r11sxxx__auto_generated_rro_product.apk"]=1

if [ ${#UNIQUE_INPUTS[@]} -eq 0 ]; then
    log_warning "No APKs or JARs found to patch"
    exit 0
fi

echo ""
log_info "━━━ Decompiling ━━━"
echo ""

# ========================================================
# 2. Decompile all unique inputs
# ========================================================
for input_name in "${!UNIQUE_INPUTS[@]}"; do
    decompile "$input_name"
done

echo ""
log_info "━━━ Applying patches ━━━"
echo ""

# ========================================================
# 3. Execute each patch folder's customize.sh
# ========================================================
for variant in "essi" "common"; do
    variant_path="$PATCHES_ROOT/$variant"
    [ ! -d "$variant_path" ] && continue

    while IFS= read -r -d '' patch_dir; do
        patch_name=$(basename "$patch_dir")
        [[ "$patch_name" == "#"* ]] && continue

        customize_script="$patch_dir/customize.sh"
        disabled_script="$patch_dir/#customize.sh"

        if [ -f "$disabled_script" ]; then
            log_warning "Skipping disabled patch: $patch_name ($variant)"
        elif [ -f "$customize_script" ]; then
            echo -e "${GREEN}[W] $patch_name -> $variant${NC}"
            export CURRENT_PATCH_DIR="$patch_dir"
            source "$customize_script"
        fi
    done < <(find "$variant_path" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
done

# ========================================================
# 4. Special: target-specific overlay for framework-res
# ========================================================
target_overlay="$dir_work/target/$TARGET/product/overlay.sh"
if [ -f "$target_overlay" ]; then
    echo -e "${GREEN}[W] Stock overlays -> overlay${NC}"
    source "$target_overlay" > /dev/null
fi

echo ""
log_info "━━━ Compiling ━━━"
echo ""

# ========================================================
# 5. Compile all
# ========================================================
for input_name in "${!UNIQUE_INPUTS[@]}"; do
    compile "$input_name"
done

echo ""
log_success "Process completed successfully"
touch "${dir_work}/out/flags/.apktool"
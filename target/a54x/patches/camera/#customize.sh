#!/bin/bash

camera_patch(){
    local cam_port="$FW_DIR/$SOURCE_FIRMWARE/system/system/cameradata"
    local cam_stock="$FW_DIR/$TARGET_FIRMWARE/system/system/cameradata"
    local filter="$dir_work/target/$TARGET/patches/camera/system/cameradata/myfilter"

    for dir in "${cam_port}" "${cam_stock}" "${filter}"; do
        if [ ! -d "${dir}" ]; then
            log_error "Directory not found: ${dir}" >&2
            return 1
        fi
    done

    rm -rf "${cam_port}" || log_warning "Failed to delete directory: ${cam_port}"
   
    cp -r ${cam_stock} ${cam_port} || log_warning "Failed to copy cameradata"

    rm -rf "${cam_port}/myfilter" || log_warning "Failed to delete myfilter"
    cp -r "${filter}" "${cam_port}" || log_warning "Failed to copy myfilter"

}

apply_ai_gallery_patch() {
    local target_file="$FW_DIR/$SOURCE_FIRMWARE/system/system/lib64/libPortraitSolution.camera.samsung.so"
    
    if [ ! -f "${target_file}" ]; then
        log_error "File not found: ${target_file}"
        return 1
    fi

    sed -i 's/system\/cameradata\/portrait_data\/single_bokeh_feature.json/system\/cameradata\/portrait_data\/singl_bokeh_feature.json\x00/g' "${target_file}"
}

ai_portrait(){
    local file="$FW_DIR/$TARGET_FIRMWARE/system/system/cameradata/portrait_data/single_bokeh_feature.json"
    local patch1="$FW_DIR/$SOURCE_FIRMWARE/system/system/cameradata/portrait_data/single_bokeh_feature.json"
    local patch="$FW_DIR/$SOURCE_FIRMWARE/system/system/cameradata/portrait_data/singl_bokeh_feature.json"

    if [ ! -f "${file}" ]; then
        log_error "File not found: ${file}"
        return 1
    fi

    cp "${file}" "${patch}" || {
        log_error "Copy file error" >&2
        return 1
        }
    
    sed -i "s/MODEL_TYPE_INSTANCE_CAPTURE/MODEL_TYPE_OBJ_INSTANCE_CAPTURE/g" "${patch1}" || {
        log_error "Error change MODEL_TYPE_INSTANCE_CAPTURE for MODEL_TYPE_OBJ_INSTANCE_CAPTURE" >&2
        return 1
        }
}

patch_midas(){
    local config_file="$FW_DIR/$TARGET_FIRMWARE/vendor/etc/midas/midas_config.json"
    local remaster="$FW_DIR/$SOURCE_FIRMWARE/system/system/priv-app/PhotoRemasterService/oat"

    if [ ! -f "${config_file}" ]; then
        log_error "File not found: ${config_file}"
        return 1
    fi

    sed -i "s/ro.product.device/ro.product.vendor.device/g" "${config_file}" || {
        log_error "Error patch midas" >&2
        return 1
        }

    if [ ! -d "${remaster}" ]; then
        log_error "Directory not found: ${remaster}"
        return 1
    else
        rm -rf "${remaster}" || {
        return 1
        }
    fi
}

# ========================================================

if [ -f "${dir_work}/out/flags/.camera" ]; then
    log_success "Camera is already patched"
    exit 0
fi

# system
delete_items "$SOURCE_FIRMWARE/system/system/lib64" "libDeepDocRectify.camera.samsung.so"
delete_items "$SOURCE_FIRMWARE/system/system/lib64" "liblow_light_hdr.arcsoft.so"
delete_items "$SOURCE_FIRMWARE/system/system/lib64" "libhigh_dynamic_range.arcsoft.so"
delete_items "$SOURCE_FIRMWARE/system/system/lib64" "libImageTagger.camera.samsung.so"
delete_items "$TARGET_FIRMWARE/vendor/lib64/hw" "camera.s5e8835.so"
copy_items "$TARGET_FIRMWARE/system/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "liblow_light_hdr.arcsoft.so"
copy_items "$TARGET_FIRMWARE/system/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "libhigh_dynamic_range.arcsoft.so"
copy_items "$TARGET_FIRMWARE/system/system/lib64" "$SOURCE_FIRMWARE/system/system/lib64" "libImageTagger.camera.samsung.so"
copy_items "$dir_work/target/$TARGET/patches/camera/vendor/lib64/hw" "$TARGET_FIRMWARE/vendor/lib64/hw" "camera.s5e8835.so"

#vendor
delete_items "$TARGET_FIRMWARE/vendor/etc" "media_codecs_c2.xml"
delete_items "$TARGET_FIRMWARE/vendor/etc" "media_codecs_performance_c2.xml"
delete_items "$TARGET_FIRMWARE/vendor/etc" "media_profiles_V1_0.xml"
copy_items "$dir_work/target/$TARGET/patches/camera/vendor/etc" "$TARGET_FIRMWARE/vendor/etc" "media_codecs_c2.xml"
copy_items "$dir_work/target/$TARGET/patches/camera/vendor/etc" "$TARGET_FIRMWARE/vendor/etc" "media_codecs_performance_c2.xml"
copy_items "$dir_work/target/$TARGET/patches/camera/vendor/etc" "$TARGET_FIRMWARE/vendor/etc" "media_profiles_V1_0.xml"

camera_patch

apply_ai_gallery_patch

ai_portrait

patch_midas

add_work "/system/cameradata/logCubefiles/3DLUT.cube" '$SOURCE_FIRMWARE/system'
add_work "/system/cameradata/myfilter/fleecia.png" '$SOURCE_FIRMWARE/system'
add_work "/system/cameradata/myfilter/cinepea.png" '$SOURCE_FIRMWARE/system'
add_work "/system/cameradata/myfilter/default.png" '$SOURCE_FIRMWARE/system'
add_work "/system/cameradata/myfilter/excitea.png" '$SOURCE_FIRMWARE/system'
add_work "/system/cameradata/myfilter/jazzchrome.png" '$SOURCE_FIRMWARE/system'
add_work "/system/cameradata/myfilter/monochrome.png" '$SOURCE_FIRMWARE/system'
add_work "/system/cameradata/myfilter/MyFilterDetector.tflite" '$SOURCE_FIRMWARE/system'
add_work "/system/cameradata/portrait_data/SRIB_HumanSegVideoLite_INT8_V101_ex8835_enn422.nnc" '$SOURCE_FIRMWARE/system'
add_work "/system/cameradata/portrait_data/SRIB_Banet_FP16_V400.tflite" '$SOURCE_FIRMWARE/system'
add_work "/system/cameradata/portrait_data/singl_bokeh_feature.json" '$SOURCE_FIRMWARE/system'
add_work "/system/cameradata/preloadfilters/grain_patch_weak_1.png" '$SOURCE_FIRMWARE/system'
add_work "/system/cameradata/preloadfilters/grain_patch_strong_4.png" '$SOURCE_FIRMWARE/system'
add_work "/system/cameradata/preloadfilters/grain_patch_strong_6.png" '$SOURCE_FIRMWARE/system'
add_work "/system/lib64/libImageTagger.camera.samsung.so" '$SOURCE_FIRMWARE/system'

log_success "Process completed successfully"
touch "${dir_work}/out/flags/.camera"
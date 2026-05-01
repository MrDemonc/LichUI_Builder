#!/bin/bash

camera_patch(){
    local cam_port="$FW_DIR/$SOURCE_DIR/system/system/cameradata"
    local cam_stock="$FW_DIR/$TARGET_DIR/system/system/cameradata"
    local filter="system/cameradata/myfilter"

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
    local target_file="$FW_DIR/$SOURCE_DIR/system/system/lib64/libPortraitSolution.camera.samsung.so"
    
    if [ ! -f "${target_file}" ]; then
        log_error "File not found: ${target_file}"
        return 1
    fi

    sed -i 's/system\/cameradata\/portrait_data\/single_bokeh_feature.json/system\/cameradata\/portrait_data\/singl_bokeh_feature.json\x00/g' "${target_file}"
}

ai_portrait(){
    local file="$FW_DIR/$TARGET_DIR/system/system/cameradata/portrait_data/single_bokeh_feature.json"
    local patch1="$FW_DIR/$SOURCE_DIR/system/system/cameradata/portrait_data/single_bokeh_feature.json"
    local patch="$FW_DIR/$SOURCE_DIR/system/system/cameradata/portrait_data/singl_bokeh_feature.json"

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
    local config_file="$FW_DIR/$TARGET_DIR/vendor/etc/midas/midas_config.json"
    local remaster="$FW_DIR/$SOURCE_DIR/system/system/priv-app/PhotoRemasterService/oat"

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

# system
delete system "lib64/libDeepDocRectify.camera.samsung.so"
delete system "lib64/liblow_light_hdr.arcsoft.so"
delete system "lib64/libhigh_dynamic_range.arcsoft.so"
add system "$FW_DIR/$TARGET_DIR/system/system/lib64/liblow_light_hdr.arcsoft.so" "lib64/liblow_light_hdr.arcsoft.so"
add system "$FW_DIR/$TARGET_DIR/system/system/lib64/libhigh_dynamic_range.arcsoft.so" "lib64/libhigh_dynamic_range.arcsoft.so"
add system "$FW_DIR/$TARGET_DIR/system/system/lib64/libImageTagger.camera.samsung.so" "lib64/libImageTagger.camera.samsung.so"

#vendor
delete vendor "etc/media_codecs_c2.xml"
delete vendor "etc/media_codecs_performance_c2.xml"
delete vendor "etc/media_profiles_V1_0.xml"
add vendor "vendor/etc/media_codecs_c2.xml" "etc/media_codecs_c2.xml"
add vendor "vendor/etc/media_codecs_performance_c2.xml" "etc/media_codecs_performance_c2.xml"
add vendor "vendor/etc/media_profiles_V1_0.xml" "etc/media_profiles_V1_0.xml"

camera_patch

apply_ai_gallery_patch

ai_portrait

patch_midas
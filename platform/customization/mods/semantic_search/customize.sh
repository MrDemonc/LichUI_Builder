# This mod use apktool patch -> patches/common/semantic_search

# Add line in Floating Feature
update_config "SEC_FLOATING_FEATURE_MSCH_SUPPORT_NLSEARCH" "TRUE"

add system "system/etc/default-permissions/default-permissions-com.samsung.mediasearch.xml" "etc/default-permissions/default-permissions-com.samsung.mediasearch.xml"
add system "system/etc/permissions/privapp-permissions-com.samsung.mediasearch.xml" "etc/permissions/privapp-permissions-com.samsung.mediasearch.xml"
add system "system/priv-app/MediaSearch" "priv-app/MediaSearch"
add system "system/priv-app/SemanticSearchCore" "priv-app/SemanticSearchCore"
add system "system/etc/mediasearch/data" "etc/mediasearch/data"
set_metadata system "system/etc/mediasearch"

#add system "system/etc/mediasearch/data/dec_adaptor.tflite" "etc/mediasearch/data/dec_adaptor.tflite"
#add system "system/etc/mediasearch/data/dec_event.tflite" "etc/mediasearch/data/dec_event.tflite"
#add system "system/etc/mediasearch/data/enc_image.tflite" "etc/mediasearch/data/enc_image.tflite"
#add system "system/etc/mediasearch/data/enc_text.tflite" "etc/mediasearch/data/enc_text.tflite"
#add system "system/etc/mediasearch/data/versioninfo.json" "etc/mediasearch/data/versioninfo.json"
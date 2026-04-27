#!/bin/bash

delete_items "$dir_work/out/apktool/working/framework-res__r11sxxx__auto_generated_rro_product/res/values" "arrays.xml"
delete_items "$dir_work/out/apktool/working/framework-res__r11sxxx__auto_generated_rro_product/res/values" "bools.xml"
delete_items "$dir_work/out/apktool/working/framework-res__r11sxxx__auto_generated_rro_product/res/values" "dimens.xml"
delete_items "$dir_work/out/apktool/working/framework-res__r11sxxx__auto_generated_rro_product/res/values" "integers.xml"
delete_items "$dir_work/out/apktool/working/framework-res__r11sxxx__auto_generated_rro_product/res/values" "public.xml"
delete_items "$dir_work/out/apktool/working/framework-res__r11sxxx__auto_generated_rro_product/res/values" "strings.xml"
copy_items "$dir_work/target/$TARGET/product/overlay/values" "$dir_work/out/apktool/working/framework-res__r11sxxx__auto_generated_rro_product/res/values" "arrays.xml"
copy_items "$dir_work/target/$TARGET/product/overlay/values" "$dir_work/out/apktool/working/framework-res__r11sxxx__auto_generated_rro_product/res/values" "bools.xml"
copy_items "$dir_work/target/$TARGET/product/overlay/values" "$dir_work/out/apktool/working/framework-res__r11sxxx__auto_generated_rro_product/res/values" "dimens.xml"
copy_items "$dir_work/target/$TARGET/product/overlay/values" "$dir_work/out/apktool/working/framework-res__r11sxxx__auto_generated_rro_product/res/values" "integers.xml"
copy_items "$dir_work/target/$TARGET/product/overlay/values" "$dir_work/out/apktool/working/framework-res__r11sxxx__auto_generated_rro_product/res/values" "public.xml"
copy_items "$dir_work/target/$TARGET/product/overlay/values" "$dir_work/out/apktool/working/framework-res__r11sxxx__auto_generated_rro_product/res/values" "strings.xml"

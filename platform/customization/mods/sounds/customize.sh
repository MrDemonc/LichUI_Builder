#!/bin/bash

add pa2qxxx system "system/hidden/INTERNAL_SDCARD/Music/Samsung/Over_the_Horizon.m4a" "hidden/INTERNAL_SDCARD/Music/Samsung/Over_the_Horizon.m4a"

add a56x system "system/media/audio/notifications" "media/audio/notifications"
add a56x system "system/media/audio/ringtones" "media/audio/ringtones"
add a56x system "system/etc/ringtones_count_list.txt" "etc/ringtones_count_list.txt"

setprop vendor "vendor.prop"
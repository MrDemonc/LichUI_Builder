#!/bin/bash

log_warning "   Applying certificate signature to InstallPackageHelper.smali..."

if [ "$OFFICIAL_ROM" = "true" ]; then
    PEM_FILE="$dir_work/Security/lich-ota.x509.pem"
else
    PEM_FILE="$dir_work/Security/aosp_platform.x509.pem"
fi

CERT_SIGNATURE=$(sed '/CERTIFICATE/d' "$PEM_FILE" | tr -d '\n' | base64 -d | xxd -p -c 0)


if [ -f "$APKTOOL/working/services/smali_classes2/com/android/server/pm/InstallPackageHelper.smali" ]; then
    sed -i "s|CONFIG_CUSTOM_PLATFORM_SIGNATURE|$CERT_SIGNATURE|g" "$APKTOOL/working/services/smali_classes2/com/android/server/pm/InstallPackageHelper.smali"
    log_success "   Certificate signature applied successfully"
else
    log_warning "   InstallPackageHelper.smali not found, skipping signature application"
fi

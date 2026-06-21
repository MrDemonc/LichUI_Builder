#!/bin/bash

log_warning "- Applying certificate signature to ScanPackageUtils.smali..."

if [ "$OFFICIAL_ROM" = "true" ]; then
    PEM_FILE="$dir_work/platform/security/lich-ota.x509.pem"
else
    PEM_FILE="$dir_work/platform/security/aosp_platform.x509.pem"
fi

CERT_SIGNATURE=$(sed '/CERTIFICATE/d' "$PEM_FILE" | tr -d '\n' | base64 -d | xxd -p -c 0)

if [ -f "$APKTOOL/working/services/smali_classes2/com/android/server/pm/ScanPackageUtils.smali" ]; then
    SMALI_PATCH "services" \
        "smali_classes2/com/android/server/pm/ScanPackageUtils.smali" "replace" \
        'signedWithCustomSignature([Landroid/content/pm/Signature;)Z' \
        'CONFIG_CUSTOM_PLATFORM_SIGNATURE' \
        "$CERT_SIGNATURE"
    log_success "- Certificate signature applied successfully"
else
    log_warning "- ScanPackageUtils.smali not found, skipping signature application"
    exit 1
fi

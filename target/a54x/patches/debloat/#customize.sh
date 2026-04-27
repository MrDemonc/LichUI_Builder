#!/bin/bash

if [ -f "${dir_work}/out/flags/.debloat" ]; then
    log_success "Debloat is already applied"
    exit 0
fi

PRODUCT_DEBLOAT=(
	"app/Chrome"
	"app/DuoStub"
	"app/Gmail2"
	"app/Maps"
	"app/YouTube"
	"overlay/SoftapOverlay6GHz"
	"overlay/SoftapOverlayOWE"
	"overlay/SoftapOverlayQC"
	"priv-app/CarrierWifi"
	"priv-app/Messages"
)

SYSTEM_DEBLOAT=(
	"app/ARCore"
	"app/BBCAgent"
	"app/BlockchainBasicKit"
	"app/CarrierDefaultApp"
	"app/FBAppManager_NS"
	"app/GearManagerStub"
	"app/KidsHome_Installer"
	"app/MAPSAgent"
	"app/MDMApp"
	"app/PlayAutoInstallConfig"
	"app/SamsungPassAutofill_v1"
	"app/UniversalMDMClient"
	"app/WifiRROverlayAppQC"
	"app/WifiRROverlayAppWifiLock"
	"hidden/SmartTutor"
	"preload/Facebook_stub_preload"
	"etc/permissions/cameraservice.xml"
	"etc/permissions/org.carconnectivity.android.digitalkey.rangingintent.xml"
	"etc/permissions/org.carconnectivity.android.digitalkey.secureelement.xml"
	"framework/scamera_sep.jar"
	"priv-app/AppUpdateCenter"
	"priv-app/AREmoji"
	"priv-app/AREmojiEditor"
	"priv-app/AuthFramework"
	"priv-app/AvatarEmojiSticker"
	"priv-app/EnhancedAttestationAgent"
	"priv-app/FBInstaller_NS"
	"priv-app/FBServices"
	"priv-app/FotaAgent"
	"priv-app/KLMSAgent"
	"priv-app/OMCAgent5"
	"priv-app/OneDrive_Samsung_v3"
	"priv-app/PaymentFramework"
	"priv-app/SPPPushClient"
	"priv-app/SamsungPass"
	"priv-app/Upday"
	"priv-app/SCameraSDKService"
	"priv-app/EsimClient"
	"priv-app/EsimKeyString"
	"priv-app/EuiccService"
	"priv-app/CIDManager"
)

for entry in "${PRODUCT_DEBLOAT[@]}"; do
    dir_part="${entry%/*}"
    name_part="${entry##*/}"
    base_dir="$SOURCE_FIRMWARE/product"
    if [ "$dir_part" != "$entry" ]; then
        base_dir="$base_dir/$dir_part"
    fi
    delete_items "$base_dir" "$name_part"
done

for entry in "${SYSTEM_DEBLOAT[@]}"; do
    dir_part="${entry%/*}"
    name_part="${entry##*/}"
    base_dir="$SOURCE_FIRMWARE/system/system"
    if [ "$dir_part" != "$entry" ]; then
        base_dir="$base_dir/$dir_part"
    fi
    delete_items "$base_dir" "$name_part"
done

log_success "Process completed successfully"
touch "${dir_work}/out/flags/.debloat"
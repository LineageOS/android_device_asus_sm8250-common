#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}"/../../..

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

function blob_fixup() {
    case "${1}" in
        etc/permissions/qti_libpermissions.xml)
            sed -i 's/<library name="android.hidl.manager-V1.0-java"/<library name="android.hidl.manager@1.0-java"/g' "${2}"
            ;;
        vendor/etc/init/init.embmssl_server.rc)
            sed -i '/vendor.qti.hardware.embmssl@1.0::IEmbms/d' "${2}"
            ;;
        vendor/bin/hw/android.hardware.media.omx@1.0-service)
            sed -i "s/libavservices_minijail_vendor.so/libavservices_minijail.so\x00\x00\x00\x00\x00\x00\x00/" "${2}"
            ;;
        product/lib/libdpmframework.so)
            sed -i "s/libhidltransport.so/libcutils-v29.so\x00\x00\x00/" "${2}"
            ;;
        product/lib64/libdpmframework.so)
            sed -i "s/libhidltransport.so/libcutils-v29.so\x00\x00\x00/" "${2}"
            ;;
        vendor/bin/hw/android.hardware.neuralnetworks@1.2-service-qti)
            ;&
        vendor/bin/hw/android.hardware.usb@1.1-service-qti)
            ;&
        vendor/lib64/hw/android.hardware.gnss@2.0-impl-qti.so)
            ;&
        vendor/lib64/hw/android.hardware.camera.provider@2.4-impl.so)
            ;&
        vendor/lib64/hw/android.hardware.bluetooth@1.0-impl-qti.so)
            ;&
        vendor/lib64/unnhal-acc-hvx.so)
            ;&
        vendor/lib64/hw/com.qti.chi.override.so)
            $PATCHELF --add-needed qtimutex.so "${2}"
            ;&
            # FALLTHROUGH: most of the above blobs also need libcomparetf2
        vendor/lib64/libril-qc-hal-qmi.so)
            ;&
        vendor/lib64/libssc.so)
            ;&
        vendor/lib64/libcamxncs.so)
            $PATCHELF --add-needed libcomparetf2.so "${2}"
            ;;
        vendor/lib64/libvidhance.so)
            $PATCHELF --add-needed libcomparetf2.so "${2}"
            $PATCHELF --add-needed libxditk_DIT_MSMv1.so "${2}"
            ;;
        product/lib64/libsecureuisvc_jni.so)
            ;&
        product/lib64/libsystemhelper_jni.so)
            sed -i "s/libhidltransport.so/libgui_shim.so\x00\x00\x00\x00\x00/" "${2}"
            ;;
    esac
}

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

ONLY_COMMON=
ONLY_TARGET=
KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-common )
                ONLY_COMMON=true
                ;;
        --only-target )
                ONLY_TARGET=true
                ;;
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

if [ -z "${ONLY_TARGET}" ]; then
    # Initialize the helper for common device
    setup_vendor "${DEVICE_COMMON}" "${VENDOR}" "${ANDROID_ROOT}" true "${CLEAN_VENDOR}"

    extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" \
        "${KANG}" --section "${SECTION}"

if [ -z "${ONLY_COMMON}" ]; then
    # Reinitialize the helper for device
    source "${MY_DIR}/../${DEVICE}/extract-files.sh"
    setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"
    for BLOB_LIST in "${MY_DIR}"/../"${DEVICE}"/proprietary-files*.txt; do
        extract "${BLOB_LIST}" "${SRC}" "${KANG}" --section "${SECTION}"
    done
fi

"${MY_DIR}/setup-makefiles.sh"

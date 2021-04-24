#
# Copyright (C) 2019 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "$HELPER" ]; then
    echo "Unable to find helper script at $HELPER"
    exit 1
fi
. "$HELPER"

if [ -z "$1" ]; then
    echo "No input image supplied"
    exit 1
fi

if [ -z "$2" ]; then
    echo "No output filename supplied"
    exit 1
fi

VENDOR_SKIP_FILES_COMMON=(
    # Toybox
    "bin/acpi"
    "bin/base64"
    "bin/basename"
    "bin/bc"
    "bin/blockdev"
    "bin/cal"
    "bin/cat"
    "bin/chattr"
    "bin/chcon"
    "bin/chgrp"
    "bin/chmod"
    "bin/chown"
    "bin/chroot"
    "bin/chrt"
    "bin/cksum"
    "bin/clear"
    "bin/cmp"
    "bin/comm"
    "bin/cp"
    "bin/cpio"
    "bin/cut"
    "bin/date"
    "bin/dd"
    "bin/df"
    "bin/diff"
    "bin/dirname"
    "bin/devmem"
    "bin/dmesg"
    "bin/dos2unix"
    "bin/du"
    "bin/echo"
    "bin/egrep"
    "bin/env"
    "bin/expand"
    "bin/expr"
    "bin/fallocate"
    "bin/false"
    "bin/fgrep"
    "bin/file"
    "bin/find"
    "bin/flock"
    "bin/fmt"
    "bin/free"
    "bin/fsync"
    "bin/getconf"
    "bin/getenforce"
    "bin/getevent"
    "bin/getprop"
    "bin/groups"
    "bin/gunzip"
    "bin/gzip"
    "bin/head"
    "bin/hostname"
    "bin/hwclock"
    "bin/i2cdetect"
    "bin/i2cdump"
    "bin/i2cget"
    "bin/i2cset"
    "bin/iconv"
    "bin/id"
    "bin/ifconfig"
    "bin/inotifyd"
    "bin/insmod"
    "bin/install"
    "bin/ionice"
    "bin/iorenice"
    "bin/kill"
    "bin/killall"
    "bin/ln"
    "bin/load_policy"
    "bin/log"
    "bin/logname"
    "bin/losetup"
    "bin/ls"
    "bin/lsattr"
    "bin/lsmod"
    "bin/lsof"
    "bin/lspci"
    "bin/lsusb"
    "bin/md5sum"
    "bin/microcom"
    "bin/mkdir"
    "bin/mkfifo"
    "bin/mknod"
    "bin/mkswap"
    "bin/mktemp"
    "bin/modinfo"
    "bin/modprobe"
    "bin/more"
    "bin/mount"
    "bin/mountpoint"
    "bin/mv"
    "bin/nc"
    "bin/netcat"
    "bin/netstat"
    "bin/newfs_msdos"
    "bin/nice"
    "bin/nl"
    "bin/nohup"
    "bin/nproc"
    "bin/nsenter"
    "bin/od"
    "bin/paste"
    "bin/patch"
    "bin/pgrep"
    "bin/pidof"
    "bin/pkill"
    "bin/pmap"
    "bin/printenv"
    "bin/printf"
    "bin/ps"
    "bin/pwd"
    "bin/readlink"
    "bin/readelf"
    "bin/realpath"
    "bin/renice"
    "bin/restorecon"
    "bin/rm"
    "bin/rmdir"
    "bin/rmmod"
    "bin/runcon"
    "bin/sed"
    "bin/sendevent"
    "bin/seq"
    "bin/setenforce"
    "bin/setprop"
    "bin/setsid"
    "bin/sha1sum"
    "bin/sha224sum"
    "bin/sha256sum"
    "bin/sha384sum"
    "bin/sha512sum"
    "bin/sleep"
    "bin/sort"
    "bin/split"
    "bin/start"
    "bin/stat"
    "bin/stop"
    "bin/strings"
    "bin/stty"
    "bin/swapoff"
    "bin/swapon"
    "bin/sync"
    "bin/sysctl"
    "bin/tac"
    "bin/tail"
    "bin/tar"
    "bin/taskset"
    "bin/tee"
    "bin/test"
    "bin/time"
    "bin/timeout"
    "bin/top"
    "bin/touch"
    "bin/tr"
    "bin/true"
    "bin/truncate"
    "bin/tty"
    "bin/ulimit"
    "bin/umount"
    "bin/uname"
    "bin/uniq"
    "bin/unix2dos"
    "bin/unlink"
    "bin/unshare"
    "bin/uptime"
    "bin/usleep"
    "bin/uudecode"
    "bin/uuencode"
    "bin/uuidgen"
    "bin/vmstat"
    "bin/watch"
    "bin/wc"
    "bin/which"
    "bin/whoami"
    "bin/xargs"
    "bin/xxd"
    "bin/yes"
    "bin/zcat"

    # Tools
    "bin/awk"
    "bin/checkpoint_gc"
    "bin/cplay"
    "bin/dumpsys"
    "bin/logwrapper"
    "bin/wpa_cli"
    "bin/sh"
    "etc/mkshrc"

    # config.fs
    "etc/fs_config_dirs"
    "etc/fs_config_files"
    "etc/group"
    "etc/passwd"

    # Kernel modules
    "lib/modules/audio_adsp_loader.ko"
    "lib/modules/audio_apr.ko"
    "lib/modules/audio_bolero_cdc.ko"
    "lib/modules/audio_hdmi.ko"
    "lib/modules/audio_machine_kona.ko"
    "lib/modules/audio_mbhc.ko"
    "lib/modules/audio_native.ko"
    "lib/modules/audio_pinctrl_lpi.ko"
    "lib/modules/audio_pinctrl_wcd.ko"
    "lib/modules/audio_platform.ko"
    "lib/modules/audio_q6.ko"
    "lib/modules/audio_q6_notifier.ko"
    "lib/modules/audio_q6_pdr.ko"
    "lib/modules/audio_rt5683.ko"
    "lib/modules/audio_rx_macro.ko"
    "lib/modules/audio_snd_event.ko"
    "lib/modules/audio_stub.ko"
    "lib/modules/audio_swr_ctrl.ko"
    "lib/modules/audio_swr.ko"
    "lib/modules/audio_tfa9874.ko"
    "lib/modules/audio_tx_macro.ko"
    "lib/modules/audio_usf.ko"
    "lib/modules/audio_va_macro.ko"
    "lib/modules/audio_wcd938x.ko"
    "lib/modules/audio_wcd938x_slave.ko"
    "lib/modules/audio_wcd9xxx.ko"
    "lib/modules/audio_wcd_core.ko"
    "lib/modules/audio_wsa_macro.ko"
    "lib/modules/br_netfilter.ko"
    "lib/modules/ec_i2c_interface.ko"
    "lib/modules/ene_6k582_station.ko"
    "lib/modules/ene_8k41_dock.ko"
    "lib/modules/ene_8k41_power.ko"
    "lib/modules/gspca_main.ko"
    "lib/modules/lcd.ko"
    "lib/modules/llcc_perfmon.ko"
    "lib/modules/ml51fb9ae_inbox.ko"
    "lib/modules/modules.alias"
    "lib/modules/modules.dep"
    "lib/modules/modules.softdep"
    "lib/modules/mpq-adapter.ko"
    "lib/modules/mpq-dmx-hw-plugin.ko"
    "lib/modules/ms51_inbox.ko"
    "lib/modules/nct7802.ko"
    "lib/modules/qca_cld3_wlan.ko"
    "lib/modules/qca_cld3_qca6390.ko"
    "lib/modules/qca_cld3_qca6490.ko"
    "lib/modules/rdbg.ko"
    "lib/modules/rmnet_perf.ko"
    "lib/modules/rmnet_shs.ko"
    "lib/modules/station_goodix_touch.ko"
    "lib/modules/station_key.ko"
    "lib/modules/texfat.ko"
    "lib/modules/tntfs.ko"
    "lib/modules/tspp.ko"

    # Overlays
    "overlay/FrameworksResCommon.apk"
    "overlay/FrameworksResTarget.apk"
    "overlay/TelephonyResCommon.apk"

    # VNDK
    "bin/vndservice"
    "bin/vndservicemanager"
    "etc/init/vndservicemanager.rc"
    "lib/libhwminijail.so"
    "lib/libgui_vendor.so"
    "etc/vintf/manifest/manifest.xml"

    # Sepolicy
    "etc/selinux/vendor_file_contexts"
    "etc/selinux/nonplat_file_contexts"
    "etc/selinux/nonplat_hwservice_contexts"
    "etc/selinux/nonplat_mac_permissions.xml"
    "etc/selinux/nonplat_property_contexts"
    "etc/selinux/nonplat_seapp_contexts"
    "etc/selinux/nonplat_sepolicy.cil"
    "etc/selinux/nonplat_service_contexts"
    "etc/selinux/plat_sepolicy_vers.txt"
    "etc/selinux/precompiled_sepolicy"
    "etc/selinux/precompiled_sepolicy.plat_and_mapping.sha256"
    "etc/selinux/vndservice_contexts"
    "etc/selinux/plat_pub_versioned.cil"
    "etc/selinux/vendor_hwservice_contexts"
    "etc/selinux/vendor_mac_permissions.xml"
    "etc/selinux/vendor_property_contexts"
    "etc/selinux/vendor_seapp_contexts"
    "etc/selinux/vendor_sepolicy.cil"

    # Symlinks
    "app/CneApp/lib/arm64/libvndfwk_detect_jni.qti.so"
    "app/QDMA/lib/arm64/libvndfwk_detect_jni.qti.so"
    "app/QDMA-UI/lib/arm64/libvndfwk_detect_jni.qti.so"
    "asusfw"
    "odm"
    "factory"
    "firmware/wlan/qca_cld/COUNTRY"
    "firmware/wlan/qca_cld/qca6390/wlan_mac.bin"
    "firmware/wlan/qca_cld/qca6490/wlan_mac.bin"
    "rfs/apq/gnss/hlos"
    "rfs/apq/gnss/ramdumps"
    "rfs/apq/gnss/readonly/firmware"
    "rfs/apq/gnss/readonly/vendor/firmware"
    "rfs/apq/gnss/readwrite"
    "rfs/apq/gnss/shared"
    "rfs/mdm/adsp/hlos"
    "rfs/mdm/adsp/ramdumps"
    "rfs/mdm/adsp/readonly/firmware"
    "rfs/mdm/adsp/readonly/vendor/firmware"
    "rfs/mdm/adsp/readwrite"
    "rfs/mdm/adsp/shared"
    "rfs/mdm/cdsp/hlos"
    "rfs/mdm/cdsp/ramdumps"
    "rfs/mdm/cdsp/readonly/firmware"
    "rfs/mdm/cdsp/readwrite"
    "rfs/mdm/cdsp/shared"
    "rfs/mdm/mpss/hlos"
    "rfs/mdm/mpss/ramdumps"
    "rfs/mdm/mpss/readonly/firmware"
    "rfs/mdm/mpss/readonly/vendor/firmware"
    "rfs/mdm/mpss/readwrite"
    "rfs/mdm/mpss/shared"
    "rfs/mdm/slpi/hlos"
    "rfs/mdm/slpi/ramdumps"
    "rfs/mdm/slpi/readonly/firmware"
    "rfs/mdm/slpi/readwrite"
    "rfs/mdm/slpi/shared"
    "rfs/mdm/tn/hlos"
    "rfs/mdm/tn/ramdumps"
    "rfs/mdm/tn/readonly/firmware"
    "rfs/mdm/tn/readwrite"
    "rfs/mdm/tn/shared"
    "rfs/msm/adsp/hlos"
    "rfs/msm/adsp/ramdumps"
    "rfs/msm/adsp/readonly/firmware"
    "rfs/msm/adsp/readonly/vendor/firmware"
    "rfs/msm/adsp/readwrite"
    "rfs/msm/adsp/shared"
    "rfs/msm/cdsp/hlos"
    "rfs/msm/cdsp/ramdumps"
    "rfs/msm/cdsp/readonly/firmware"
    "rfs/msm/cdsp/readonly/vendor/firmware"
    "rfs/msm/cdsp/readwrite"
    "rfs/msm/cdsp/shared"
    "rfs/msm/mpss/hlos"
    "rfs/msm/mpss/ramdumps"
    "rfs/msm/mpss/readonly/firmware"
    "rfs/msm/mpss/readonly/vendor/firmware"
    "rfs/msm/mpss/readwrite"
    "rfs/msm/mpss/shared"
    "rfs/msm/slpi/hlos"
    "rfs/msm/slpi/ramdumps"
    "rfs/msm/slpi/readonly/firmware"
    "rfs/msm/slpi/readonly/vendor/firmware"
    "rfs/msm/slpi/readwrite"
    "rfs/msm/slpi/shared"
    "lib/libEGL_adreno.so"
    "lib/libGLESv2_adreno.so"
    "lib/libq3dtools_adreno.so"
    "lib64/libEGL_adreno.so"
    "lib64/libGLESv2_adreno.so"
    "lib64/libq3dtools_adreno.so"

    # Asus setenforce
    "etc/init/hw/init.asus.debugtool.rc"
    "etc/init/init.asus.shippingrework.rc"
    "etc/init/init.asus.vib_test.rc"
    "bin/AsusReInstallAttestationKey.sh"
    "bin/init.asus.check_last.sh"
    "bin/init.asus.check_asdf.sh"
    "bin/init.asus.checkdevcfg.sh"
    "bin/triggerpanic.sh"
    "bin/savelogs.sh"
    "bin/savelogmtp.sh"
    "bin/setenforce.sh"
    "bin/shipping_rework.sh"
    "bin/widevine.sh"

    # Region specific build.prop
    "build_eu_elite.prop"
    "build_eu.prop"
    "build_ru.prop"
    "build_ww_elite.prop"

    # Misc daemons
    "bin/sar_setting"
    "bin/antennaswap"
    "bin/ecUeventd"
    "bin/asus_osinfo"

    # Rootdir
    "etc/fstab.qcom"
    "etc/init/hw/init.asus.usb.rc"
    "etc/init/hw/init.qcom.factory.rc"
    "etc/init/hw/init.qcom.rc"
    "etc/init/hw/init.recovery.qcom.rc"
    "etc/init/hw/init.target.rc"

    # libhardware
    "lib64/hw/audio.primary.default.so"
    "lib/hw/audio.primary.default.so"
    "lib64/hw/local_time.default.so"
    "lib/hw/local_time.default.so"
    "lib64/hw/power.default.so"
    "lib/hw/power.default.so"
    "lib64/hw/vibrator.default.so"
    "lib/hw/vibrator.default.so"

    # Wifi
    "bin/hostapd_cli"
    "bin/hw/android.hardware.wifi@1.0-service"
    "bin/hw/hostapd"
    "bin/hw/wpa_supplicant"
    "etc/init/android.hardware.wifi@1.0-service.rc"
    "etc/init/hostapd.android.rc"
    "etc/vintf/manifest/android.hardware.wifi@1.0-service.xml"
    "etc/vintf/manifest/android.hardware.wifi.hostapd.xml"
    "lib/libwifi-hal-ctrl.so"
    "lib/libwifi-hal-qcom.so"
    "lib/libwpa_client.so"
    "lib64/libwifi-hal.so"
    "lib64/libwifi-hal-ctrl.so"
    "lib64/libwifi-hal-qcom.so"
    "lib64/libwpa_client.so"
    "lib64/vendor.qti.hardware.wifi.hostapd@1.0.so"
    "lib64/vendor.qti.hardware.wifi.hostapd@1.1.so"
    "lib64/vendor.qti.hardware.wifi.supplicant@2.0.so"
    "lib64/vendor.qti.hardware.wifi.supplicant@2.1.so"
    "lib64/libcld80211.so"
    "lib64/libkeystore-engine-wifi-hidl.so"
    "lib64/libkeystore-wifi-hidl.so"

    # Bootctrl
    "lib/hw/bootctrl.kona.so"
    "lib/hw/android.hardware.boot@1.0-impl-1.1-qti.so"
    "lib/hw/android.hardware.boot@1.1-impl.so"
    "lib/libboot_control_qti.so"
    "lib64/hw/bootctrl.kona.so"
    "lib64/hw/android.hardware.boot@1.0-impl-1.1-qti.so"
    "lib64/hw/android.hardware.boot@1.1-impl.so"
    "lib64/libboot_control_qti.so"
    "bin/hw/android.hardware.boot@1.1-service"
    "etc/init/android.hardware.boot@1.1-service.rc"
    "etc/vintf/manifest/android.hardware.boot@1.1.xml"

    # Power
    "bin/hw/android.hardware.power-service"
    "etc/init/android.hardware.power-service.rc"
    "etc/vintf/manifest/power.xml"

    # Display (we keep sdmcore prebuilt)
    "etc/vintf/manifest/android.hardware.graphics.mapper-impl-qti-display.xml"
    "lib64/hw/android.hardware.graphics.mapper@3.0-impl-qti-display.so"
    "lib/hw/android.hardware.graphics.mapper@3.0-impl-qti-display.so"
    "lib64/vendor.qti.hardware.display.mapper@1.0.so"
    "lib64/vendor.qti.hardware.display.mapper@1.1.so"
    "lib64/vendor.qti.hardware.display.mapper@2.0.so"
    "lib64/vendor.qti.hardware.display.mapper@3.0.so"
    "lib/vendor.qti.hardware.display.mapper@1.0.so"
    "lib/vendor.qti.hardware.display.mapper@1.1.so"
    "lib/vendor.qti.hardware.display.mapper@2.0.so"
    "lib/vendor.qti.hardware.display.mapper@3.0.so"
    "lib64/vendor.qti.hardware.display.mapperextensions@1.0.so"
    "lib64/vendor.qti.hardware.display.mapperextensions@1.1.so"
    "lib/vendor.qti.hardware.display.mapperextensions@1.0.so"
    "lib/vendor.qti.hardware.display.mapperextensions@1.1.so"
    "etc/init/vendor.qti.hardware.display.allocator-service.rc"
    "etc/vintf/manifest/vendor.qti.hardware.display.allocator-service.xml"
    "bin/hw/vendor.qti.hardware.display.allocator-service"
    "lib64/vendor.qti.hardware.display.allocator@1.0.so"
    "lib64/vendor.qti.hardware.display.allocator@3.0.so"
    "lib/vendor.qti.hardware.display.allocator@1.0.so"
    "lib/vendor.qti.hardware.display.allocator@3.0.so"
    "lib64/vendor.qti.hardware.display.composer@1.0.so"
    "lib64/vendor.qti.hardware.display.composer@2.0.so"
    "lib64/vendor.qti.hardware.display.composer@2.1.so"
    "lib/vendor.qti.hardware.display.composer@1.0.so"
    "lib/vendor.qti.hardware.display.composer@2.0.so"
    "lib/vendor.qti.hardware.display.composer@2.1.so"
    "etc/init/android.hardware.memtrack@1.0-service.rc"
    "bin/hw/android.hardware.memtrack@1.0-service"
    "lib64/hw/android.hardware.memtrack@1.0-impl.so"
    "lib/hw/android.hardware.memtrack@1.0-impl.so"
    "lib64/hw/gralloc.kona.so"
    "lib/hw/gralloc.kona.so"
    "lib64/hw/memtrack.kona.so"
    "lib/hw/memtrack.kona.so"
    "lib64/libqdMetaData.so"
    "lib/libqdMetaData.so"
    "lib64/libdisplayconfig.so"
    "lib/libdisplayconfig.so"
    "lib64/vendor.display.config@1.0.so"
    "lib64/vendor.display.config@1.1.so"
    "lib64/vendor.display.config@1.10.so"
    "lib64/vendor.display.config@1.11.so"
    "lib64/vendor.display.config@1.12.so"
    "lib64/vendor.display.config@1.13.so"
    "lib64/vendor.display.config@1.14.so"
    "lib64/vendor.display.config@1.15.so"
    "lib64/vendor.display.config@1.2.so"
    "lib64/vendor.display.config@1.3.so"
    "lib64/vendor.display.config@1.4.so"
    "lib64/vendor.display.config@1.5.so"
    "lib64/vendor.display.config@1.6.so"
    "lib64/vendor.display.config@1.7.so"
    "lib64/vendor.display.config@1.8.so"
    "lib64/vendor.display.config@1.9.so"
    "lib/vendor.display.config@1.0.so"
    "lib/vendor.display.config@1.1.so"
    "lib/vendor.display.config@1.10.so"
    "lib/vendor.display.config@1.11.so"
    "lib/vendor.display.config@1.12.so"
    "lib/vendor.display.config@1.13.so"
    "lib/vendor.display.config@1.14.so"
    "lib/vendor.display.config@1.15.so"
    "lib/vendor.display.config@1.2.so"
    "lib/vendor.display.config@1.3.so"
    "lib/vendor.display.config@1.4.so"
    "lib/vendor.display.config@1.5.so"
    "lib/vendor.display.config@1.6.so"
    "lib/vendor.display.config@1.7.so"
    "lib/vendor.display.config@1.8.so"
    "lib/vendor.display.config@1.9.so"
    "lib64/libdisplayconfig.so"
    "lib64/libdisplaydebug.so"
    "lib64/libdrm.so"
    "lib64/libdrmutils.so"
    "lib64/libgpu_tonemapper.so"
    "lib64/libgralloccore.so"
    "lib64/libgrallocutils.so"
    "lib64/libqdutils.so"
    "lib64/libqservice.so"
    "lib64/libdisplayconfig.so"
    "lib/libdisplaydebug.so"
    "lib/libdrm.so"
    "lib/libdrmutils.so"
    "lib/libgpu_tonemapper.so"
    "lib/libgralloccore.so"
    "lib/libgrallocutils.so"
    "lib/libqdutils.so"
    "lib/libqservice.so"
    "lib/libhistogram.so"

    # Media
    "bin/hw/android.hardware.media.omx@1.0-service"
    "etc/init/android.hardware.media.omx@1.0-service.rc"
    "bin/hw/android.hardware.cas@1.2-service"
    "etc/init/android.hardware.cas@1.2-service.rc"
    "etc/vintf/manifest/android.hardware.cas@1.2-service.xml"
    "lib/libavservices_minijail_vendor.so"
    "lib/libstagefright_amrnb_common.so"
    "lib64/libstagefright_bufferpool@2.0.1.so"
    "lib/libstagefright_bufferpool@2.0.1.so"
    "lib/libstagefright_enc_common.so"
    "lib/libstagefright_flacdec.so"
    "lib/libstagefright_soft_aacdec.so"
    "lib/libstagefright_soft_aacenc.so"
    "lib/libstagefright_soft_amrdec.so"
    "lib/libstagefright_soft_amrnbenc.so"
    "lib/libstagefright_soft_amrwbenc.so"
    "lib/libstagefright_soft_avcdec.so"
    "lib/libstagefright_soft_avcenc.so"
    "lib/libstagefright_soft_flacdec.so"
    "lib/libstagefright_soft_flacenc.so"
    "lib/libstagefright_soft_g711dec.so"
    "lib/libstagefright_soft_gsmdec.so"
    "lib/libstagefright_soft_hevcdec.so"
    "lib/libstagefright_soft_mp3dec.so"
    "lib/libstagefright_soft_mpeg2dec.so"
    "lib/libstagefright_soft_mpeg4dec.so"
    "lib/libstagefright_soft_mpeg4enc.so"
    "lib/libstagefright_softomx_plugin.so"
    "lib64/libstagefright_softomx.so"
    "lib/libstagefright_softomx.so"
    "lib/libstagefright_soft_opusdec.so"
    "lib/libstagefright_soft_rawdec.so"
    "lib/libstagefright_soft_vorbisdec.so"
    "lib/libstagefright_soft_vpxdec.so"
    "lib/libstagefright_soft_vpxenc.so"
    "lib/libvorbisidec.so"
    "lib/libvpx.so"
    "lib64/libeffectsconfig.so"
    "lib/libeffectsconfig.so"
    "lib64/libeffects.so"
    "lib/libeffects.so"
    "lib64/libwebrtc_audio_preprocessing.so"
    "lib/libwebrtc_audio_preprocessing.so"
    "lib64/mediacas/libclearkeycasplugin.so"
    "lib/mediacas/libclearkeycasplugin.so"
    "lib64/mediadrm/libdrmclearkeyplugin.so"
    "lib/mediadrm/libdrmclearkeyplugin.so"
    "lib64/soundfx/libaudiopreprocessing.so"
    "lib64/soundfx/libbundlewrapper.so"
    "lib64/soundfx/libdownmix.so"
    "lib64/soundfx/libdynproc.so"
    "lib64/soundfx/libeffectproxy.so"
    "lib64/soundfx/libldnhncr.so"
    "lib64/soundfx/libreverbwrapper.so"
    "lib64/soundfx/libvisualizer.so"
    "lib/soundfx/libaudiopreprocessing.so"
    "lib/soundfx/libbundlewrapper.so"
    "lib/soundfx/libdownmix.so"
    "lib/soundfx/libdynproc.so"
    "lib/soundfx/libeffectproxy.so"
    "lib/soundfx/libldnhncr.so"
    "lib/soundfx/libreverbwrapper.so"
    "lib/soundfx/libvisualizer.so"
    "lib/vndk/libstagefright_foundation.so"
    "lib/vndk/libstagefright_omx.so"
    "lib64/libstagefrighthw.so"
    "lib64/libc2dcolorconvert.so"
    "lib64/libcodec2_hidl@1.0.so"
    "lib64/libcodec2_vndk.so"
    "lib64/libmm-omxcore.so"
    "lib64/libOmxAacEnc.so"
    "lib64/libOmxAmrEnc.so"
    "lib64/libOmxCore.so"
    "lib64/libOmxEvrcEnc.so"
    "lib64/libOmxG711Enc.so"
    "lib64/libOmxQcelp13Enc.so"
    "lib64/libOmxVdec.so"
    "lib64/libOmxVenc.so"
    "lib/libstagefrighthw.so"
    "lib/libc2dcolorconvert.so"
    "lib/libcodec2_hidl@1.0.so"
    "lib/libcodec2_vndk.so"
    "lib/libmm-omxcore.so"
    "lib/libOmxAacEnc.so"
    "lib/libOmxAmrEnc.so"
    "lib/libOmxCore.so"
    "lib/libOmxEvrcEnc.so"
    "lib/libOmxG711Enc.so"
    "lib/libOmxQcelp13Enc.so"
    "lib/libOmxVdec.so"
    "lib/libOmxVenc.so"
    "lib/libopus.so"
    "lib64/vendor.qti.hardware.capabilityconfigstore@1.0.so"
    "lib/vendor.qti.hardware.capabilityconfigstore@1.0.so"
    "lib64/libplatformconfig.so"
    "lib/libplatformconfig.so"
)
ALL_SKIP_FILES=("${VENDOR_SKIP_FILES_COMMON[@]}" "${VENDOR_SKIP_FILES_DEVICE[@]}")

generate_prop_list_from_image "$1" "$2" ALL_SKIP_FILES

# Fixups
_output_file=$2
function presign() {
    sed -i "s|vendor/$1$|vendor/$1;PRESIGNED|g" $_output_file
}
function as_module() {
    sed -i "s|vendor/$1$|-vendor/$1|g" $_output_file
}

presign "app/TrustZoneAccessService/TrustZoneAccessService.apk"
as_module "lib64/libthermalclient.so"
as_module "lib/libthermalclient.so"
as_module "lib64/libfastcvopt.so"
as_module "lib/libfastcvopt.so"
as_module "etc/vintf/manifest/android.hardware.atrace@1.0-service.xml"
as_module "etc/vintf/manifest/android.hardware.biometrics.fingerprint@2.1-service.xml"
as_module "etc/vintf/manifest/android.hardware.gnss@2.1-service-qti.xml"
as_module "etc/vintf/manifest/android.hardware.graphics.mapper-impl-qti-display.xml"
as_module "etc/vintf/manifest/android.hardware.health@2.1.xml"
as_module "etc/vintf/manifest/android.hardware.lights-qti.xml"
as_module "etc/vintf/manifest/android.hardware.neuralnetworks@1.3-service-qti-hta.xml"
as_module "etc/vintf/manifest/android.hardware.neuralnetworks@1.3-service-qti.xml"
as_module "etc/vintf/manifest/android.hardware.sensors@2.0-multihal.xml"
as_module "etc/vintf/manifest/android.hardware.thermal@2.0-service.qti.xml"
as_module "etc/vintf/manifest/android.hardware.usb@1.2-service.xml"
as_module "etc/vintf/manifest/c2_manifest_vendor.xml"
as_module "etc/vintf/manifest/manifest_android.hardware.drm@1.3-service.clearkey.xml"
as_module "etc/vintf/manifest/manifest_android.hardware.drm@1.3-service.widevine.xml"
as_module "etc/vintf/manifest/vendor.qti.gnss@4.0-service.xml"
as_module "etc/vintf/manifest/vendor.qti.hardware.display.allocator-service.xml"
as_module "etc/vintf/manifest/vendor.qti.hardware.display.composer-service.xml"

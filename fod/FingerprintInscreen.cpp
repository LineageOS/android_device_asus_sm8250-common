/*
 * Copyright (C) 2020 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "FingerprintInscreenService"

#include "FingerprintInscreen.h"

#include <android-base/file.h>
#include <hidl/HidlTransportSupport.h>

#define LOCAL_HBM_MODE "/proc/localHbm"
#define TEST_KEYCODE_PATH "/sys/devices/platform/goodix_ts.0/test_keycode"
#define LOCAL_HBM_ON "1"
#define LOCAL_HBM_OFF "0"
#define FOD_WAKEUP_EVENT "33"

namespace vendor {
namespace lineage {
namespace biometrics {
namespace fingerprint {
namespace inscreen {
namespace V1_0 {
namespace implementation {

FingerprintInscreen::FingerprintInscreen() {
    this->mGoodixFingerprintDaemon = IGoodixFingerprintDaemon::getService();
}

Return<void> FingerprintInscreen::onStartEnroll() {
    return Void();
}

Return<void> FingerprintInscreen::onFinishEnroll() {
    return Void();
}

Return<void> FingerprintInscreen::onPress() {
    this->mGoodixFingerprintDaemon->sendCommand(200001, {},
                                                [](int, const hidl_vec<signed char>&) {});
    android::base::WriteStringToFile(LOCAL_HBM_ON, LOCAL_HBM_MODE);
    this->mGoodixFingerprintDaemon->sendCommand(200002, {},
                                                [](int, const hidl_vec<signed char>&) {});
    return Void();
}

Return<void> FingerprintInscreen::onRelease() {
    android::base::WriteStringToFile(LOCAL_HBM_OFF, LOCAL_HBM_MODE);
    this->mGoodixFingerprintDaemon->sendCommand(200003, {},
                                                [](int, const hidl_vec<signed char>&) {});
    return Void();
}

Return<void> FingerprintInscreen::onShowFODView() {
    android::base::WriteStringToFile(FOD_WAKEUP_EVENT, TEST_KEYCODE_PATH);
    return Void();
}

Return<void> FingerprintInscreen::onHideFODView() {
    return Void();
}

Return<bool> FingerprintInscreen::handleAcquired(int32_t, int32_t) {
    return false;
}

Return<bool> FingerprintInscreen::handleError(int32_t, int32_t) {
    return false;
}

Return<void> FingerprintInscreen::setLongPressEnabled(bool) {
    return Void();
}

Return<int32_t> FingerprintInscreen::getDimAmount(int32_t) {
    return 0;
}

Return<bool> FingerprintInscreen::shouldBoostBrightness() {
    return false;
}

Return<void> FingerprintInscreen::setCallback(const sp<IFingerprintInscreenCallback>&) {
    return Void();
}

Return<int32_t> FingerprintInscreen::getPositionX() {
    return 410;
}

Return<int32_t> FingerprintInscreen::getPositionY() {
    return 1651;
}

Return<int32_t> FingerprintInscreen::getSize() {
    return 260;
}

}  // namespace implementation
}  // namespace V1_0
}  // namespace inscreen
}  // namespace fingerprint
}  // namespace biometrics
}  // namespace lineage
}  // namespace vendor

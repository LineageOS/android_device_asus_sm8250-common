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

#include <gui/SurfaceComposerClient.h>

using namespace android;

extern "C" {

void _ZN7android21SurfaceComposerClient13createSurfaceERKNS_7String8EjjijPNS_14SurfaceControlENS_13LayerMetadataEPj(
        sp<SurfaceControl>* retval,
        SurfaceComposerClient* self,
        const String8&, uint32_t, uint32_t,
        PixelFormat, uint32_t,
        SurfaceControl*,
        LayerMetadata,
        uint32_t*);

void _ZN7android21SurfaceComposerClient13createSurfaceERKNS_7String8EjjijPNS_14SurfaceControlENS_13LayerMetadataE(
        void* retval,
        void* self,
        const String8& name, uint32_t w, uint32_t h,
        PixelFormat format, uint32_t flags,
        SurfaceControl* parent,
        LayerMetadata metadata) {
    sp<SurfaceControl>* ret = new(retval) sp<SurfaceControl>;
    _ZN7android21SurfaceComposerClient13createSurfaceERKNS_7String8EjjijPNS_14SurfaceControlENS_13LayerMetadataEPj(
        (sp<SurfaceControl>*)ret, (SurfaceComposerClient*)self, name, w, h, format, flags, parent, metadata, NULL);
}

}

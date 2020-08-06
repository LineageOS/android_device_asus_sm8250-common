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
package org.lineageos.frameratetile;

import android.content.Context
import android.graphics.drawable.Icon
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

class FrameRateTile : TileService() {
    override fun onStartListening() {
        super.onStartListening()

        val sharedPreferences = createDeviceProtectedStorageContext().getSharedPreferences(
                Constants.FRAME_RATE_TILE, Context.MODE_PRIVATE
        )
        qsTile.state = Tile.STATE_ACTIVE
        qsTile.icon = when (sharedPreferences.getInt(Constants.FPS, 60)) {
            90 -> Icon.createWithResource(this, R.drawable.ic_frame_rate_mode_90)
            120 -> Icon.createWithResource(this, R.drawable.ic_frame_rate_mode_120)
            144 -> Icon.createWithResource(this, R.drawable.ic_frame_rate_mode_144)
            else -> Icon.createWithResource(this, R.drawable.ic_frame_rate_mode_60)
        }
        qsTile.updateTile()
    }

    override fun onClick() {
        super.onClick()

        val sharedPreferences = createDeviceProtectedStorageContext().getSharedPreferences(
                Constants.FRAME_RATE_TILE, Context.MODE_PRIVATE
        )
        val fps = when (sharedPreferences.getInt(Constants.FPS, 60)) {
            60 -> 90
            90 -> 120
            120 -> 144
            else -> 60 // Roll back 144 -> 60
        }

        Utils.changeFps(sharedPreferences, fps)
        qsTile.icon = when (fps) {
            60 -> Icon.createWithResource(this, R.drawable.ic_frame_rate_mode_60)
            90 -> Icon.createWithResource(this, R.drawable.ic_frame_rate_mode_90)
            120 -> Icon.createWithResource(this, R.drawable.ic_frame_rate_mode_120)
            144 -> Icon.createWithResource(this, R.drawable.ic_frame_rate_mode_144)
            else -> Icon.createWithResource(this, R.drawable.ic_frame_rate_mode_60)
        }
        qsTile.updateTile()
    }
}

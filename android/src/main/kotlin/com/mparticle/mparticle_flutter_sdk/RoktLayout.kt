package com.mparticle.mparticle_flutter_sdk

import android.content.Context
import com.mparticle.kits.RoktEmbeddedView
import com.mparticle.kits.RoktLayoutDimensionCallBack
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import kotlin.math.abs

class RoktLayout(
    context: Context?,
    messenger: BinaryMessenger,
    viewId: Int,
) : PlatformView,
    RoktLayoutDimensionCallBack {
    val layout: RoktEmbeddedView? = context?.let { RoktEmbeddedView(it) }
    private var lastHeight = 0
    private val channel: MethodChannel = MethodChannel(messenger, "rokt_layout_$viewId")

    init {
        layout?.dimensionCallBack = this
    }

    private fun sendUpdatedHeight(height: Double) {
        val map: MutableMap<String, Any> = mutableMapOf()
        map[VIEW_HEIGHT_LISTENER_PARAM] = height
        channel.invokeMethod(VIEW_HEIGHT_LISTENER, map)
    }

    override fun getView(): RoktEmbeddedView? = layout

    override fun dispose() {
        layout?.dimensionCallBack = null
        channel.setMethodCallHandler(null)
    }

    companion object {
        private const val VIEW_HEIGHT_LISTENER = "viewHeightListener"
        private const val VIEW_HEIGHT_LISTENER_PARAM = "size"
        private const val OUT_OF_SYNC_HEIGHT_DIFF = 1
    }

    override fun onHeightChanged(height: Int) {
        if (abs(lastHeight - height) >= OUT_OF_SYNC_HEIGHT_DIFF) {
            lastHeight = height
            sendUpdatedHeight(lastHeight.toDouble())
        }
    }
}

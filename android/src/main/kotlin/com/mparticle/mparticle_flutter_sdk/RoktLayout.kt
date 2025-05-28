package com.mparticle.mparticle_flutter_sdk

import android.content.Context
import com.mparticle.rokt.RoktEmbeddedView
import com.mparticle.rokt.RoktLayoutDimensionCallBack
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
    val layout: RoktEmbeddedView? = if (context != null) RoktEmbeddedView(context) else null
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

    private fun sendUpdatedPadding(
        left: Double,
        top: Double,
        right: Double,
        bottom: Double,
    ) {
        val map: MutableMap<String, Any> = mutableMapOf()
        map[VIEW_PADDING_LEFT] = left
        map[VIEW_PADDING_TOP] = top
        map[VIEW_PADDING_RIGHT] = right
        map[VIEW_PADDING_BOTTOM] = bottom
        channel.invokeMethod(VIEW_PADDING_LISTENER, map)
    }

    override fun getView(): RoktEmbeddedView? = layout

    override fun dispose() {
        layout?.dimensionCallBack = null
    }

    companion object {
        private const val VIEW_HEIGHT_LISTENER = "viewHeightListener"
        private const val VIEW_PADDING_LISTENER = "viewPaddingListener"
        private const val VIEW_HEIGHT_LISTENER_PARAM = "size"
        private const val VIEW_PADDING_LEFT = "left"
        private const val VIEW_PADDING_TOP = "top"
        private const val VIEW_PADDING_RIGHT = "right"
        private const val VIEW_PADDING_BOTTOM = "bottom"
        private const val OUT_OF_SYNC_HEIGHT_DIFF = 1
    }

    override fun onHeightChanged(height: Int) {
        if (abs(lastHeight - height) >= OUT_OF_SYNC_HEIGHT_DIFF) {
            lastHeight = height
            sendUpdatedHeight(lastHeight.toDouble())
        }
    }

    override fun onMarginChanged(
        start: Int,
        top: Int,
        end: Int,
        bottom: Int,
    ) {
        sendUpdatedPadding(start.toDouble(), top.toDouble(), end.toDouble(), bottom.toDouble())
    }
}

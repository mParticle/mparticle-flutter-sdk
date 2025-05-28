package com.mparticle.mparticle_flutter_sdk

import android.content.Context
import com.mparticle.rokt.RoktEmbeddedView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class RoktLayoutFactory(
    private val messenger: BinaryMessenger,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    val nativeViews = mutableMapOf<Int, RoktEmbeddedView>()

    override fun create(
        context: Context?,
        viewId: Int,
        args: Any?,
    ): PlatformView {
        val roktLayout = RoktLayout(context, messenger, viewId)
        roktLayout.layout?.let { layout ->
            nativeViews[viewId] = layout
        }
        return roktLayout
    }
}

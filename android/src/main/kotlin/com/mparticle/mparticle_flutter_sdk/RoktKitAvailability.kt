package com.mparticle.mparticle_flutter_sdk

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformViewRegistry

internal object RoktKitAvailability {
    const val REQUIRED_MESSAGE =
        "Rokt is unavailable. Add com.mparticle:android-rokt-kit to your app's build.gradle."

    private const val ROKT_EMBEDDED_VIEW_CLASS = "com.mparticle.kits.RoktEmbeddedView"

    fun isAvailable(): Boolean =
        try {
            Class.forName(ROKT_EMBEDDED_VIEW_CLASS)
            true
        } catch (_: ClassNotFoundException) {
            false
        } catch (_: LinkageError) {
            false
        }

    fun createDelegate(messenger: BinaryMessenger): RoktPluginDelegate? {
        if (!isAvailable()) {
            return null
        }
        return RoktBridge(messenger)
    }

    fun registerPlatformView(
        registry: PlatformViewRegistry,
        delegate: RoktPluginDelegate,
    ) {
        delegate.registerPlatformView(registry)
    }
}

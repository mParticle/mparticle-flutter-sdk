package com.mparticle.mparticle_flutter_sdk

import android.app.Activity
import android.content.Context
import android.graphics.Typeface
import android.os.Build
import com.mparticle.MParticle
import com.mparticle.internal.Logger
import com.mparticle.kits.RoktEmbeddedView
import com.mparticle.kits.rokt
import com.rokt.roktsdk.CacheConfig
import com.rokt.roktsdk.RoktConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformViewRegistry
import java.lang.ref.WeakReference

internal class RoktBridge(
    messenger: BinaryMessenger,
) : RoktPluginDelegate {
    private val layoutFactory = RoktLayoutFactory(messenger)
    private val roktEventHandler =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            RoktEventHandler(messenger)
        } else {
            null
        }

    override fun registerPlatformView(registry: PlatformViewRegistry) {
        registry.registerViewFactory(VIEW_TYPE, layoutFactory)
    }

    override fun selectPlacements(
        call: MethodCall,
        result: MethodChannel.Result,
        applicationContext: Context?,
        flutterAssets: FlutterPlugin.FlutterAssets?,
    ) {
        try {
            val placementId: String? = call.argument("placementId")
            val attributes: Map<String, Any?>? = call.argument("attributes")
            val placeHolders: MutableMap<String, WeakReference<RoktEmbeddedView>> = mutableMapOf()
            val configMap = call.argument<HashMap<String, Any>>("config")
            val config = configMap?.let { buildRoktConfig(it) }
            val customFonts = call.argument<HashMap<String, String>>("fontFilePathMap")
                .orEmpty()
                .mapNotNull { (key, fontPath) ->
                    applicationContext?.assets?.let { assets ->
                        flutterAssets?.getAssetFilePathByName(fontPath)?.let { assetPath ->
                            runCatching {
                                key to WeakReference(Typeface.createFromAsset(assets, assetPath))
                            }.getOrNull()
                        }
                    }
                }
                .toMap()

            call.argument<HashMap<Int, String>>("placeholders")?.entries?.forEach { entry ->
                layoutFactory.nativeViews[entry.key]?.let { view ->
                    placeHolders[entry.value] = WeakReference(view)
                }
            }

            if (placementId == null) {
                result.error(TAG, "Missing placementId", null)
                return
            }

            val stringAttributes: MutableMap<String, String> = mutableMapOf()
            attributes?.forEach { (key, value) ->
                stringAttributes[key] = value?.toString() ?: ""
            }

            MParticle.getInstance()?.let { instance ->
                instance.rokt.selectPlacements(
                    placementId,
                    stringAttributes,
                    placeHolders.takeIf { it.isNotEmpty() },
                    customFonts.takeIf { it.isNotEmpty() },
                    config,
                )
                result.success(true)
            } ?: result.error(TAG, "No mParticle instance exists", null)
        } catch (e: Exception) {
            result.error(TAG, e.localizedMessage, null)
        }
    }

    override fun subscribeToEvents(
        call: MethodCall,
        result: MethodChannel.Result,
        activity: Activity?,
    ) {
        val identifier = call.argument<String>("identifier")
        if (identifier.isNullOrBlank()) {
            result.error(TAG, "Missing identifier", null)
            return
        }

        MParticle.getInstance()?.let { instance ->
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                activity?.let { currentActivity ->
                    roktEventHandler?.subscribeToEvents(
                        events = instance.rokt.events(identifier),
                        activity = currentActivity,
                        identifier = identifier,
                    )
                }
            }
            result.success(true)
        } ?: result.error(TAG, "No mParticle instance exists", null)
    }

    override fun purchaseFinalized(call: MethodCall, result: MethodChannel.Result) {
        val placementId = call.argument<String>("placementId")
        val catalogItemId = call.argument<String>("catalogItemId")
        val success = call.argument<Boolean>("success") ?: true
        if (placementId != null && catalogItemId != null) {
            MParticle.getInstance()?.rokt?.purchaseFinalized(
                placementId,
                catalogItemId,
                success,
            )
            result.success("Success")
        } else {
            result.error(
                "INVALID_PARAMS",
                "placementId and catalogItemId are required",
                null,
            )
        }
    }

    override fun selectShoppableAds(call: MethodCall, result: MethodChannel.Result) {
        Logger.warning("selectShoppableAds is not yet supported on Android")
        result.success(true)
    }

    private fun buildRoktConfig(configMap: Map<String, Any>): RoktConfig {
        val builder = RoktConfig.Builder()
        (configMap["colorMode"] as? String)?.let {
            builder.colorMode(it.toColorMode())
        }
        (configMap["cacheConfig"] as? Map<String, Any>)?.let { cacheConfig ->
            val cacheDurationInSeconds = cacheConfig["cacheDurationInSeconds"] as? Int ?: 0
            val cacheAttributes = cacheConfig["cacheAttributes"] as? Map<String, String>
            builder.cacheConfig(CacheConfig(cacheDurationInSeconds.toLong(), cacheAttributes))
        }

        return builder.build()
    }

    private fun String.toColorMode(): RoktConfig.ColorMode =
        when (this) {
            "dark" -> RoktConfig.ColorMode.DARK
            "light" -> RoktConfig.ColorMode.LIGHT
            else -> RoktConfig.ColorMode.SYSTEM
        }

    private companion object {
        private const val TAG = "MparticleFlutterSdkPlugin"
        private const val VIEW_TYPE = "rokt_sdk.rokt.com/rokt_layout"
    }
}

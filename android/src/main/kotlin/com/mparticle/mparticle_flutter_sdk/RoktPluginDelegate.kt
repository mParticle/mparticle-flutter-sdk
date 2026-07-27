package com.mparticle.mparticle_flutter_sdk

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformViewRegistry

internal interface RoktPluginDelegate {
    fun registerPlatformView(registry: PlatformViewRegistry)

    fun selectPlacements(
        call: MethodCall,
        result: MethodChannel.Result,
        applicationContext: Context?,
        flutterAssets: FlutterPlugin.FlutterAssets?,
    )

    fun subscribeToEvents(
        call: MethodCall,
        result: MethodChannel.Result,
        activity: Activity?,
    )

    fun purchaseFinalized(call: MethodCall, result: MethodChannel.Result)

    fun selectShoppableAds(call: MethodCall, result: MethodChannel.Result)
}

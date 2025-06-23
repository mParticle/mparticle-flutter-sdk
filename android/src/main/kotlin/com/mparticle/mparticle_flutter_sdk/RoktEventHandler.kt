package com.mparticle.mparticle_flutter_sdk

import android.app.Activity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.mparticle.RoktEvent
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.launch
import java.util.ArrayDeque

class RoktEventHandler(private val messenger: BinaryMessenger) {

    private val eventListeners = mutableMapOf<Any?, ArrayDeque<EventChannel.EventSink>>()
    private val eventSubscriptions = mutableMapOf<String, Job?>()

    init {
        setupEventChannel()
    }

    fun subscribeToEvents(events: Flow<RoktEvent>, identifier: String? = null, activity: Activity) {
        val activeJob = eventSubscriptions[identifier.orEmpty()]?.takeIf { it.isActive }
        if (activeJob != null) {
            return
        }
        val owner = activity as? LifecycleOwner ?: return

        val job = owner.lifecycleScope.launch {
            owner.lifecycle.repeatOnLifecycle(Lifecycle.State.CREATED) {
                events.collect { event ->
                    val params = mutableMapOf<String, String>()

                    params["event"] = event::class.simpleName ?: "RoktEvent"
                    event.placementId?.let { params["placementId"] = it }

                    when (event) {
                        is RoktEvent.InitComplete -> {
                            params["status"] = event.success.toString()
                        }
                        is RoktEvent.OpenUrl -> {
                            params["url"] = event.url
                        }
                        is RoktEvent.CartItemInstantPurchase -> {
                            params["cartItemId"] = event.cartItemId
                            params["catalogItemId"] = event.catalogItemId
                            params["currency"] = event.currency
                            params["description"] = event.description
                            params["linkedProductId"] = event.linkedProductId
                            params["totalPrice"] = event.totalPrice.toString()
                            params["quantity"] = event.quantity.toString()
                            params["unitPrice"] = event.unitPrice.toString()
                        }
                        else -> {
                            // No custom parameters needed for other events
                        }
                    }

                    identifier?.let { params["identifier"] = it }
                    eventListeners.values.flatten().forEach { listener -> listener.success(params) }
                }
            }
        }
        eventSubscriptions[identifier.orEmpty()] = job
    }

    private fun setupEventChannel() {
        EventChannel(messenger, EVENT_CHANNEL_NAME).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(
                    arguments: Any?,
                    sink: EventChannel.EventSink?,
                ) {
                    sink?.let {
                        val sinks = eventListeners.getOrPut(arguments) { ArrayDeque() }
                        sinks.addLast(it)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    val sinks = eventListeners[arguments]
                    if (sinks?.isNotEmpty() == true) {
                        sinks.removeLast()
                    }
                    if (sinks?.isEmpty() == true) {
                        eventListeners.remove(arguments)
                    }
                }
            },
        )
    }

    private val RoktEvent.placementId: String?
        get() = when (this) {
            is RoktEvent.FirstPositiveEngagement -> placementId
            is RoktEvent.OfferEngagement -> placementId
            is RoktEvent.PlacementClosed -> placementId
            is RoktEvent.PlacementCompleted -> placementId
            is RoktEvent.PlacementFailure -> placementId
            is RoktEvent.PlacementInteractive -> placementId
            is RoktEvent.PlacementReady -> placementId
            is RoktEvent.PositiveEngagement -> placementId
            is RoktEvent.OpenUrl -> placementId
            is RoktEvent.CartItemInstantPurchase -> placementId
            else -> null
        }

    companion object {
        private const val EVENT_CHANNEL_NAME = "MPRoktEvents"
    }
}

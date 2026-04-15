//
//  RoktEventHandler.swift
//  rokt_sdk
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation
import Flutter
import mParticle_Apple_SDK
import RoktContracts

class RoktEventHandler: NSObject, FlutterStreamHandler {

    private var eventListeners: [String: [FlutterEventSink]] = [:]
    private let eventQueue = DispatchQueue(label: "com.mparticle.rokt.event.queue")
    private let EVENT_CHANNEL_NAME = "MPRoktEvents"

    init(messenger: FlutterBinaryMessenger) {
        super.init()
        setupEventChannel(messenger: messenger)
    }

    private func setupEventChannel(messenger: FlutterBinaryMessenger) {
        let eventChannel = FlutterEventChannel(name: EVENT_CHANNEL_NAME, binaryMessenger: messenger)
        eventChannel.setStreamHandler(self)
    }

    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        eventQueue.sync {
            let key = String(describing: arguments ?? "nil")
            var sinks = eventListeners[key] ?? []
            sinks.append(eventSink)
            eventListeners[key] = sinks
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventQueue.sync {
            let key = String(describing: arguments ?? "nil")
            if var sinks = eventListeners[key], !sinks.isEmpty {
                sinks.removeLast()
                if sinks.isEmpty {
                    eventListeners.removeValue(forKey: key)
                } else {
                    eventListeners[key] = sinks
                }
            }
        }
        return nil
    }


    func subscribeToEvents(identifier: String) {
        MParticle.sharedInstance().rokt.events(identifier) { event in
            var params: [String: String] = [:]

            params["event"] = String(describing: type(of: event)).replacingOccurrences(of: "Rokt", with: "").replacingOccurrences(of: "Event", with: "")
            params["identifier"] = identifier

            if let placementId = event.roktPlacementId {
                params["placementId"] = placementId
            }
            
            switch event {
            case let initCompleteEvent as RoktEvent.InitComplete:
                params["status"] = initCompleteEvent.success ? "true" : "false"
            case let openUrlEvent as RoktEvent.OpenUrl:
                params["url"] = openUrlEvent.url
            case let cartItemInstantPurchaseEvent as RoktEvent.CartItemInstantPurchase:
                params["cartItemId"] = cartItemInstantPurchaseEvent.cartItemId
                params["catalogItemId"] = cartItemInstantPurchaseEvent.catalogItemId
                params["currency"] = cartItemInstantPurchaseEvent.currency
                params["description"] = cartItemInstantPurchaseEvent.description
                params["linkedProductId"] = cartItemInstantPurchaseEvent.linkedProductId
                params["totalPrice"] = cartItemInstantPurchaseEvent.totalPrice?.stringValue
                params["quantity"] = cartItemInstantPurchaseEvent.quantity?.stringValue
                params["unitPrice"] = cartItemInstantPurchaseEvent.unitPrice?.stringValue
            case let initiatedEvent as RoktEvent.CartItemInstantPurchaseInitiated:
                params["cartItemId"] = initiatedEvent.cartItemId
                params["catalogItemId"] = initiatedEvent.catalogItemId
            case let failureEvent as RoktEvent.CartItemInstantPurchaseFailure:
                params["cartItemId"] = failureEvent.cartItemId
                params["catalogItemId"] = failureEvent.catalogItemId
                params["error"] = failureEvent.error
            case let devicePayEvent as RoktEvent.CartItemDevicePay:
                params["cartItemId"] = devicePayEvent.cartItemId
                params["catalogItemId"] = devicePayEvent.catalogItemId
                params["paymentProvider"] = devicePayEvent.paymentProvider
            default:
                break
            }

            let allSinks = self.eventQueue.sync {
                return Array(self.eventListeners.values.joined())
            }

            allSinks.forEach { listener in
                DispatchQueue.main.async {
                    listener(params)
                }
            }
        }
    }
}

private extension RoktEvent {
    var roktPlacementId: String? {
        switch self {
        case let event as RoktEvent.FirstPositiveEngagement: return event.identifier
        case let event as RoktEvent.OfferEngagement: return event.identifier
        case let event as RoktEvent.PlacementClosed: return event.identifier
        case let event as RoktEvent.PlacementCompleted: return event.identifier
        case let event as RoktEvent.PlacementFailure: return event.identifier
        case let event as RoktEvent.PlacementInteractive: return event.identifier
        case let event as RoktEvent.PlacementReady: return event.identifier
        case let event as RoktEvent.PositiveEngagement: return event.identifier
        case let event as RoktEvent.OpenUrl: return event.identifier
        case let event as RoktEvent.CartItemInstantPurchase: return event.identifier
        case let event as RoktEvent.CartItemInstantPurchaseInitiated: return event.identifier
        case let event as RoktEvent.CartItemInstantPurchaseFailure: return event.identifier
        case let event as RoktEvent.InstantPurchaseDismissal: return event.identifier
        case let event as RoktEvent.CartItemDevicePay: return event.identifier
        default: return nil
        }
    }
}

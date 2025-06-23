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

class RoktEventHandler: NSObject, FlutterStreamHandler {

    private var eventListeners: [String: [FlutterEventSink]] = [:]
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
        let key = String(describing: arguments ?? "nil")
        var sinks = eventListeners[key] ?? []
        sinks.append(eventSink)
        eventListeners[key] = sinks
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        let key = String(describing: arguments ?? "nil")
        if var sinks = eventListeners[key], !sinks.isEmpty {
            sinks.removeLast()
            if sinks.isEmpty {
                eventListeners.removeValue(forKey: key)
            } else {
                eventListeners[key] = sinks
            }
        }
        return nil
    }


    func subscribeToEvents(identifier: String) {
        MParticle.sharedInstance().rokt.events(identifier) { event in
            var params: [String: String] = [:]

            params["event"] = String(describing: type(of: event)).replacingOccurrences(of: "MPRokt", with: "").replacingOccurrences(of: "Event", with: "")
            params["identifier"] = identifier

            if let placementId = event.roktPlacementId {
                params["placementId"] = placementId
            }
            
            switch event {
            case let initCompleteEvent as MPRoktEvent.MPRoktInitComplete:
                params["status"] = initCompleteEvent.success ? "true" : "false"
            case let openUrlEvent as MPRoktEvent.MPRoktOpenUrl:
                params["url"] = openUrlEvent.url
            case let cartItemInstantPurchaseEvent as MPRoktEvent.MPRoktCartItemInstantPurchase:
                params["cartItemId"] = cartItemInstantPurchaseEvent.cartItemId
                params["catalogItemId"] = cartItemInstantPurchaseEvent.catalogItemId
                params["currency"] = cartItemInstantPurchaseEvent.currency
                params["description"] = cartItemInstantPurchaseEvent.description
                params["linkedProductId"] = cartItemInstantPurchaseEvent.linkedProductId
                params["totalPrice"] = cartItemInstantPurchaseEvent.totalPrice?.stringValue
                params["quantity"] = cartItemInstantPurchaseEvent.quantity?.stringValue
                params["unitPrice"] = cartItemInstantPurchaseEvent.unitPrice?.stringValue
            default:
                break
            }

            self.eventListeners.values.joined().forEach { listener in
                listener(params)
            }
        }
    }
}

private extension MPRoktEvent {
    var roktPlacementId: String? {
        switch self {
        case let event as MPRoktEvent.MPRoktFirstPositiveEngagement: return event.placementId
        case let event as MPRoktEvent.MPRoktOfferEngagement: return event.placementId
        case let event as MPRoktEvent.MPRoktPlacementClosed: return event.placementId
        case let event as MPRoktEvent.MPRoktPlacementCompleted: return event.placementId
        case let event as MPRoktEvent.MPRoktPlacementFailure: return event.placementId
        case let event as MPRoktEvent.MPRoktPlacementInteractive: return event.placementId
        case let event as MPRoktEvent.MPRoktPlacementReady: return event.placementId
        case let event as MPRoktEvent.MPRoktPositiveEngagement: return event.placementId
        case let event as MPRoktEvent.MPRoktOpenUrl: return event.placementId
        case let event as MPRoktEvent.MPRoktCartItemInstantPurchase: return event.placementId
        default: return nil
        }
    }
}

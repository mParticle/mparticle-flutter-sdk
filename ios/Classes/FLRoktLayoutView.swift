//
//  FLRoktLayoutView.swift
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

import Flutter
import UIKit
import mParticle_Apple_SDK

class FLRoktLayoutView: NSObject, FlutterPlatformView {
    let roktEmbeddedView: MPRoktEmbeddedView
    let id: Int64
    let channel: FlutterMethodChannel
    var constraints: [NSLayoutConstraint]?
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        self.id = viewId
        channel = FlutterMethodChannel(name: "rokt_layout_\(id)", binaryMessenger: messenger)
        roktEmbeddedView = MPRoktEmbeddedView()
        super.init()
    }

    func view() -> UIView {
        return roktEmbeddedView
    }

    private func setupConstraintsIfNeeded() {
        roktEmbeddedView.translatesAutoresizingMaskIntoConstraints = false
        guard constraints == nil, let superview = roktEmbeddedView.superview else { return }
        constraints = [
            roktEmbeddedView.topAnchor.constraint(equalTo: superview.topAnchor),
            roktEmbeddedView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            roktEmbeddedView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            roktEmbeddedView.leadingAnchor.constraint(equalTo: superview.leadingAnchor)
        ]
        constraints?.forEach{ $0.isActive = true }
        superview.setNeedsLayout()
    }

    func sendUpdatedHeight(height: Double){
        var callbackMap = [String: Any] ()
        setupConstraintsIfNeeded()
        callbackMap["size"] = height
        channel.invokeMethod("viewHeightListener", arguments: callbackMap)
    }
}

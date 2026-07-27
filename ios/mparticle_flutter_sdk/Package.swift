// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mparticle_flutter_sdk",
    platforms: [
        .iOS("15.6"),
    ],
    products: [
        .library(name: "mparticle-flutter-sdk", targets: ["mparticle_flutter_sdk"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(
            url: "https://github.com/mParticle/mparticle-apple-sdk.git",
            .upToNextMajor(from: "9.3.1")
        ),
        .package(
            url: "https://github.com/ROKT/rokt-contracts-apple.git",
            .upToNextMajor(from: "2.0.0")
        ),
    ],
    targets: [
        .target(
            name: "mparticle_flutter_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "mParticle-Apple-SDK", package: "mparticle-apple-sdk"),
                .product(name: "RoktContracts", package: "rokt-contracts-apple"),
            ],
            cSettings: [
                .headerSearchPath("include/mparticle_flutter_sdk"),
            ]
        ),
    ]
)

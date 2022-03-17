// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SION",
    products: [
        .library(
            name: "SION",
            type: .dynamic,
            targets: ["SION"]),
        ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SION",
            dependencies: []),
        .target(
          name: "SIONRun",
          dependencies: ["SION"]),
        .testTarget(
            name: "SIONTests",
            dependencies: ["SION"]),
        ]
)

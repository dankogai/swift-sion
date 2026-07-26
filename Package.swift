// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SION",
    platforms: [
        // Swift Regex requires these OS versions on Apple platforms
        .macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9),
    ],
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
        .executableTarget(
          name: "SIONRun",
          dependencies: ["SION"]),
        .testTarget(
            name: "SIONTests",
            dependencies: ["SION"]),
        ]
)

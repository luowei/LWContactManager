// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LWContactManager",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "LWContactManager",
            targets: ["LWContactManager"]),
    ],
    dependencies: [
        // No external dependencies - uses native Contacts framework
    ],
    targets: [
        .target(
            name: "LWContactManager",
            dependencies: [],
            path: "Sources/LWContactManager"),
    ]
)

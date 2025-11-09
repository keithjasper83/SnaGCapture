// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SnaGCapture",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SnaGCapture",
            targets: ["SnaGCapture"]),
    ],
    targets: [
        .target(
            name: "SnaGCapture",
            path: "SnaGCapture",
            exclude: ["Info.plist", "Assets.xcassets"]),
        .testTarget(
            name: "SnaGCaptureTests",
            dependencies: ["SnaGCapture"],
            path: "SnaGCaptureTests"),
    ]
)

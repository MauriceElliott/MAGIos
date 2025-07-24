// swift-tools-version: 6.0
// MAGIos Embedded Swift Kernel Package
// Simplified configuration for bare-metal kernel development

import PackageDescription

let package = Package(
    name: "MAGIos",
    products: [
        .library(
            name: "MAGIos",
            type: .static,
            targets: ["MAGIos"]
        )
    ],
    targets: [
        .target(
            name: "MAGIos",
            path: "src/swift",
            swiftSettings: [
                .enableExperimentalFeature("Embedded")
            ]
        )
    ]
)

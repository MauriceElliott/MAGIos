// swift-tools-version: 6.0
// MAGIos Embedded Swift Kernel Package
// Simplified configuration for bare-metal kernel development

import PackageDescription

// === PATH CONSTANTS ===
// Centralized path configuration for easier maintenance
let swiftKernelPath = "src/swernel"
let kernelPath = "src/kernel"
let supportPath = "src/support"

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
            path: swiftKernelPath,
            swiftSettings: [
                .enableExperimentalFeature("Embedded"),
                .unsafeFlags([
                    "-target", "i686-unknown-none-elf",
                    "-Xfrontend", "-disable-objc-interop",
                    "-Xclang-linker", "-nostdlib",
                    "-wmo",
                ]),
            ]
        )
    ]
)

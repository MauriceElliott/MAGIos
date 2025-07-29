// swift-tools-version: 6.0
// MAGIos Embedded Swift Kernel Package
// See PACKAGE_DOCUMENTATION at bottom for detailed documentation

import PackageDescription

// PATH_CONSTANTS
let swiftKernelPath = "Sources/"

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
            sources: ["swernel", "support"],
            swiftSettings: [
                .enableExperimentalFeature("Embedded"),
                .unsafeFlags([
                    "-target", "i686-unknown-none-elf",
                    "-Xfrontend", "-disable-objc-interop",
                    "-Xclang-linker", "-nostdlib",
                    "-Xfrontend", "-function-sections",
                    "-module-name", "SwiftKernel",
                    "-wmo",
                    "-c",
                    "-emit-object",
                ]),
            ],
        )
    ]
)

/*
 * === PACKAGE_DOCUMENTATION ===
 *
 * PATH_CONSTANTS:
 * Centralized path configuration for easier maintenance
 * swiftKernelPath: Points to Swift kernel (swernel) source location
 * kernelPath: Points to C kernel source location
 * supportPath: Points to support libraries location
 *
 * PACKAGE_CONFIGURATION:
 * Swift package configuration for bare-metal kernel development
 * Static library type for embedding in kernel binary
 * Simplified configuration focused on embedded Swift support
 *
 * EMBEDDED_SWIFT_SETTINGS:
 * .enableExperimentalFeature("Embedded"): Enables embedded Swift mode
 * Target architecture: i686-unknown-none-elf for 32-bit kernel
 * -Xfrontend -disable-objc-interop: Disables Objective-C interoperability
 * -Xclang-linker -nostdlib: Disables standard library linking
 * -wmo: Whole module optimization for better embedded performance
 *
 * TARGET_CONFIGURATION:
 * Single target "MAGIos" containing Swift kernel components
 * Path points to swernel directory containing Swift kernel source
 * All Swift settings configured for embedded kernel environment
 */

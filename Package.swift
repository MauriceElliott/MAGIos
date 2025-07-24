// swift-tools-version: 6.0
// MAGIos Embedded Swift Kernel Package
// Production Swift kernel for Evangelion-themed operating system

import PackageDescription

let package = Package(
    name: "MAGIosSwift",
    products: [
        // Static library for linking with C kernel components
        .library(
            name: "MAGIosSwift",
            type: .static,
            targets: ["MAGIosSwift"]
        )
    ],
    targets: [
        .target(
            name: "MAGIosSwift",
            path: "src",
            swiftSettings: [
                // Enable Embedded Swift compilation mode
                .enableExperimentalFeature("Embedded"),

                // Embedded Swift compiler flags
                .unsafeFlags([
                    // Target bare-metal i686 architecture
                    "-target", "i686-unknown-none-elf",

                    // Disable standard library and runtime features
                    "-Xfrontend", "-disable-objc-interop",
                    "-Xfrontend", "-disable-stack-protector",
                    "-Xfrontend", "-disable-reflection-metadata",
                    "-Xfrontend", "-disable-reflection-names",

                    // Code generation optimizations
                    "-Xfrontend", "-function-sections",
                    "-Xfrontend", "-gline-tables-only",

                    // Whole module optimization for size and performance
                    "-O",
                    "-whole-module-optimization",

                    // C compatibility flags for freestanding environment
                    "-Xcc", "-ffreestanding",
                    "-Xcc", "-fno-stack-protector",
                    "-Xcc", "-nostdlib",
                    "-Xcc", "-m32",
                    "-Xcc", "-mpreferred-stack-boundary=2",

                    // Additional kernel-specific optimizations
                    "-Xfrontend", "-sil-verify-all",
                ]),
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-nostdlib",
                    "-static",
                ])
            ]
        )
    ]
)

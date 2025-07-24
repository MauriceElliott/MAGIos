// swift-tools-version: 6.0
// MAGIos Embedded Swift Package
// Swift package configuration for the MAGIos kernel components

import PackageDescription

let package = Package(
    name: "MAGIos-Swift",
    products: [
        // Static library that will be linked with the C kernel
        .library(
            name: "MAGIosSwift",
            type: .static,
            targets: ["MAGIosSwift"]
        ),
        // Demo executable for testing Swift kernel functionality
        .executable(
            name: "SwiftKernelDemo",
            targets: ["SwiftKernelDemo"]
        ),
    ],
    targets: [
        .target(
            name: "MAGIosSwift",
            path: "Sources/MAGIosSwift",
            exclude: ["SwiftKernelDemo.swift"],
            swiftSettings: [
                // Enable Embedded Swift compilation mode
                .enableExperimentalFeature("Embedded"),

                // Disable features not available in embedded mode
                .unsafeFlags([
                    "-Xfrontend", "-disable-objc-interop",
                    "-Xfrontend", "-disable-stack-protector",
                    "-Xfrontend", "-function-sections",
                    "-Xfrontend", "-gline-tables-only",

                    // Target i686-elf to match existing kernel
                    "-target", "i686-unknown-none-elf",

                    // Optimization and size settings
                    "-O",
                    "-whole-module-optimization",

                    // Freestanding environment (no standard library runtime)
                    "-Xcc", "-ffreestanding",
                    "-Xcc", "-fno-stack-protector",
                    "-Xcc", "-nostdlib",
                    "-Xcc", "-m32",

                    // Alignment and ABI compatibility with C kernel
                    "-Xcc", "-mpreferred-stack-boundary=2",
                ]),
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-nostdlib",
                    "-static",
                ])
            ]
        ),
        .executableTarget(
            name: "SwiftKernelDemo",
            dependencies: [],
            path: "Sources/SwiftKernelDemo",
            sources: ["main.swift"]
        ),
    ]
)

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MAGIos",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "kernel",
            targets: ["MAGIos"]
        )
    ],
    targets: [
        .executableTarget(
            name: "MAGIos",
            path: "Sources",
            sources: ["adam.swift"],
            swiftSettings: [
                .unsafeFlags([
                    "-Xfrontend", "-function-sections",
                    "-Xfrontend", "-gline-tables-only",
                    "-Xcc", "-ffreestanding",
                    "-parse-as-library",
                ])
            ]
        )
    ]
)

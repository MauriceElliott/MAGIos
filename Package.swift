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
            path: "Sources/MAGIos",
            sources: ["main.swift"],
            swiftSettings: [
                .unsafeFlags([
                    "-Xfrontend", "-function-sections",
                    "-Xfrontend", "-gline-tables-only",
                    "-parse-as-library",
                ])
            ]
        )
    ]
)

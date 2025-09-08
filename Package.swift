// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MAGIos",
    products: [
        .executable(name: "MAGIos", targets: ["Adam"]),
    ],
    targets: [
        //The MAGI themselves, the OS that holds the loose tendrils of society together.
        .executableTarget(
            name: "Adam",
            swiftSettings: [
                .enableExperimentalFeature("Embedded"),
                .unsafeFlags(
                [
                    "-target", "x86_64-unknown-linux-gnu",
                    "-Xfrontend", "-disable-objc-interop",
                    "-Xfrontend", "-function-sections",
                    "-wmo",
                    "-c",
                    "-o adam.o",
                ]),
            ],
        ),
    ]
)

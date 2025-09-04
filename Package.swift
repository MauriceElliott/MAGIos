// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MAGIos",
    products: [
        .executable(name: "MAGIos", targets: ["Plug"]),
        .executable(name: "Lilith", targets: ["Terminal"])
    ],
    targets: [
        //The MAGI themselves, the OS that holds the loose tendrils of society together.
        .executableTarget(
            name: "Plug",
            dependencies: ["Core"],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ],
        ),

        //To test functionality from the commandline.
        .executableTarget(
            name: "Terminal",
            dependencies: ["Core"]
        ),

        //At the center of everything.
        .target(
            name: "Core"
        )
    ]
)

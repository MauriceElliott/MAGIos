// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MAGIos",
    targets: [
        //The MAGI themselves, the OS that holds the loose tendrils of society together.
        .target(
            name: "Adam",
            path: "Sources/Core/",
            swiftSettings: [
                .enableExperimentalFeature("Embedded"),
                .unsafeFlags(
                [
                    "-target", "riscv64-none-none-eabi",
                    "-Xfrontend", "-disable-objc-interop",
                    "-Xfrontend", "-function-sections",
                    "-Xfrontend", "-disable-stack-protector",
                    "-wmo",
                    "-c",
                    "-emit-object",
                    //"-nostdlib" //Not sure if this is required, we will see. It is recommended.
                ]),
            ],
        ),
    ]
)

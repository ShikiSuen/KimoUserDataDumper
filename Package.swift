// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KimoUserDataDumper",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "KimoUserDataDumper",
            targets: ["KimoUserDataDumper"]
        ),
    ],
    targets: [
        .target(
            name: "ObjcKimoCommunicator",
            publicHeadersPath: "include",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("Foundation")
            ]
        ),
        .executableTarget(
            name: "KimoUserDataDumper",
            dependencies: ["ObjcKimoCommunicator"]
        ),
    ]
)
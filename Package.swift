// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swift-ISO8583",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Swift-ISO8583",
            targets: ["Swift-ISO8583"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Swift-ISO8583",
            resources: [
                .process("Resources/customisoconfig.plist"),
                .process("Resources/customisoMTI.plist"),
                .process("Resources/isoconfig.plist"),
                .process("Resources/isodatatypes.plist"),
                .process("Resources/isoMTI.plist")
            ]
        ),
        .testTarget(
            name: "Swift-ISO8583Tests",
            dependencies: ["Swift-ISO8583"]
        ),
    ]
)

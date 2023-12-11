// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HealthKitHelper",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HealthKitHelper",
            targets: ["HealthKitHelper"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/ra9r/Ra9rKit.git",
            from: "1.4.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HealthKitHelper",
            dependencies: ["Ra9rKit"]
        ),
        .testTarget(
            name: "HealthKitHelperTests",
            dependencies: ["HealthKitHelper"]),
    ]
)

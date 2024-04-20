// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "indexstore_db_cli",
    dependencies: [
        .package(url: "https://github.com/apple/indexstore-db", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "indexstore_db_cli", dependencies: [
            // other dependencies
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
             .product(name: "IndexStoreDB", package: "indexstore-db"),
        ]),
    ]
)

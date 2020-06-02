// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RSASwiftGenerator",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/kmussel/ccommoncrypto.git", from: "0.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "RSASwiftGenerator",
            path: "Sources",
            exclude: ["Tests"],
            dependencies: [])
    ]
)

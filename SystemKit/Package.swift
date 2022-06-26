// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SystemKit",
    products: [
        .library(name: "SystemKit", targets: ["SystemKit"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "SystemKit", dependencies: [], path: "SystemKit"),
        .testTarget(name: "SystemKitTests", dependencies: ["SystemKit"], path: "SystemKitTests")
    ],
    swiftLanguageVersions: [.v5]
)

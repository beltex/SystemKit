//
//  Package.swift
//  SystemKit
//
//  Created by Viraj Chitnis on 7/24/20.
//  Copyright © 2020 beltex. All rights reserved.
//

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

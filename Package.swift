// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "BurnRollCore",
    platforms: [
        .iOS(.v26),
        .macOS(.v14)
    ],
    products: [
        .library(name: "BurnRollCore", targets: ["BurnRollCore"])
    ],
    targets: [
        .target(
            name: "BurnRollCore",
            path: "BurnRoll/Models"
        ),
        .testTarget(
            name: "BurnRollCoreTests",
            dependencies: ["BurnRollCore"],
            path: "BurnRollCoreTests"
        )
    ]
)

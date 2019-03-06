// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "QLoop",
    products: [
        .library(name: "QLoop", targets: ["QLoop"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "QLoop", dependencies: []),
        .testTarget(name: "QLoopTests", dependencies: ["QLoop"]),
    ]
)

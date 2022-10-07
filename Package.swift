// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "LNURLAuthKit",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "LNURLAuthKit", targets: ["LNURLAuthKit"]),
        .executable(name: "example", targets: ["Example"])
    ],
    dependencies: [
        .package(url: "https://github.com/GigaBitcoin/secp256k1.swift", from: "0.9.2"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "2.1.0")
    ],
    targets: [
        .target(name: "LNURLAuthKit", dependencies: [
            .product(name: "secp256k1", package: "secp256k1.swift"),
            .product(name: "Crypto", package: "swift-crypto"),
        ]),
        .executableTarget(name: "Example", dependencies: ["LNURLAuthKit"]),
        .testTarget(name: "LNURLAuthKitTests", dependencies: ["LNURLAuthKit"]),
    ]
)

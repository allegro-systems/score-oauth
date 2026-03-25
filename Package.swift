// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ScoreOAuth",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "ScoreOAuth", targets: ["ScoreOAuth"]),
    ],
    dependencies: [
        .package(path: "../../score"),
    ],
    targets: [
        .target(
            name: "ScoreOAuth",
            dependencies: [
                .product(name: "Score", package: "Score"),
            ]
        ),
        .testTarget(
            name: "ScoreOAuthTests",
            dependencies: ["ScoreOAuth"]
        ),
    ]
)

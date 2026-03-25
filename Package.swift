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
        .package(url: "https://github.com/allegro-systems/score.git", branch: "main"),
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

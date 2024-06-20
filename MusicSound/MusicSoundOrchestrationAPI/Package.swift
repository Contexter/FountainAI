// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MusicSoundOrchestrationAPI",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Fluent", package: "fluent")
            ],
            path: "Sources/App"
        ),
        .target(
            name: "Run",
            dependencies: [.target(name: "App")],
            path: "Sources/Run"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [.target(name: "App")],
            path: "Tests/AppTests"
        )
    ]
)

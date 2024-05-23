// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "VaporAppDeploy",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/behrang/YamlSwift.git", from: "3.4.3")
    ],
    targets: [
        .executableTarget(
            name: "VaporAppDeploy",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yaml", package: "YamlSwift")
            ]
        )
    ]
)

// swift-tools-version:5.3
import PackageDescription

/// The package description for the VaporAppDeploy project.
let package = Package(
    /// The name of the package.
    name: "VaporAppDeploy",
    /// The platforms supported by this package.
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        /// The Swift Argument Parser package dependency.
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        /// The YamlSwift package dependency.
        .package(url: "https://github.com/behrang/YamlSwift.git", from: "3.4.3"),
        /// The Yams package dependency.
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0")
    ],
    targets: [
        /// The executable target for VaporAppDeploy.
        .target(
            /// The name of the target.
            name: "VaporAppDeploy",
            /// The dependencies for the target.
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yaml", package: "YamlSwift"),
                .product(name: "Yams", package: "Yams")
            ]
        )
    ]
)

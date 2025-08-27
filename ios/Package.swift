// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorVideoWebview",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "CapacitorVideoWebview",
            targets: ["VideoWebviewPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main")
    ],
    targets: [
        .target(
            name: "VideoWebviewPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "Sources/VideoWebviewPlugin"),
        .testTarget(
            name: "VideoWebviewPluginTests",
            dependencies: ["VideoWebviewPlugin"],
            path: "Tests/VideoWebviewPluginTests")
    ]
)

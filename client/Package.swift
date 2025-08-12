// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ClientApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ClientApp", targets: ["ClientApp"])
    ],
    dependencies: [
        // Dependencies for WebRTC or SSH tunnels would be declared here.
    ],
    targets: [
        .executableTarget(
            name: "ClientApp",
            dependencies: []
        )
    ]
)

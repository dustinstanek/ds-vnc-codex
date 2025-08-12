// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "HostAgent",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "HostAgent", targets: ["HostAgent"])
    ],
    targets: [
        .executableTarget(
            name: "HostAgent"
        ),
        .testTarget(
            name: "HostAgentTests",
            dependencies: ["HostAgent"]
        )
    ]
)

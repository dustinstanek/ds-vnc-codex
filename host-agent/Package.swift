// swift-tools-version:5.7
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

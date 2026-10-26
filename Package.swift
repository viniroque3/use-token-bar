// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UseTokenBar",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "UseTokenBar", targets: ["UseTokenBar"])
    ],
    targets: [
        .executableTarget(
            name: "UseTokenBar",
            path: "Sources/UseTokenBar"
        )
    ]
)

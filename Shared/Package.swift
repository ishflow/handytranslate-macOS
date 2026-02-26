// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Shared",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(name: "Shared", targets: ["Shared"])
    ],
    targets: [
        .target(name: "Shared")
    ]
)

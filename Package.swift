// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "RDFKit",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "RDFKit",
            targets: ["RDFKit"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RDFKit",
            dependencies: [],
            resources: [.copy("Turtle")]
        ),
        .testTarget(
            name: "RDFKitTests",
            dependencies: ["RDFKit"],
            resources: [.copy("Data")]
        )
    ]
)

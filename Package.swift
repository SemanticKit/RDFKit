// swift-tools-version: 6.2
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
    dependencies: [
        .package(url: "https://github.com/SemanticKit/SemanticKit.git", branch: "main")
    ],
    targets: [
        .target(
            name: "RDFKit",
            dependencies: ["SemanticKit"],
            resources: [.copy("Turtle")]
        ),
        .testTarget(
            name: "RDFKitTests",
            dependencies: ["RDFKit", "SemanticKit"],
            resources: [.copy("Data")]
        )
    ]
)

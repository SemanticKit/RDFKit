// swift-tools-version: 6.4
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "RDFKit",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .visionOS(.v27)
    ],
    products: [
        .library(
            name: "RDFKit",
            targets: ["RDFKit"]
        ),
        .library(
            name: "RDFCore",
            targets: ["RDFCore"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SemanticKit/IRIKit.git", branch: "main"),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.0")
    ],
    targets: [
        .target(
            name: "RDFCore",
            dependencies: ["IRIKit"]
        ),
        .target(
            name: "RDFKit",
            dependencies: [
                "RDFCore",
                "RDFKitMacros"
            ],
            exclude: [
                "OWL/AGENTS.md",
                "RDF/AGENTS.md",
                "RDF/rdf.ttl",
                "RDFS/AGENTS.md",
                "RDFS/rdfs.ttl",
                "Turtle/owl.ttl",
                "Turtle/rdf.ttl",
                "Turtle/rdfs.ttl"
            ]
        ),
        .macro(
            name: "RDFKitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "RDFKitTests",
            dependencies: ["RDFKit"],
            exclude: [
                "Data/shacl.rdf",
                "Data/shacl.ttl"
            ]
        ),
        .target(
            name: "Fauna",
            dependencies: ["RDFKit"]
        ),
        .testTarget(
            name: "FaunaTests",
            dependencies: ["Fauna"]
        )
    ]
)

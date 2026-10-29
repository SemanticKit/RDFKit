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
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "604.0.0")
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
                "DSL_INVARIANTS.md",
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
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "RDFKitTests",
            dependencies: ["RDFKit", "RDFCore"],
            exclude: [
                "Data/shacl.rdf",
                "Data/shacl.ttl",
                "Fixtures/.gitkeep"
            ]
        ),
        .target(
            name: "Fauna",
            dependencies: ["RDFCore", "RDFKit"]
        ),
        .testTarget(
            name: "RDFKitMacrosTests",
            dependencies: [
                "RDFKitMacros",
                .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "FaunaTests",
            dependencies: [
                "Fauna",
                "RDFKit",
                "RDFCore",
                .product(name: "IRIKit", package: "IRIKit")
            ]
        )
    ]
)

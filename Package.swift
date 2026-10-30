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
    dependencies: [
        .package(url: "https://github.com/SemanticKit/IRIKit.git", branch: "main"),
        // The SemanticKit invariants as build rules: RegoPolicyEvaluate runs
        // the SemanticKitDesignGuidelines policies over every Swift file of
        // the targets below, and a `deny` finding fails the build.
        .package(url: "https://github.com/SemanticKit/SemanticKitBuildPlugins.git", branch: "main")
    ],
    targets: [
        .target(
            name: "RDFKit",
            dependencies: [
                "IRIKit",
                .product(name: "SemanticKitDesignGuidelines", package: "SemanticKitBuildPlugins")
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
            ],
            plugins: [
                .plugin(name: "RegoPolicyEvaluate", package: "SemanticKitBuildPlugins")
            ]
        ),
        .testTarget(
            name: "RDFKitTests",
            dependencies: [
                "RDFKit",
                .product(name: "SemanticKitDesignGuidelines", package: "SemanticKitBuildPlugins")
            ],
            exclude: [
                "Data/shacl.rdf",
                "Data/shacl.ttl"
            ],
            plugins: [
                .plugin(name: "RegoPolicyEvaluate", package: "SemanticKitBuildPlugins")
            ]
        )
    ]
)

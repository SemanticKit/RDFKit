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
        .testTarget(
            name: "RDFKitTests",
            dependencies: ["RDFKit"],
            exclude: [
                "Data/shacl.rdf",
                "Data/shacl.ttl"
            ]
        )
    ]
)

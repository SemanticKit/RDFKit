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
            name: "Prototype",
            targets: ["Prototype"]
        ),
        .library(
            name: "RDFKit",
            targets: ["RDFKit"]
        ),
        .library(
            name: "RDFCore",
            targets: ["RDFCore"]
        ),
        .library(name: "FOAF", targets: ["FOAF"]),
        .library(name: "Cert", targets: ["Cert"]),
        .library(name: "ACL", targets: ["ACL"]),
        .library(name: "ACP", targets: ["ACP"]),
        .library(name: "LDP", targets: ["LDP"]),
        .library(name: "Solid", targets: ["Solid"]),
        .library(name: "ReferencedVocabularies", targets: ["ReferencedVocabularies"])
    ],
    dependencies: [
        .package(url: "https://github.com/SemanticKit/IRIKit.git", branch: "main"),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.0")
    ],
    targets: [
        .target(
            name: "Prototype",
            dependencies: [
                "IRIKit",
                "RDFKitMacros"
            ]
        ),
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
            dependencies: ["RDFKit"],
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
        .target(
            name: "ReferencedVocabularies",
            dependencies: ["RDFCore", "RDFKit"],
            path: "Sources/Vocabularies/Referenced"
        ),
        .target(
            name: "FOAF",
            dependencies: ["RDFCore", "RDFKit", "ReferencedVocabularies"],
            path: "Sources/Vocabularies/FOAF"
        ),
        .target(
            name: "Cert",
            dependencies: ["RDFCore", "RDFKit", "FOAF"],
            path: "Sources/Vocabularies/Cert"
        ),
        .target(
            name: "ACL",
            dependencies: ["RDFCore", "RDFKit", "FOAF", "ReferencedVocabularies"],
            path: "Sources/Vocabularies/ACL"
        ),
        .target(
            name: "ACP",
            dependencies: ["RDFCore", "RDFKit"],
            path: "Sources/Vocabularies/ACP"
        ),
        .target(
            name: "LDP",
            dependencies: ["RDFCore", "RDFKit"],
            path: "Sources/Vocabularies/LDP"
        ),
        .target(
            name: "Solid",
            dependencies: ["RDFCore", "RDFKit", "FOAF", "LDP", "ReferencedVocabularies"],
            path: "Sources/Vocabularies/Solid"
        ),
        .testTarget(
            name: "VocabularyTests",
            dependencies: ["RDFCore", "RDFKit", "ReferencedVocabularies", "FOAF", "Cert", "ACL", "ACP", "LDP", "Solid", .product(name: "IRIKit", package: "IRIKit")]
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

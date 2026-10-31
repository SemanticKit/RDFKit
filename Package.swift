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
        ),
        .library(
            name: "RDFFormats",
            targets: ["RDFFormats"]
        ),
        .library(
            name: "XSD",
            targets: ["XSD"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SemanticKit/IRIKit.git", branch: "main"),
        .package(url: "https://github.com/SemanticKit/EBNFKit.git", branch: "main"),
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
                "OWL/AGENTS.md",
                "OWL/README.md",
                "RDF/AGENTS.md",
                "RDF/README.md",
                "RDFS/AGENTS.md",
                "RDFS/README.md",
                "DSL_INVARIANTS.md"
            ],
            // RDF, RDFS and OWL, translated from rdf.ttl, rdfs.ttl and
            // owl.ttl as published.
            plugins: ["RDFTranslatorPlugin"]
        ),
        // The Swift a vocabulary's classes and properties generate, which the
        // @Ontology macro and RDFTranslator both emit.
        .target(
            name: "OntologyGeneration",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax")
            ],
            exclude: ["W3C"],
            plugins: ["SemanticsEmitterPlugin"]
        ),
        // The semantic tables of RDF 1.2 Semantics, OWL 2 Profiles and OWL 2
        // RDF-Based Semantics (Sources/OntologyGeneration/W3C), translated to
        // the Semantics OntologyGeneration reads on every build.
        .executableTarget(
            name: "SemanticsEmitter",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax")
            ]
        ),
        .plugin(
            name: "SemanticsEmitterPlugin",
            capability: .buildTool(),
            dependencies: ["SemanticsEmitter"]
        ),
        .macro(
            name: "RDFKitMacros",
            dependencies: [
                "OntologyGeneration",
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        // The formats, read with the grammars their specifications publish
        // (Sources/RDFFormats/Grammars), which EBNFTranslatorPlugin
        // translates to Swift on every build.
        .target(
            name: "RDFFormats",
            dependencies: [
                "IRIKit",
                "RDFCore"
            ],
            exclude: ["Grammars/README.md"],
            plugins: [
                .plugin(name: "EBNFTranslatorPlugin", package: "EBNFKit")
            ]
        ),
        // The XML Schema datatypes RDF uses (RDF 1.2 Concepts §5.1), each a
        // Swift value type, emitted from the W3C documents in Sources/XSD/W3C
        // for the datatypes units.txt lists.
        .target(
            name: "XSD",
            dependencies: ["RDFKit"],
            exclude: ["W3C/README.md"],
            plugins: ["XSDEmitterPlugin"]
        ),
        .executableTarget(
            name: "XSDEmitter",
            dependencies: [
                "XSDDefinitions",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax")
            ]
        ),
        .plugin(
            name: "XSDEmitterPlugin",
            capability: .buildTool(),
            dependencies: ["XSDEmitter"]
        ),
        // The W3C documents that define the XML Schema datatypes
        // (Sources/XSD/W3C), read as their structure gives them.
        .target(
            name: "XSDDefinitions"
        ),
        // RDF in, Swift out: the translator and the build tool plugin that
        // runs it over a target's RDF documents, through the generators
        // @Ontology uses.
        .executableTarget(
            name: "RDFTranslator",
            dependencies: [
                "IRIKit",
                "RDFCore",
                "RDFFormats",
                "OntologyGeneration",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax")
            ]
        ),
        .plugin(
            name: "RDFTranslatorPlugin",
            capability: .buildTool(),
            dependencies: ["RDFTranslator"]
        ),
        // FOAF as published (index.rdf, RDF/XML), translated term by term.
        .target(
            name: "FOAF",
            dependencies: ["IRIKit", "RDFKit", "RDFCore"],
            path: "Tests/ParallelTests/Fixtures/FOAF",
            plugins: ["RDFTranslatorPlugin"]
        ),
        // Alice's profile (alice.ttl), translated to the FOAF individuals it
        // states.
        .target(
            name: "AliceProfile",
            dependencies: ["FOAF", "IRIKit", "RDFKit", "RDFCore", "XSD"],
            path: "Tests/ParallelTests/Fixtures/AliceProfile",
            plugins: ["RDFTranslatorPlugin"]
        ),
        // The parallel, RDF in and Swift out and back, frozen by checksum.
        .testTarget(
            name: "ParallelTests",
            dependencies: ["AliceProfile", "FOAF", "RDFCore", "RDFFormats"],
            path: "Tests/ParallelTests",
            exclude: ["Fixtures"]
        ),
        .testTarget(
            name: "FOAFTests",
            dependencies: ["FOAF", "RDFKit", "RDFCore"]
        ),
        .testTarget(
            name: "RDFKitTests",
            dependencies: ["RDFKit", "RDFCore"],
            exclude: [
                "Data/shacl.rdf",
                "Data/shacl.ttl"
            ]
        ),
        .testTarget(
            name: "RDFFormatsTests",
            dependencies: ["RDFFormats", "RDFCore"]
        ),
        .testTarget(
            name: "XSDTests",
            dependencies: ["XSD", "RDFKit"]
        ),
        .testTarget(
            name: "RDFCoreTests",
            dependencies: ["RDFCore"]
        ),
        .testTarget(
            name: "RDFKitMacrosTests",
            dependencies: [
                "RDFKitMacros",
                .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax")
            ]
        )
    ]
)

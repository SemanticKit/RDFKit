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
            name: "RDF",
            targets: ["RDF"]
        ),
        .library(
            name: "OWL",
            targets: ["OWL"]
        ),
        .plugin(
            name: "RDFTranslatorPlugin",
            targets: ["RDFTranslatorPlugin"]
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
                "RDF",
                "OWL",
                "RDFKitMacros"
            ],
            exclude: [
                "DSL_INVARIANTS.md",
                "OWL/AGENTS.md",
                "RDF/AGENTS.md",
                "RDFS/AGENTS.md"
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
        .target(
            name: "RDFFormats",
            dependencies: [
                "IRIKit",
                "RDFCore"
            ]
        ),

        // RDF in, Swift out: the translator and the build tool plugin that
        // runs it over a target's RDF documents. The Swift it writes uses
        // RDFCore, as the Swift @Ontology writes does.
        .executableTarget(
            name: "RDFTranslator",
            dependencies: ["IRIKit", "RDFCore", "RDFFormats"]
        ),
        .plugin(
            name: "RDFTranslatorPlugin",
            capability: .buildTool(),
            dependencies: ["RDFTranslator"]
        ),

        // The layers: RDF and RDF Schema (rdf.ttl and rdfs.ttl, which refer
        // to each other), then OWL 2 (owl.ttl).
        .target(
            name: "RDF",
            dependencies: ["RDFCore"],
            path: "Tests/ParallelTests/Fixtures/W3C",
            plugins: ["RDFTranslatorPlugin"]
        ),
        .target(
            name: "OWL",
            dependencies: ["RDF"],
            plugins: ["RDFTranslatorPlugin"]
        ),

        // Vocabularies and data built on the layers.
        .target(
            name: "FOAF",
            dependencies: ["OWL", "RDF"],
            path: "Tests/ParallelTests/Fixtures/FOAF",
            plugins: ["RDFTranslatorPlugin"]
        ),
        .target(
            name: "AliceProfile",
            dependencies: ["FOAF"],
            path: "Tests/ParallelTests/Fixtures/AliceProfile",
            plugins: ["RDFTranslatorPlugin"]
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
        .testTarget(
            name: "RDFFormatsTests",
            dependencies: [
                "RDFFormats",
                "RDFCore",
                "RDFKit",
                .product(name: "IRIKit", package: "IRIKit")
            ],
            exclude: [
                "W3C/README.md"
            ],
            resources: [
                .copy("W3C/rdf-tests")
            ]
        ),
        .testTarget(
            name: "RDFCoreTests",
            dependencies: [
                "RDFCore",
                "RDFKit",
                .product(name: "IRIKit", package: "IRIKit")
            ]
        ),
        .testTarget(
            name: "RDFKitMacrosTests",
            dependencies: [
                "RDFKitMacros",
                .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "RDFTranslatorTests",
            dependencies: [
                "RDFCore",
                "RDFFormats",
                "RDF",
                "OWL"
            ],
            plugins: ["RDFTranslatorPlugin"]
        ),
        .testTarget(
            name: "ParallelTests",
            dependencies: [
                "RDFCore",
                "RDFFormats",
                "RDF",
                "OWL",
                "FOAF",
                "AliceProfile"
            ],
            exclude: ["Fixtures"]
        )
    ]
)

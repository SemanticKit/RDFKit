// swift-tools-version: 6.4
import PackageDescription
import CompilerPluginSupport

/// The settings of a target whose Swift RDFTranslatorPlugin generates: the
/// generated Swift compiles without warnings, deprecated declarations
/// (`owl:deprecated`) included, so a warning in it fails the build.
let generated: [SwiftSetting] = [.treatAllWarnings(as: .error)]

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
                "IRIKit",
                "RDFCore",
                "RDF",
                "OWL",
                "RDFKitMacros"
            ]
        ),
        // How generated Swift spells a name and a text, shared by the
        // @Ontology macro and RDFTranslator so both decide it the same way,
        // through SwiftParser.
        .target(
            name: "SwiftSpelling",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ]
        ),
        .macro(
            name: "RDFKitMacros",
            dependencies: [
                "SwiftSpelling",
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
        // RDFCore, as the Swift @Ontology writes does, and is built with
        // SwiftSyntax's typed nodes, as @Ontology's is.
        .executableTarget(
            name: "RDFTranslator",
            dependencies: [
                "IRIKit",
                "RDFCore",
                "RDFFormats",
                "SwiftSpelling",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftBasicFormat", package: "swift-syntax")
            ]
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
            swiftSettings: generated,
            plugins: ["RDFTranslatorPlugin"]
        ),
        .target(
            name: "OWL",
            dependencies: ["RDF"],
            swiftSettings: generated,
            plugins: ["RDFTranslatorPlugin"]
        ),

        // Vocabularies and data built on the layers.
        .target(
            name: "FOAF",
            dependencies: ["OWL", "RDF"],
            path: "Tests/ParallelTests/Fixtures/FOAF",
            swiftSettings: generated,
            plugins: ["RDFTranslatorPlugin"]
        ),
        .target(
            name: "AliceProfile",
            dependencies: ["FOAF"],
            path: "Tests/ParallelTests/Fixtures/AliceProfile",
            swiftSettings: generated,
            plugins: ["RDFTranslatorPlugin"]
        ),
        // SHACL 1.2's published vocabulary (shacl.ttl), on RDF and OWL.
        .target(
            name: "SHACL",
            dependencies: ["OWL", "RDF"],
            path: "Tests/SHACLTranslationTests/Fixtures/SHACL",
            swiftSettings: generated,
            plugins: ["RDFTranslatorPlugin"]
        ),
        // The entailment regime vocabulary, whose ent:RDF is named like the
        // RDF module it builds on.
        .target(
            name: "EntailmentRegimes",
            dependencies: ["OWL", "RDF"],
            path: "Tests/EntailmentTranslationTests/Fixtures/EntailmentRegimes",
            swiftSettings: generated,
            plugins: ["RDFTranslatorPlugin"]
        ),

        // Data on no layer: rdf:type names no class.
        .target(
            name: "PlainData",
            dependencies: ["RDFCore"],
            path: "Tests/PlainDataTranslationTests/Fixtures/PlainData",
            swiftSettings: generated,
            plugins: ["RDFTranslatorPlugin"]
        ),

        // The W3C test vocabularies the RDF test suites' manifests are
        // written in, as published.
        .target(
            name: "TestManifest",
            dependencies: ["OWL", "RDF"],
            path: "Tests/RDFFormatsTests/Vocabularies/TestManifest",
            swiftSettings: generated,
            plugins: ["RDFTranslatorPlugin"]
        ),
        .target(
            name: "RDFTest",
            dependencies: ["OWL", "RDF"],
            path: "Tests/RDFFormatsTests/Vocabularies/RDFTest",
            swiftSettings: generated,
            plugins: ["RDFTranslatorPlugin"]
        ),

        .testTarget(
            name: "RDFKitTests",
            dependencies: [
                "RDFKit",
                "RDFCore",
                "RDFFormats",
                "RDF",
                "OWL",
                "FOAF",
                "AliceProfile",
                .product(name: "IRIKit", package: "IRIKit")
            ],
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
                "RDF",
                "FOAF",
                "AliceProfile",
                "TestManifest",
                "RDFTest",
                .product(name: "IRIKit", package: "IRIKit")
            ],
            exclude: [
                "W3C/README.md",
                "Vocabularies",
                "Fixtures"
            ],
            resources: [
                .copy("W3C/rdf-tests")
            ]
        ),
        .testTarget(
            name: "RDFCoreTests",
            dependencies: [
                "RDFCore",
                "RDFFormats",
                .product(name: "IRIKit", package: "IRIKit")
            ],
            exclude: ["Fixtures"]
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
            name: "SHACLTranslationTests",
            dependencies: [
                "RDFCore",
                "RDFFormats",
                "RDF",
                "SHACL",
                .product(name: "IRIKit", package: "IRIKit")
            ],
            exclude: ["Fixtures"]
        ),
        .testTarget(
            name: "EntailmentTranslationTests",
            dependencies: [
                "RDFCore",
                "RDFFormats",
                "RDF",
                "EntailmentRegimes"
            ],
            exclude: ["Fixtures"]
        ),
        .testTarget(
            name: "PlainDataTranslationTests",
            dependencies: [
                "RDFCore",
                "RDFFormats",
                "PlainData",
                "RDFTranslator",
                .product(name: "IRIKit", package: "IRIKit"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ],
            exclude: ["Fixtures"]
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

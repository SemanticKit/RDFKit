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
                "RDF/AGENTS.md",
                "RDF/rdf.ttl",
                "RDFS/AGENTS.md",
                "RDFS/rdfs.ttl",
                "Turtle/owl.ttl",
                "Turtle/rdf.ttl",
                "Turtle/rdfs.ttl",
                "DSL_INVARIANTS.md",
                "Pending"
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
        // The W3C documents that define the XML Schema datatypes
        // (Sources/XSD/W3C), read as their structure gives them.
        .target(
            name: "XSDDefinitions"
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
            dependencies: ["RDFFormats", "RDFCore"],
            resources: [.copy("Fixtures")]
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

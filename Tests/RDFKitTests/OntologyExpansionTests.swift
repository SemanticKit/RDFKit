import Foundation
import Testing
@testable import RDFKit

@Suite struct OntologyExpansionTests {
    @Test func expansionProducesSourceForDeclaredClass() throws {
        let source = try OntologyExpansion(ontologyExpression: "GeneratedRDFOntology()")
            .source(for: GeneratedRDFOntology())

        #expect(source.contains("public struct CompoundLiteral: OntologyScopedTerm, RDFClass"))
        #expect(source.contains("public static var ontology: GeneratedRDFOntology { GeneratedRDFOntology() }"))
        #expect(source.contains("public static let localName = LocalName(\"CompoundLiteral\")"))
        #expect(source.contains("public init(_ value: String)"))
    }

    @Test func expansionPreservesLowerCamelLocalName() throws {
        let source = try OntologyExpansion(ontologyExpression: "GeneratedRDFOntology()")
            .source(for: GeneratedRDFOntology())

        #expect(source.contains("public struct SubClassOf: OntologyScopedTerm, RDFProperty"))
        #expect(source.contains("public static let localName = LocalName(\"subClassOf\")"))
    }

    @Test func expansionStopsAtConfiguredDepthBound() {
        #expect(throws: OntologyObjectGraph.Failure.self) {
            try OntologyExpansion(maximumDepth: 0).source(for: GeneratedRDFOntology())
        }
    }

    @Test func rdfVocabularyExpansionUsesStandardDSLContent() throws {
        let source = try OntologyExpansion().source(for: RDF.self)

        #expect(source.contains("public extension RDF"))
        #expect(source.contains("public struct CompoundLiteral: RDFKit.RDFClass, RDFTerm"))
        #expect(source.contains("public static var type: TypeTerm { TypeTerm() }"))
        #expect(source.contains("public static let localName = LocalName(\"type\")"))
        #expect(source.contains("public struct PlainLiteral: RDFKit.RDFDatatype, RDFTerm"))
        #expect(source.contains("DeprecatedTerm"))
        #expect(source.contains("public static let deprecated = true"))
        #expect(source.expandedDeclarationCount == 32)
    }

    @Test func rdfsVocabularyExpansionUsesStandardDSLContent() throws {
        let source = try OntologyExpansion().source(for: RDFS())

        #expect(source.contains("public extension RDFS"))
        #expect(source.contains("public struct Resource: RDFKit.RDFClass, RDFSTerm"))
        #expect(source.contains("LabeledTerm"))
        #expect(source.contains("CommentedTerm"))
        #expect(source.contains("public static let labels: [String] = [\"Resource\"]"))
        #expect(source.contains("public static let comments: [String] = [\"The class resource, everything.\"]"))
        #expect(source.contains("public static var subClassOf: SubClassOf { SubClassOf() }"))
        #expect(source.contains("public struct SubClassOf: RDFKit.RDFProperty, RDFSLowerCamelTerm"))
        #expect(source.contains("RelationshipProperty"))
        #expect(source.contains("DomainConstrainedProperty"))
        #expect(source.contains("RangeConstrainedProperty"))
        #expect(source.contains("public static let domains: [IRI] = [IRI(\"http://www.w3.org/2000/01/rdf-schema#Class\")]"))
        #expect(source.contains("public static let ranges: [IRI] = [IRI(\"http://www.w3.org/2000/01/rdf-schema#Class\")]"))
        #expect(source.expandedDeclarationCount == 16)
    }

    @Test func owlVocabularyExpansionUsesStandardDSLContent() throws {
        let source = try OntologyExpansion().source(for: OWL.self)

        #expect(source.contains("public extension OWL"))
        #expect(source.contains("public struct Thing: RDFKit.RDFClass, OWLTerm"))
        #expect(source.contains("LabeledTerm"))
        #expect(source.contains("CommentedTerm"))
        #expect(source.contains("public static let labels: [String] = [\"Thing\"]"))
        #expect(source.contains("public static let comments: [String] = [\"The class of OWL individuals.\"]"))
        #expect(source.contains("public static var allValuesFrom: AllValuesFrom { AllValuesFrom() }"))
        #expect(source.contains("public struct AllValuesFrom: RDFKit.RDFProperty, OWLLowerCamelTerm"))
        #expect(source.contains("public struct VersionInfo: RDFKit.RDFProperty, OWLLowerCamelTerm"))
        #expect(source.contains("public struct TopObjectProperty: RDFKit.RDFProperty, OWLLowerCamelTerm"))
        #expect(source.contains("RelationshipProperty"))
        #expect(source.contains("RDFKit.AnnotationProperty"))
        #expect(source.contains("RDFKit.ObjectProperty"))
        #expect(source.contains("public static let domains: [IRI] = [IRI(\"http://www.w3.org/2002/07/owl#Thing\")]"))
        #expect(source.contains("public static let ranges: [IRI] = [IRI(\"http://www.w3.org/2002/07/owl#Thing\")]"))
        #expect(source.expandedDeclarationCount == 77)
    }

    @Test func generatedVocabularySourceCoversEveryStandardsMatrixTerm() throws {
        let matrix = try StandardsMatrix.bundled()

        try assertGeneratedVocabularySource(
            try OntologyExpansion().source(for: RDF.self),
            covers: matrix.entries(in: "RDF")
        )
        try assertGeneratedVocabularySource(
            try OntologyExpansion().source(for: RDFS.self),
            covers: matrix.entries(in: "RDFS")
        )
        try assertGeneratedVocabularySource(
            try OntologyExpansion().source(for: OWL.self),
            covers: matrix.entries(in: "OWL")
        )
    }

    @Test func generatedOntologySourceBuildsInConsumerPackage() throws {
        let generatedSource = try OntologyExpansion(ontologyExpression: "ConsumerOntology()")
            .sourceFile(for: ConsumerOntology())
        let packageRoot = try makeConsumerPackage(
            generatedSource: generatedSource,
            supportSource: consumerOntologySource(),
            supportFileName: "ConsumerOntology.swift"
        )

        defer {
            try? FileManager.default.removeItem(at: packageRoot)
        }

        #expect(generatedSource.contains("import RDFKit"))
        try buildConsumerPackage(at: packageRoot)
    }

    @Test func generatedVocabularySourceBuildsInConsumerPackage() throws {
        let generatedSource = try OntologyExpansion()
            .sourceFile(for: ConsumerVocabulary.self)
        let packageRoot = try makeConsumerPackage(
            generatedSource: generatedSource,
            supportSource: consumerVocabularySource(),
            supportFileName: "ConsumerVocabulary.swift"
        )

        defer {
            try? FileManager.default.removeItem(at: packageRoot)
        }

        #expect(generatedSource.contains("public protocol ConsumerVocabularyTerm"))
        #expect(generatedSource.contains("public extension ConsumerVocabulary"))
        #expect(generatedSource.contains("public static var owner: Owner { Owner() }"))
        try buildConsumerPackage(at: packageRoot)
    }

    private struct GeneratedRDFOntology: Ontology {
        var content: some Content {
            Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)

            Class("CompoundLiteral") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
            }
            Property("subClassOf") {
                Type(RDF.Property.self)
                Domain(RDFS.Class.self)
                Range(RDFS.Class.self)
            }
        }
    }

    private struct ConsumerOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/generated#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)
            Alias("owl", OWL.self)

            Class("Asset") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
                Label("Asset")
                Comment("A generated asset class.")
            }
            Property("owner") {
                Type(RDF.Property.self)
                Domain(IRI("https://example.com/generated#Asset"))
                Range(RDFS.Resource.self)
                Label("owner")
                Comment("The resource that owns an asset.")
            }
            Datatype("SKU") {
                Type(RDFS.Datatype.self)
                SubClassOf(RDFS.Literal.self)
                Label("SKU")
            }
            Individual("exampleAsset") {
                Type(IRI("https://example.com/generated#Asset"))
                Label("Example Asset")
            }
        }
    }

    private struct ConsumerVocabulary: Vocabulary {
        static var ontology: some Content {
            Namespace("https://example.com/vocabulary#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)
            Alias("owl", OWL.self)

            Class("Asset") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
                Label("Asset")
                Comment("A generated asset class.")
            }
            Property("owner") {
                Type(RDF.Property.self)
                Domain(IRI("https://example.com/vocabulary#Asset"))
                Range(RDFS.Resource.self)
                Label("owner")
                Comment("The resource that owns an asset.")
            }
            Datatype("SKU") {
                Type(RDFS.Datatype.self)
                SubClassOf(RDFS.Literal.self)
                Label("SKU")
            }
            Individual("exampleAsset") {
                Type(IRI("https://example.com/vocabulary#Asset"))
                Label("Example Asset")
            }
        }
    }

    private func assertGeneratedVocabularySource(
        _ source: String,
        covers entries: [VocabularyMatrixEntry]
    ) throws {
        for entry in entries {
            let typeName = try expectedSwiftTypeName(for: entry.localName)
            let declaration = try declarationSource(in: source, typeName: typeName)

            #expect(declaration.contains("public struct \(typeName):"))
            #expect(declaration.contains("RDFKit.\(expectedRoleProtocol(for: entry.role))"))
            assertGeneratedFactSource(declaration, matches: entry)
            if expectedExplicitLocalName(typeName: typeName, localName: entry.localName) {
                #expect(declaration.contains("public static let localName = LocalName(\"\(entry.localName.rawValue)\")"))
            }
            if expectedLowerCamelName(entry.localName.rawValue) {
                #expect(source.contains("public static var \(entry.localName.rawValue): \(typeName) { \(typeName)() }"))
            }
        }

        #expect(source.expandedDeclarationCount == entries.count)
    }

    private func declarationSource(in source: String, typeName: String) throws -> String {
        let prefix = "public struct \(typeName):"
        let start = try #require(source.range(of: prefix)?.lowerBound)
        let tail = source[start...]
        let end = try #require(tail.range(of: "\n    }")?.upperBound)

        return String(tail[..<end])
    }

    private func assertGeneratedFactSource(_ declaration: String, matches entry: VocabularyMatrixEntry) {
        assertIRIArray("types", Set(entry.directTypes), in: declaration)
        assertIRIArray("domains", Set(entry.domain), in: declaration)
        assertIRIArray("ranges", Set(entry.range), in: declaration)
        assertIRIArray("superproperties", Set(entry.subpropertyChain), in: declaration)
        assertIRIArray("seeAlso", Set(entry.seeAlso), in: declaration)
        assertIRIArray("isDefinedBy", Set(entry.isDefinedBy), in: declaration)
        assertStringArray("labels", Set(entry.labels), in: declaration)
        assertStringArray("comments", Set(entry.comments), in: declaration)

        if entry.directTypes.isEmpty == false {
            #expect(declaration.contains("TypedTerm"))
        }
        if entry.subclassChain.isEmpty == false {
            #expect(declaration.contains("SubclassAwareTerm"))
        }
        if entry.labels.isEmpty == false {
            #expect(declaration.contains("LabeledTerm"))
        }
        if entry.comments.isEmpty == false {
            #expect(declaration.contains("CommentedTerm"))
        }
        if entry.seeAlso.isEmpty == false {
            #expect(declaration.contains("SeeAlsoTerm"))
        }
        if entry.isDefinedBy.isEmpty == false {
            #expect(declaration.contains("IsDefinedByTerm"))
        }
        if entry.subpropertyChain.isEmpty == false {
            #expect(declaration.contains("SubpropertyAwareProperty"))
        }
        if entry.domain.isEmpty == false {
            #expect(declaration.contains("DomainConstrainedProperty"))
        }
        if entry.range.isEmpty == false {
            #expect(declaration.contains("RangeConstrainedProperty"))
        }
    }

    private func assertIRIArray(_ name: String, _ values: Set<IRI>, in declaration: String) {
        if values.isEmpty {
            #expect(declaration.contains("static let \(name):") == false)
        } else {
            #expect(declaration.contains("public static let \(name): [IRI] = \(expectedIRIArraySource(values))"))
        }
    }

    private func assertStringArray(_ name: String, _ values: Set<String>, in declaration: String) {
        if values.isEmpty {
            #expect(declaration.contains("static let \(name):") == false)
        } else {
            #expect(declaration.contains("public static let \(name): [String] = \(expectedStringArraySource(values))"))
        }
    }

    private func expectedRoleProtocol(for role: VocabularyRole) -> String {
        switch role {
        case .class:
            "RDFClass"
        case .property:
            "RDFProperty"
        case .datatype:
            "RDFDatatype"
        case .individual:
            "RDFIndividual"
        case .term:
            "Term"
        }
    }

    private func expectedIRIArraySource(_ values: Set<IRI>) -> String {
        let values = values.sorted().map { "IRI(\"\(expectedEscapedSwiftString($0.rawValue))\")" }
        return "[\(values.joined(separator: ", "))]"
    }

    private func expectedStringArraySource(_ values: Set<String>) -> String {
        let values = values.sorted().map { "\"\(expectedEscapedSwiftString($0))\"" }
        return "[\(values.joined(separator: ", "))]"
    }

    private func expectedSwiftTypeName(for localName: LocalName) throws -> String {
        if localName.rawValue == "type" {
            return "TypeTerm"
        }

        let pieces = localName.rawValue.unicodeScalars
            .split { CharacterSet.alphanumerics.contains($0) == false }
            .map { expectedUpperCamel(String($0)) }
        var typeName = pieces.joined()

        if let first = typeName.unicodeScalars.first, CharacterSet.decimalDigits.contains(first) {
            typeName = "Term" + typeName
        }

        guard expectedSwiftTypeIdentifier(typeName) else {
            throw OntologyExpansion.Failure.invalidSwiftTypeName(localName.rawValue)
        }

        return typeName
    }

    private func expectedLowerCamelName(_ localName: String) -> Bool {
        guard let first = localName.unicodeScalars.first else { return false }
        return CharacterSet.lowercaseLetters.contains(first)
    }

    private func expectedExplicitLocalName(typeName: String, localName: LocalName) -> Bool {
        typeName != localName.rawValue
    }

    private func expectedUpperCamel(_ value: String) -> String {
        guard let first = value.first else { return "" }
        return String(first).uppercased() + value.dropFirst()
    }

    private func expectedSwiftTypeIdentifier(_ value: String) -> Bool {
        guard let first = value.unicodeScalars.first else { return false }
        guard CharacterSet.letters.contains(first) || first == "_" else { return false }

        return value.unicodeScalars.dropFirst().allSatisfy {
            CharacterSet.alphanumerics.contains($0) || $0 == "_"
        }
    }

    private func expectedEscapedSwiftString(_ value: String) -> String {
        var escaped = ""

        for character in value {
            switch character {
            case "\\":
                escaped += "\\\\"
            case "\"":
                escaped += "\\\""
            case "\n":
                escaped += "\\n"
            case "\r":
                escaped += "\\r"
            case "\t":
                escaped += "\\t"
            default:
                escaped.append(character)
            }
        }

        return escaped
    }

    private func makeConsumerPackage(
        generatedSource: String,
        supportSource: String,
        supportFileName: String
    ) throws -> URL {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("RDFKitGeneratedOntology-\(UUID().uuidString)")
        let sources = root
            .appendingPathComponent("Sources")
            .appendingPathComponent("GeneratedOntologySmoke")

        try FileManager.default.createDirectory(at: sources, withIntermediateDirectories: true)
        try write(packageManifestSource(), to: root.appendingPathComponent("Package.swift"))
        try write(supportSource, to: sources.appendingPathComponent(supportFileName))
        try write(generatedSource, to: sources.appendingPathComponent("GeneratedTerms.swift"))

        return root
    }

    private func packageManifestSource() -> String {
        let packagePath = expectedEscapedSwiftString(repositoryRoot().path)

        return """
        // swift-tools-version: 6.3
        import PackageDescription

        let package = Package(
            name: "GeneratedOntologySmoke",
            platforms: [.macOS(.v26)],
            products: [
                .library(name: "GeneratedOntologySmoke", targets: ["GeneratedOntologySmoke"])
            ],
            dependencies: [
                .package(path: "\(packagePath)")
            ],
            targets: [
                .target(name: "GeneratedOntologySmoke", dependencies: ["RDFKit"])
            ]
        )
        """
    }

    private func consumerOntologySource() -> String {
        """
        import RDFKit

        public struct ConsumerOntology: Ontology {
            public init() {}

            public var content: some Content {
                Namespace("https://example.com/generated#")
                Alias("rdf", RDF.self)
                Alias("rdfs", RDFS.self)
                Alias("owl", OWL.self)

                Class("Asset") {
                    Type(RDFS.Class.self)
                    SubClassOf(RDFS.Resource.self)
                    Label("Asset")
                    Comment("A generated asset class.")
                }
                Property("owner") {
                    Type(RDF.Property.self)
                    Domain(IRI("https://example.com/generated#Asset"))
                    Range(RDFS.Resource.self)
                    Label("owner")
                    Comment("The resource that owns an asset.")
                }
                Datatype("SKU") {
                    Type(RDFS.Datatype.self)
                    SubClassOf(RDFS.Literal.self)
                    Label("SKU")
                }
                Individual("exampleAsset") {
                    Type(IRI("https://example.com/generated#Asset"))
                    Label("Example Asset")
                }
            }
        }

        public struct ConsumerGeneratedOntologyUseOntology: Ontology {
            public init() {}

            public var content: some Content {
                Namespace("https://example.com/generated-use#")

                Class("TaggedAsset") {
                    Type(RDFS.Class.self)
                    SubClassOf(Asset.self)
                    SeeAlso(Owner())
                }

                Property("trackedOwner") {
                    Type(RDF.Property.self)
                    SubPropertyOf(Owner.self)
                    Domain("TaggedAsset")
                    Range(Asset.self)
                }

                Datatype("GeneratedSKU") {
                    Type(RDFS.Datatype.self)
                    SubClassOf(SKU.self)
                }

                Individual("exampleTaggedAsset") {
                    Type("TaggedAsset")
                    SeeAlso(ExampleAsset.self)
                }
            }
        }

        public func generatedOntologyUseGraph() throws -> OntologyObjectGraph {
            try OntologyObjectGraph(ConsumerGeneratedOntologyUseOntology())
        }
        """
    }

    private func consumerVocabularySource() -> String {
        """
        import RDFKit

        public struct ConsumerVocabulary: Vocabulary {
            public init() {}

            public static var ontology: some Content {
                Namespace("https://example.com/vocabulary#")
                Alias("rdf", RDF.self)
                Alias("rdfs", RDFS.self)
                Alias("owl", OWL.self)

                Class("Asset") {
                    Type(RDFS.Class.self)
                    SubClassOf(RDFS.Resource.self)
                    Label("Asset")
                    Comment("A generated asset class.")
                }
                Property("owner") {
                    Type(RDF.Property.self)
                    Domain(IRI("https://example.com/vocabulary#Asset"))
                    Range(RDFS.Resource.self)
                    Label("owner")
                    Comment("The resource that owns an asset.")
                }
                Datatype("SKU") {
                    Type(RDFS.Datatype.self)
                    SubClassOf(RDFS.Literal.self)
                    Label("SKU")
                }
                Individual("exampleAsset") {
                    Type(IRI("https://example.com/vocabulary#Asset"))
                    Label("Example Asset")
                }
            }
        }

        public struct ConsumerGeneratedVocabularyUseOntology: Ontology {
            public init() {}

            public var content: some Content {
                Namespace("https://example.com/vocabulary-use#")
                Alias("vocab", ConsumerVocabulary.self)

                Class("TaggedAsset") {
                    Type(ConsumerVocabulary.Asset.self)
                    SubClassOf(ConsumerVocabulary.Asset.self)
                    SeeAlso(ConsumerVocabulary.owner)
                }

                Property("catalogOwner") {
                    Type(RDF.Property.self)
                    SubPropertyOf(ConsumerVocabulary.owner)
                    Domain("TaggedAsset")
                    Range(ConsumerVocabulary.Asset.self)
                }

                Datatype("GeneratedSKU") {
                    Type(ConsumerVocabulary.SKU.self)
                    SubClassOf(ConsumerVocabulary.SKU.self)
                }

                Individual("exampleTaggedAsset") {
                    Type("TaggedAsset")
                    SeeAlso(ConsumerVocabulary.exampleAsset)
                }
            }
        }

        public func generatedVocabularyUseGraph() throws -> OntologyObjectGraph {
            try OntologyObjectGraph(ConsumerGeneratedVocabularyUseOntology())
        }
        """
    }

    private func buildConsumerPackage(at packageRoot: URL) throws {
        let process = Process()
        let output = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["swift", "build", "--package-path", packageRoot.path]
        process.standardOutput = output
        process.standardError = output

        try process.run()
        process.waitUntilExit()

        let outputData = output.fileHandleForReading.readDataToEndOfFile()
        let outputText = String(decoding: outputData, as: UTF8.self)

        if process.terminationStatus != 0 {
            throw ConsumerPackageBuildFailure(output: outputText)
        }
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func write(_ text: String, to url: URL) throws {
        try text.write(to: url, atomically: true, encoding: .utf8)
    }
}

private struct ConsumerPackageBuildFailure: Error, CustomStringConvertible {
    let output: String

    var description: String {
        output
    }
}

private extension String {
    var expandedDeclarationCount: Int {
        components(separatedBy: "public struct ").count - 1
    }
}

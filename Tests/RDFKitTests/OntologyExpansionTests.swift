import Foundation
import Testing
@testable import RDFKit

@Suite struct OntologyExpansionTests {
    @Test func expansionProducesSourceForDeclaredClass() throws {
        let source = try OntologyExpansion(ontologyExpression: "GeneratedRDFOntology()")
            .source(for: GeneratedRDFOntology())

        #expect(source.contains("public struct CompoundLiteral: OntologyScopedTerm, RDFClass"))
        #expect(source.contains("public static let ontology = GeneratedRDFOntology()"))
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
        #expect(throws: OntologyExpansion.Failure.self) {
            try OntologyExpansion(maximumDepth: 0).source(for: GeneratedRDFOntology())
        }
    }

    @Test func rdfVocabularyExpansionUsesStandardDSLContent() throws {
        let source = try OntologyExpansion().source(for: RDF.self)

        #expect(source.contains("public extension RDF"))
        #expect(source.contains("public struct CompoundLiteral: RDFKit.RDFClass, RDFTerm"))
        #expect(source.contains("public static var type: TypeTerm { TypeTerm() }"))
        #expect(source.contains("public static let localName = LocalName(\"type\")"))
        #expect(source.contains("public struct PlainLiteral: RDFKit.RDFDatatype, RDFTerm, DeprecatedTerm"))
        #expect(source.contains("public static let deprecated = true"))
        #expect(source.expandedDeclarationCount == 32)
    }

    @Test func rdfsVocabularyExpansionUsesStandardDSLContent() throws {
        let source = try OntologyExpansion().source(for: RDFS())

        #expect(source.contains("public extension RDFS"))
        #expect(source.contains("public struct Resource: RDFKit.RDFClass, RDFSTerm"))
        #expect(source.contains("public struct Resource: RDFKit.RDFClass, RDFSTerm, LabeledTerm, CommentedTerm"))
        #expect(source.contains("public static let labels: [String] = [\"Resource\"]"))
        #expect(source.contains("public static let comments: [String] = [\"The class resource, everything.\"]"))
        #expect(source.contains("public static var subClassOf: SubClassOf { SubClassOf() }"))
        #expect(source.contains("public struct SubClassOf: RDFKit.RDFProperty, RDFSLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty"))
        #expect(source.contains("public static let domains: [IRI] = [IRI(\"http://www.w3.org/2000/01/rdf-schema#Class\")]"))
        #expect(source.contains("public static let ranges: [IRI] = [IRI(\"http://www.w3.org/2000/01/rdf-schema#Class\")]"))
        #expect(source.expandedDeclarationCount == 16)
    }

    @Test func owlVocabularyExpansionUsesStandardDSLContent() throws {
        let source = try OntologyExpansion().source(for: OWL.self)

        #expect(source.contains("public extension OWL"))
        #expect(source.contains("public struct Thing: RDFKit.RDFClass, OWLTerm, LabeledTerm, CommentedTerm"))
        #expect(source.contains("public static let labels: [String] = [\"Thing\"]"))
        #expect(source.contains("public static let comments: [String] = [\"The class of OWL individuals.\"]"))
        #expect(source.contains("public static var allValuesFrom: AllValuesFrom { AllValuesFrom() }"))
        #expect(source.contains("public struct AllValuesFrom: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty"))
        #expect(source.contains("public struct VersionInfo: RDFKit.RDFProperty, OWLLowerCamelTerm, RDFKit.AnnotationProperty, DomainConstrainedProperty, RangeConstrainedProperty"))
        #expect(source.contains("public struct TopObjectProperty: RDFKit.RDFProperty, OWLLowerCamelTerm, RDFKit.ObjectProperty, DomainConstrainedProperty, RangeConstrainedProperty"))
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

    private func assertGeneratedVocabularySource(
        _ source: String,
        covers entries: [VocabularyMatrixEntry]
    ) throws {
        for entry in entries {
            let typeName = try expectedSwiftTypeName(for: entry.localName)

            #expect(source.contains("public struct \(typeName):"))
            if expectedExplicitLocalName(typeName: typeName, localName: entry.localName) {
                #expect(source.contains("public static let localName = LocalName(\"\(entry.localName.rawValue)\")"))
            }
            if expectedLowerCamelName(entry.localName.rawValue) {
                #expect(source.contains("public static var \(entry.localName.rawValue): \(typeName) { \(typeName)() }"))
            }
        }

        #expect(source.expandedDeclarationCount == entries.count)
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
}

private extension String {
    var expandedDeclarationCount: Int {
        components(separatedBy: "public struct ").count - 1
    }
}

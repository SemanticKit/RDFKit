import Testing
import RDFKit

@Suite struct PublicOntologyExpansionTests {
    @Test func publicExpansionProducesOntologyTermSource() throws {
        let source = try OntologyExpansion(ontologyExpression: "PublicGeneratedOntology()")
            .sourceFile(for: PublicGeneratedOntology())

        #expect(source.contains("import RDFKit"))
        #expect(source.contains("public struct Asset: OntologyScopedTerm, RDFClass"))
        #expect(source.contains("public static var ontology: PublicGeneratedOntology { PublicGeneratedOntology() }"))
        #expect(source.contains("public static let localName = LocalName(\"Asset\")"))
        #expect(source.contains("public struct Owner: OntologyScopedTerm, RDFProperty"))
        #expect(source.contains("public static let localName = LocalName(\"owner\")"))
        #expect(source.contains("public struct AssetCode: OntologyScopedTerm, RDFDatatype"))
        #expect(source.contains("public struct SampleAsset: OntologyScopedTerm, RDFIndividual"))
        #expect(source.contains("public static let localName = LocalName(\"sampleAsset\")"))
    }

    @Test func publicExpansionProducesVocabularyTermSource() throws {
        let source = try OntologyExpansion()
            .sourceFile(for: PublicGeneratedVocabulary.self)

        #expect(source.contains("import RDFKit"))
        #expect(source.contains("public protocol PublicGeneratedVocabularyTerm"))
        #expect(source.contains("public extension PublicGeneratedVocabulary"))
        #expect(source.contains("public struct Asset: RDFKit.RDFClass, PublicGeneratedVocabularyTerm"))
        #expect(source.contains("public static var owner: Owner { Owner() }"))
        #expect(source.contains("public struct Owner: RDFKit.RDFProperty, PublicGeneratedVocabularyLowerCamelTerm"))
        #expect(source.contains("RelationshipProperty"))
        #expect(source.contains("DomainConstrainedProperty"))
        #expect(source.contains("RangeConstrainedProperty"))
        #expect(source.contains("public struct AssetCode: RDFKit.RDFDatatype, PublicGeneratedVocabularyTerm"))
        #expect(source.contains("public static var sampleAsset: SampleAsset { SampleAsset() }"))
        #expect(source.contains("public struct SampleAsset: RDFKit.RDFIndividual, PublicGeneratedVocabularyLowerCamelTerm"))
    }

    private struct PublicGeneratedOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/public-generated#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)

            Class("Asset") {
                Type(RDFS.Class.self)
                Label("Asset")
            }

            Property("owner") {
                Type(RDF.Property.self)
                Domain("Asset")
                Range(RDFS.Resource.self)
            }

            Datatype("AssetCode") {
                Type(RDFS.Datatype.self)
            }

            Individual("sampleAsset") {
                Type("Asset")
            }
        }
    }

    private struct PublicGeneratedVocabulary: Vocabulary {
        static var ontology: some Content {
            Namespace("https://example.com/public-generated-vocabulary#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)

            Class("Asset") {
                Type(RDFS.Class.self)
                Label("Asset")
            }

            Property("owner") {
                Type(RDF.Property.self)
                Domain("Asset")
                Range(RDFS.Resource.self)
            }

            Datatype("AssetCode") {
                Type(RDFS.Datatype.self)
            }

            Individual("sampleAsset") {
                Type("Asset")
            }
        }
    }
}
